Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j324KwRi028662
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:58 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j324KwZo073736
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:58 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j324KwWA018185
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:58 -0500
Date: Fri, 1 Apr 2005 19:13:46 -0800
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: [PATCH 3/6] CKRM: Add limit support for mem controller
Message-ID: <20050402031346.GD23284@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="aT9PWwzfKXlsBJM1"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--aT9PWwzfKXlsBJM1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------

--aT9PWwzfKXlsBJM1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=11-03-mem_core-limit

Patch 3 of 6 patches to support memory controller under CKRM framework.
This patch provides the limit support for teh controller.

 include/linux/ckrm_mem.h   |    2 
 kernel/ckrm/ckrm_memcore.c |  159 +++++++++++++++++++++++++++++++++++++++++++--
 kernel/ckrm/ckrm_memctlr.c |   16 ++++
 3 files changed, 172 insertions(+), 5 deletions(-)

Index: linux-2.6.12-rc1/include/linux/ckrm_mem.h
===================================================================
--- linux-2.6.12-rc1.orig/include/linux/ckrm_mem.h
+++ linux-2.6.12-rc1/include/linux/ckrm_mem.h
@@ -44,6 +44,8 @@ struct ckrm_mem_res {
 					 * parent if more than this is needed.
 					 */
 	int hier;			/* hiearchy level, root = 0 */
+	int impl_guar;			/* for classes with don't care guar */
+	int nr_dontcare;		/* # of dont care children */
 };
 
 extern atomic_t ckrm_mem_real_count;
Index: linux-2.6.12-rc1/kernel/ckrm/ckrm_memcore.c
===================================================================
--- linux-2.6.12-rc1.orig/kernel/ckrm/ckrm_memcore.c
+++ linux-2.6.12-rc1/kernel/ckrm/ckrm_memcore.c
@@ -95,9 +95,46 @@ mem_res_initcls_one(struct ckrm_mem_res 
 	INIT_LIST_HEAD(&res->mcls_list);
 
 	res->pg_unused = 0;
+	res->nr_dontcare = 1; /* for default class */
 	kref_init(&res->nr_users);
 }
 
+static void
+set_impl_guar_children(struct ckrm_mem_res *parres)
+{
+	struct ckrm_core_class *child = NULL;
+	struct ckrm_mem_res *cres;
+	int nr_dontcare = 1; /* for defaultclass */
+	int guar, impl_guar;
+	int resid = mem_rcbs.resid;
+
+	ckrm_lock_hier(parres->core);
+	while ((child = ckrm_get_next_child(parres->core, child)) != NULL) {
+		cres = ckrm_get_res_class(child, resid, struct ckrm_mem_res);
+		/* treat NULL cres as don't care as that child is just being
+		 * created.
+		 * FIXME: need a better way to handle this case.
+		 */
+		if (!cres || cres->pg_guar == CKRM_SHARE_DONTCARE)
+			nr_dontcare++;
+	}
+
+	parres->nr_dontcare = nr_dontcare;
+	guar = (parres->pg_guar == CKRM_SHARE_DONTCARE) ?
+			parres->impl_guar : parres->pg_unused;
+	impl_guar = guar / parres->nr_dontcare;
+
+	while ((child = ckrm_get_next_child(parres->core, child)) != NULL) {
+		cres = ckrm_get_res_class(child, resid, struct ckrm_mem_res);
+		if (cres && cres->pg_guar == CKRM_SHARE_DONTCARE) {
+			cres->impl_guar = impl_guar;
+			set_impl_guar_children(cres);
+		}
+	}
+	ckrm_unlock_hier(parres->core);
+
+}
+
 static void *
 mem_res_alloc(struct ckrm_core_class *core, struct ckrm_core_class *parent)
 {
@@ -139,14 +176,106 @@ mem_res_alloc(struct ckrm_core_class *co
 			res->pg_limit = ckrm_tot_lru_pages;
 			res->hier = 0;
 			ckrm_mem_root_class = res;
-		} else
+		} else {
+			int guar;
 			res->hier = pres->hier + 1;
+			set_impl_guar_children(pres);
+			guar = (pres->pg_guar == CKRM_SHARE_DONTCARE) ?
+				pres->impl_guar : pres->pg_unused;
+			res->impl_guar = guar / pres->nr_dontcare;
+		}
 		ckrm_nr_mem_classes++;
 	} else
 		printk(KERN_ERR "MEM_RC: alloc: GFP_ATOMIC failed\n");
 	return res;
 }
 
+/*
+ * It is the caller's responsibility to make sure that the parent only
+ * has chilren that are to be accounted. i.e if a new child is added
+ * this function should be called after it has been added, and if a
+ * child is deleted this should be called after the child is removed.
+ */
+static void
+child_maxlimit_changed_local(struct ckrm_mem_res *parres)
+{
+	int maxlimit = 0;
+	struct ckrm_mem_res *childres;
+	struct ckrm_core_class *child = NULL;
+
+	/* run thru parent's children and get new max_limit of parent */
+	ckrm_lock_hier(parres->core);
+	while ((child = ckrm_get_next_child(parres->core, child)) != NULL) {
+		childres = ckrm_get_res_class(child, mem_rcbs.resid,
+				struct ckrm_mem_res);
+		if (maxlimit < childres->shares.my_limit)
+			maxlimit = childres->shares.my_limit;
+	}
+	ckrm_unlock_hier(parres->core);
+	parres->shares.cur_max_limit = maxlimit;
+}
+
+/*
+ * Recalculate the guarantee and limit in # of pages... and propagate the
+ * same to children.
+ * Caller is responsible for protecting res and for the integrity of parres
+ */
+static void
+recalc_and_propagate(struct ckrm_mem_res * res, struct ckrm_mem_res * parres)
+{
+	struct ckrm_core_class *child = NULL;
+	struct ckrm_mem_res *cres;
+	int resid = mem_rcbs.resid;
+	struct ckrm_shares *self = &res->shares;
+
+	if (parres) {
+		struct ckrm_shares *par = &parres->shares;
+
+		/* calculate pg_guar and pg_limit */
+		if (parres->pg_guar == CKRM_SHARE_DONTCARE ||
+				self->my_guarantee == CKRM_SHARE_DONTCARE) {
+			res->pg_guar = CKRM_SHARE_DONTCARE;
+		} else if (par->total_guarantee) {
+			u64 temp = (u64) self->my_guarantee * parres->pg_guar;
+			do_div(temp, par->total_guarantee);
+			res->pg_guar = (int) temp;
+			res->impl_guar = CKRM_SHARE_DONTCARE;
+		} else {
+			res->pg_guar = 0;
+			res->impl_guar = CKRM_SHARE_DONTCARE;
+		}
+
+		if (parres->pg_limit == CKRM_SHARE_DONTCARE ||
+				self->my_limit == CKRM_SHARE_DONTCARE) {
+			res->pg_limit = CKRM_SHARE_DONTCARE;
+		} else if (par->max_limit) {
+			u64 temp = (u64) self->my_limit * parres->pg_limit;
+			do_div(temp, par->max_limit);
+			res->pg_limit = (int) temp;
+		} else
+			res->pg_limit = 0;
+	}
+
+	/* Calculate unused units */
+	if (res->pg_guar == CKRM_SHARE_DONTCARE)
+		res->pg_unused = CKRM_SHARE_DONTCARE;
+	else if (self->total_guarantee) {
+		u64 temp = (u64) self->unused_guarantee * res->pg_guar;
+		do_div(temp, self->total_guarantee);
+		res->pg_unused = (int) temp;
+	} else
+		res->pg_unused = 0;
+
+	/* propagate to children */
+	ckrm_lock_hier(res->core);
+	while ((child = ckrm_get_next_child(res->core, child)) != NULL) {
+		cres = ckrm_get_res_class(child, resid, struct ckrm_mem_res);
+		recalc_and_propagate(cres, res);
+	}
+	ckrm_unlock_hier(res->core);
+	return;
+}
+
 static void
 mem_res_free(void *my_res)
 {
@@ -161,6 +290,14 @@ mem_res_free(void *my_res)
 	pres = ckrm_get_res_class(res->parent, mem_rcbs.resid,
 			struct ckrm_mem_res);
 
+	if (pres) {
+		child_guarantee_changed(&pres->shares,
+				res->shares.my_guarantee, 0);
+		child_maxlimit_changed_local(pres);
+		recalc_and_propagate(pres, NULL);
+		set_impl_guar_children(pres);
+	}
+
 	/*
 	 * Making it all zero as freeing of data structure could 
 	 * happen later.
@@ -186,13 +323,24 @@ static int
 mem_set_share_values(void *my_res, struct ckrm_shares *shares)
 {
 	struct ckrm_mem_res *res = my_res;
+	struct ckrm_mem_res *parres;
+	int rc;
 
 	if (!res)
 		return -EINVAL;
 
-	printk(KERN_INFO "set_share called for %s resource of class %s\n",
-			MEM_RES_NAME, res->core->name);
-	return 0;
+	parres = ckrm_get_res_class(res->parent, mem_rcbs.resid,
+		struct ckrm_mem_res);
+
+	rc = set_shares(shares, &res->shares, parres ? &parres->shares : NULL);
+
+	if ((rc == 0) && (parres != NULL)) {
+		child_maxlimit_changed_local(parres);
+		recalc_and_propagate(parres, NULL);
+		set_impl_guar_children(parres);
+	}
+
+	return rc;
 }
 
 static int
Index: linux-2.6.12-rc1/kernel/ckrm/ckrm_memctlr.c
===================================================================
--- linux-2.6.12-rc1.orig/kernel/ckrm/ckrm_memctlr.c
+++ linux-2.6.12-rc1/kernel/ckrm/ckrm_memctlr.c
@@ -66,7 +66,20 @@ decr_use_count(struct ckrm_mem_res *cls,
 int
 ckrm_class_limit_ok(struct ckrm_mem_res *cls)
 {
-	return 1; /* stub for now */
+	int ret, i, pg_total = 0;
+
+	if ((mem_rcbs.resid == -1) || !cls)
+		return 1;
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		pg_total += cls->pg_total[i];
+	if (cls->pg_limit == CKRM_SHARE_DONTCARE) {
+		struct ckrm_mem_res *parcls = ckrm_get_res_class(cls->parent,
+					mem_rcbs.resid, struct ckrm_mem_res);
+		ret = (parcls ? ckrm_class_limit_ok(parcls) : 0);
+	} else
+		ret = (pg_total <= cls->pg_limit);
+
+	return ret;
 }
 
 static void migrate_list(struct list_head *list,

--aT9PWwzfKXlsBJM1--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
