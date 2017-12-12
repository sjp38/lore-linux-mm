Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED2C6B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 04:04:40 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id l14so15297379pgu.17
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 01:04:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b10si11165302pgq.193.2017.12.12.01.04.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 01:04:38 -0800 (PST)
Subject: Re: [PATCH] mm,oom: use ALLOC_OOM for OOM victim's last second allocation
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171207115127.GH20234@dhcp22.suse.cz>
	<201712072059.HAJ04643.QSJtVMFLFOOOHF@I-love.SAKURA.ne.jp>
	<20171207122249.GI20234@dhcp22.suse.cz>
	<201712081958.EBB43715.FOVJQFtFLOMOSH@I-love.SAKURA.ne.jp>
	<20171211114229.GA4779@dhcp22.suse.cz>
In-Reply-To: <20171211114229.GA4779@dhcp22.suse.cz>
Message-Id: <201712121709.CCD95874.OHLOFQFFMVJOtS@I-love.SAKURA.ne.jp>
Date: Tue, 12 Dec 2017 17:09:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com

Michal Hocko wrote:
> That being said, I will keep refusing other such tweaks unless you have
> a sound usecase behind. If you really _want_ to help out here then you
> can focus on the reaping of the mlock memory.

Not the reaping of the mlock'ed memory. Although Manish's report was mlock'ed
case, there are other cases (e.g. MAP_SHARED, mmu_notifier, mmap_sem held for
write) which can lead to this race condition. If we think about artificial case,
it would be possible to run 1024 threads not sharing signal_struct but consume
almost 0KB memory (i.e. written without using C library) and many of them are
running between __gfp_pfmemalloc_flags() and mutex_trylock() waiting for
ALLOC_OOM.

What the Manish's report revealed is the fact that we accidentally broke the

	/*
	 * Kill all user processes sharing victim->mm in other thread groups, if
	 * any.  They don't get access to memory reserves, though, to avoid
	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
	 * oom killed thread cannot exit because it requires the semaphore and
	 * its contended by another thread trying to allocate memory itself.
	 * That thread will now get access to memory reserves since it has a
	 * pending fatal signal.
	 */

assumption via 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
oom_reaped tasks"), and we already wasted for 16 months. There is no need to
wait for fixing mlock'ed, MAP_SHARED, mmu_notifier and mmap_sem cases because
"OOM victims consuming almost 0KB memory" case cannot be solved.

The mlock'ed, MAP_SHARED, mmu_notifier and mmap_sem cases are a sort of alias
of "OOM victims consuming almost 0KB memory" case.

Anyway, since you introduced MMF_OOM_VICTIM flag, I will try a patch which
checks MMF_OOM_VICTIM instead of oom_reserves_allowed().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
