Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4EA6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:32:16 -0400 (EDT)
Received: by payr10 with SMTP id r10so28479181pay.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:15 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id xs3si6063296pbb.215.2015.06.09.23.32.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 23:32:15 -0700 (PDT)
Received: by pabli10 with SMTP id li10so8028225pab.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:14 -0700 (PDT)
From: Wenwei Tao <wenweitaowenwei@gmail.com>
Subject: [RFC PATCH 0/6] add defer mechanism to ksm to make it more suitable for Android devices
Date: Wed, 10 Jun 2015 14:27:13 +0800
Message-Id: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org, hughd@google.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, wenweitaowenwei@gmail.com

I observe that it is unlikely for KSM to merge new pages from an area
that has already been scanned twice on Android mobile devices, so it's
a waste of power to scan these areas in high frequency. In this patchset,
a defer mechanism is introduced which is borrowed from page compaction to KSM.

A new slot list called active_slot is added into ksm_scan. MMs which have
VMA marked for merging via madvise are added (MM is new to KSM) or moved to
(MM is in the ksm_scan.mm_slot list) active_slot. In "scan_get_next_rmap_item()",
the active_slot list will be scaned firstly unless it is empty, then the mm_slot list.
MMs in the active_slot list will be scaned twice, after that they will be moved
to mm_slot list. Once scanning the mm_slot list, the defer mechanism will be activated:

a) if KSM scans "ksm_thread_pages_to_scan" pages but none of them get
merged or become unstable, increase the ksm_defer_shift(new member of ksm_scan)
by one (no more than 6 by now). And in the next "1UL << ksm_scan.ksm_defer_shift"
times KSM been scheduled or woken up it will not do the actual scan, compare
and merge job, it just schedule out.

b) if KSM scans "ksm_thread_pages_to_scan" pages and more than zero of them
get merged or become unstable, reset the ksm_defer_shift and ksm_considered
to zero.

Some applications may continue to produce new mergeable VMAs to KSM, in order
to avoid scanning VMAs of these applications that have already been scanned twice,
we use VM_HUGETLB to indicate new mergeable VMAs since hugetlb vm are not
supported by KSM.

Wenwei Tao (6):
  mm: add defer mechanism to ksm to make it more suitable
  mm: change the condition of identifying hugetlb vm
  perf: change the condition of identifying hugetlb vm
  fs/binfmt_elf.c: change the condition of identifying hugetlb vm
  x86/mm: change the condition of identifying hugetlb vm
  powerpc/kvm: change the condition of identifying hugetlb vm

 arch/powerpc/kvm/e500_mmu_host.c |    3 +-
 arch/x86/mm/tlb.c                |    3 +-
 fs/binfmt_elf.c                  |    2 +-
 include/linux/hugetlb_inline.h   |    2 +-
 include/linux/mempolicy.h        |    2 +-
 kernel/events/core.c             |    2 +-
 mm/gup.c                         |    6 +-
 mm/huge_memory.c                 |   17 ++-
 mm/ksm.c                         |  230 +++++++++++++++++++++++++++++++++-----
 mm/madvise.c                     |    6 +-
 mm/memory.c                      |    5 +-
 mm/mprotect.c                    |    6 +-
 12 files changed, 238 insertions(+), 46 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
