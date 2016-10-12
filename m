Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D08A6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 12:10:23 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rz1so47981560pab.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 09:10:23 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h2si10004474pfg.144.2016.10.12.09.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 09:10:22 -0700 (PDT)
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9CG8bEs012107
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 09:10:22 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 261raxr23p-6
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 09:10:22 -0700
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 4d3d2b90909611e694fa0002c992ebde-327f1a50 for <linux-mm@kvack.org>;	Wed, 12
 Oct 2016 09:09:50 -0700
From: Shaohua Li <shli@fb.com>
Subject: [PATCH] vmscan: set correct defer count for shrinker
Date: Wed, 12 Oct 2016 09:09:49 -0700
Message-ID: <2414be961b5d25892060315fbb56bb19d81d0c07.1476227351.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, "v4.0+" <stable@vger.kernel.org>

Our system uses significantly more slab memory with memcg enabled with
latest kernel. With 3.10 kernel, slab uses 2G memory, while with 4.6
kernel, 6G memory is used. Looks the shrinker has problem. Let's see we
have two memcg for one shrinker. In do_shrink_slab:

1. Check cg1. nr_deferred = 0, assume total_scan = 700. batch size is 1024,
then no memory is freed. nr_deferred = 700
2. Check cg2. nr_deferred = 700. Assume freeable = 20, then total_scan = 10
or 40. Let's assume it's 10. No memory is freed. nr_deferred = 10.

The deferred share of cg1 is lost in this case. kswapd will free no
memory even run above steps again and again.

The fix makes sure one memcg's deferred share isn't lost.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org (v4.0+)
Signed-off-by: Shaohua Li <shli@fb.com>
---
 mm/vmscan.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0fe8b71..c3822ae 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -291,6 +291,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	int nid = shrinkctl->nid;
 	long batch_size = shrinker->batch ? shrinker->batch
 					  : SHRINK_BATCH;
+	long scanned = 0, next_deferred;
 
 	freeable = shrinker->count_objects(shrinker, shrinkctl);
 	if (freeable == 0)
@@ -312,7 +313,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
 		       shrinker->scan_objects, total_scan);
 		total_scan = freeable;
-	}
+		next_deferred = nr;
+	} else
+		next_deferred = total_scan;
 
 	/*
 	 * We need to avoid excessive windup on filesystem shrinkers
@@ -369,17 +372,22 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 
 		count_vm_events(SLABS_SCANNED, nr_to_scan);
 		total_scan -= nr_to_scan;
+		scanned += nr_to_scan;
 
 		cond_resched();
 	}
 
+	if (next_deferred >= scanned)
+		next_deferred -= scanned;
+	else
+		next_deferred = 0;
 	/*
 	 * move the unused scan count back into the shrinker in a
 	 * manner that handles concurrent updates. If we exhausted the
 	 * scan, there is no need to do an update.
 	 */
-	if (total_scan > 0)
-		new_nr = atomic_long_add_return(total_scan,
+	if (next_deferred > 0)
+		new_nr = atomic_long_add_return(next_deferred,
 						&shrinker->nr_deferred[nid]);
 	else
 		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
