Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id E10D66B003A
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 10:29:33 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id f8so3008593wiw.9
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 07:29:33 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
        by mx.google.com with ESMTPS id iz9si489635wic.4.2014.04.30.07.29.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 07:29:32 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so2301246wiv.3
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 07:29:32 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] mm: constify nmask argument to mbind()
Date: Wed, 30 Apr 2014 16:29:17 +0200
Message-Id: <1398868157-24323-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jianguo Wu <wujianguo@huawei.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

The nmask argument to mbind() is const according to the user-space
header numaif.h, and since the kernel does indeed not modify it, it
might as well be declared const in the kernel.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/linux/syscalls.h | 2 +-
 mm/mempolicy.c           | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index a4a0588..bfef0be 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -723,7 +723,7 @@ asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
 				int flags);
 asmlinkage long sys_mbind(unsigned long start, unsigned long len,
 				unsigned long mode,
-				unsigned long __user *nmask,
+				const unsigned long __user *nmask,
 				unsigned long maxnode,
 				unsigned flags);
 asmlinkage long sys_get_mempolicy(int __user *policy,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 78e1472..727187f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1362,7 +1362,7 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 }
 
 SYSCALL_DEFINE6(mbind, unsigned long, start, unsigned long, len,
-		unsigned long, mode, unsigned long __user *, nmask,
+		unsigned long, mode, const unsigned long __user *, nmask,
 		unsigned long, maxnode, unsigned, flags)
 {
 	nodemask_t nodes;
-- 
2.0.0.rc1.4.gd8779e1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
