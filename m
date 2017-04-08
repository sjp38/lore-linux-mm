Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9446B0038
	for <linux-mm@kvack.org>; Sat,  8 Apr 2017 02:53:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b23so2447119pfc.22
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 23:53:16 -0700 (PDT)
Received: from hpt (firewall.seclab.cs.ucsb.edu. [128.111.48.252])
        by mx.google.com with ESMTP id y3si7461752pff.122.2017.04.07.23.53.15
        for <linux-mm@kvack.org>;
        Fri, 07 Apr 2017 23:53:15 -0700 (PDT)
From: Chris Salls <salls@cs.ucsb.edu>
Subject: [PATCH] mm/mempolicy.c: fix error handling in set_mempolicy and mbind.
Date: Fri,  7 Apr 2017 23:48:11 -0700
Message-Id: <1491634091-18817-1-git-send-email-salls@cs.ucsb.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: security@kernel.org, Chris Salls <salls@cs.ucsb.edu>

In the case that compat_get_bitmap fails we do not want to copy the
bitmap to the user as it will contain uninitialized stack data and
leak sensitive data.

Signed-off-by: Chris Salls <salls@cs.ucsb.edu>
---
 mm/mempolicy.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 75b2745..37d0b33 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1529,7 +1529,6 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 COMPAT_SYSCALL_DEFINE3(set_mempolicy, int, mode, compat_ulong_t __user *, nmask,
 		       compat_ulong_t, maxnode)
 {
-	long err = 0;
 	unsigned long __user *nm = NULL;
 	unsigned long nr_bits, alloc_size;
 	DECLARE_BITMAP(bm, MAX_NUMNODES);
@@ -1538,14 +1537,13 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 	alloc_size = ALIGN(nr_bits, BITS_PER_LONG) / 8;
 
 	if (nmask) {
-		err = compat_get_bitmap(bm, nmask, nr_bits);
+		if (compat_get_bitmap(bm, nmask, nr_bits))
+			return -EFAULT;
 		nm = compat_alloc_user_space(alloc_size);
-		err |= copy_to_user(nm, bm, alloc_size);
+		if (copy_to_user(nm, bm, alloc_size))
+			return -EFAULT;
 	}
 
-	if (err)
-		return -EFAULT;
-
 	return sys_set_mempolicy(mode, nm, nr_bits+1);
 }
 
@@ -1553,7 +1551,6 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 		       compat_ulong_t, mode, compat_ulong_t __user *, nmask,
 		       compat_ulong_t, maxnode, compat_ulong_t, flags)
 {
-	long err = 0;
 	unsigned long __user *nm = NULL;
 	unsigned long nr_bits, alloc_size;
 	nodemask_t bm;
@@ -1562,14 +1559,13 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 	alloc_size = ALIGN(nr_bits, BITS_PER_LONG) / 8;
 
 	if (nmask) {
-		err = compat_get_bitmap(nodes_addr(bm), nmask, nr_bits);
+		if (compat_get_bitmap(nodes_addr(bm), nmask, nr_bits))
+			return -EFAULT;
 		nm = compat_alloc_user_space(alloc_size);
-		err |= copy_to_user(nm, nodes_addr(bm), alloc_size);
+		if (copy_to_user(nm, nodes_addr(bm), alloc_size))
+			return -EFAULT;
 	}
 
-	if (err)
-		return -EFAULT;
-
 	return sys_mbind(start, len, mode, nm, nr_bits+1, flags);
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
