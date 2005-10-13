Date: Thu, 13 Oct 2005 11:49:40 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Remove policy contextualization from mbind
Message-ID: <Pine.LNX.4.62.0510131146580.16263@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Policy contextualization is only useful for task based policies and not for vma based
policies. It may be useful to define allowed nodes that are not accessible from this
thread because other threads may have access to these nodes. Without 
this patch strange memory policy situations may cause an application to 
fail with out of memory.

Example:

Lets say we have two threads A and B that share the same address
space and a huge array computational array X.

Thread A is restricted by its cpuset to nodes 0 and 1 and thread B
is restricted by its cpuset to nodes 2 and 3.

Thread A now wants to restrict allocations to the first node and thus
applies a BIND policy on X to node 0 and 2. The cpuset limits this to node
0. Thus pages for X must be allocated on node 0 now.

Thread B now touches a page that has never been used in X and faults in a
page. According to the BIND policy of the vma for X the page must be
allocated on page 0. However, the cpuset of B does not allow allocation
on 0 and 1. Now the application fails in alloc_pages with out of memory.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---

Patch is based on the memory policy layering patch that I posted 
yesterday.

Index: linux-2.6.14-rc4/mm/mempolicy.c
===================================================================
--- linux-2.6.14-rc4.orig/mm/mempolicy.c	2005-10-12 14:21:21.000000000 -0700
+++ linux-2.6.14-rc4/mm/mempolicy.c	2005-10-12 18:20:05.000000000 -0700
@@ -369,7 +369,7 @@ long do_mbind(unsigned long start, unsig
 		return -EINVAL;
 	if (end == start)
 		return 0;
-	if (contextualize_policy(mode, nmask))
+	if (mpol_check_policy(mode, nmask))
 		return -EINVAL;
 	new = mpol_new(mode, nmask);
 	if (IS_ERR(new))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
