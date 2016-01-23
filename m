Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 642F86B0254
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 02:39:52 -0500 (EST)
Received: by mail-lf0-f43.google.com with SMTP id c192so59433732lfe.2
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 23:39:52 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id c188si4501799lfe.196.2016.01.22.23.39.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 23:39:51 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id n70so5240268lfn.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 23:39:51 -0800 (PST)
Subject: [PATCH 2/2] mm: limit VmData with RLIMIT_DATA
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 23 Jan 2016 10:39:47 +0300
Message-ID: <145353478691.23962.7610086254586675400.stgit@zurg>
In-Reply-To: <145353478067.23962.14991739413777907906.stgit@zurg>
References: <145353478067.23962.14991739413777907906.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linuxfoundation.org>, linux-kernel@vger.kernel.org
Cc: Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>

This adds is correct version of RLIMIT_DATA check.
And kernel boot option "ignore_rlimit_data" for reverting old behavior.
Also could be set by /sys/module/kernel/parameters/ignore_rlimit_data.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 Documentation/kernel-parameters.txt |    5 +++++
 mm/mmap.c                           |    8 ++++++++
 2 files changed, 13 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index cfb2c0f1a4a8..850239102e86 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1461,6 +1461,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			could change it dynamically, usually by
 			/sys/module/printk/parameters/ignore_loglevel.
 
+	ignore_rlimit_data
+			Ignore setrlimit(RLIMIT_DATA) setting for private
+			mappings (as it was before). Could be changed by
+			/sys/module/kernel/parameters/ignore_rlimit_data.
+
 	ihash_entries=	[KNL]
 			Set number of hash buckets for inode cache.
 
diff --git a/mm/mmap.c b/mm/mmap.c
index e0cd98c510ba..af272025b1b9 100644
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
 
+static bool ignore_rlimit_data = false;
+core_param(ignore_rlimit_data, ignore_rlimit_data, bool, 0644);
 
 static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
@@ -2982,6 +2985,11 @@ bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 	if (mm->total_vm + npages > rlimit(RLIMIT_AS) >> PAGE_SHIFT)
 		return false;
 
+	if (!ignore_rlimit_data && (flags & (VM_WRITE | VM_SHARED |
+		(VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)))) == VM_WRITE &&
+	    mm->data_vm + npages > rlimit(RLIMIT_DATA) >> PAGE_SHIFT)
+		return false;
+
 	return true;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
