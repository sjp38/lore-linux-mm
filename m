Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E18C76B025E
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 08:27:17 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so6140662wms.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 05:27:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h194si13213055wmd.115.2016.12.08.05.27.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 05:27:16 -0800 (PST)
Date: Thu, 8 Dec 2016 14:27:15 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161208132714.GA26530@dhcp22.suse.cz>
References: <1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20161207081555.GB17136@dhcp22.suse.cz>
 <201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Thu 08-12-16 00:29:26, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 06-12-16 19:33:59, Tetsuo Handa wrote:
> > > If the OOM killer is invoked when many threads are looping inside the
> > > page allocator, it is possible that the OOM killer is preempted by other
> > > threads.
> > 
> > Hmm, the only way I can see this would happen is when the task which
> > actually manages to take the lock is not invoking the OOM killer for
> > whatever reason. Is this what happens in your case? Are you able to
> > trigger this reliably?
> 
> Regarding http://I-love.SAKURA.ne.jp/tmp/serial-20161206.txt.xz ,
> somebody called oom_kill_process() and reached
> 
>   pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
> 
> line but did not reach
> 
>   pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> 
> line within tolerable delay.

I would be really interested in that. This can happen only if
find_lock_task_mm fails. This would mean that either we are selecting a
child without mm or the selected victim has no mm anymore. Both cases
should be ephemeral because oom_badness will rule those tasks on the
next round. So the primary question here is why no other task has hit
out_of_memory. Have you tried to instrument the kernel and see whether
GFP_NOFS contexts simply preempted any other attempt to get there?
I would find it quite unlikely but not impossible. If that is the case
we should really think how to move forward. One way is to make the oom
path fully synchronous as suggested below. Other is to tweak GFP_NOFS
some more and do not take the lock while we are evaluating that. This
sounds quite messy though.

[...]

> > So, why don't you simply s@mutex_trylock@mutex_lock_killable@ then?
> > The trylock is simply an optimistic heuristic to retry while the memory
> > is being freed. Making this part sync might help for the case you are
> > seeing.
> 
> May I? Something like below? With patch below, the OOM killer can send
> SIGKILL smoothly and printk() can report smoothly (the frequency of
> "** XXX printk messages dropped **" messages is significantly reduced).

Well, this has to be properly evaluated. The fact that
__oom_reap_task_mm requires the oom_lock makes it more complicated. We
definitely do not want to starve it. On the other hand the oom
invocation path shouldn't stall for too long and even when we have
hundreds of tasks blocked on the lock and blocking the oom reaper then
the reaper should run _eventually_. It might take some time but this a
glacial slow path so it should be acceptable.

That being said, this should be OK. But please make sure to mention all
these details in the changelog. Also make sure to document the actual
failure mode as mentioned above.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2c6d5f6..ee0105b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3075,7 +3075,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
>  	 * Acquire the oom lock.  If that fails, somebody else is
>  	 * making progress for us.
>  	 */
> -	if (!mutex_trylock(&oom_lock)) {
> +	if (mutex_lock_killable(&oom_lock)) {
>  		*did_some_progress = 1;
>  		schedule_timeout_uninterruptible(1);
>  		return NULL;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
