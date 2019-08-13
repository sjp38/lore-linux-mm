Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34058C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 01:42:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7089206A2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 01:42:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="bUnixvT+";
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="tfCtR3Jo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7089206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F7BF6B0007; Mon, 12 Aug 2019 21:42:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 680936B0008; Mon, 12 Aug 2019 21:42:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 522EC6B000A; Mon, 12 Aug 2019 21:42:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id 23A2E6B0007
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:42:40 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C1DDC181AC9B4
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:42:39 +0000 (UTC)
X-FDA: 75815705238.13.brain81_515bd36b3d80d
X-HE-Tag: brain81_515bd36b3d80d
X-Filterd-Recvd-Size: 14552
Received: from userp2120.oracle.com (userp2120.oracle.com [156.151.31.85])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:42:38 +0000 (UTC)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7D1cr3q011095;
	Tue, 13 Aug 2019 01:42:34 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2019-08-05;
 bh=AWrIfLdhfDA8NCFcIQD/AQqNushc7mLII+SffaCbHoU=;
 b=bUnixvT+jMV9WCUoG1ZoDTfqyZye4pD4HfX0SKc8NDIoAVyXOrhIjI3Y7qk3Wzb9+ueJ
 pCizaqZPgmBlZ6zotywnfH2c81NJ4pZH/ju7sP8hK5iXfQD1QrJNUj1jrRfe4ckzoxGX
 aJruVeJIg/YMwa0Vve6/NgtccPYXuNGS+PBFSOHVJJitDhUxhdtyYUyXoCIzqFlJjUVh
 BPmQUxj02vI3d6gLgwZzDYQp0uWOsO5e+XLM2ZQ76ImQRjo2KAGT1or+/UNDLLpGnQsp
 oEv3aq5P6k0fz8fQLGcgA12QScLuzrkd6BASwg9zT0pX8r5lYuvv262gagFyggYCeD4F NA== 
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=AWrIfLdhfDA8NCFcIQD/AQqNushc7mLII+SffaCbHoU=;
 b=tfCtR3JoM8K6hOhyodo3w4a953AfO/DFhLiuSD2FYGw93/gk5275PiPnKQ3mzKtd75fn
 5iW8oE9k8+49yEjeVQqgS36n8afjmK5v1K+AlzBb58vDFMEV76XZzNUd+BvtDVHJBK7w
 +DJE29O1IGT+GxYbiEOIY+Oa0sCJWwEUWC2YTC7HC4TfZ6FeS8CtlVokddj+ZdarrsBP
 mLKiIr/2k+c0MYJqOtgjG5H8E8qU8ndyrXLq/EtNmkDiOoEcGRBk04EY+Rk8JyOVelfE
 fCljOpG8Yx+1BrYtWJL1kIkWMk8AJ4ZJhkykvf80+zTppMpKJcNouux6NnpMx5doWbNy KQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2u9pjqax59-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 13 Aug 2019 01:42:34 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7D1cWd6058167;
	Tue, 13 Aug 2019 01:40:34 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2u9k1vw1nv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 13 Aug 2019 01:40:34 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7D1eWAm005147;
	Tue, 13 Aug 2019 01:40:32 GMT
Received: from concerto.internal (/10.154.133.246)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 12 Aug 2019 18:40:31 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
        mhocko@suse.com, dan.j.williams@intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, osalvador@suse.de,
        richard.weiyang@gmail.com, hannes@cmpxchg.org, arunks@codeaurora.org,
        rppt@linux.vnet.ibm.com, jgg@ziepe.ca, amir73il@gmail.com,
        alexander.h.duyck@linux.intel.com, linux-mm@kvack.org,
        linux-kernel-mentees@lists.linuxfoundation.org,
        linux-kernel@vger.kernel.org, Bharath Vedartham <linux.bhar@gmail.com>,
        Vandana BN <bnvandana@gmail.com>
Subject: [RFC PATCH 2/2] mm/vmscan: Add fragmentation and page starvation prediction to kswapd
Date: Mon, 12 Aug 2019 19:40:12 -0600
Message-Id: <20190813014012.30232-3-khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190813014012.30232-1-khalid.aziz@oracle.com>
References: <20190813014012.30232-1-khalid.aziz@oracle.com>
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9347 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908130015
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9347 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908130015
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds proactive memory reclamation to kswapd using the
free page exhaustion/fragmentation prediction based upon memory
consumption trend. It uses the least squares fit algorithm introduced
earlier for this prediction. A new function node_trend_analysis()
iterates through all zones and updates trend data in the lookback
window for least square fit algorithm. At the same time it flags any
zones that have potential for exhaustion/fragmentation by setting
ZONE_POTENTIAL_FRAG flag.

prepare_kswapd_sleep() calls node_trend_analysis() to check if the
node has potential exhaustion/fragmentation. If so, kswapd will
continue reclamataion. balance_pgdat has been modified to take
potential fragmentation into account when deciding when to wake
kcompactd up. Any zones that have potential severe fragmentation get
watermark boosted to reclaim and compact free pages proactively.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
Tested-by: Vandana BN <bnvandana@gmail.com>
---
 include/linux/mmzone.h |  38 ++++++++++++++
 mm/page_alloc.c        |  27 ----------
 mm/vmscan.c            | 116 ++++++++++++++++++++++++++++++++++++++---
 3 files changed, 148 insertions(+), 33 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9a0e5cab7171..a523476b5ce1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -587,6 +587,12 @@ struct zone {
=20
 	bool			contiguous;
=20
+	/*
+	 * Structures to use for memory consumption prediction for
+	 * each order
+	 */
+	struct lsq_struct	mem_prediction[MAX_ORDER];
+
 	ZONE_PADDING(_pad3_)
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
@@ -611,6 +617,9 @@ enum zone_flags {
 	ZONE_BOOSTED_WATERMARK,		/* zone recently boosted watermarks.
 					 * Cleared when kswapd is woken.
 					 */
+	ZONE_POTENTIAL_FRAG,		/* zone detected with a potential
+					 * external fragmentation event.
+					 */
 };
=20
 extern int mem_predict(struct frag_info *frag_vec, struct zone *zone);
@@ -1130,6 +1139,35 @@ static inline struct zoneref *first_zones_zonelist=
(struct zonelist *zonelist,
 #define for_each_zone_zonelist(zone, z, zlist, highidx) \
 	for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, NULL)
=20
+extern int watermark_boost_factor;
+
+static inline void boost_watermark(struct zone *zone)
+{
+	unsigned long max_boost;
+
+	if (!watermark_boost_factor)
+		return;
+
+	max_boost =3D mult_frac(zone->_watermark[WMARK_HIGH],
+			watermark_boost_factor, 10000);
+
+	/*
+	 * high watermark may be uninitialised if fragmentation occurs
+	 * very early in boot so do not boost. We do not fall
+	 * through and boost by pageblock_nr_pages as failing
+	 * allocations that early means that reclaim is not going
+	 * to help and it may even be impossible to reclaim the
+	 * boosted watermark resulting in a hang.
+	 */
+	if (!max_boost)
+		return;
+
+	max_boost =3D max(pageblock_nr_pages, max_boost);
+
+	zone->watermark_boost =3D min(zone->watermark_boost + pageblock_nr_page=
s,
+		max_boost);
+}
+
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 272c6de1bf4e..1b4e6ba16f1c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2351,33 +2351,6 @@ static bool can_steal_fallback(unsigned int order,=
 int start_mt)
 	return false;
 }
=20
-static inline void boost_watermark(struct zone *zone)
-{
-	unsigned long max_boost;
-
-	if (!watermark_boost_factor)
-		return;
-
-	max_boost =3D mult_frac(zone->_watermark[WMARK_HIGH],
-			watermark_boost_factor, 10000);
-
-	/*
-	 * high watermark may be uninitialised if fragmentation occurs
-	 * very early in boot so do not boost. We do not fall
-	 * through and boost by pageblock_nr_pages as failing
-	 * allocations that early means that reclaim is not going
-	 * to help and it may even be impossible to reclaim the
-	 * boosted watermark resulting in a hang.
-	 */
-	if (!max_boost)
-		return;
-
-	max_boost =3D max(pageblock_nr_pages, max_boost);
-
-	zone->watermark_boost =3D min(zone->watermark_boost + pageblock_nr_page=
s,
-		max_boost);
-}
-
 /*
  * This function implements actual steal behaviour. If order is large en=
ough,
  * we can steal whole pageblock. If not, we first move freepages in this
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 44df66a98f2a..b9cf6658c83d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -51,6 +51,7 @@
 #include <linux/printk.h>
 #include <linux/dax.h>
 #include <linux/psi.h>
+#include <linux/jiffies.h>
=20
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -3397,14 +3398,82 @@ static void clear_pgdat_congested(pg_data_t *pgda=
t)
 	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
 }
=20
+/*
+ * Update  trend data and perform trend analysis for a zone to foresee
+ * a low memory or severe fragmentation event
+ */
+static int zone_trend_analysis(struct zone *zone)
+{
+	struct frag_info frag_vec[MAX_ORDER];
+	int order, result;
+	unsigned long total_free_pages;
+	unsigned long curr_free_pages;
+
+	total_free_pages =3D frag_vec[0].free_pages =3D 0;
+	for (order =3D 0; order < MAX_ORDER; order++) {
+		curr_free_pages =3D zone->free_area[order].nr_free << order;
+		total_free_pages +=3D curr_free_pages;
+
+		if (order < MAX_ORDER - 1) {
+			frag_vec[order + 1].free_pages =3D
+				frag_vec[order].free_pages + curr_free_pages;
+			frag_vec[order + 1].time =3D
+				jiffies64_to_msecs(get_jiffies_64()
+				- INITIAL_JIFFIES);
+		}
+	}
+	frag_vec[0].free_pages =3D total_free_pages;
+	frag_vec[0].time =3D frag_vec[MAX_ORDER - 1].time;
+
+	result =3D mem_predict(frag_vec, zone);
+
+	return result;
+}
+
+/*
+ * Perform trend analysis for memory usage for each zone in the node to
+ * detect potential upcoming low memory or fragmented memory conditions
+ */
+static int node_trend_analysis(pg_data_t *pgdat, int classzone_idx)
+{
+	struct zone *zone =3D NULL;
+	int i, retval =3D 0;
+
+	for (i =3D 0; i <=3D classzone_idx; i++) {
+		int zoneval;
+
+		zone =3D pgdat->node_zones + i;
+
+		if (!managed_zone(zone))
+			continue;
+
+		/*
+		 * Check if trend analysis shows potential fragmentation
+		 * in near future
+		 */
+		zoneval =3D zone_trend_analysis(zone);
+		if (zoneval & MEMPREDICT_COMPACT)
+			set_bit(ZONE_POTENTIAL_FRAG, &zone->flags);
+		if (zoneval & MEMPREDICT_RECLAIM)
+			boost_watermark(zone);
+		retval |=3D zoneval;
+	}
+
+	return retval;
+}
+
 /*
  * Prepare kswapd for sleeping. This verifies that there are no processe=
s
  * waiting in throttle_direct_reclaim() and that watermarks have been me=
t.
+ * It also checks if this node could have a potential external fragmenta=
tion
+ * event which could lead to direct reclaim/compaction stalls.
  *
  * Returns true if kswapd is ready to sleep
  */
 static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classz=
one_idx)
 {
+	int retval;
+
 	/*
 	 * The throttled processes are normally woken up in balance_pgdat() as
 	 * soon as allow_direct_reclaim() is true. But there is a potential
@@ -3425,6 +3494,21 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat,=
 int order, int classzone_idx)
 	if (pgdat->kswapd_failures >=3D MAX_RECLAIM_RETRIES)
 		return true;
=20
+	/*
+	 * Check whether this node could have a potential memory
+	 * exhaustion in near future. If trend analysis shows such
+	 * an event occurring, don't allow kswapd to sleep so
+	 * reclamation starts now to prevent memory exhaustion. If
+	 * trend analysis shows no impending memory exhaustion but
+	 * shows impending severe fragmentation, return true to
+	 * wake up kcompactd.
+	 */
+	retval =3D node_trend_analysis(pgdat, classzone_idx);
+	if (retval & MEMPREDICT_RECLAIM)
+		return false;
+	if (retval & MEMPREDICT_COMPACT)
+		return true;
+
 	if (pgdat_balanced(pgdat, order, classzone_idx)) {
 		clear_pgdat_congested(pgdat);
 		return true;
@@ -3498,6 +3582,8 @@ static int balance_pgdat(pg_data_t *pgdat, int orde=
r, int classzone_idx)
 	unsigned long nr_boost_reclaim;
 	unsigned long zone_boosts[MAX_NR_ZONES] =3D { 0, };
 	bool boosted;
+	bool potential_frag =3D 0;
+	bool need_compact;
 	struct zone *zone;
 	struct scan_control sc =3D {
 		.gfp_mask =3D GFP_KERNEL,
@@ -3524,9 +3610,27 @@ static int balance_pgdat(pg_data_t *pgdat, int ord=
er, int classzone_idx)
=20
 		nr_boost_reclaim +=3D zone->watermark_boost;
 		zone_boosts[i] =3D zone->watermark_boost;
+
+		/*
+		 * Check if any of the zones could have a potential
+		 * fragmentation event.
+		 */
+		if (test_bit(ZONE_POTENTIAL_FRAG, &zone->flags)) {
+			potential_frag =3D 1;
+			clear_bit(ZONE_POTENTIAL_FRAG, &zone->flags);
+		}
 	}
 	boosted =3D nr_boost_reclaim;
=20
+	/*
+	 * If kswapd is woken up because of watermark boosting or forced
+	 * to run another balance_pgdat run because it detected an
+	 * external fragmentation event, run compaction after
+	 * reclaiming some pages. need_compact is true if such compaction
+	 * is required.
+	 */
+	need_compact =3D boosted || potential_frag;
+
 restart:
 	sc.priority =3D DEF_PRIORITY;
 	do {
@@ -3645,7 +3749,6 @@ static int balance_pgdat(pg_data_t *pgdat, int orde=
r, int classzone_idx)
 		 */
 		nr_reclaimed =3D sc.nr_reclaimed - nr_reclaimed;
 		nr_boost_reclaim -=3D min(nr_boost_reclaim, nr_reclaimed);
-
 		/*
 		 * If reclaim made no progress for a boost, stop reclaim as
 		 * IO cannot be queued and it could be an infinite loop in
@@ -3676,13 +3779,14 @@ static int balance_pgdat(pg_data_t *pgdat, int or=
der, int classzone_idx)
 			zone->watermark_boost -=3D min(zone->watermark_boost, zone_boosts[i])=
;
 			spin_unlock_irqrestore(&zone->lock, flags);
 		}
+	}
=20
-		/*
-		 * As there is now likely space, wakeup kcompact to defragment
-		 * pageblocks.
-		 */
+	/*
+	 * As there is now likely space, wakeup kcompactd to defragment
+	 * pageblocks.
+	 */
+	if (need_compact)
 		wakeup_kcompactd(pgdat, pageblock_order, classzone_idx);
-	}
=20
 	snapshot_refaults(NULL, pgdat);
 	__fs_reclaim_release();
--=20
2.20.1


