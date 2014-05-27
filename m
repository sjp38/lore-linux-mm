Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD6F6B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 00:57:17 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so8582819pbb.22
        for <linux-mm@kvack.org>; Mon, 26 May 2014 21:57:16 -0700 (PDT)
Received: from mail-pb0-x22a.google.com (mail-pb0-x22a.google.com [2607:f8b0:400e:c01::22a])
        by mx.google.com with ESMTPS id qf10si17072092pbb.86.2014.05.26.21.57.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 May 2014 21:57:16 -0700 (PDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so8697196pbc.1
        for <linux-mm@kvack.org>; Mon, 26 May 2014 21:57:15 -0700 (PDT)
From: Vinayak Menon <vinayakm.list@gmail.com>
Subject: [PATCH] mm: fix zero page check in vm_normal_page
Date: Tue, 27 May 2014 10:26:35 +0530
Message-Id: <1401166595-4792-1-git-send-email-vinayakm.list@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hannes@cmpxchg.org, mgorman@suse.de, riel@redhat.com, mingo@kernel.org, peterz@infradead.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, Vinayak Menon <vinayakm.list@gmail.com>

An issue was observed when a userspace task exits.
The page which hits error here is the zero page.
In zap_pte_range, vm_normal_page gets called, and it
returns a page address and not NULL, even though the
pte corresponds to zero pfn. In this case,
HAVE_PTE_SPECIAL is not set, and VM_MIXEDMAP is set
in vm_flags. In the case of VM_MIXEDMAP , only pfn_valid
is checked, and not is_zero_pfn. This results in
zero page being returned instead of NULL.

BUG: Bad page map in process mediaserver  pte:9dff379f pmd:9bfbd831
page:c0ed8e60 count:1 mapcount:-1 mapping:  (null) index:0x0
page flags: 0x404(referenced|reserved)
addr:40c3f000 vm_flags:10220051 anon_vma:  (null) mapping:d9fe0764 index:fd
vma->vm_ops->fault:   (null)
vma->vm_file->f_op->mmap: binder_mmap+0x0/0x274
CPU: 0 PID: 1463 Comm: mediaserver Tainted: G        W    3.10.17+ #1
[<c001549c>] (unwind_backtrace+0x0/0x11c) from [<c001200c>] (show_stack+0x10/0x14)
[<c001200c>] (show_stack+0x10/0x14) from [<c0103d78>] (print_bad_pte+0x158/0x190)
[<c0103d78>] (print_bad_pte+0x158/0x190) from [<c01055f0>] (unmap_single_vma+0x2e4/0x598)
[<c01055f0>] (unmap_single_vma+0x2e4/0x598) from [<c010618c>] (unmap_vmas+0x34/0x50)
[<c010618c>] (unmap_vmas+0x34/0x50) from [<c010a9e4>] (exit_mmap+0xc8/0x1e8)
[<c010a9e4>] (exit_mmap+0xc8/0x1e8) from [<c00520f0>] (mmput+0x54/0xd0)
[<c00520f0>] (mmput+0x54/0xd0) from [<c005972c>] (do_exit+0x360/0x990)
[<c005972c>] (do_exit+0x360/0x990) from [<c0059ef0>] (do_group_exit+0x84/0xc0)
[<c0059ef0>] (do_group_exit+0x84/0xc0) from [<c0066de0>] (get_signal_to_deliver+0x4d4/0x548)
[<c0066de0>] (get_signal_to_deliver+0x4d4/0x548) from [<c0011500>] (do_signal+0xa8/0x3b8)

Signed-off-by: Vinayak Menon <vinayakm.list@gmail.com>
---
 mm/memory.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 037b812..c9a5027 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -771,6 +771,8 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 		if (vma->vm_flags & VM_MIXEDMAP) {
 			if (!pfn_valid(pfn))
 				return NULL;
+			if (is_zero_pfn(pfn))
+				return NULL;
 			goto out;
 		} else {
 			unsigned long off;
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
