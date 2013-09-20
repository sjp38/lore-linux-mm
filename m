Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 71EA96B0033
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 23:16:10 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so9209371pbb.0
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 20:16:10 -0700 (PDT)
From: Jonathan Brassow <jbrassow@redhat.com>
Subject: [PATCH] RAID5: Change kmem_cache name string of RAID 4/5/6 stripe cache
Date: Thu, 19 Sep 2013 22:16:00 -0500
Message-Id: <1379646960-12553-2-git-send-email-jbrassow@redhat.com>
In-Reply-To: <1379646960-12553-1-git-send-email-jbrassow@redhat.com>
References: <1379646960-12553-1-git-send-email-jbrassow@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-raid@vger.kernel.org
Cc: linux-mm@kvack.org, cl@linux.com, Jonathan Brassow <jbrassow@redhat.com>

The unique portion of the kmem_cache name used when dm-raid is creating
a RAID 4/5/6 array is the memory address of it's associated 'mddev'
structure.  This is not always unique.  The memory associated
with the 'mddev' structure can be freed and a future 'mddev' structure
can be allocated from the exact same spot.  This causes an identical
name to the old cache to be created when kmem_cache_create is called.
If an old name is still present amoung slab_caches due to cache merging,
the call will fail.  This is not theoretical, I see this regularly when
performing device-mapper RAID 4/5/6 tests (although, strangely only on
Fedora-19).

Making the unique portion of the kmem_cache name based on jiffies fixes
this problem.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
---
 drivers/md/raid5.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index 7ff4f25..f731ce9 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -1618,7 +1618,7 @@ static int grow_stripes(struct r5conf *conf, int num)
 			"raid%d-%s", conf->level, mdname(conf->mddev));
 	else
 		sprintf(conf->cache_name[0],
-			"raid%d-%p", conf->level, conf->mddev);
+			"raid%d-%llu", conf->level, get_jiffies_64());
 	sprintf(conf->cache_name[1], "%s-alt", conf->cache_name[0]);
 
 	conf->active_name = 0;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
