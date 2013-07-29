Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id BE8136B007B
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:19:44 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 29 Jul 2013 13:19:43 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 7B1833E40040
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:19:19 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6TJJfQu270846
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:19:41 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6TJJeGc031844
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:19:40 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 3/5] rbtree_test: add test for postorder iteration
Date: Mon, 29 Jul 2013 12:19:28 -0700
Message-Id: <1375125570-9401-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1375125570-9401-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1375125570-9401-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Just check that we examine all nodes in the tree for the postorder iteration.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
Reviewed-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 lib/rbtree_test.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
index 122f02f..31dd4cc 100644
--- a/lib/rbtree_test.c
+++ b/lib/rbtree_test.c
@@ -114,6 +114,16 @@ static int black_path_count(struct rb_node *rb)
 	return count;
 }
 
+static void check_postorder(int nr_nodes)
+{
+	struct rb_node *rb;
+	int count = 0;
+	for (rb = rb_first_postorder(&root); rb; rb = rb_next_postorder(rb))
+		count++;
+
+	WARN_ON_ONCE(count != nr_nodes);
+}
+
 static void check(int nr_nodes)
 {
 	struct rb_node *rb;
@@ -136,6 +146,8 @@ static void check(int nr_nodes)
 
 	WARN_ON_ONCE(count != nr_nodes);
 	WARN_ON_ONCE(count < (1 << black_path_count(rb_last(&root))) - 1);
+
+	check_postorder(nr_nodes);
 }
 
 static void check_augmented(int nr_nodes)
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
