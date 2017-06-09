Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 483036B0365
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 10:21:46 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v104so8661376wrb.6
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:21:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d11si1283010wrb.272.2017.06.09.07.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 07:21:45 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v59EIfaH081997
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 10:21:43 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2aysy92ppd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Jun 2017 10:21:43 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 9 Jun 2017 15:21:39 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v4 10/20] mm/spf; fix lock dependency against mapping->i_mmap_rwsem
Date: Fri,  9 Jun 2017 16:20:59 +0200
In-Reply-To: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497018069-17790-11-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

kworker/32:1/819 is trying to acquire lock:
 (&vma->vm_sequence){+.+...}, at: [<c0000000002f20e0>]
zap_page_range_single+0xd0/0x1a0

but task is already holding lock:
 (&mapping->i_mmap_rwsem){++++..}, at: [<c0000000002f229c>]
unmap_mapping_range+0x7c/0x160

which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

-> #2 (&mapping->i_mmap_rwsem){++++..}:
       down_write+0x84/0x130
       __vma_adjust+0x1f4/0xa80
       __split_vma.isra.2+0x174/0x290
       do_munmap+0x13c/0x4e0
       vm_munmap+0x64/0xb0
       elf_map+0x11c/0x130
       load_elf_binary+0x6f0/0x15f0
       search_binary_handler+0xe0/0x2a0
       do_execveat_common.isra.14+0x7fc/0xbe0
       call_usermodehelper_exec_async+0x14c/0x1d0
       ret_from_kernel_thread+0x5c/0x68

-> #1 (&vma->vm_sequence/1){+.+...}:
       __vma_adjust+0x124/0xa80
       __split_vma.isra.2+0x174/0x290
       do_munmap+0x13c/0x4e0
       vm_munmap+0x64/0xb0
       elf_map+0x11c/0x130
       load_elf_binary+0x6f0/0x15f0
       search_binary_handler+0xe0/0x2a0
       do_execveat_common.isra.14+0x7fc/0xbe0
       call_usermodehelper_exec_async+0x14c/0x1d0
       ret_from_kernel_thread+0x5c/0x68

-> #0 (&vma->vm_sequence){+.+...}:
       lock_acquire+0xf4/0x310
       unmap_page_range+0xcc/0xfa0
       zap_page_range_single+0xd0/0x1a0
       unmap_mapping_range+0x138/0x160
       truncate_pagecache+0x50/0xa0
       put_aio_ring_file+0x48/0xb0
       aio_free_ring+0x40/0x1b0
       free_ioctx+0x38/0xc0
       process_one_work+0x2cc/0x8a0
       worker_thread+0xac/0x580
       kthread+0x164/0x1b0
       ret_from_kernel_thread+0x5c/0x68

other info that might help us debug this:

Chain exists of:
  &vma->vm_sequence --> &vma->vm_sequence/1 --> &mapping->i_mmap_rwsem

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&mapping->i_mmap_rwsem);
                               lock(&vma->vm_sequence/1);
                               lock(&mapping->i_mmap_rwsem);
  lock(&vma->vm_sequence);

 *** DEADLOCK ***

To fix that we must grab the vm_sequence lock after any mapping one in
__vma_adjust().

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/mmap.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 008fc35aa75e..0cad4d9b71d8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -707,10 +707,6 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	long adjust_next = 0;
 	int remove_next = 0;
 
-	write_seqcount_begin(&vma->vm_sequence);
-	if (next)
-		write_seqcount_begin_nested(&next->vm_sequence, SINGLE_DEPTH_NESTING);
-
 	if (next && !insert) {
 		struct vm_area_struct *exporter = NULL, *importer = NULL;
 
@@ -818,6 +814,11 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 		}
 	}
 
+	write_seqcount_begin(&vma->vm_sequence);
+	if (next)
+		write_seqcount_begin_nested(&next->vm_sequence,
+					    SINGLE_DEPTH_NESTING);
+
 	anon_vma = vma->anon_vma;
 	if (!anon_vma && adjust_next)
 		anon_vma = next->anon_vma;
@@ -934,8 +935,6 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			 * "vma->vm_next" gap must be updated.
 			 */
 			next = vma->vm_next;
-			if (next)
-				write_seqcount_begin_nested(&next->vm_sequence, SINGLE_DEPTH_NESTING);
 		} else {
 			/*
 			 * For the scope of the comment "next" and
@@ -952,11 +951,14 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 		if (remove_next == 2) {
 			remove_next = 1;
 			end = next->vm_end;
+			write_seqcount_end(&vma->vm_sequence);
 			goto again;
-		}
-		else if (next)
+		} else if (next) {
+			if (next != vma)
+				write_seqcount_begin_nested(&next->vm_sequence,
+							    SINGLE_DEPTH_NESTING);
 			vma_gap_update(next);
-		else {
+		} else {
 			/*
 			 * If remove_next == 2 we obviously can't
 			 * reach this path.
@@ -982,7 +984,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	if (insert && file)
 		uprobe_mmap(insert);
 
-	if (next)
+	if (next && next != vma)
 		write_seqcount_end(&next->vm_sequence);
 	write_seqcount_end(&vma->vm_sequence);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
