Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7B24A6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 11:39:51 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so31642865pdb.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 08:39:51 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id pk5si39888758pbb.133.2015.04.29.08.39.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 08:39:50 -0700 (PDT)
Received: by pacwv17 with SMTP id wv17so31234049pac.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 08:39:50 -0700 (PDT)
From: Shawn Chang <citypw@gmail.com>
Subject: [PATCH] Hardening memory maunipulation. 
Date: Wed, 29 Apr 2015 23:39:35 +0800
Message-Id: <1430321975-13626-1-git-send-email-citypw@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: spender@grsecurity.net, keescook@chromium.org, Shawn C <citypw@gmail.com>

From: Shawn C <citypw@gmail.com>

Hi kernel maintainers,

It won't allow the address above the TASK_SIZE being mmap'ed( or mprotect'ed).
This patch is from PaX/Grsecurity.

Thanks for your review time!

Signed-off-by: Shawn C <citypw@gmail.com>
---
 mm/madvise.c   | 4 ++++
 mm/mempolicy.c | 5 +++++
 mm/mlock.c     | 4 ++++
 mm/mprotect.c  | 5 +++++
 4 files changed, 18 insertions(+)

diff --git a/mm/madvise.c b/mm/madvise.c
index d551475..3f5dd3d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -484,6 +484,10 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	if (end < start)
 		return error;
 
+	/* We should never reach the kernel address space here */
+	if (end > TASK_SIZE)
+		return error;
+
 	error = 0;
 	if (end == start)
 		return error;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ede2629..56c2eed 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1161,6 +1161,11 @@ static long do_mbind(unsigned long start, unsigned long len,
 
 	if (end < start)
 		return -EINVAL;
+
+	/* We should never reach the kernel address space here */
+	if (end > TASK_SIZE)
+		return -EINVAL;
+
 	if (end == start)
 		return 0;
 
diff --git a/mm/mlock.c b/mm/mlock.c
index 6fd2cf1..c7f6785 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -566,6 +566,10 @@ static int do_mlock(unsigned long start, size_t len, int on)
 		return -EINVAL;
 	if (end == start)
 		return 0;
+
+	if (end > TASK_SIZE)
+		return -EINVAL;
+
 	vma = find_vma(current->mm, start);
 	if (!vma || vma->vm_start > start)
 		return -ENOMEM;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 8858483..cd58a31 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -351,6 +351,11 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 	end = start + len;
 	if (end <= start)
 		return -ENOMEM;
+
+	/* We should never reach the kernel address space here */
+	if (end > TASK_SIZE)
+		return -EINVAL;
+
 	if (!arch_validate_prot(prot))
 		return -EINVAL;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
