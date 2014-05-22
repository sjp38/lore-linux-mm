Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id C41B66B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 05:09:46 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so2343979eei.0
        for <linux-mm@kvack.org>; Thu, 22 May 2014 02:09:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 48si14005861eeu.101.2014.05.22.02.09.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 02:09:45 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/3] fs/superblock: Avoid locking counting inodes and dentries before reclaiming them
Date: Thu, 22 May 2014 10:09:38 +0100
Message-Id: <1400749779-24879-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1400749779-24879-1-git-send-email-mgorman@suse.de>
References: <1400749779-24879-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Dave@kvack.org, "Chinner <david"@fromorbit.com, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

From: Tim Chen <tim.c.chen@linux.intel.com>

We remove the call to grab_super_passive in call to super_cache_count.
This becomes a scalability bottleneck as multiple threads are trying to do
memory reclamation, e.g. when we are doing large amount of file read and
page cache is under pressure.  The cached objects quickly got reclaimed
down to 0 and we are aborting the cache_scan() reclaim.  But counting
creates a log jam acquiring the sb_lock.

We are holding the shrinker_rwsem which ensures the safety of call to
list_lru_count_node() and s_op->nr_cached_objects.  The shrinker is
unregistered now before ->kill_sb() so the operation is safe when we are
doing unmount.

The impact will depend heavily on the machine and the workload but for a
small machine using postmark tuned to use 4xRAM size the results were

                                  3.15.0-rc5            3.15.0-rc5
                                     vanilla         shrinker-v1r1
Ops/sec Transactions         21.00 (  0.00%)       24.00 ( 14.29%)
Ops/sec FilesCreate          39.00 (  0.00%)       44.00 ( 12.82%)
Ops/sec CreateTransact       10.00 (  0.00%)       12.00 ( 20.00%)
Ops/sec FilesDeleted       6202.00 (  0.00%)     6202.00 (  0.00%)
Ops/sec DeleteTransact       11.00 (  0.00%)       12.00 (  9.09%)
Ops/sec DataRead/MB          25.97 (  0.00%)       29.10 ( 12.05%)
Ops/sec DataWrite/MB         49.99 (  0.00%)       56.02 ( 12.06%)

ffsb running in a configuration that is meant to simulate a mail server showed

                                 3.15.0-rc5             3.15.0-rc5
                                    vanilla          shrinker-v1r1
Ops/sec readall           9402.63 (  0.00%)      9567.97 (  1.76%)
Ops/sec create            4695.45 (  0.00%)      4735.00 (  0.84%)
Ops/sec delete             173.72 (  0.00%)       179.83 (  3.52%)
Ops/sec Transactions     14271.80 (  0.00%)     14482.81 (  1.48%)
Ops/sec Read                37.00 (  0.00%)        37.60 (  1.62%)
Ops/sec Write               18.20 (  0.00%)        18.30 (  0.55%)

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/super.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index a852b1a..d20d5b1 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -112,9 +112,14 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 
 	sb = container_of(shrink, struct super_block, s_shrink);
 
-	if (!grab_super_passive(sb))
-		return 0;
-
+	/*
+	 * Don't call grab_super_passive as it is a potential
+	 * scalability bottleneck. The counts could get updated
+	 * between super_cache_count and super_cache_scan anyway.
+	 * Call to super_cache_count with shrinker_rwsem held
+	 * ensures the safety of call to list_lru_count_node() and
+	 * s_op->nr_cached_objects().
+	 */
 	if (sb->s_op && sb->s_op->nr_cached_objects)
 		total_objects = sb->s_op->nr_cached_objects(sb,
 						 sc->nid);
@@ -125,7 +130,6 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 						 sc->nid);
 
 	total_objects = vfs_pressure_ratio(total_objects);
-	drop_super(sb);
 	return total_objects;
 }
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
