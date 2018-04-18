Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7FA86B000C
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 22:39:31 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x32-v6so184062pld.16
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 19:39:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j6-v6sor70460plk.49.2018.04.17.19.39.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 19:39:30 -0700 (PDT)
Date: Tue, 17 Apr 2018 19:39:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: fix concurrent munlock and oom reaper unmap
In-Reply-To: <201804180057.w3I0vieV034949@www262.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1804171545460.53786@chino.kir.corp.google.com> <201804180057.w3I0vieV034949@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 18 Apr 2018, Tetsuo Handa wrote:

> > Since exit_mmap() is done without the protection of mm->mmap_sem, it is
> > possible for the oom reaper to concurrently operate on an mm until
> > MMF_OOM_SKIP is set.
> > 
> > This allows munlock_vma_pages_all() to concurrently run while the oom
> > reaper is operating on a vma.  Since munlock_vma_pages_range() depends on
> > clearing VM_LOCKED from vm_flags before actually doing the munlock to
> > determine if any other vmas are locking the same memory, the check for
> > VM_LOCKED in the oom reaper is racy.
> > 
> > This is especially noticeable on architectures such as powerpc where
> > clearing a huge pmd requires kick_all_cpus_sync().  If the pmd is zapped
> > by the oom reaper during follow_page_mask() after the check for pmd_none()
> > is bypassed, this ends up deferencing a NULL ptl.
> 
> I don't know whether the explanation above is correct.
> Did you actually see a crash caused by this race?
> 

Yes, it's trivially reproducible on power by simply mlocking a ton of 
memory and triggering oom kill.

> > Fix this by reusing MMF_UNSTABLE to specify that an mm should not be
> > reaped.  This prevents the concurrent munlock_vma_pages_range() and
> > unmap_page_range().  The oom reaper will simply not operate on an mm that
> > has the bit set and leave the unmapping to exit_mmap().
> 
> But this patch is setting MMF_OOM_SKIP without reaping any memory as soon as
> MMF_UNSTABLE is set, which is the situation described in 212925802454:
> 

Oh, you're referring to __oom_reap_task_mm() returning true because of 
MMF_UNSTABLE and then setting MMF_OOM_SKIP itself?  Yes, that is dumb.  We 
could change __oom_reap_task_mm() to only set MMF_OOM_SKIP if MMF_UNSTABLE 
hasn't been set.  I'll send a v2, which I needed to do anyway to do 
s/kick_all_cpus_sync/serialize_against_pte_lookup/ in the changelog (power 
only does it for the needed cpus).
