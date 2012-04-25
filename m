Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 3AC0C6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 16:59:31 -0400 (EDT)
Received: by iajr24 with SMTP id r24so841335iaj.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 13:59:30 -0700 (PDT)
Date: Wed, 25 Apr 2012 13:59:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: avoid checking set of allowed nodes twice when
 selecting a victim
In-Reply-To: <20120425080611.GA11068@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1204251346160.29822@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1204031633460.8112@chino.kir.corp.google.com> <20120412140137.GA32729@tiehlicka.suse.cz> <alpine.DEB.2.00.1204241605570.17792@chino.kir.corp.google.com> <20120425080611.GA11068@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, 25 Apr 2012, Michal Hocko wrote:

> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 46bf2ed5..a9df008 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -171,23 +171,10 @@ static bool oom_unkillable_task(struct task_struct *p,
> > >  	return false;
> > >  }
> > >  
> > > -/**
> > > - * oom_badness - heuristic function to determine which candidate task to kill
> > > - * @p: task struct of which task we should calculate
> > > - * @totalpages: total present RAM allowed for page allocation
> > > - *
> > > - * The heuristic for determining which task to kill is made to be as simple and
> > > - * predictable as possible.  The goal is to return the highest value for the
> > > - * task consuming the most memory to avoid subsequent oom failures.
> > > - */
> > > -unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> > > +/* can be used only for tasks which are killable as per oom_unkillable_task */
> > > +static unsigned int __oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> > >  		      const nodemask_t *nodemask, unsigned long totalpages)
> > >  {
> > > -	long points;
> > > -
> > > -	if (oom_unkillable_task(p, memcg, nodemask))
> > > -		return 0;
> > > -
> > >  	p = find_lock_task_mm(p);
> > >  	if (!p)
> > >  		return 0;
> > > @@ -239,6 +226,26 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> > >  	return (points < 1000) ? points : 1000;
> > >  }
> > >  
> > > +/**
> > > + * oom_badness - heuristic function to determine which candidate task to kill
> > > + * @p: task struct of which task we should calculate
> > > + * @totalpages: total present RAM allowed for page allocation
> > > + *
> > > + * The heuristic for determining which task to kill is made to be as simple and
> > > + * predictable as possible.  The goal is to return the highest value for the
> > > + * task consuming the most memory to avoid subsequent oom failures.
> > > + */
> > > +unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> > > +		      const nodemask_t *nodemask, unsigned long totalpages)
> > > +{
> > > +	long points;
> > > +
> > > +	if (oom_unkillable_task(p, memcg, nodemask))
> > > +		return 0;
> > > +
> > > +	return __oom_badness(p, memcg, nodemask, totalpages);
> > > +}
> > > +
> > >  /*
> > >   * Determine the type of allocation constraint.
> > >   */
> > > @@ -366,7 +373,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > >  			}
> > >  		}
> > >  
> > > -		points = oom_badness(p, memcg, nodemask, totalpages);
> > > +		points = __oom_badness(p, memcg, nodemask, totalpages);
> > >  		if (points > *ppoints) {
> > >  			chosen = p;
> > >  			*ppoints = points;
> > 
> > No, the way I had it written is correct: the above unnecessarily checks 
> > for membership in a memcg or intersection with a set of allowable nodes 
> > for child threads in oom_kill_process().  
> 
> your patch does 
> 	if (oom_unkillable_task(child, memcg, nodemask))
> 		continue;
> 	oom_badness((child, memcg, nodemask,
> 				   totalpages);
> 
> in oom_kill_process so the check is very same. Or am I missing
> something?
> 

Here you go again.

Why would you ever do something like this?

/proc/pid/oom_score certainly doesn't care about cpusets or memcg and 
exports only oom scores in a global context, anything else would be 
inconsistent.  It only cares about whether the thread is init or another 
kthread because they are ineligible.  So let's leave /proc/pid/oom_score 
out of this.

That's the function of oom_badness(): to assign a point value for a 
specific process to determine the highest priority for oom kill.  It 
shouldn't care about the context of the oom kill; and that's why 
/proc/pid/oom_score, which is always global, doesn't care.

Now tell me what's clearer in terms of the code: calling 
oom_unkillable_task() to determine the context of the oom kill explicitly 
where it matters or calling either oom_badness() or __oom_badness() and 
remembering what the heck the difference between the two is.

You're patch also wouldn't compile because you've removed the declaration 
of "points" from __oom_badness(), which actually uses it, to 
oom_badness(), which doesn't use it, for no apparent reason.

If this sounds frustrated, then it certainly is.  This patch has stalled 
out three weeks from being in -mm because of your broken patch suggestion.  
My patch fixes an issue that people with very large systems and a high 
CONFIG_NODES_SHIFT will encounter and possibly cause timeouts and we run 
with it internally as part of a fix for a faster oom killer because this 
problem actually manifests itself in real-world situations.

And here you are, just like when you wanted to rework a patch of mine and 
rewrite the changelog so Andrew mistakenly sent it to Linus as a fix for a 
patch that wasn't even in his tree, suggesting broken (and admittedly 
untested) patches as some kind of cleanup that actually just makes the 
code harder to understand if you're reading it.

This patch fixes a real-world issue that has been tested on thousands of 
machines.  Please keep your little untested follow-up changes that you 
think make it look better to yourself so that this patch can get merged 
and help people out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
