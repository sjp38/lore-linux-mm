Subject: [RFC][PATCH 2/5] RSS accounting callbacks
Message-Id: <20070205132529.367C91B676@openx4.frec.bull.fr>
Date: Mon, 5 Feb 2007 14:25:29 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, menage@google.com
List-ID: <linux-mm.kvack.org>

Add callbacks to allocate and free instances of the controller.

Signed-off-by: Patrick Le Dot <Patrick.Le-Dot@bull.net>
---

 kernel/res_group/memctlr.c |   57 ++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 54 insertions(+), 3 deletions(-)

diff -puN a/kernel/res_group/memctlr.c b/kernel/res_group/memctlr.c
--- a/kernel/res_group/memctlr.c	2006-12-08 09:34:49.000000000 +0100
+++ b/kernel/res_group/memctlr.c	2006-12-08 09:44:15.000000000 +0100
@@ -37,6 +37,8 @@
 
 static const char res_ctlr_name[] = "memctlr";
 static struct resource_group *root_rgroup;
+static const char version[] = "0.01";
+static struct memctlr *memctlr_root;
 
 /*
  * this struct is used in mm_struct
@@ -68,14 +70,63 @@ static struct memctlr *get_memctlr(struc
 								&memctlr_rg));
 }
 
+static void memctlr_init_new(struct memctlr *res)
+{
+	res->shares.min_shares = SHARE_DONT_CARE;
+	res->shares.max_shares = SHARE_DONT_CARE;
+	res->shares.child_shares_divisor = SHARE_DEFAULT_DIVISOR;
+	res->shares.unused_min_shares = SHARE_DEFAULT_DIVISOR;
+}
+
+static struct res_shares *memctlr_alloc_instance(struct resource_group *rgroup)
+{
+	struct memctlr *res;
+
+	res = kzalloc(sizeof(struct memctlr), GFP_KERNEL);
+	if (!res)
+		return NULL;
+	memctlr_init_new(res);
+	if (is_res_group_root(rgroup)) {
+		root_rgroup = rgroup;
+		memctlr_root = res;
+		printk("Memory Controller version %s\n", version);
+	}
+	return &res->shares;
+}
+
+static void memctlr_free_instance(struct res_shares *shares)
+{
+	struct memctlr *res;
+
+	res = get_memctlr_from_shares(shares);
+	BUG_ON(!res);
+	/*
+	 * Containers do not allow removal of groups that have tasks
+	 * associated with them. To free a container, it must be empty.
+	 * Handle transfer of charges in the move_task notification
+	 */
+	kfree(res);
+}
+
+static ssize_t memctlr_show_stats(struct res_shares *shares, char *buf,
+					size_t len)
+{
+	int i = 0;
+
+	i += snprintf(buf, len, "Accounting will be added soon\n");
+	buf += i;
+	len -= i;
+	return i;
+}
+
 struct res_controller memctlr_rg = {
 	.name = res_ctlr_name,
 	.ctlr_id = NO_RES_ID,
-	.alloc_shares_struct = NULL,
-	.free_shares_struct = NULL,
+	.alloc_shares_struct = memctlr_alloc_instance,
+	.free_shares_struct = memctlr_free_instance,
 	.move_task = NULL,
 	.shares_changed = NULL,
-	.show_stats = NULL,
+	.show_stats = memctlr_show_stats,
 };
 
 int __init memctlr_init(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
