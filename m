Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 679A86B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 12:07:26 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so3868556pac.17
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 09:07:24 -0700 (PDT)
Received: from mail-qa0-x24a.google.com (mail-qa0-x24a.google.com [2607:f8b0:400d:c00::24a])
        by mx.google.com with ESMTPS id v6si10515746qge.21.2014.07.31.09.07.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 09:07:23 -0700 (PDT)
Received: by mail-qa0-f74.google.com with SMTP id j15so282072qaq.3
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 09:07:23 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] dm bufio: fully initialize shrinker
Date: Thu, 31 Jul 2014 09:07:19 -0700
Message-Id: <1406822839-2423-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Dave Chinner <dchinner@redhat.com>, linux-raid@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

1d3d4437eae1 ("vmscan: per-node deferred work") added a flags field to
struct shrinker assuming that all shrinkers were zero filled.  The dm
bufio shrinker is not zero filled, which leaves arbitrary kmalloc() data
in flags.  So far the only defined flags bit is SHRINKER_NUMA_AWARE.
But there are proposed patches which add other bits to shrinker.flags
(e.g. memcg awareness).

Rather than simply initializing the shrinker, this patch uses kzalloc()
when allocating the dm_bufio_client to ensure that the embedded shrinker
and any other similar structures are zeroed.

This fixes theoretical over aggressive shrinking of dm bufio objects.
If the uninitialized dm_bufio_client.shrinker.flags contains
SHRINKER_NUMA_AWARE then shrink_slab() would call the dm shrinker for
each numa node rather than just once.  This has been broken since 3.12.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 drivers/md/dm-bufio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
index 4e84095833db..d724459860d9 100644
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -1541,7 +1541,7 @@ struct dm_bufio_client *dm_bufio_client_create(struct block_device *bdev, unsign
 	BUG_ON(block_size < 1 << SECTOR_SHIFT ||
 	       (block_size & (block_size - 1)));
 
-	c = kmalloc(sizeof(*c), GFP_KERNEL);
+	c = kzalloc(sizeof(*c), GFP_KERNEL);
 	if (!c) {
 		r = -ENOMEM;
 		goto bad_client;
-- 
2.0.0.526.g5318336

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
