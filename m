Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2CEEC5AE59
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 20:08:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9581A21019
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 20:08:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="PsgOMFgZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9581A21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22CC96B0005; Tue, 10 Sep 2019 16:08:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DCAC6B0006; Tue, 10 Sep 2019 16:08:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CB526B0007; Tue, 10 Sep 2019 16:08:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0056.hostedemail.com [216.40.44.56])
	by kanga.kvack.org (Postfix) with ESMTP id D9EB86B0005
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:08:17 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9408E180AD7C3
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 20:08:17 +0000 (UTC)
X-FDA: 75920097834.17.scale78_dd5a9cb25363
X-HE-Tag: scale78_dd5a9cb25363
X-Filterd-Recvd-Size: 8295
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 20:08:14 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d7802b10000>; Tue, 10 Sep 2019 13:08:17 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 10 Sep 2019 13:08:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 10 Sep 2019 13:08:13 -0700
Received: from HQMAIL111.nvidia.com (172.20.187.18) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 10 Sep
 2019 20:08:13 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL111.nvidia.com
 (172.20.187.18) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Tue, 10 Sep 2019 20:08:13 +0000
Received: from ng-desktop.nvidia.com (Not Verified[10.110.48.106]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d7802ac0004>; Tue, 10 Sep 2019 13:08:12 -0700
From: Nitin Gupta <nigupta@nvidia.com>
To: <akpm@linux-foundation.org>, <vbabka@suse.cz>,
	<mgorman@techsingularity.net>, <mhocko@suse.com>, <dan.j.williams@intel.com>,
	<khalid.aziz@oracle.com>
CC: Nitin Gupta <nigupta@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Yu
 Zhao <yuzhao@google.com>, Qian Cai <cai@lca.pw>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Allison Randal <allison@lohutok.net>, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>,
	Arun KS <arunks@codeaurora.org>, Wei Yang <richard.weiyang@gmail.com>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
Subject: [PATCH] mm: Add callback for defining compaction completion
Date: Tue, 10 Sep 2019 13:07:32 -0700
Message-ID: <20190910200756.7143-1-nigupta@nvidia.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1568146097; bh=5cPjeCNYem1KL8UtK79YMpBLLRjfRCpTK43Q+R/UDig=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Transfer-Encoding:
	 Content-Type;
	b=PsgOMFgZ9300JaIQhk0hMNa/bCWXjmnsdRnC9R+fSYfPdDL6IWEFvdQxteteK6k0m
	 fUvgsIUNBIFSy/zTfv5gJBANXGod15ITQcqIkjHrDzzOwQIsciwSRhXnIBZ/izIZyc
	 y0y0lqA5dy11MDVXBwUfXvDTEnLgOQ/IfxSqG0tCjKVkC08N0iEThEzRsSXCw3oQwA
	 Lhc9IxrLt7xxeePH1fIlhil4Zs/x3/pD6uqbwALJLj2WEcslzkfXZ8zVS3tBZY0ava
	 39i0HfoFNsJvRW9sXzXSG5NuswARoWBXeXF/Va+e8mzCLdQd8lwjVJCv+Gz1hB6PeL
	 Ta9dPOF2WktEw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For some applications we need to allocate almost all memory as hugepages.
However, on a running system, higher order allocations can fail if the
memory is fragmented. Linux kernel currently does on-demand compaction as
we request more hugepages but this style of compaction incurs very high
latency. Experiments with one-time full memory compaction (followed by
hugepage allocations) shows that kernel is able to restore a highly
fragmented memory state to a fairly compacted memory state within <1 sec
for a 32G system. Such data suggests that a more proactive compaction can
help us allocate a large fraction of memory as hugepages keeping allocation
latencies low.

In general, compaction can introduce unexpected latencies for applications
that don't even have strong requirements for contiguous allocations. It is
also hard to efficiently determine if the current system state can be
easily compacted due to mixing of unmovable memory. Due to these reasons,
automatic background compaction by the kernel itself is hard to get right
in a way which does not hurt unsuspecting applications or waste CPU cycles.

Even with these caveats, pro-active compaction can still be very useful in
certain scenarios to reduce hugepage allocation latencies. This callback
interface allows drivers to drive compaction based on their own policies
like the current level of external fragmentation for a particular order,
system load etc.

Signed-off-by: Nitin Gupta <nigupta@nvidia.com>
---
 include/linux/compaction.h | 10 ++++++++++
 mm/compaction.c            | 20 ++++++++++++++------
 mm/internal.h              |  2 ++
 3 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 9569e7c786d3..1ea828450fa2 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -58,6 +58,16 @@ enum compact_result {
 	COMPACT_SUCCESS,
 };
=20
+/* Callback function to determine if compaction is finished. */
+typedef enum compact_result (*compact_finished_cb)(
+	struct zone *zone, int order);
+
+enum compact_result compact_zone_order(struct zone *zone, int order,
+		gfp_t gfp_mask, enum compact_priority prio,
+		unsigned int alloc_flags, int classzone_idx,
+		struct page **capture,
+		compact_finished_cb compact_finished_cb);
+
 struct alloc_context; /* in mm/internal.h */
=20
 /*
diff --git a/mm/compaction.c b/mm/compaction.c
index 952dc2fb24e5..73e2e9246bc4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1872,6 +1872,9 @@ static enum compact_result __compact_finished(struct =
compact_control *cc)
 			return COMPACT_PARTIAL_SKIPPED;
 	}
=20
+	if (cc->compact_finished_cb)
+		return cc->compact_finished_cb(cc->zone, cc->order);
+
 	if (is_via_compact_memory(cc->order))
 		return COMPACT_CONTINUE;
=20
@@ -2274,10 +2277,11 @@ compact_zone(struct compact_control *cc, struct cap=
ture_control *capc)
 	return ret;
 }
=20
-static enum compact_result compact_zone_order(struct zone *zone, int order=
,
+enum compact_result compact_zone_order(struct zone *zone, int order,
 		gfp_t gfp_mask, enum compact_priority prio,
 		unsigned int alloc_flags, int classzone_idx,
-		struct page **capture)
+		struct page **capture,
+		compact_finished_cb compact_finished_cb)
 {
 	enum compact_result ret;
 	struct compact_control cc =3D {
@@ -2293,10 +2297,11 @@ static enum compact_result compact_zone_order(struc=
t zone *zone, int order,
 					MIGRATE_ASYNC :	MIGRATE_SYNC_LIGHT,
 		.alloc_flags =3D alloc_flags,
 		.classzone_idx =3D classzone_idx,
-		.direct_compaction =3D true,
+		.direct_compaction =3D !compact_finished_cb,
 		.whole_zone =3D (prio =3D=3D MIN_COMPACT_PRIORITY),
 		.ignore_skip_hint =3D (prio =3D=3D MIN_COMPACT_PRIORITY),
-		.ignore_block_suitable =3D (prio =3D=3D MIN_COMPACT_PRIORITY)
+		.ignore_block_suitable =3D (prio =3D=3D MIN_COMPACT_PRIORITY),
+		.compact_finished_cb =3D compact_finished_cb
 	};
 	struct capture_control capc =3D {
 		.cc =3D &cc,
@@ -2313,11 +2318,13 @@ static enum compact_result compact_zone_order(struc=
t zone *zone, int order,
 	VM_BUG_ON(!list_empty(&cc.freepages));
 	VM_BUG_ON(!list_empty(&cc.migratepages));
=20
-	*capture =3D capc.page;
+	if (capture)
+		*capture =3D capc.page;
 	current->capture_control =3D NULL;
=20
 	return ret;
 }
+EXPORT_SYMBOL(compact_zone_order);
=20
 int sysctl_extfrag_threshold =3D 500;
=20
@@ -2361,7 +2368,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_ma=
sk, unsigned int order,
 		}
=20
 		status =3D compact_zone_order(zone, order, gfp_mask, prio,
-				alloc_flags, ac_classzone_idx(ac), capture);
+				alloc_flags, ac_classzone_idx(ac), capture,
+				NULL);
 		rc =3D max(status, rc);
=20
 		/* The allocation should succeed, stop compacting */
diff --git a/mm/internal.h b/mm/internal.h
index e32390802fd3..f873f7c2b9dc 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -11,6 +11,7 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/tracepoint-defs.h>
+#include <linux/compaction.h>
=20
 /*
  * The set of flags that only affect watermark checking and reclaim
@@ -203,6 +204,7 @@ struct compact_control {
 	bool whole_zone;		/* Whole zone should/has been scanned */
 	bool contended;			/* Signal lock or sched contention */
 	bool rescan;			/* Rescanning the same pageblock */
+	compact_finished_cb compact_finished_cb;
 };
=20
 /*
--=20
2.21.0


