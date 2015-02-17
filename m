Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BAAE56B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 08:22:49 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so43660099pdb.9
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 05:22:49 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id fj3si7500282pbc.45.2015.02.17.05.22.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Feb 2015 05:22:48 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141230112158.GA15546@dhcp22.suse.cz>
	<201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
	<201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
	<20150210151934.GA11212@phnom.home.cmpxchg.org>
	<201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
In-Reply-To: <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
Message-Id: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
Date: Tue, 17 Feb 2015 21:23:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@suse.cz, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

Tetsuo Handa wrote:
> Johannes Weiner wrote:
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 8e20f9c2fa5a..f77c58ebbcfa 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2382,8 +2382,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  		if (high_zoneidx < ZONE_NORMAL)
> >  			goto out;
> >  		/* The OOM killer does not compensate for light reclaim */
> > -		if (!(gfp_mask & __GFP_FS))
> > +		if (!(gfp_mask & __GFP_FS)) {
> > +			/*
> > +			 * XXX: Page reclaim didn't yield anything,
> > +			 * and the OOM killer can't be invoked, but
> > +			 * keep looping as per should_alloc_retry().
> > +			 */
> > +			*did_some_progress = 1;
> >  			goto out;
> > +		}
> 
> Why do you omit out_of_memory() call for GFP_NOIO / GFP_NOFS allocations?

I can see "possible memory allocation deadlock in %s (mode:0x%x)" warnings
at kmem_alloc() in fs/xfs/kmem.c . I think commit 9879de7373fcfb46 "mm:
page_alloc: embed OOM killing naturally into allocation slowpath" introduced
a regression and below one is the fix.

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2381,9 +2381,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
                /* The OOM killer does not needlessly kill tasks for lowmem */
                if (high_zoneidx < ZONE_NORMAL)
                        goto out;
-               /* The OOM killer does not compensate for light reclaim */
-               if (!(gfp_mask & __GFP_FS))
-                       goto out;
                /*
                 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
                 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.

BTW, I think commit c32b3cbe0d067a9c "oom, PM: make OOM detection in the freezer
path raceless" opened a race window for __alloc_pages_may_oom(__GFP_NOFAIL)
allocation to fail when OOM killer is disabled. I think something like

--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -789,7 +789,7 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	bool ret = false;
 
 	down_read(&oom_sem);
-	if (!oom_killer_disabled) {
+	if (!oom_killer_disabled || (gfp_mask & __GFP_NOFAIL)) {
 		__out_of_memory(zonelist, gfp_mask, order, nodemask, force_kill);
 		ret = true;
 	}

is needed. But such change can race with up_write() and wait_event() in
oom_killer_disable(). While the comment of oom_killer_disable() says
"The function cannot be called when there are runnable user tasks because
the userspace would see unexpected allocation failures as a result.",
aren't there still kernel threads which might do __GFP_NOFAIL allocations?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
