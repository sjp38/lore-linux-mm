Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 61FD8900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:38:34 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p4CJcWZA008143
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:38:32 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by hpaq2.eem.corp.google.com with ESMTP id p4CJc6wO020851
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:38:30 -0700
Received: by pwi9 with SMTP id 9so889732pwi.10
        for <linux-mm@kvack.org>; Thu, 12 May 2011 12:38:30 -0700 (PDT)
Date: Thu, 12 May 2011 12:38:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: OOM Killer don't works at all if the system have >gigabytes
 memory (was Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable())
In-Reply-To: <BANLkTi=fNtPZQk5Mp7rbZJFpA1tzBh+VcA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1105121229150.2407@chino.kir.corp.google.com>
References: <1889981320.330808.1305081044822.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com> <alpine.DEB.2.00.1105111331480.9346@chino.kir.corp.google.com> <BANLkTi=fNtPZQk5Mp7rbZJFpA1tzBh+VcA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531368966-109542298-1305229109=:2407"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: CAI Qian <caiqian@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531368966-109542298-1305229109=:2407
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Thu, 12 May 2011, Minchan Kim wrote:

> > processes a 1% bonus for every 30% of memory they use as proposed
> > earlier.)
> 
> I didn't follow earlier your suggestion.
> But it's not formal patch so I expect if you send formal patch to
> merge, you would write down the rationale.
> 

Yes, I'm sure we'll still have additional discussion when KOSAKI-san 
replies to my review of his patchset, so this quick patch was written only 
for CAI's testing at this point.

In reference to the above, I think that giving root processes a 3% bonus 
at all times may be a bit aggressive.  As mentioned before, I don't think 
that all root processes using 4% of memory and the remainder of system 
threads are using 1% should all be considered equal.  At the same time, I 
do not believe that two threads using 50% of memory should be considered 
equal if one is root and one is not.  So my idea was to discount 1% for 
every 30% of memory that a root process uses rather than a strict 3%.

That change can be debated and I think we'll probably settle on something 
more aggressive like 1% for every 10% of memory used since oom scores are 
only useful in comparison to other oom scores: in the above scenario where 
there are two threads, one by root and one not by root, using 50% of 
memory each, I think it would be legitimate to give the root task a 5% 
bonus so that it would only be selected if no other threads used more than 
44% of memory (even though the root thread is truly using 50%).

This is a heuristic within the oom killer badness scoring that can always 
be debated back and forth, but I think a 1% bonus for root processes for 
every 10% of memory used is plausible.

Comments?

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -160,7 +160,7 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
> > A  A  A  A  */
> > A  A  A  A if (p->flags & PF_OOM_ORIGIN) {
> > A  A  A  A  A  A  A  A task_unlock(p);
> > - A  A  A  A  A  A  A  return 1000;
> > + A  A  A  A  A  A  A  return 10000;
> > A  A  A  A }
> >
> > A  A  A  A /*
> > @@ -177,32 +177,32 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
> > A  A  A  A points = get_mm_rss(p->mm) + p->mm->nr_ptes;
> > A  A  A  A points += get_mm_counter(p->mm, MM_SWAPENTS);
> >
> > - A  A  A  points *= 1000;
> > + A  A  A  points *= 10000;
> > A  A  A  A points /= totalpages;
> > A  A  A  A task_unlock(p);
> >
> > A  A  A  A /*
> > - A  A  A  A * Root processes get 3% bonus, just like the __vm_enough_memory()
> > - A  A  A  A * implementation used by LSMs.
> > + A  A  A  A * Root processes get 1% bonus per 30% memory used for a total of 3%
> > + A  A  A  A * possible just like LSMs.
> > A  A  A  A  */
> > A  A  A  A if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> > - A  A  A  A  A  A  A  points -= 30;
> > + A  A  A  A  A  A  A  points -= 100 * (points / 3000);
> >
> > A  A  A  A /*
> > A  A  A  A  * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
> > A  A  A  A  * either completely disable oom killing or always prefer a certain
> > A  A  A  A  * task.
> > A  A  A  A  */
> > - A  A  A  points += p->signal->oom_score_adj;
> > + A  A  A  points += p->signal->oom_score_adj * 10;
> >
> > A  A  A  A /*
> > A  A  A  A  * Never return 0 for an eligible task that may be killed since it's
> > - A  A  A  A * possible that no single user task uses more than 0.1% of memory and
> > + A  A  A  A * possible that no single user task uses more than 0.01% of memory and
> > A  A  A  A  * no single admin tasks uses more than 3.0%.
> > A  A  A  A  */
> > A  A  A  A if (points <= 0)
> > A  A  A  A  A  A  A  A return 1;
> > - A  A  A  return (points < 1000) ? points : 1000;
> > + A  A  A  return (points < 10000) ? points : 10000;
> > A }
> >
> > A /*
> > @@ -314,7 +314,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > A  A  A  A  A  A  A  A  A  A  A  A  */
> > A  A  A  A  A  A  A  A  A  A  A  A if (p == current) {
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A chosen = p;
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  *ppoints = 1000;
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  *ppoints = 10000;
> 
> Scattering constant value isn't good.
> You are proving it now.
> I think you did it since this is not a formal patch.
> I expect you will define new value (ex, OOM_INTERNAL_MAX_SCORE or whatever)
> 

Right, we could probably do something like

	#define OOM_SCORE_MAX_FACTOR	10
	#define OOM_SCORE_MAX		(OOM_SCORE_ADJ_MAX * OOM_SCORE_MAX_FACTOR)

in mm/oom_kill.c, which would then be used to replace all of the constants 
above since OOM_SCORE_ADJ_MAX is already defined to be 1000 in 
include/linux/oom.h.
--531368966-109542298-1305229109=:2407--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
