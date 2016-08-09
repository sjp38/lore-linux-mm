Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7111A6B025F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:38:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so32753642pfg.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:38:17 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id r71si1655316pfb.169.2016.08.09.09.38.12
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 09:38:12 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [RFC 03/11] mm, memcg: Add swap_cgroup_iter iterator
Date: Tue,  9 Aug 2016 09:37:45 -0700
Message-Id: <1470760673-12420-4-git-send-email-ying.huang@intel.com>
In-Reply-To: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>

From: Huang Ying <ying.huang@intel.com>

Swap cgroup uses a discontinuous array to store the information for the
swap entries.  lookup_swap_cgroup() provides the good encapsulation to
access one element of the discontinuous array.  To make it easier to
access multiple elements of the discontinuous array, an iterator for
swap cgroup named swap_cgroup_iter is added in this patch.

This will be used for transparent huge page (THP) swap support.  Where
the swap_cgroup for multiple swap entries will be changed together.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swap_cgroup.c | 62 +++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 46 insertions(+), 16 deletions(-)

diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
index 310ac0b..3563b8b 100644
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
@@ -75,6 +82,34 @@ static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
 	return sc + offset % SC_PER_PAGE;
 }
 
+static void swap_cgroup_iter_init(struct swap_cgroup_iter *iter, swp_entry_t ent)
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
@@ -87,20 +122,18 @@ static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
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
 
@@ -114,18 +147,15 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
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
