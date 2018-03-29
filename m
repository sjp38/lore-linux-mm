Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE686B0006
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:26:04 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k6so2495405wmi.6
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 04:26:04 -0700 (PDT)
Received: from isilmar-4.linta.de (isilmar-4.linta.de. [136.243.71.142])
        by mx.google.com with ESMTPS id g6si4753545wrd.443.2018.03.29.04.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 04:26:03 -0700 (PDT)
From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 047/109] mm: add kernel_[sg]et_mempolicy() helpers; remove in-kernel calls to syscalls
Date: Thu, 29 Mar 2018 13:23:24 +0200
Message-Id: <20180329112426.23043-48-linux@dominikbrodowski.net>
In-Reply-To: <20180329112426.23043-1-linux@dominikbrodowski.net>
References: <20180329112426.23043-1-linux@dominikbrodowski.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: viro@ZenIV.linux.org.uk, torvalds@linux-foundation.org, arnd@arndb.de, linux-arch@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Using the mm-internal kernel_[sg]et_mempolicy() helper allows us to get
rid of the mm-internal calls to the sys_[sg]et_mempolicy() syscalls.

This patch is part of a series which removes in-kernel calls to syscalls.
On this basis, the syscall entry path can be streamlined. For details, see
http://lkml.kernel.org/r/20180325162527.GA17492@light.dominikbrodowski.net

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 mm/mempolicy.c | 29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index e4d7d4c0b253..ca817e768d0e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1365,8 +1365,8 @@ SYSCALL_DEFINE6(mbind, unsigned long, start, unsigned long, len,
 }
 
 /* Set the process memory policy */
-SYSCALL_DEFINE3(set_mempolicy, int, mode, const unsigned long __user *, nmask,
-		unsigned long, maxnode)
+static long kernel_set_mempolicy(int mode, const unsigned long __user *nmask,
+				 unsigned long maxnode)
 {
 	int err;
 	nodemask_t nodes;
@@ -1384,6 +1384,12 @@ SYSCALL_DEFINE3(set_mempolicy, int, mode, const unsigned long __user *, nmask,
 	return do_set_mempolicy(mode, flags, &nodes);
 }
 
+SYSCALL_DEFINE3(set_mempolicy, int, mode, const unsigned long __user *, nmask,
+		unsigned long, maxnode)
+{
+	return kernel_set_mempolicy(mode, nmask, maxnode);
+}
+
 static int kernel_migrate_pages(pid_t pid, unsigned long maxnode,
 				const unsigned long __user *old_nodes,
 				const unsigned long __user *new_nodes)
@@ -1485,9 +1491,11 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 
 
 /* Retrieve NUMA policy */
-SYSCALL_DEFINE5(get_mempolicy, int __user *, policy,
-		unsigned long __user *, nmask, unsigned long, maxnode,
-		unsigned long, addr, unsigned long, flags)
+static int kernel_get_mempolicy(int __user *policy,
+				unsigned long __user *nmask,
+				unsigned long maxnode,
+				unsigned long addr,
+				unsigned long flags)
 {
 	int err;
 	int uninitialized_var(pval);
@@ -1510,6 +1518,13 @@ SYSCALL_DEFINE5(get_mempolicy, int __user *, policy,
 	return err;
 }
 
+SYSCALL_DEFINE5(get_mempolicy, int __user *, policy,
+		unsigned long __user *, nmask, unsigned long, maxnode,
+		unsigned long, addr, unsigned long, flags)
+{
+	return kernel_get_mempolicy(policy, nmask, maxnode, addr, flags);
+}
+
 #ifdef CONFIG_COMPAT
 
 COMPAT_SYSCALL_DEFINE5(get_mempolicy, int __user *, policy,
@@ -1528,7 +1543,7 @@ COMPAT_SYSCALL_DEFINE5(get_mempolicy, int __user *, policy,
 	if (nmask)
 		nm = compat_alloc_user_space(alloc_size);
 
-	err = sys_get_mempolicy(policy, nm, nr_bits+1, addr, flags);
+	err = kernel_get_mempolicy(policy, nm, nr_bits+1, addr, flags);
 
 	if (!err && nmask) {
 		unsigned long copy_size;
@@ -1560,7 +1575,7 @@ COMPAT_SYSCALL_DEFINE3(set_mempolicy, int, mode, compat_ulong_t __user *, nmask,
 			return -EFAULT;
 	}
 
-	return sys_set_mempolicy(mode, nm, nr_bits+1);
+	return kernel_set_mempolicy(mode, nm, nr_bits+1);
 }
 
 COMPAT_SYSCALL_DEFINE6(mbind, compat_ulong_t, start, compat_ulong_t, len,
-- 
2.16.3
