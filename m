Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 751AC6B4038
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 07:26:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g15-v6so6472349edm.11
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:26:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h30-v6sor3528010ede.57.2018.08.27.04.26.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 04:26:37 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/3] xen/gntdev: fix up blockable calls to mn_invl_range_start
Date: Mon, 27 Aug 2018 13:26:21 +0200
Message-Id: <20180827112623.8992-2-mhocko@kernel.org>
In-Reply-To: <20180827112623.8992-1-mhocko@kernel.org>
References: <20180827112623.8992-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>

From: Michal Hocko <mhocko@suse.com>

93065ac753e4 ("mm, oom: distinguish blockable mode for mmu notifiers")
has introduced blockable parameter to all mmu_notifiers and the notifier
has to back off when called in !blockable case and it could block down
the road.

The above commit implemented that for mn_invl_range_start but both
in_range checks are done unconditionally regardless of the blockable
mode and as such they would fail all the time for regular calls.
Fix this by checking blockable parameter as well.

Once we are there we can remove the stale TODO. The lock has to be
sleepable because we wait for completion down in gnttab_unmap_refs_sync.

Changes since v1
- pull in_range check into mn_invl_range_start - Juergen

Fixes: 93065ac753e4 ("mm, oom: distinguish blockable mode for mmu notifiers")
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Juergen Gross <jgross@suse.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/xen/gntdev.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 57390c7666e5..b0b02a501167 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -492,12 +492,19 @@ static bool in_range(struct gntdev_grant_map *map,
 	return true;
 }
 
-static void unmap_if_in_range(struct gntdev_grant_map *map,
-			      unsigned long start, unsigned long end)
+static int unmap_if_in_range(struct gntdev_grant_map *map,
+			      unsigned long start, unsigned long end,
+			      bool blockable)
 {
 	unsigned long mstart, mend;
 	int err;
 
+	if (!in_range(map, start, end))
+		return 0;
+
+	if (!blockable)
+		return -EAGAIN;
+
 	mstart = max(start, map->vma->vm_start);
 	mend   = min(end,   map->vma->vm_end);
 	pr_debug("map %d+%d (%lx %lx), range %lx %lx, mrange %lx %lx\n",
@@ -508,6 +515,8 @@ static void unmap_if_in_range(struct gntdev_grant_map *map,
 				(mstart - map->vma->vm_start) >> PAGE_SHIFT,
 				(mend - mstart) >> PAGE_SHIFT);
 	WARN_ON(err);
+
+	return 0;
 }
 
 static int mn_invl_range_start(struct mmu_notifier *mn,
@@ -519,25 +528,20 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
 	struct gntdev_grant_map *map;
 	int ret = 0;
 
-	/* TODO do we really need a mutex here? */
 	if (blockable)
 		mutex_lock(&priv->lock);
 	else if (!mutex_trylock(&priv->lock))
 		return -EAGAIN;
 
 	list_for_each_entry(map, &priv->maps, next) {
-		if (in_range(map, start, end)) {
-			ret = -EAGAIN;
+		ret = unmap_if_in_range(map, start, end, blockable);
+		if (ret)
 			goto out_unlock;
-		}
-		unmap_if_in_range(map, start, end);
 	}
 	list_for_each_entry(map, &priv->freeable_maps, next) {
-		if (in_range(map, start, end)) {
-			ret = -EAGAIN;
+		ret = unmap_if_in_range(map, start, end, blockable);
+		if (ret)
 			goto out_unlock;
-		}
-		unmap_if_in_range(map, start, end);
 	}
 
 out_unlock:
-- 
2.18.0
