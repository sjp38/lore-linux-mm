Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 662D86B29F2
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 08:07:44 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s54-v6so2218986eda.20
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 05:07:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z40-v6sor311198edb.43.2018.08.23.05.07.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 05:07:43 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] xen/gntdev: fix up blockable calls to mn_invl_range_start
Date: Thu, 23 Aug 2018 14:07:07 +0200
Message-Id: <20180823120707.10998-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, xen-devel@lists.xenproject.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>

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

Fixes: 93065ac753e4 ("mm, oom: distinguish blockable mode for mmu notifiers")
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Juergen Gross <jgross@suse.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/xen/gntdev.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 57390c7666e5..e7d8bb1bee2a 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -519,21 +519,20 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
 	struct gntdev_grant_map *map;
 	int ret = 0;
 
-	/* TODO do we really need a mutex here? */
 	if (blockable)
 		mutex_lock(&priv->lock);
 	else if (!mutex_trylock(&priv->lock))
 		return -EAGAIN;
 
 	list_for_each_entry(map, &priv->maps, next) {
-		if (in_range(map, start, end)) {
+		if (!blockable && in_range(map, start, end)) {
 			ret = -EAGAIN;
 			goto out_unlock;
 		}
 		unmap_if_in_range(map, start, end);
 	}
 	list_for_each_entry(map, &priv->freeable_maps, next) {
-		if (in_range(map, start, end)) {
+		if (!blockable && in_range(map, start, end)) {
 			ret = -EAGAIN;
 			goto out_unlock;
 		}
-- 
2.18.0
