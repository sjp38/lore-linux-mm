Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D58816B025E
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 09:46:28 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so7718708wjb.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 06:46:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nw7si34387068wjb.268.2016.12.09.06.46.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 06:46:27 -0800 (PST)
Date: Fri, 9 Dec 2016 15:46:25 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161209144624.GB4334@dhcp22.suse.cz>
References: <1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20161207081555.GB17136@dhcp22.suse.cz>
 <201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
 <20161208132714.GA26530@dhcp22.suse.cz>
 <201612092323.BGC65668.QJFVLtFFOOMOSH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612092323.BGC65668.QJFVLtFFOOMOSH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Fri 09-12-16 23:23:10, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 08-12-16 00:29:26, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Tue 06-12-16 19:33:59, Tetsuo Handa wrote:
> > > > > If the OOM killer is invoked when many threads are looping inside the
> > > > > page allocator, it is possible that the OOM killer is preempted by other
> > > > > threads.
> > > > 
> > > > Hmm, the only way I can see this would happen is when the task which
> > > > actually manages to take the lock is not invoking the OOM killer for
> > > > whatever reason. Is this what happens in your case? Are you able to
> > > > trigger this reliably?
> > > 
> > > Regarding http://I-love.SAKURA.ne.jp/tmp/serial-20161206.txt.xz ,
> > > somebody called oom_kill_process() and reached
> > > 
> > >   pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
> > > 
> > > line but did not reach
> > > 
> > >   pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> > > 
> > > line within tolerable delay.
> > 
> > I would be really interested in that. This can happen only if
> > find_lock_task_mm fails. This would mean that either we are selecting a
> > child without mm or the selected victim has no mm anymore. Both cases
> > should be ephemeral because oom_badness will rule those tasks on the
> > next round. So the primary question here is why no other task has hit
> > out_of_memory.
> 
> This can also happen due to AB-BA livelock (oom_lock v.s. console_sem).

Care to explain how would that livelock look like?

> >                Have you tried to instrument the kernel and see whether
> > GFP_NOFS contexts simply preempted any other attempt to get there?
> > I would find it quite unlikely but not impossible. If that is the case
> > we should really think how to move forward. One way is to make the oom
> > path fully synchronous as suggested below. Other is to tweak GFP_NOFS
> > some more and do not take the lock while we are evaluating that. This
> > sounds quite messy though.
> 
> Do you mean "tweak GFP_NOFS" as something like below patch?
> 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3036,6 +3036,17 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
>  
>  	*did_some_progress = 0;
>  
> +	if (!(gfp_mask & (__GFP_FS | __GFP_NOFAIL))) {
> +		if ((current->flags & PF_DUMPCORE) ||
> +		    (order > PAGE_ALLOC_COSTLY_ORDER) ||
> +		    (ac->high_zoneidx < ZONE_NORMAL) ||
> +		    (pm_suspended_storage()) ||
> +		    (gfp_mask & __GFP_THISNODE))
> +			return NULL;
> +		*did_some_progress = 1;
> +		return NULL;
> +	}
> +
>  	/*
>  	 * Acquire the oom lock.  If that fails, somebody else is
>  	 * making progress for us.
> 
> Then, serial-20161209-gfp.txt in http://I-love.SAKURA.ne.jp/tmp/20161209.tar.xz is
> console log with above patch applied. Spinning without invoking the OOM killer.
> It did not avoid locking up.

OK, so the reason of the lock up must be something different. If we are
really {dead,live}locking on the printk because of warn_alloc then that
path should be tweaked instead. Something like below should rule this
out:
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ed65d7df72d5..c2ba51cec93d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3024,11 +3024,14 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
 	struct va_format vaf;
 	va_list args;
+	static DEFINE_MUTEX(warn_lock);
 
 	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
 	    debug_guardpage_minorder() > 0)
 		return;
 
+	mutex_lock(&warn_lock);
+
 	/*
 	 * This documents exceptions given to allocations in certain
 	 * contexts that are allowed to allocate outside current's set
@@ -3054,6 +3057,8 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	dump_stack();
 	if (!should_suppress_show_mem())
 		show_mem(filter);
+
+	mutex_unlock(&warn_lock);
 }
 
 static inline struct page *
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
