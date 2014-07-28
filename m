Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD9E6B0035
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 03:22:13 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so9400396pdb.33
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 00:22:13 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bw4si16840427pbd.160.2014.07.28.00.22.12
        for <linux-mm@kvack.org>;
        Mon, 28 Jul 2014 00:22:12 -0700 (PDT)
From: "Chen, Gong" <gong.chen@linux.intel.com>
Subject: [PATCH 1/2] APEI, GHES: Cleanup unnecessary function for lock-less list
Date: Mon, 28 Jul 2014 02:50:59 -0400
Message-Id: <1406530260-26078-2-git-send-email-gong.chen@linux.intel.com>
In-Reply-To: <1406530260-26078-1-git-send-email-gong.chen@linux.intel.com>
References: <1406530260-26078-1-git-send-email-gong.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@intel.com, n-horiguchi@ah.jp.nec.com, bp@alien8.de
Cc: linux-acpi@vger.kernel.org, linux-mm@kvack.org, "Chen, Gong" <gong.chen@linux.intel.com>

We have provided a reverse function for lock-less list so delete
uncessary codes.

Signed-off-by: Chen, Gong <gong.chen@linux.intel.com>
Acked-by: Borislav Petkov <bp@suse.de>
---
 drivers/acpi/apei/ghes.c | 18 ++----------------
 1 file changed, 2 insertions(+), 16 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index dab7cb7..1f9fba9 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -734,20 +734,6 @@ static int ghes_notify_sci(struct notifier_block *this,
 	return ret;
 }
 
-static struct llist_node *llist_nodes_reverse(struct llist_node *llnode)
-{
-	struct llist_node *next, *tail = NULL;
-
-	while (llnode) {
-		next = llnode->next;
-		llnode->next = tail;
-		tail = llnode;
-		llnode = next;
-	}
-
-	return tail;
-}
-
 static void ghes_proc_in_irq(struct irq_work *irq_work)
 {
 	struct llist_node *llnode, *next;
@@ -761,7 +747,7 @@ static void ghes_proc_in_irq(struct irq_work *irq_work)
 	 * Because the time order of estatus in list is reversed,
 	 * revert it back to proper order.
 	 */
-	llnode = llist_nodes_reverse(llnode);
+	llnode = llist_reverse_order(llnode);
 	while (llnode) {
 		next = llnode->next;
 		estatus_node = llist_entry(llnode, struct ghes_estatus_node,
@@ -794,7 +780,7 @@ static void ghes_print_queued_estatus(void)
 	 * Because the time order of estatus in list is reversed,
 	 * revert it back to proper order.
 	 */
-	llnode = llist_nodes_reverse(llnode);
+	llnode = llist_reverse_order(llnode);
 	while (llnode) {
 		estatus_node = llist_entry(llnode, struct ghes_estatus_node,
 					   llnode);
-- 
2.0.0.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
