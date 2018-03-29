Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 567616B000C
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:26:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x15so522514wmc.7
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 04:26:09 -0700 (PDT)
Received: from isilmar-4.linta.de (isilmar-4.linta.de. [136.243.71.142])
        by mx.google.com with ESMTPS id y6si4609688wrb.133.2018.03.29.04.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 04:26:07 -0700 (PDT)
From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 044/109] mm: add kernel_migrate_pages() helper, move compat syscall to mm/mempolicy.c
Date: Thu, 29 Mar 2018 13:23:21 +0200
Message-Id: <20180329112426.23043-45-linux@dominikbrodowski.net>
In-Reply-To: <20180329112426.23043-1-linux@dominikbrodowski.net>
References: <20180329112426.23043-1-linux@dominikbrodowski.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: viro@ZenIV.linux.org.uk, torvalds@linux-foundation.org, arnd@arndb.de, linux-arch@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Move compat_sys_migrate_pages() to mm/mempolicy.c and make it call a newly
introduced helper -- kernel_migrate_pages() -- instead of the syscall.

This patch is part of a series which removes in-kernel calls to syscalls.
On this basis, the syscall entry path can be streamlined. For details, see
http://lkml.kernel.org/r/20180325162527.GA17492@light.dominikbrodowski.net

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 kernel/compat.c | 33 ---------------------------------
 mm/mempolicy.c  | 48 ++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 44 insertions(+), 37 deletions(-)

diff --git a/kernel/compat.c b/kernel/compat.c
index 3f5fa8902e7d..51bdf1808943 100644
--- a/kernel/compat.c
+++ b/kernel/compat.c
@@ -508,39 +508,6 @@ COMPAT_SYSCALL_DEFINE6(move_pages, pid_t, pid, compat_ulong_t, nr_pages,
 	}
 	return sys_move_pages(pid, nr_pages, pages, nodes, status, flags);
 }
-
-COMPAT_SYSCALL_DEFINE4(migrate_pages, compat_pid_t, pid,
-		       compat_ulong_t, maxnode,
-		       const compat_ulong_t __user *, old_nodes,
-		       const compat_ulong_t __user *, new_nodes)
-{
-	unsigned long __user *old = NULL;
-	unsigned long __user *new = NULL;
-	nodemask_t tmp_mask;
-	unsigned long nr_bits;
-	unsigned long size;
-
-	nr_bits = min_t(unsigned long, maxnode - 1, MAX_NUMNODES);
-	size = ALIGN(nr_bits, BITS_PER_LONG) / 8;
-	if (old_nodes) {
-		if (compat_get_bitmap(nodes_addr(tmp_mask), old_nodes, nr_bits))
-			return -EFAULT;
-		old = compat_alloc_user_space(new_nodes ? size * 2 : size);
-		if (new_nodes)
-			new = old + size / sizeof(unsigned long);
-		if (copy_to_user(old, nodes_addr(tmp_mask), size))
-			return -EFAULT;
-	}
-	if (new_nodes) {
-		if (compat_get_bitmap(nodes_addr(tmp_mask), new_nodes, nr_bits))
-			return -EFAULT;
-		if (new == NULL)
-			new = compat_alloc_user_space(size);
-		if (copy_to_user(new, nodes_addr(tmp_mask), size))
-			return -EFAULT;
-	}
-	return sys_migrate_pages(pid, nr_bits + 1, old, new);
-}
 #endif
 
 /*
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d879f1d8a44a..7399ede02b5f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1377,9 +1377,9 @@ SYSCALL_DEFINE3(set_mempolicy, int, mode, const unsigned long __user *, nmask,
 	return do_set_mempolicy(mode, flags, &nodes);
 }
 
-SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
-		const unsigned long __user *, old_nodes,
-		const unsigned long __user *, new_nodes)
+static int kernel_migrate_pages(pid_t pid, unsigned long maxnode,
+				const unsigned long __user *old_nodes,
+				const unsigned long __user *new_nodes)
 {
 	struct mm_struct *mm = NULL;
 	struct task_struct *task;
@@ -1469,6 +1469,13 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 
 }
 
+SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
+		const unsigned long __user *, old_nodes,
+		const unsigned long __user *, new_nodes)
+{
+	return kernel_migrate_pages(pid, maxnode, old_nodes, new_nodes);
+}
+
 
 /* Retrieve NUMA policy */
 SYSCALL_DEFINE5(get_mempolicy, int __user *, policy,
@@ -1571,7 +1578,40 @@ COMPAT_SYSCALL_DEFINE6(mbind, compat_ulong_t, start, compat_ulong_t, len,
 	return sys_mbind(start, len, mode, nm, nr_bits+1, flags);
 }
 
-#endif
+COMPAT_SYSCALL_DEFINE4(migrate_pages, compat_pid_t, pid,
+		       compat_ulong_t, maxnode,
+		       const compat_ulong_t __user *, old_nodes,
+		       const compat_ulong_t __user *, new_nodes)
+{
+	unsigned long __user *old = NULL;
+	unsigned long __user *new = NULL;
+	nodemask_t tmp_mask;
+	unsigned long nr_bits;
+	unsigned long size;
+
+	nr_bits = min_t(unsigned long, maxnode - 1, MAX_NUMNODES);
+	size = ALIGN(nr_bits, BITS_PER_LONG) / 8;
+	if (old_nodes) {
+		if (compat_get_bitmap(nodes_addr(tmp_mask), old_nodes, nr_bits))
+			return -EFAULT;
+		old = compat_alloc_user_space(new_nodes ? size * 2 : size);
+		if (new_nodes)
+			new = old + size / sizeof(unsigned long);
+		if (copy_to_user(old, nodes_addr(tmp_mask), size))
+			return -EFAULT;
+	}
+	if (new_nodes) {
+		if (compat_get_bitmap(nodes_addr(tmp_mask), new_nodes, nr_bits))
+			return -EFAULT;
+		if (new == NULL)
+			new = compat_alloc_user_space(size);
+		if (copy_to_user(new, nodes_addr(tmp_mask), size))
+			return -EFAULT;
+	}
+	return kernel_migrate_pages(pid, nr_bits + 1, old, new);
+}
+
+#endif /* CONFIG_COMPAT */
 
 struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
 						unsigned long addr)
-- 
2.16.3
