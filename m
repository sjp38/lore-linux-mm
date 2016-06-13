Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88FD66B0274
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 15:48:17 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id wy7so47362899lbb.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:48:17 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id 12si260793wmf.86.2016.06.13.12.48.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 12:48:16 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id n184so17328732wmn.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:48:16 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [RFC 13/18] limits: track RLIMIT_AS actual max
Date: Mon, 13 Jun 2016 22:44:20 +0300
Message-Id: <1465847065-3577-14-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Track maximum size of address space, presented in /proc/self/limits.

Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
---
 mm/mmap.c   | 4 ++++
 mm/mremap.c | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 4e683dd..4876c21 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2706,6 +2706,9 @@ static int do_brk(unsigned long addr, unsigned long len)
 out:
 	perf_event_mmap(vma);
 	mm->total_vm += len >> PAGE_SHIFT;
+
+	bump_rlimit(RLIMIT_AS, mm->total_vm << PAGE_SHIFT);
+
 	mm->data_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED)
 		mm->locked_vm += (len >> PAGE_SHIFT);
@@ -2926,6 +2929,7 @@ bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 {
 	mm->total_vm += npages;
+	bump_rlimit(RLIMIT_AS, mm->total_vm << PAGE_SHIFT);
 
 	if (is_exec_mapping(flags))
 		mm->exec_vm += npages;
diff --git a/mm/mremap.c b/mm/mremap.c
index ade3e13..6be3c01 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -397,6 +397,9 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	if (vma->vm_flags & VM_LOCKED)
 		bump_rlimit(RLIMIT_MEMLOCK, (mm->locked_vm << PAGE_SHIFT) +
 			    new_len - old_len);
+	bump_rlimit(RLIMIT_AS, (mm->total_vm << PAGE_SHIFT) +
+		    new_len - old_len);
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
