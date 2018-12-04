Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5ADAA6B713E
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 18:21:42 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s22so9938885pgv.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 15:21:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w10si15033595pgj.214.2018.12.04.15.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 15:21:41 -0800 (PST)
Date: Tue, 4 Dec 2018 15:21:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm/mmu_notifier: contextual information for event
 triggering invalidation
Message-Id: <20181204152137.5e6791987739fd64ce7ea421@linux-foundation.org>
In-Reply-To: <20181203201817.10759-4-jglisse@redhat.com>
References: <20181203201817.10759-1-jglisse@redhat.com>
	<20181203201817.10759-4-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org, dri-devel@lists.freedesktop.org

On Mon,  3 Dec 2018 15:18:17 -0500 jglisse@redhat.com wrote:

> CPU page table update can happens for many reasons, not only as a result
> of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> as a result of kernel activities (memory compression, reclaim, migration,
> ...).
> 
> Users of mmu notifier API track changes to the CPU page table and take
> specific action for them. While current API only provide range of virtual
> address affected by the change, not why the changes is happening.
> 
> This patchset adds event information so that users of mmu notifier can
> differentiate among broad category:
>     - UNMAP: munmap() or mremap()
>     - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
>     - PROTECTION_VMA: change in access protections for the range
>     - PROTECTION_PAGE: change in access protections for page in the range
>     - SOFT_DIRTY: soft dirtyness tracking
> 
> Being able to identify munmap() and mremap() from other reasons why the
> page table is cleared is important to allow user of mmu notifier to
> update their own internal tracking structure accordingly (on munmap or
> mremap it is not longer needed to track range of virtual address as it
> becomes invalid).
> 
> ...
>
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -519,6 +519,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
>  			struct mmu_notifier_range range;
>  			struct mmu_gather tlb;
>  
> +			range.event = MMU_NOTIFY_CLEAR;
>  			range.start = vma->vm_start;
>  			range.end = vma->vm_end;
>  			range.mm = mm;

mmu_notifier_range and MMU_NOTIFY_CLEAR aren't defined if
CONFIG_MMU_NOTIFIER=n.

I'll try a temporary bodge:

+++ a/include/linux/mmu_notifier.h
@@ -10,8 +10,6 @@
 struct mmu_notifier;
 struct mmu_notifier_ops;
 
-#ifdef CONFIG_MMU_NOTIFIER
-
 /*
  * The mmu notifier_mm structure is allocated and installed in
  * mm->mmu_notifier_mm inside the mm_take_all_locks() protected
@@ -32,6 +30,8 @@ struct mmu_notifier_range {
 	bool blockable;
 };
 
+#ifdef CONFIG_MMU_NOTIFIER
+
 struct mmu_notifier_ops {
 	/*
 	 * Called either by mmu_notifier_unregister or when the mm is


But this new code should vanish altogether if CONFIG_MMU_NOTIFIER=n,
please.  Or at least, we shouldn't be unnecessarily initializing .mm
and .event.  Please take a look at debloating this code.
