Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id A21C06B003A
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:23 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 26 Jul 2013 17:14:22 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id AE067C90041
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:17 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6QLEJAh157126
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:19 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6QLEH0s013440
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 18:14:18 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 3/5] rbtree_test: add test for postorder iteration
Date: Fri, 26 Jul 2013 14:13:41 -0700
Message-Id: <1374873223-25557-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Just check that we examine all nodes in the tree for the postorder iteration.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
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
