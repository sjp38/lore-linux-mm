Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0A96B0264
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:37:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id l89so70263731lfi.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:37:49 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id cx1si59703wjb.182.2016.07.15.03.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 03:37:48 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id i5so1745188wmg.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:37:48 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [PATCH 10/14] resource limits: track highwater mark of address space size
Date: Fri, 15 Jul 2016 13:35:57 +0300
Message-Id: <1468578983-28229-11-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Track maximum size of address space, to be able to configure
RLIMIT_AS resource limits. The information is available
with taskstats and cgroupstats netlink socket.

Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
---
 mm/mmap.c   | 4 ++++
 mm/mremap.c | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index c37f599..ded2f8d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2707,6 +2707,9 @@ static int do_brk(unsigned long addr, unsigned long len)
 out:
 	perf_event_mmap(vma);
 	mm->total_vm += len >> PAGE_SHIFT;
+
+	update_resource_highwatermark(RLIMIT_AS, mm->total_vm << PAGE_SHIFT);
+
 	mm->data_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED)
 		mm->locked_vm += (len >> PAGE_SHIFT);
@@ -2927,6 +2930,7 @@ bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 {
 	mm->total_vm += npages;
+	update_resource_highwatermark(RLIMIT_AS, mm->total_vm << PAGE_SHIFT);
 
 	if (is_exec_mapping(flags))
 		mm->exec_vm += npages;
diff --git a/mm/mremap.c b/mm/mremap.c
index f1821335..aa717d0 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -398,6 +398,9 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 		update_resource_highwatermark(RLIMIT_MEMLOCK,
 					      (mm->locked_vm << PAGE_SHIFT) +
 					      new_len - old_len);
+	update_resource_highwatermark(RLIMIT_AS, (mm->total_vm << PAGE_SHIFT) +
+				      new_len - old_len);
+
 	return vma;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
