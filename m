Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE5C8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 07:00:06 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id w196-v6so2771839itb.4
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 04:00:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g196-v6si706498itc.105.2018.09.12.04.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 04:00:04 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
References: <201809120306.w8C36JbS080965@www262.sakura.ne.jp>
 <20180912071842.GY10951@dhcp22.suse.cz>
 <201809120758.w8C7wrCN068547@www262.sakura.ne.jp>
 <20180912081733.GA10951@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <dea26bf6-97f9-a443-4563-1d13bc6e2133@i-love.sakura.ne.jp>
Date: Wed, 12 Sep 2018 19:59:24 +0900
MIME-Version: 1.0
In-Reply-To: <20180912081733.GA10951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On 2018/09/12 17:17, Michal Hocko wrote:
> On Wed 12-09-18 16:58:53, Tetsuo Handa wrote:
>> Michal Hocko wrote:
>>> OK, I will fold the following to the patch
>>
>> OK. But at that point, my patch which tries to wait for reclaimed memory
>> to be re-allocatable addresses a different problem which you are refusing.
> 
> I am trying to address a real world example of when the excessive amount
> of memory is in page tables. As David pointed, this can happen with some
> userspace allocators.

My patch or David's patch will address it as well, without scattering
down_write(&mm->mmap_sem)/up_write(&mm->mmap_sem) like your attempt.

> 
>> By the way, is it guaranteed that vma->vm_ops->close(vma) in remove_vma() never
>> sleeps? Since remove_vma() has might_sleep() since 2005, and that might_sleep()
>> predates the git history, I don't know what that ->close() would do.
> 
> Hmm, I am afraid we cannot assume anything so we have to consider it
> unsafe. A cursory look at some callers shows that they are taking locks.
> E.g. drm_gem_object_put_unlocked might take a mutex. So MMF_OOM_SKIP
> would have to set right after releasing page tables.

I won't be happy unless handed over section can run in atomic context
(e.g. preempt_disable()/preempt_enable()) because current thread might be
SCHED_IDLE priority.

If current thread is SCHED_IDLE priority, it might be difficult to hand over
because current thread is unlikely able to reach

+	if (oom) {
+		/*
+		 * the exit path is guaranteed to finish without any unbound
+		 * blocking at this stage so make it clear to the caller.
+		 */
+		mm->mmap = NULL;
+		up_write(&mm->mmap_sem);
+	}

before the OOM reaper kernel thread (which is not SCHED_IDLE priority) checks
whether mm->mmap is already NULL.

Honestly, I'm not sure whether current thread (even !SCHED_IDLE priority) can
reach there before the OOM killer checks whether mm->mmap is already NULL, for
current thread has to do more things than the OOM reaper can do.

Also, in the worst case,

+                               /*
+                                * oom_reaper cannot handle mlocked vmas but we
+                                * need to serialize it with munlock_vma_pages_all
+                                * which clears VM_LOCKED, otherwise the oom reaper
+                                * cannot reliably test it.
+                                */
+                               if (oom)
+                                       down_write(&mm->mmap_sem);

would cause the OOM reaper to set MMF_OOM_SKIP without reclaiming any memory
if munlock_vma_pages_all(vma) by current thread did not complete quick enough
to make down_read_trylock(&mm->mmap_sem) attempt by the OOM reaper succeed.
