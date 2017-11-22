Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35B826B02D2
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id r23so7463288pfg.17
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g78si15729199pfk.234.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 50/62] cgroup: Remove IDR wrappers
Date: Wed, 22 Nov 2017 13:07:27 -0800
Message-Id: <20171122210739.29916-51-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The IDR now behaves the way the cgroup wrappers made the IDR behave,
so the wrappers are no longer needed.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 kernel/cgroup/cgroup.c | 59 ++++++++++----------------------------------------
 1 file changed, 11 insertions(+), 48 deletions(-)

diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 351b355336d4..67b4c2aa69a9 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -80,12 +80,6 @@ EXPORT_SYMBOL_GPL(cgroup_mutex);
 EXPORT_SYMBOL_GPL(css_set_lock);
 #endif
 
-/*
- * Protects cgroup_idr and css_idr so that IDs can be released without
- * grabbing cgroup_mutex.
- */
-static DEFINE_SPINLOCK(cgroup_idr_lock);
-
 /*
  * Protects cgroup_file->kn for !self csses.  It synchronizes notifications
  * against file removal/re-creation across css hiding.
@@ -291,37 +285,6 @@ bool cgroup_on_dfl(const struct cgroup *cgrp)
 	return cgrp->root == &cgrp_dfl_root;
 }
 
-/* IDR wrappers which synchronize using cgroup_idr_lock */
-static int cgroup_idr_alloc(struct idr *idr, void *ptr, int start, int end,
-			    gfp_t gfp_mask)
-{
-	int ret;
-
-	idr_preload(gfp_mask);
-	spin_lock_bh(&cgroup_idr_lock);
-	ret = idr_alloc(idr, ptr, start, end, gfp_mask & ~__GFP_DIRECT_RECLAIM);
-	spin_unlock_bh(&cgroup_idr_lock);
-	idr_preload_end();
-	return ret;
-}
-
-static void *cgroup_idr_replace(struct idr *idr, void *ptr, int id)
-{
-	void *ret;
-
-	spin_lock_bh(&cgroup_idr_lock);
-	ret = idr_replace(idr, ptr, id);
-	spin_unlock_bh(&cgroup_idr_lock);
-	return ret;
-}
-
-static void cgroup_idr_remove(struct idr *idr, int id)
-{
-	spin_lock_bh(&cgroup_idr_lock);
-	idr_remove(idr, id);
-	spin_unlock_bh(&cgroup_idr_lock);
-}
-
 static bool cgroup_has_tasks(struct cgroup *cgrp)
 {
 	return cgrp->nr_populated_csets;
@@ -1883,7 +1846,7 @@ int cgroup_setup_root(struct cgroup_root *root, u16 ss_mask, int ref_flags)
 
 	lockdep_assert_held(&cgroup_mutex);
 
-	ret = cgroup_idr_alloc(&root->cgroup_idr, root_cgrp, 1, 2, GFP_KERNEL);
+	ret = idr_alloc(&root->cgroup_idr, root_cgrp, 1, 2, GFP_KERNEL);
 	if (ret < 0)
 		goto out;
 	root_cgrp->id = ret;
@@ -4532,7 +4495,7 @@ static void css_free_work_fn(struct work_struct *work)
 		int id = css->id;
 
 		ss->css_free(css);
-		cgroup_idr_remove(&ss->css_idr, id);
+		idr_remove(&ss->css_idr, id);
 		cgroup_put(cgrp);
 
 		if (parent)
@@ -4589,7 +4552,7 @@ static void css_release_work_fn(struct work_struct *work)
 
 	if (ss) {
 		/* css release path */
-		cgroup_idr_replace(&ss->css_idr, NULL, css->id);
+		idr_replace(&ss->css_idr, NULL, css->id);
 		if (ss->css_released)
 			ss->css_released(css);
 	} else {
@@ -4605,7 +4568,7 @@ static void css_release_work_fn(struct work_struct *work)
 		     tcgrp = cgroup_parent(tcgrp))
 			tcgrp->nr_dying_descendants--;
 
-		cgroup_idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
+		idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
 		cgrp->id = -1;
 
 		/*
@@ -4731,14 +4694,14 @@ static struct cgroup_subsys_state *css_create(struct cgroup *cgrp,
 	if (err)
 		goto err_free_css;
 
-	err = cgroup_idr_alloc(&ss->css_idr, NULL, 2, 0, GFP_KERNEL);
+	err = idr_alloc(&ss->css_idr, NULL, 2, 0, GFP_KERNEL);
 	if (err < 0)
 		goto err_free_css;
 	css->id = err;
 
 	/* @css is ready to be brought online now, make it visible */
 	list_add_tail_rcu(&css->sibling, &parent_css->children);
-	cgroup_idr_replace(&ss->css_idr, css, css->id);
+	idr_replace(&ss->css_idr, css, css->id);
 
 	err = online_css(css);
 	if (err)
@@ -4794,7 +4757,7 @@ static struct cgroup *cgroup_create(struct cgroup *parent)
 	 * Temporarily set the pointer to NULL, so idr_find() won't return
 	 * a half-baked cgroup.
 	 */
-	cgrp->id = cgroup_idr_alloc(&root->cgroup_idr, NULL, 2, 0, GFP_KERNEL);
+	cgrp->id = idr_alloc(&root->cgroup_idr, NULL, 2, 0, GFP_KERNEL);
 	if (cgrp->id < 0) {
 		ret = -ENOMEM;
 		goto out_stat_exit;
@@ -4833,7 +4796,7 @@ static struct cgroup *cgroup_create(struct cgroup *parent)
 	 * @cgrp is now fully operational.  If something fails after this
 	 * point, it'll be released via the normal destruction path.
 	 */
-	cgroup_idr_replace(&root->cgroup_idr, cgrp, cgrp->id);
+	idr_replace(&root->cgroup_idr, cgrp, cgrp->id);
 
 	/*
 	 * On the default hierarchy, a child doesn't automatically inherit
@@ -4847,7 +4810,7 @@ static struct cgroup *cgroup_create(struct cgroup *parent)
 	return cgrp;
 
 out_idr_free:
-	cgroup_idr_remove(&root->cgroup_idr, cgrp->id);
+	idr_remove(&root->cgroup_idr, cgrp->id);
 out_stat_exit:
 	if (cgroup_on_dfl(parent))
 		cgroup_stat_exit(cgrp);
@@ -5166,7 +5129,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss, bool early)
 		/* allocation can't be done safely during early init */
 		css->id = 1;
 	} else {
-		css->id = cgroup_idr_alloc(&ss->css_idr, css, 1, 2, GFP_KERNEL);
+		css->id = idr_alloc(&ss->css_idr, css, 1, 2, GFP_KERNEL);
 		BUG_ON(css->id < 0);
 	}
 
@@ -5273,7 +5236,7 @@ int __init cgroup_init(void)
 			struct cgroup_subsys_state *css =
 				init_css_set.subsys[ss->id];
 
-			css->id = cgroup_idr_alloc(&ss->css_idr, css, 1, 2,
+			css->id = idr_alloc(&ss->css_idr, css, 1, 2,
 						   GFP_KERNEL);
 			BUG_ON(css->id < 0);
 		} else {
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
