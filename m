Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 49F1D6B0003
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 06:19:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v15-v6so973360edm.13
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 03:19:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id br7-v6si1041943ejb.281.2018.10.09.03.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 03:19:35 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Preserve _PAGE_DEVMAP across mprotect() calls
Date: Tue,  9 Oct 2018 12:19:17 +0200
Message-Id: <20181009101917.32497-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, stable@vger.kernel.org

Currently _PAGE_DEVMAP bit is not preserved in mprotect(2) calls. As a
result we will see warnings such as:

BUG: Bad page map in process JobWrk0013  pte:800001803875ea25 pmd:7624381067
addr:00007f0930720000 vm_flags:280000f9 anon_vma:          (null) mapping:ffff97f2384056f0 index:0
file:457-000000fe00000030-00000009-000000ca-00000001_2001.fileblock fault:xfs_filemap_fault [xfs] mmap:xfs_file_mmap [xfs] readpage:          (null)
CPU: 3 PID: 15848 Comm: JobWrk0013 Tainted: G        W          4.12.14-2.g7573215-default #1 SLE12-SP4 (unreleased)
Hardware name: Intel Corporation S2600WFD/S2600WFD, BIOS SE5C620.86B.01.00.0833.051120182255 05/11/2018
Call Trace:
 dump_stack+0x5a/0x75
 print_bad_pte+0x217/0x2c0
 ? enqueue_task_fair+0x76/0x9f0
 _vm_normal_page+0xe5/0x100
 zap_pte_range+0x148/0x740
 unmap_page_range+0x39a/0x4b0
 unmap_vmas+0x42/0x90
 unmap_region+0x99/0xf0
 ? vma_gap_callbacks_rotate+0x1a/0x20
 do_munmap+0x255/0x3a0
 vm_munmap+0x54/0x80
 SyS_munmap+0x1d/0x30
 do_syscall_64+0x74/0x150
 entry_SYSCALL_64_after_hwframe+0x3d/0xa2
...

when mprotect(2) gets used on DAX mappings. Also there is a wide variety
of other failures that can result from the missing _PAGE_DEVMAP flag
when the area gets used by get_user_pages() later.

Fix the problem by including _PAGE_DEVMAP in a set of flags that get
preserved by mprotect(2).

Fixes: 69660fd797c3 ("x86, mm: introduce _PAGE_DEVMAP")
Fixes: ebd31197931d ("powerpc/mm: Add devmap support for ppc64")
CC: stable@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 4 ++--
 arch/x86/include/asm/pgtable_types.h         | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 2fdc865ca374..2a2486526d1f 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -114,7 +114,7 @@
  */
 #define _HPAGE_CHG_MASK (PTE_RPN_MASK | _PAGE_HPTEFLAGS | _PAGE_DIRTY | \
 			 _PAGE_ACCESSED | H_PAGE_THP_HUGE | _PAGE_PTE | \
-			 _PAGE_SOFT_DIRTY)
+			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
 /*
  * user access blocked by key
  */
@@ -132,7 +132,7 @@
  */
 #define _PAGE_CHG_MASK	(PTE_RPN_MASK | _PAGE_HPTEFLAGS | _PAGE_DIRTY | \
 			 _PAGE_ACCESSED | _PAGE_SPECIAL | _PAGE_PTE |	\
-			 _PAGE_SOFT_DIRTY)
+			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
 
 #define H_PTE_PKEY  (H_PTE_PKEY_BIT0 | H_PTE_PKEY_BIT1 | H_PTE_PKEY_BIT2 | \
 		     H_PTE_PKEY_BIT3 | H_PTE_PKEY_BIT4)
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index b64acb08a62b..106b7d0e2dae 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -124,7 +124,7 @@
  */
 #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
 			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
-			 _PAGE_SOFT_DIRTY)
+			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
 
 /*
-- 
2.16.4
