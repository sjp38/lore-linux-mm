Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D32CF6B0262
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 20:07:35 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v67so75584826pfv.1
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 17:07:35 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y6si41974292pfy.74.2016.09.07.09.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 09:47:04 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v3 02/10] mm, memcg: Add swap_cgroup_iter iterator
Date: Wed,  7 Sep 2016 09:46:01 -0700
Message-Id: <1473266769-2155-3-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

The swap cgroup uses a kind of discontinuous array to record the
information for the swap entries.  lookup_swap_cgroup() provides a good
encapsulation to access one element of the discontinuous array.  To make
it easier to access multiple elements of the discontinuous array, an
iterator for the swap cgroup named swap_cgroup_iter is added in this
patch.

This will be used for transparent huge page (THP) swap support.  Where
the swap_cgroup for multiple swap entries will be changed together.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swap_cgroup.c | 63 ++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 47 insertions(+), 16 deletions(-)

diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
index 310ac0b..4ae3e7b 100644
--- a/mm/swap_cgroup.c
+++ b/mm/swap_cgroup.c
@@ -18,6 +18,13 @@ struct swap_cgroup {
 };
 #define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
 
+struct swap_cgroup_iter {
+	struct swap_cgroup_ctrl *ctrl;
+	struct swap_cgroup *sc;
+	swp_entry_t entry;
+	unsigned long flags;
+};
+
 /*
  * SwapCgroup implements "lookup" and "exchange" operations.
  * In typical usage, this swap_cgroup is accessed via memcg's charge/uncharge
@@ -75,6 +82,35 @@ static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
 	return sc + offset % SC_PER_PAGE;
 }
 
+static void swap_cgroup_iter_init(struct swap_cgroup_iter *iter,
+				  swp_entry_t ent)
+{
+	iter->entry = ent;
+	iter->sc = lookup_swap_cgroup(ent, &iter->ctrl);
+	spin_lock_irqsave(&iter->ctrl->lock, iter->flags);
+}
+
+static void swap_cgroup_iter_exit(struct swap_cgroup_iter *iter)
+{
+	spin_unlock_irqrestore(&iter->ctrl->lock, iter->flags);
+}
+
+/*
+ * swap_cgroup is stored in a kind of discontinuous array.  That is,
+ * they are continuous in one page, but not across page boundary.  And
+ * there is one lock for each page.
+ */
+static void swap_cgroup_iter_advance(struct swap_cgroup_iter *iter)
+{
+	iter->sc++;
+	iter->entry.val++;
+	if (!(((unsigned long)iter->sc) & PAGE_MASK)) {
+		spin_unlock_irqrestore(&iter->ctrl->lock, iter->flags);
+		iter->sc = lookup_swap_cgroup(iter->entry, &iter->ctrl);
+		spin_lock_irqsave(&iter->ctrl->lock, iter->flags);
+	}
+}
+
 /**
  * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
  * @ent: swap entry to be cmpxchged
@@ -87,20 +123,18 @@ static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
 unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
 					unsigned short old, unsigned short new)
 {
-	struct swap_cgroup_ctrl *ctrl;
-	struct swap_cgroup *sc;
-	unsigned long flags;
+	struct swap_cgroup_iter iter;
 	unsigned short retval;
 
-	sc = lookup_swap_cgroup(ent, &ctrl);
+	swap_cgroup_iter_init(&iter, ent);
 
-	spin_lock_irqsave(&ctrl->lock, flags);
-	retval = sc->id;
+	retval = iter.sc->id;
 	if (retval == old)
-		sc->id = new;
+		iter.sc->id = new;
 	else
 		retval = 0;
-	spin_unlock_irqrestore(&ctrl->lock, flags);
+
+	swap_cgroup_iter_exit(&iter);
 	return retval;
 }
 
@@ -114,18 +148,15 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
  */
 unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
 {
-	struct swap_cgroup_ctrl *ctrl;
-	struct swap_cgroup *sc;
+	struct swap_cgroup_iter iter;
 	unsigned short old;
-	unsigned long flags;
 
-	sc = lookup_swap_cgroup(ent, &ctrl);
+	swap_cgroup_iter_init(&iter, ent);
 
-	spin_lock_irqsave(&ctrl->lock, flags);
-	old = sc->id;
-	sc->id = id;
-	spin_unlock_irqrestore(&ctrl->lock, flags);
+	old = iter.sc->id;
+	iter.sc->id = id;
 
+	swap_cgroup_iter_exit(&iter);
 	return old;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
