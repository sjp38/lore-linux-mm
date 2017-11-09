Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70E0D440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 11:03:05 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id z52so3450018wrc.5
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 08:03:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x24si307464edd.77.2017.11.09.08.03.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 08:03:03 -0800 (PST)
Date: Thu, 9 Nov 2017 17:03:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Avoid KERN_CONT uses in warn_alloc
Message-ID: <20171109160300.yjyjpzc4z7ctj4lt@dhcp22.suse.cz>
References: <b31236dfe3fc924054fd7842bde678e71d193638.1509991345.git.joe@perches.com>
 <20171107125055.cl5pyp2zwon44x5l@dhcp22.suse.cz>
 <1510068865.1000.19.camel@perches.com>
 <20171107154351.ebtitvjyo5v3bt26@dhcp22.suse.cz>
 <1510070607.1000.23.camel@perches.com>
 <20171109100531.3cn2hcqnuj7mjaju@dhcp22.suse.cz>
 <1510242547.15768.62.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510242547.15768.62.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

[I've just noticed that Andrew was not on the CC, also add Tejun who has
 added nodemask_pr_args - the patch is http://lkml.kernel.org/r/20171109100531.3cn2hcqnuj7mjaju@dhcp22.suse.cz
 The only downside I can think of is that nodemask_pr_args cannot get
 any argument with sideeffects now. But that doesn't seem to be the case
 in the current code and the simplicit of the code using it is quite
 attractive to me]

On Thu 09-11-17 07:49:07, Joe Perches wrote:
> On Thu, 2017-11-09 at 11:05 +0100, Michal Hocko wrote:
> > On Tue 07-11-17 08:03:27, Joe Perches wrote:
> > > On Tue, 2017-11-07 at 16:43 +0100, Michal Hocko wrote:
> > > > On Tue 07-11-17 07:34:25, Joe Perches wrote:
> > > 
> > > []
> > > > > I believe, but have not tested, that using a specific width
> > > > > as an argument to %*pb[l] will constrain the number of
> > > > > spaces before the '(null)' output in any NULL pointer use.
> > > > > 
> > > > > So how about a #define like
> > > > > 
> > > > > /*
> > > > >  * nodemask_pr_args is only used with a "%*pb[l]" format for a nodemask.
> > > > >  * A NULL nodemask uses 6 to emit "(null)" without leading spaces.
> > > > >  */
> > > > > #define nodemask_pr_args(maskp)			\
> > > > > 	(maskp) ? MAX_NUMNODES : 6,		\
> > > > > 	(maskp) ? (maskp)->bits : NULL
> > > > 
> > > > Why not -1 then?
> > > 
> > > I believe it's the field width and not the precision that
> > > needs to be set.
> > 
> > But the first of the two arguments is the field with specifier, not the
> > precision. /me confused...
> > 
> > Anyway, the following works as expected when printing the OOM report:
> > [   47.005321] mem_eater invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
> > [   47.007183] mem_eater cpuset=/ mems_allowed=0-1
> > [   47.007829] CPU: 3 PID: 3223 Comm: mem_eater Tainted: G        W       4.13.0-pr1-dirty #11
> > 
> > I hope I haven't overlooked anything
> 
> Hey Michal.
> 
> Seems right.  The bit I overlooked was that the
> field width is overridden if the output is longer
> so 0 works perfectly well.
> 
> Thanks.
> 
> If it's useful,
> 
> Acked-by: Joe Perches <joe@perches.com>
> 
> cheers, Joe
> > ---
> > From 35aa7742d35d29af88c66dd5e6f8f5d62215f5fd Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Thu, 9 Nov 2017 10:58:41 +0100
> > Subject: [PATCH] mm: simplify nodemask printing
> > 
> > alloc_warn and dump_header have to explicitly handle NULL nodemask which
> > forces both paths to use pr_cont. We can do better. printk already
> > handles NULL pointers properly so all what we need is to teach
> > nodemask_pr_args to handle NULL nodemask carefully. This allows
> > simplification of both alloc_warn and dump_header and get rid of pr_cont
> > altogether.
> > 
> > This patch has been motivated by patch from Joe Perches
> > http://lkml.kernel.org/r/b31236dfe3fc924054fd7842bde678e71d193638.1509991345.git.joe@perches.com
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  include/linux/nodemask.h |  2 +-
> >  mm/oom_kill.c            | 12 ++++--------
> >  mm/page_alloc.c          | 12 +++---------
> >  3 files changed, 8 insertions(+), 18 deletions(-)
> > 
> > diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> > index cf0b91c3ec12..5d3cc67207ed 100644
> > --- a/include/linux/nodemask.h
> > +++ b/include/linux/nodemask.h
> > @@ -103,7 +103,7 @@ extern nodemask_t _unused_nodemask_arg_;
> >   *
> >   * Can be used to provide arguments for '%*pb[l]' when printing a nodemask.
> >   */
> > -#define nodemask_pr_args(maskp)		MAX_NUMNODES, (maskp)->bits
> > +#define nodemask_pr_args(maskp)	(maskp) ? MAX_NUMNODES : 0, (maskp) ? (maskp)->bits : NULL
> >  
> >  /*
> >   * The inline keyword gives the compiler room to decide to inline, or
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 8dd0e088189b..606213a81ceb 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -426,14 +426,10 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
> >  
> >  static void dump_header(struct oom_control *oc, struct task_struct *p)
> >  {
> > -	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=",
> > -		current->comm, oc->gfp_mask, &oc->gfp_mask);
> > -	if (oc->nodemask)
> > -		pr_cont("%*pbl", nodemask_pr_args(oc->nodemask));
> > -	else
> > -		pr_cont("(null)");
> > -	pr_cont(",  order=%d, oom_score_adj=%hd\n",
> > -		oc->order, current->signal->oom_score_adj);
> > +	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n",
> > +		current->comm, oc->gfp_mask, &oc->gfp_mask,
> > +		nodemask_pr_args(oc->nodemask), oc->order,
> > +			current->signal->oom_score_adj);
> >  	if (!IS_ENABLED(CONFIG_COMPACTION) && oc->order)
> >  		pr_warn("COMPACTION is disabled!!!\n");
> >  
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index d755434aee94..457e43ed4c10 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3281,20 +3281,14 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
> >  	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
> >  		return;
> >  
> > -	pr_warn("%s: ", current->comm);
> > -
> >  	va_start(args, fmt);
> >  	vaf.fmt = fmt;
> >  	vaf.va = &args;
> > -	pr_cont("%pV", &vaf);
> > +	pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=%*pbl\n",
> > +			current->comm, &vaf, gfp_mask, &gfp_mask,
> > +			nodemask_pr_args(nodemask));
> >  	va_end(args);
> >  
> > -	pr_cont(", mode:%#x(%pGg), nodemask=", gfp_mask, &gfp_mask);
> > -	if (nodemask)
> > -		pr_cont("%*pbl\n", nodemask_pr_args(nodemask));
> > -	else
> > -		pr_cont("(null)\n");
> > -
> >  	cpuset_print_current_mems_allowed();
> >  
> >  	dump_stack();
> > -- 
> > 2.14.2
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
