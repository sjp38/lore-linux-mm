Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 201D66B46CB
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:40:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id gn4so749135plb.9
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:40:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g69-v6si1348664pfa.204.2018.08.28.07.40.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 07:40:11 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: OOM victims do not need to select next OOM
 victim unless __GFP_NOFAIL.
References: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180828124030.GB12564@cmpxchg.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <58e0bd2d-71bd-cf46-0929-ef5eb0c6c2bc@i-love.sakura.ne.jp>
Date: Tue, 28 Aug 2018 22:29:56 +0900
MIME-Version: 1.0
In-Reply-To: <20180828124030.GB12564@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>

On 2018/08/28 21:40, Johannes Weiner wrote:
> On Mon, Aug 20, 2018 at 07:37:45PM +0900, Tetsuo Handa wrote:
>> Commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
>> oom_reaped tasks") changed to select next OOM victim as soon as
>> MMF_OOM_SKIP is set. But since OOM victims can try ALLOC_OOM allocation
>> and then give up (if !memcg OOM) or can use forced charge and then retry
>> (if memcg OOM), OOM victims do not need to select next OOM victim unless
>> they are doing __GFP_NOFAIL allocations.
> 
> Can you outline the exact sequence here? After a task invokes the OOM
> killer, it will retry and do ALLOC_OOM before invoking it again. If
> that succeeds, OOM is not invoked another time.

Did you mean

  After a task invoked the OOM killer, that task will retry and an OOM
  victim will do ALLOC_OOM before that task or that OOM victim again
  invokes the OOM killer.

? Then, yes. But the OOM reaper disturbs this behavior.

> 
> If there is a race condition where the allocating task gets killed
> right before it acquires the oom_lock itself, there is another attempt
> to allocate under the oom lock to catch parallel kills. It's not using
> ALLOC_OOM, but that's intentional because we want to restore the high
> watermark, not just make a single allocation from reserves succeed.

Yes. Though an OOM victim will try ALLOC_OOM watermark unless
__GFP_NOMEMALLOC due to

  /* Avoid allocations with no watermarks from looping endlessly */
  if (tsk_is_oom_victim(current) &&
      (alloc_flags == ALLOC_OOM || (gfp_mask & __GFP_NOMEMALLOC)))
          goto nopage;

test after returning from __alloc_pages_may_oom().

> 
> If that doesn't succeed, then we are committed to killing something.

No. we want to avoid unnecessary killing of additional processes. The test
above was updated by commit c288983dddf71421 ("mm/page_alloc.c: make sure
OOM victim can try allocations with no watermarks once") in order to avoid
unnecessary killing of additional processes.

Thanks to the test above, an OOM victim is expected to give up allocation
without selecting next OOM victim. But if the OOM reaper set MMF_OOM_SKIP
before that OOM victim enters into out_of_memory(),

  /*
   * If current has a pending SIGKILL or is exiting, then automatically
   * select it.  The goal is to allow it to allocate so that it may
   * quickly exit and free its memory.
   */
  if (task_will_free_mem(current)) {
      mark_oom_victim(current);
      wake_oom_reaper(current);
      return true;
  }

test does not help. In other words, an OOM victim will select next OOM
victim when we can avoid selecting next OOM victim.

> Racing with the OOM reaper then is no different than another task
> voluntarily exiting or munmap()ing in parallel. I don't know why we
> should special case your particular scenario.

Because we want to avoid unnecessary killing of additional processes.

> 
> Granted, the OOM reaper is not exactly like the others, because it can
> be considered to be part of the OOM killer itself. But then we should
> wait for it like we wait for any concurrent OOM kill, and not allow
> another __alloc_pages_may_oom() while the reaper is still at work;
> instead of more hard-to-understand special cases in this code.

The OOM reaper may set MMF_OOM_SKIP without reclaiming any memory (due
to e.g. mlock()ed memory, shared memory, unable to grab mmap_sem for read).
We haven't reached to the point where the OOM reaper reclaims all memory
nor allocating threads wait some more after setting MMF_OOM_SKIP.
Therefore, this

  if (tsk_is_oom_victim(current) && !(oc->gfp_mask & __GFP_NOFAIL))
      return true;

is the simplest mitigation we can do now.
