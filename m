Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 255A76B0261
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 06:34:37 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 200so7775104pge.12
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 03:34:37 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j123si5392468pgc.260.2017.12.08.03.34.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 03:34:35 -0800 (PST)
Subject: Re: [PATCH] mm,oom: use ALLOC_OOM for OOM victim's last second allocation
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1512646940-3388-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171207115127.GH20234@dhcp22.suse.cz>
	<201712072059.HAJ04643.QSJtVMFLFOOOHF@I-love.SAKURA.ne.jp>
	<20171207122249.GI20234@dhcp22.suse.cz>
In-Reply-To: <20171207122249.GI20234@dhcp22.suse.cz>
Message-Id: <201712081958.EBB43715.FOVJQFtFLOMOSH@I-love.SAKURA.ne.jp>
Date: Fri, 8 Dec 2017 19:58:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com

Michal Hocko wrote:
> On Thu 07-12-17 20:59:34, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Thu 07-12-17 20:42:20, Tetsuo Handa wrote:
> > > > Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
> > > > count causes random kernel panics when an OOM victim which consumed memory
> > > > in a way the OOM reaper does not help was selected by the OOM killer [1].
> > > > Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> > > > oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
> > > > to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
> > > > victim's mm were not able to try allocation from memory reserves after the
> > > > OOM reaper gave up reclaiming memory.
> > > > 
> > > > Therefore, this patch allows OOM victims to use ALLOC_OOM watermark for
> > > > last second allocation attempt.
> > > > 
> > > > [1] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com
> > > > 
> > > > Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
> > > > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
> > > > Acked-by: Michal Hocko <mhocko@suse.com>
> > > 
> > > I haven't acked _this_ patch! I will have a look but the patch is
> > > different enough from the original that keeping any acks or reviews is
> > > inappropriate. Do not do it again!
> > 
> > I see. But nothing has changed except that this is called before entering
> > into the OOM killer. I assumed that this is a trivial change.
> 
> Let the reviewers judge and have them add their acks/reviewed-bys again.

OK. Here I prepare food for review. Johannes, please be sure to respond.

When Manish reported this problem, I tried to manage this problem by
"mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for once."
but it was rejected by Michal
( http://lkml.kernel.org/r/20170821084307.GB25956@dhcp22.suse.cz ).
Michal told me

  Sigh... Let me repeat for the last time (this whole thread is largely a
  waste of time to be honest). Find a _robust_ solution rather than
  fiddling with try-once-more kind of hacks. E.g. do an allocation attempt
  _before_ we do any disruptive action (aka kill a victim). This would
  help other cases when we race with an exiting tasks or somebody managed
  to free memory while we were selecting an oom victim which can take
  quite some time.

and I wrote "mm,oom: move last second allocation to inside the OOM killer" (with
an acceptance to apply "mm,oom: use ALLOC_OOM for OOM victim's last second
allocation" on top of it) but it was rejected by Johannes.

Therefore, I'm stuck between Michal and Johannes. And I updated "mm,oom: use
ALLOC_OOM for OOM victim's last second allocation" not to depend on "mm,oom:
move last second allocation to inside the OOM killer".

The original "mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for once."
is the simplest change and easy to handle all corner cases. But if we go "mm,oom: use
ALLOC_OOM for OOM victim's last second allocation" approach, we also need to apply
"mm,oom: Set ->signal->oom_mm to all thread groups sharing the victim's mm."
( http://lkml.kernel.org/r/1511872888-4579-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp )
in order to handle corner cases, and it was rejected by Michal. Then, if we won't
handle corner cases, we need to update

	/*
	 * Kill all user processes sharing victim->mm in other thread groups, if
	 * any.  They don't get access to memory reserves, though, to avoid
	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
	 * oom killed thread cannot exit because it requires the semaphore and
	 * its contended by another thread trying to allocate memory itself.
	 * That thread will now get access to memory reserves since it has a
	 * pending fatal signal.
	 */

comment which is no longer true.

Michal and Johannes, please discuss between you and show me the direction to go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
