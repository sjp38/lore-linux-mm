Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9ADF86B0005
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 05:00:40 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id x4so53471786lbm.0
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 02:00:40 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id pp7si4757680lbc.46.2016.01.23.02.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Jan 2016 02:00:39 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id z62so5353223lfd.0
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 02:00:38 -0800 (PST)
Subject: [PATCH v2] mm: warn about VmData over RLIMIT_DATA
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 23 Jan 2016 13:00:34 +0300
Message-ID: <145354323486.16567.6251495688050187292.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linuxfoundation.org>, linux-kernel@vger.kernel.org
Cc: Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>

This patch fixes 84638335900f ("mm: rework virtual memory accounting")

Before that commit RLIMIT_DATA have control only over size of the brk region.
But that change have caused problems with all existing versions of valgrind,
because it set RLIMIT_DATA to zero.

This patch fixes RLIMIT_DATA check (limit actually in bytes, not pages)
and by default turns it into warning which prints at first VmData misuse.
Like: "VmData 516096 exceeds RLIMIT_DATA 512000"

Behavior is controlled by boot param ignore_rlimit_data=y/n and by sysfs
/sys/module/kernel/parameters/ignore_rlimit_data. For now it set to "y".

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Link: http://lkml.kernel.org/r/20151228211015.GL2194@uranus
Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 Documentation/kernel-parameters.txt |    5 +++++
 mm/mmap.c                           |   12 +++++++++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index cfb2c0f1a4a8..d728caf7aa52 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1461,6 +1461,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			could change it dynamically, usually by
 			/sys/module/printk/parameters/ignore_loglevel.
 
+	ignore_rlimit_data
+			Ignore RLIMIT_DATA setting for private mappings,
+			print warning at first misuse. Could be changed by
+			/sys/module/kernel/parameters/ignore_rlimit_data.
+
 	ihash_entries=	[KNL]
 			Set number of hash buckets for inode cache.
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 84b12624ceb0..46d2ed6cb0df 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -42,6 +42,7 @@
 #include <linux/memory.h>
 #include <linux/printk.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/moduleparam.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -69,6 +70,8 @@ const int mmap_rnd_compat_bits_max = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX;
 int mmap_rnd_compat_bits __read_mostly = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
 #endif
 
+static bool ignore_rlimit_data = true;
+core_param(ignore_rlimit_data, ignore_rlimit_data, bool, 0644);
 
 static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
@@ -2982,9 +2985,12 @@ bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 	if (mm->total_vm + npages > rlimit(RLIMIT_AS) >> PAGE_SHIFT)
 		return false;
 
-	if ((flags & (VM_WRITE | VM_SHARED | (VM_STACK_FLAGS &
-				(VM_GROWSUP | VM_GROWSDOWN)))) == VM_WRITE)
-		return mm->data_vm + npages <= rlimit(RLIMIT_DATA);
+	if ((flags & (VM_WRITE | VM_SHARED |
+		(VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)))) == VM_WRITE &&
+	    mm->data_vm + npages > rlimit(RLIMIT_DATA) >> PAGE_SHIFT &&
+	    !WARN_ONCE(ignore_rlimit_data, "VmData %lu exceeds RLIMIT_DATA %lu",
+		       (mm->data_vm + npages)<<PAGE_SHIFT, rlimit(RLIMIT_DATA)))
+		return false;
 
 	return true;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
