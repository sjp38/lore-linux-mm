Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F241A6B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 10:04:30 -0500 (EST)
Message-ID: <4B4DE0C1.7080709@suse.com>
Date: Wed, 13 Jan 2010 10:03:29 -0500
From: Jeff Mahoney <jeffm@suse.com>
MIME-Version: 1.0
Subject: [patch] hugetlb: Fix section mismatches #2
References: <20100113004855.550486769@suse.com> <20100113004938.715904356@suse.com> <alpine.DEB.2.00.1001130127450.469@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1001130127450.469@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

 hugetlb_register_node calls hugetlb_sysfs_add_hstate, which is marked with
 __init. Since hugetlb_register_node is only called by
 hugetlb_register_all_nodes, which in turn is only called by hugetlb_init,
 it's safe to mark both of them as __init.

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
---
 mm/hugetlb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1650,7 +1650,7 @@ static void hugetlb_unregister_all_nodes
  * Register hstate attributes for a single node sysdev.
  * No-op if attributes already registered.
  */
-void hugetlb_register_node(struct node *node)
+void __init hugetlb_register_node(struct node *node)
 {
 	struct hstate *h;
 	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
@@ -1683,7 +1683,7 @@ void hugetlb_register_node(struct node *
  * sysdevs of nodes that have memory.  All on-line nodes should have
  * registered their associated sysdev by this time.
  */
-static void hugetlb_register_all_nodes(void)
+static void __init hugetlb_register_all_nodes(void)
 {
 	int nid;
 
-- 
Jeff Mahoney
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
