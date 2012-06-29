Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A90B66B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 16:37:20 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5950921dak.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 13:37:19 -0700 (PDT)
Date: Fri, 29 Jun 2012 13:37:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc][patch 3/3] mm, memcg: introduce own oom handler to iterate
 only over its own threads
In-Reply-To: <20120628171618.GA27089@redhat.com>
Message-ID: <alpine.DEB.2.00.1206291333080.6040@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206251847180.24838@chino.kir.corp.google.com> <4FE94968.6010500@jp.fujitsu.com> <alpine.DEB.2.00.1206261323260.8673@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206262229380.32567@chino.kir.corp.google.com> <alpine.DEB.2.00.1206271837460.14446@chino.kir.corp.google.com> <20120628171618.GA27089@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu, 28 Jun 2012, Oleg Nesterov wrote:

> > @@ -348,6 +348,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> >  	struct task_struct *chosen = NULL;
> >  	unsigned long chosen_points = 0;
> >
> > +	rcu_read_lock();
> >  	do_each_thread(g, p) {
> >  		unsigned int points;
> >
> > @@ -370,6 +371,9 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> >  			chosen_points = points;
> >  		}
> >  	} while_each_thread(g, p);
> > +	if (chosen)
> > +		get_task_struct(chosen);
> 
> OK, so the caller should do put_task_struct().
> 

oom_kill_process() will now do the put_task_struct() since we need a 
reference before killing it, so callers to oom_kill_process() are 
responsible for grabbing it before doing rcu_read_unlock().

> But, unless I misread the patch,
> 
> > @@ -454,6 +458,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> > ...
> > +	rcu_read_lock();
> > +	p = find_lock_task_mm(victim);
> > +	if (!p) {
> > +		rcu_read_unlock();
> > +		put_task_struct(victim);

So if the victim has no threads that have an mm, then we have raced with 
select_bad_process() and we silently return.

> >  		return;
> > +	} else
> > +		victim = p;
> 
> And, before return,
> 
> > +	put_task_struct(victim);
> 
> Doesn't look right if victim != p.
> 

Ah, good catch, we need to do

	if (!p) {
		rcu_read_unlock();
		put_task_struct(victim);
		return;
	} else {
		put_task_struct(victim);
		victim = p;
		get_task_struct(victim);
		rcu_read_unlock();
	}

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
