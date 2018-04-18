Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A18326B000C
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 21:36:52 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x5-v6so89910pln.21
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 18:36:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id ba2-v6si140902plb.110.2018.04.17.18.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 18:36:51 -0700 (PDT)
Message-Id: <201804180057.w3I0vieV034949@www262.sakura.ne.jp>
Subject: Re: [patch] mm, oom: fix concurrent munlock and oom reaper unmap
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 18 Apr 2018 09:57:44 +0900
References: <alpine.DEB.2.21.1804171545460.53786@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1804171545460.53786@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

David Rientjes wrote:
> Since exit_mmap() is done without the protection of mm->mmap_sem, it is
> possible for the oom reaper to concurrently operate on an mm until
> MMF_OOM_SKIP is set.
> 
> This allows munlock_vma_pages_all() to concurrently run while the oom
> reaper is operating on a vma.  Since munlock_vma_pages_range() depends on
> clearing VM_LOCKED from vm_flags before actually doing the munlock to
> determine if any other vmas are locking the same memory, the check for
> VM_LOCKED in the oom reaper is racy.
> 
> This is especially noticeable on architectures such as powerpc where
> clearing a huge pmd requires kick_all_cpus_sync().  If the pmd is zapped
> by the oom reaper during follow_page_mask() after the check for pmd_none()
> is bypassed, this ends up deferencing a NULL ptl.

I don't know whether the explanation above is correct.
Did you actually see a crash caused by this race?

> 
> Fix this by reusing MMF_UNSTABLE to specify that an mm should not be
> reaped.  This prevents the concurrent munlock_vma_pages_range() and
> unmap_page_range().  The oom reaper will simply not operate on an mm that
> has the bit set and leave the unmapping to exit_mmap().

But this patch is setting MMF_OOM_SKIP without reaping any memory as soon as
MMF_UNSTABLE is set, which is the situation described in 212925802454:

    At the same time if the OOM reaper doesn't wait at all for the memory of
    the current OOM candidate to be freed by exit_mmap->unmap_vmas, it would
    generate a spurious OOM kill.

If exit_mmap() does not wait for any pages and __oom_reap_task_mm() can not
handle mlock()ed pages, isn't it better to revert 212925802454 like I mentioned
at https://patchwork.kernel.org/patch/10095661/ and let the OOM reaper reclaim
as much as possible before setting MMF_OOM_SKIP?
