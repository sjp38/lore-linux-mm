Received: from smtp2.fc.hp.com (smtp2.fc.hp.com [15.11.136.114])
	by atlrel8.hp.com (Postfix) with ESMTP id 07CBE36F69
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:26:32 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp2.fc.hp.com (Postfix) with ESMTP id C08BEAC7A
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:26:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 4F297134251
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:26:32 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 21502-08 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:26:30 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 1B78C134225
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:26:30 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 6/6] Migrate-on-fault - add MPOL_NOOP
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441108.5198.36.camel@localhost.localdomain>
References: <1144441108.5198.36.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:27:54 -0400
Message-Id: <1144441674.5198.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Migrate-on-fault prototype 6/6 V0.2 - add MPOL_NOOP

V0.2 -	this patch is new in the V0.2 series.  No change between
	2.6.16-mm1 and 2.6.17-rc1-mm1

This patch augments the MPOL_MF_LAZY feature by adding a "NOOP"
policy to mbind().  When the NOOP policy is used with the 'MOVE
and 'LAZY flags, mbind() [check_range()] will walk the specified
range and unmap eligible pages so that they will be migrated on
next touch.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-mm1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.16-mm1.orig/include/linux/mempolicy.h	2006-03-23 16:49:16.000000000 -0500
+++ linux-2.6.16-mm1/include/linux/mempolicy.h	2006-03-23 16:49:22.000000000 -0500
@@ -13,8 +13,9 @@
 #define MPOL_PREFERRED	1
 #define MPOL_BIND	2
 #define MPOL_INTERLEAVE	3
+#define MPOL_NOOP	4	/* retain existing policy for range */
 
-#define MPOL_MAX MPOL_INTERLEAVE
+#define MPOL_MAX MPOL_NOOP
 
 /* Flags for get_mem_policy */
 #define MPOL_F_NODE	(1<<0)	/* return next IL mode instead of node mask */
Index: linux-2.6.16-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.16-mm1.orig/mm/mempolicy.c	2006-03-23 16:49:16.000000000 -0500
+++ linux-2.6.16-mm1/mm/mempolicy.c	2006-03-23 16:49:22.000000000 -0500
@@ -117,6 +117,7 @@ static int mpol_check_policy(int mode, n
 
 	switch (mode) {
 	case MPOL_DEFAULT:
+	case MPOL_NOOP:
 		if (!empty)
 			return -EINVAL;
 		break;
@@ -163,7 +164,7 @@ static struct mempolicy *mpol_new(int mo
 	struct mempolicy *policy;
 
 	PDprintk("setting mode %d nodes[0] %lx\n", mode, nodes_addr(*nodes)[0]);
-	if (mode == MPOL_DEFAULT)
+	if (mode == MPOL_DEFAULT || mode == MPOL_NOOP)
 		return NULL;
 	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL);
 	if (!policy)
@@ -726,7 +727,7 @@ long do_mbind(unsigned long start, unsig
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
 
-	if (mode == MPOL_DEFAULT)
+	if (mode == MPOL_DEFAULT || mode == MPOL_NOOP)
 		flags &= ~MPOL_MF_STRICT;
 
 	len = (len + PAGE_SIZE - 1) & PAGE_MASK;
@@ -762,10 +763,13 @@ long do_mbind(unsigned long start, unsig
 	if (!IS_ERR(vma)) {
 		int nr_failed = 0;
 
-		err = mbind_range(vma, start, end, new);
+		if (mode == MPOL_NOOP)
+			err = 0;
+		else
+			err = mbind_range(vma, start, end, new);
 
 		if (!list_empty(&pagelist)) {
-			if (!(flags & MPOL_MF_LAZY))
+			if (mode != MPOL_NOOP && !(flags & MPOL_MF_LAZY))
 				nr_failed = migrate_pages_to(&pagelist,
 								 vma, -1);
 			else


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
