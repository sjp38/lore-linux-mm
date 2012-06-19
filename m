Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 283126B0075
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 04:38:04 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 14:08:01 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5J8bwl28126750
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:07:58 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5JE7kTS025896
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 00:07:46 +1000
Message-ID: <4FE03A55.7070503@linux.vnet.ibm.com>
Date: Tue, 19 Jun 2012 16:37:41 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 10/10] cleanup the code between tmem_obj_init and tmem_obj_find
References: <4FE0392E.3090300@linux.vnet.ibm.com>
In-Reply-To: <4FE0392E.3090300@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

tmem_obj_find and insertion tmem-obj have the some logic, we can integrate
the code

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 drivers/staging/zcache/tmem.c |   58 +++++++++++++++++++++-------------------
 1 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/zcache/tmem.c b/drivers/staging/zcache/tmem.c
index 1ca66ea..cdf2d3c 100644
--- a/drivers/staging/zcache/tmem.c
+++ b/drivers/staging/zcache/tmem.c
@@ -72,33 +72,48 @@ void tmem_register_pamops(struct tmem_pamops *m)
  * the hashbucket lock must be held.
  */

-/* searches for object==oid in pool, returns locked object if found */
-static struct tmem_obj *tmem_obj_find(struct tmem_hashbucket *hb,
-					struct tmem_oid *oidp)
+static struct tmem_obj
+*__tmem_obj_find(struct tmem_hashbucket*hb, struct tmem_oid *oidp,
+		 struct rb_node *parent, struct rb_node **link)
 {
-	struct rb_node *rbnode;
+	struct rb_node **rbnode;
 	struct tmem_obj *obj;

-	rbnode = hb->obj_rb_root.rb_node;
-	while (rbnode) {
-		BUG_ON(RB_EMPTY_NODE(rbnode));
-		obj = rb_entry(rbnode, struct tmem_obj, rb_tree_node);
+	rbnode = &hb->obj_rb_root.rb_node;
+	while (*rbnode) {
+		BUG_ON(RB_EMPTY_NODE(*rbnode));
+		obj = rb_entry(*rbnode, struct tmem_obj,
+			       rb_tree_node);
 		switch (tmem_oid_compare(oidp, &obj->oid)) {
 		case 0: /* equal */
 			goto out;
 		case -1:
-			rbnode = rbnode->rb_left;
+			rbnode = &(*rbnode)->rb_left;
 			break;
 		case 1:
-			rbnode = rbnode->rb_right;
+			rbnode = &(*rbnode)->rb_right;
 			break;
 		}
 	}
+
+	if (parent)
+		parent = &obj->rb_tree_node;
+	if (link)
+		link = rbnode;
+
 	obj = NULL;
 out:
 	return obj;
 }

+
+/* searches for object==oid in pool, returns locked object if found */
+static struct tmem_obj *tmem_obj_find(struct tmem_hashbucket *hb,
+					struct tmem_oid *oidp)
+{
+	return __tmem_obj_find(hb, oidp, NULL, NULL);
+}
+
 static void tmem_pampd_destroy_all_in_obj(struct tmem_obj *);

 /* free an object that has no more pampds in it */
@@ -131,8 +146,7 @@ static void tmem_obj_init(struct tmem_obj *obj, struct tmem_hashbucket *hb,
 					struct tmem_oid *oidp)
 {
 	struct rb_root *root = &hb->obj_rb_root;
-	struct rb_node **new = &(root->rb_node), *parent = NULL;
-	struct tmem_obj *this;
+	struct rb_node **new = NULL, *parent = NULL;

 	BUG_ON(pool == NULL);
 	atomic_inc(&pool->obj_count);
@@ -144,22 +158,10 @@ static void tmem_obj_init(struct tmem_obj *obj, struct tmem_hashbucket *hb,
 	obj->pampd_count = 0;
 	(*tmem_pamops.new_obj)(obj);
 	SET_SENTINEL(obj, OBJ);
-	while (*new) {
-		BUG_ON(RB_EMPTY_NODE(*new));
-		this = rb_entry(*new, struct tmem_obj, rb_tree_node);
-		parent = *new;
-		switch (tmem_oid_compare(oidp, &this->oid)) {
-		case 0:
-			BUG(); /* already present; should never happen! */
-			break;
-		case -1:
-			new = &(*new)->rb_left;
-			break;
-		case 1:
-			new = &(*new)->rb_right;
-			break;
-		}
-	}
+
+	if (__tmem_obj_find(hb, oidp, parent, new))
+		BUG();
+
 	rb_link_node(&obj->rb_tree_node, parent, new);
 	rb_insert_color(&obj->rb_tree_node, root);
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
