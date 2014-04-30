Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 88F9D6B0039
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:01:10 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id k14so2173609wgh.13
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:01:09 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
        by mx.google.com with ESMTPS id fy10si1486473wib.22.2014.04.30.13.01.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 13:01:09 -0700 (PDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so2832228wib.1
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:01:08 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] mm: constify nmask argument to set_mempolicy()
Date: Wed, 30 Apr 2014 22:00:34 +0200
Message-Id: <1398888034-12882-1-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1398868157-24323-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1398868157-24323-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

The nmask argument to set_mempolicy() is const according to the
user-space header numaif.h, and since the kernel does indeed not
modify it, it might as well be declared const in the kernel.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/linux/syscalls.h | 2 +-
 mm/mempolicy.c           | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index bfef0be..b0881a0 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -711,7 +711,7 @@ asmlinkage long sys_keyctl(int cmd, unsigned long arg2, unsigned long arg3,
 
 asmlinkage long sys_ioprio_set(int which, int who, int ioprio);
 asmlinkage long sys_ioprio_get(int which, int who);
-asmlinkage long sys_set_mempolicy(int mode, unsigned long __user *nmask,
+asmlinkage long sys_set_mempolicy(int mode, const unsigned long __user *nmask,
 				unsigned long maxnode);
 asmlinkage long sys_migrate_pages(pid_t pid, unsigned long maxnode,
 				const unsigned long __user *from,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 727187f..b09586d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1383,7 +1383,7 @@ SYSCALL_DEFINE6(mbind, unsigned long, start, unsigned long, len,
 }
 
 /* Set the process memory policy */
-SYSCALL_DEFINE3(set_mempolicy, int, mode, unsigned long __user *, nmask,
+SYSCALL_DEFINE3(set_mempolicy, int, mode, const unsigned long __user *, nmask,
 		unsigned long, maxnode)
 {
 	int err;
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
