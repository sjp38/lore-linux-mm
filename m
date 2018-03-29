Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B02546B0009
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:26:06 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id m7so2609794wrb.16
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 04:26:06 -0700 (PDT)
Received: from isilmar-4.linta.de (isilmar-4.linta.de. [136.243.71.142])
        by mx.google.com with ESMTPS id a6si692867wma.90.2018.03.29.04.26.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 04:26:05 -0700 (PDT)
From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 045/109] mm: add kernel_move_pages() helper, move compat syscall to mm/migrate.c
Date: Thu, 29 Mar 2018 13:23:22 +0200
Message-Id: <20180329112426.23043-46-linux@dominikbrodowski.net>
In-Reply-To: <20180329112426.23043-1-linux@dominikbrodowski.net>
References: <20180329112426.23043-1-linux@dominikbrodowski.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: viro@ZenIV.linux.org.uk, torvalds@linux-foundation.org, arnd@arndb.de, linux-arch@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Move compat_sys_move_pages() to mm/migrate.c and make it call a newly
introduced helper -- kernel_move_pages() -- instead of the syscall.

This patch is part of a series which removes in-kernel calls to syscalls.
On this basis, the syscall entry path can be streamlined. For details, see
http://lkml.kernel.org/r/20180325162527.GA17492@light.dominikbrodowski.net

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 kernel/compat.c | 22 ----------------------
 mm/migrate.c    | 39 +++++++++++++++++++++++++++++++++++----
 2 files changed, 35 insertions(+), 26 deletions(-)

diff --git a/kernel/compat.c b/kernel/compat.c
index 51bdf1808943..6d21894806b4 100644
--- a/kernel/compat.c
+++ b/kernel/compat.c
@@ -488,28 +488,6 @@ get_compat_sigset(sigset_t *set, const compat_sigset_t __user *compat)
 }
 EXPORT_SYMBOL_GPL(get_compat_sigset);
 
-#ifdef CONFIG_NUMA
-COMPAT_SYSCALL_DEFINE6(move_pages, pid_t, pid, compat_ulong_t, nr_pages,
-		       compat_uptr_t __user *, pages32,
-		       const int __user *, nodes,
-		       int __user *, status,
-		       int, flags)
-{
-	const void __user * __user *pages;
-	int i;
-
-	pages = compat_alloc_user_space(nr_pages * sizeof(void *));
-	for (i = 0; i < nr_pages; i++) {
-		compat_uptr_t p;
-
-		if (get_user(p, pages32 + i) ||
-			put_user(compat_ptr(p), pages + i))
-			return -EFAULT;
-	}
-	return sys_move_pages(pid, nr_pages, pages, nodes, status, flags);
-}
-#endif
-
 /*
  * Allocate user-space memory for the duration of a single system call,
  * in order to marshall parameters inside a compat thunk.
diff --git a/mm/migrate.c b/mm/migrate.c
index 1e5525a25691..003886606a22 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -34,6 +34,7 @@
 #include <linux/backing-dev.h>
 #include <linux/compaction.h>
 #include <linux/syscalls.h>
+#include <linux/compat.h>
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
@@ -1745,10 +1746,10 @@ static int do_pages_stat(struct mm_struct *mm, unsigned long nr_pages,
  * Move a list of pages in the address space of the currently executing
  * process.
  */
-SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
-		const void __user * __user *, pages,
-		const int __user *, nodes,
-		int __user *, status, int, flags)
+static int kernel_move_pages(pid_t pid, unsigned long nr_pages,
+			     const void __user * __user *pages,
+			     const int __user *nodes,
+			     int __user *status, int flags)
 {
 	struct task_struct *task;
 	struct mm_struct *mm;
@@ -1807,6 +1808,36 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 	return err;
 }
 
+SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
+		const void __user * __user *, pages,
+		const int __user *, nodes,
+		int __user *, status, int, flags)
+{
+	return kernel_move_pages(pid, nr_pages, pages, nodes, status, flags);
+}
+
+#ifdef CONFIG_COMPAT
+COMPAT_SYSCALL_DEFINE6(move_pages, pid_t, pid, compat_ulong_t, nr_pages,
+		       compat_uptr_t __user *, pages32,
+		       const int __user *, nodes,
+		       int __user *, status,
+		       int, flags)
+{
+	const void __user * __user *pages;
+	int i;
+
+	pages = compat_alloc_user_space(nr_pages * sizeof(void *));
+	for (i = 0; i < nr_pages; i++) {
+		compat_uptr_t p;
+
+		if (get_user(p, pages32 + i) ||
+			put_user(compat_ptr(p), pages + i))
+			return -EFAULT;
+	}
+	return kernel_move_pages(pid, nr_pages, pages, nodes, status, flags);
+}
+#endif /* CONFIG_COMPAT */
+
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * Returns true if this is a safe migration target node for misplaced NUMA
-- 
2.16.3
