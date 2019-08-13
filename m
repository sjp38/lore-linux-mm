Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E7AFC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 01:40:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 890A3206A2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 01:40:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="oS74yJ1H";
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nofqohuo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 890A3206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D12CB6B0005; Mon, 12 Aug 2019 21:40:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC3806B0006; Mon, 12 Aug 2019 21:40:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8AD76B0007; Mon, 12 Aug 2019 21:40:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0004.hostedemail.com [216.40.44.4])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6986B0005
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:40:43 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2F31B37E1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:40:43 +0000 (UTC)
X-FDA: 75815700366.29.toad33_4065bb53e0955
X-HE-Tag: toad33_4065bb53e0955
X-Filterd-Recvd-Size: 17353
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:40:42 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7D1delh194811;
	Tue, 13 Aug 2019 01:40:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2019-08-05;
 bh=W7olyqMEnKkatUqz1lQyWN3evuwwaasu9s6VIUHKsQ8=;
 b=oS74yJ1HzTk3k/0/Vx4Au/r7pQfcRQF50hVFvrj9hNF1IXD/SVOyKYVth8cm0WEweqlT
 pZCBVObu4sI/NtzZIYrOtuLCdfFcZhEpcNkcTjRWQY+z3d4RGBOaN7tgtYz8WlVk3JHG
 bRYQXSwgsQiMgB3PkDH5n0ZdbTwAer7rwwb/rufiBcLWy4wSS3SYL8YPfNdDmo9BP1Cd
 nxBQo7cWyWsd2FL+2HrgBiBDpAni2sIazP9In364iLzA1SIDjQ8eKPpta/ffEkMTAaiJ
 3CDp04RpryX9wF/trwtqWhJXHE51TXf+p0Fn9VIfnliEHGg5uUkmnbb/oPXFlNs3dLsG hw== 
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=W7olyqMEnKkatUqz1lQyWN3evuwwaasu9s6VIUHKsQ8=;
 b=nofqohuov3BP+Cc9QNke9ajQeTqL8hus5PbtpQG5mUay3H1CIzmwiqXxqJtkPZ6qV9WU
 Qy4cTX5nFYkCmdMGoNQV+LRI85AJYQM/TQTvyOMy4BgFgTNTaZpSxywR8qbp5B/dkcvC
 97kqr/mWN4DkpGjbcI4g3E1h5ZDzMSkcArPeV+uvgki6uDLp5CUitHhkwOttY8D1jBvk
 3SbXBq/x50GrfMHHelCMEcIeA5dmv6FNk05NhsUk5qqMwJFkGBLJeXeYbQGX+HITFyE2
 Ev/6YBhlk++rZKJbpfxp0nIQ2GOVIsoA5HC9M62/rAlB3fmMJnPrAcKtMVicP6WWmswh 4Q== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2u9nbtb1gp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 13 Aug 2019 01:40:35 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7D1cZPR138460;
	Tue, 13 Aug 2019 01:40:34 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2u9m0asa3d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 13 Aug 2019 01:40:34 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7D1eUDM014871;
	Tue, 13 Aug 2019 01:40:30 GMT
Received: from concerto.internal (/10.154.133.246)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 12 Aug 2019 18:40:29 -0700
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
Subject: [RFC PATCH 1/2] mm: Add trend based prediction algorithm for memory usage
Date: Mon, 12 Aug 2019 19:40:11 -0600
Message-Id: <20190813014012.30232-2-khalid.aziz@oracle.com>
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
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908130015
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Direct page reclamation and compaction have high and unpredictable
latency costs for applications. This patch adds code to predict if
system is about to run out of free memory by watching the historical
memory consumption trends. It computes a best fit line to this
historical data using method of least squares. it can then compute if
system will run out of memory if the current trend continues.
Historical data is held in a new data structure lsq_struct for each
zone and each order within the zone. Size of the window for historical
data is given by LSQ_LOOKBACK.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
Reviewed-by: Vandana BN <bnvandana@gmail.com>
---
 include/linux/mmzone.h |  34 +++++
 mm/Makefile            |   2 +-
 mm/lsq.c               | 273 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 308 insertions(+), 1 deletion(-)
 create mode 100644 mm/lsq.c

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d77d717c620c..9a0e5cab7171 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -355,6 +355,38 @@ struct per_cpu_nodestat {
=20
 #endif /* !__GENERATING_BOUNDS.H */
=20
+/*
+ * Size of lookback window for the free memory exhaustion prediction
+ * algorithm. Keep it to less than 16 to keep data manageable
+ */
+#define LSQ_LOOKBACK 8
+
+/*
+ * How far forward to look when determining if memory exhaustion would
+ * become an issue.
+ */
+extern unsigned long mempredict_threshold;
+
+/*
+ * Structure to keep track of current values required to compute the bes=
t
+ * fit line using method of least squares
+ */
+struct lsq_struct {
+	bool ready;
+	int next;
+	u64 x[LSQ_LOOKBACK];
+	unsigned long y[LSQ_LOOKBACK];
+};
+
+struct frag_info {
+	unsigned long free_pages;
+	unsigned long time;
+};
+
+/* Possile bits to be set by mem_predict in its return value */
+#define MEMPREDICT_RECLAIM	0x01
+#define MEMPREDICT_COMPACT	0x02
+
 enum zone_type {
 #ifdef CONFIG_ZONE_DMA
 	/*
@@ -581,6 +613,8 @@ enum zone_flags {
 					 */
 };
=20
+extern int mem_predict(struct frag_info *frag_vec, struct zone *zone);
+
 static inline unsigned long zone_managed_pages(struct zone *zone)
 {
 	return (unsigned long)atomic_long_read(&zone->managed_pages);
diff --git a/mm/Makefile b/mm/Makefile
index 338e528ad436..fb7b3c19dd13 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -39,7 +39,7 @@ obj-y			:=3D filemap.o mempool.o oom_kill.o fadvise.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o vmacache.o \
 			   interval_tree.o list_lru.o workingset.o \
-			   debug.o gup.o $(mmu-y)
+			   debug.o gup.o lsq.o $(mmu-y)
=20
 # Give 'page_alloc' its own module-parameter namespace
 page-alloc-y :=3D page_alloc.o
diff --git a/mm/lsq.c b/mm/lsq.c
new file mode 100644
index 000000000000..6005a2b2f44d
--- /dev/null
+++ b/mm/lsq.c
@@ -0,0 +1,273 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * lsq.c: Provide a prediction on whether free memory exhaustion is
+ *	imminent or not by using a best fit line based upon method of
+ *	least squares. Best fit line is based upon recent historical
+ *	data. This historical data forms the lookback window for the
+ *	algorithm.
+ *
+ *
+ * Author: Robert Harris
+ * Author: Khalid Aziz <khalid.aziz@oracle.com>
+ *
+ * Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved=
.
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This code is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 only, as
+ * published by the Free Software Foundation.
+ *
+ * This code is distributed in the hope that it will be useful, but WITH=
OUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * version 2 for more details (a copy is included in the LICENSE file th=
at
+ * accompanied this code).
+ *
+ * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 U=
SA
+ * or visit www.oracle.com if you need additional information or have an=
y
+ * questions.
+ *
+ */
+
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/math64.h>
+
+/*
+ * How far forward to look when determining if fragmentation would
+ * become an issue. The unit for this is same as the unit for the
+ * x-axis of graph where sample points for memory utilization are being
+ * plotted. We start with a default value of 1000 units but can tweak it
+ * dynamically to get better prediction results. With data points for
+ * memory being gathered with granularity of milliseconds, this translat=
es
+ * to a look ahead of 1 second. If system is 1 second away from severe
+ * fragmentation, start compaction now to avoid direct comapction.
+ */
+unsigned long mempredict_threshold =3D 1000;
+
+/*
+ * Threshold for number of free pages that should trigger reclamation,
+ * expressed as percentage of total number of pages
+ */
+#define MEMRECLAMATION_THRESHOLD	20
+
+/*
+ * This function inserts the given value into the list of most recently =
seen
+ * data and returns the parameters, m and c, of a straight line of the f=
orm
+ * y =3D (mx/100) + c that, according to the the method of least squares
+ * fits them best. This implementation looks at just the last few data p=
oints
+ * (lookback window) which allows for fixed amount of storage required f=
or
+ * data points and a nearly fixed time to calculate best fit line. Using
+ * line equation of the form y=3D(mx/100)+c instead of y=3Dmx+c allows u=
s to
+ * avoid floating point operations since m can be fractional often.
+ */
+static int
+lsq_fit(struct lsq_struct *lsq, unsigned long new_y, u64 new_x,
+	long long *m, long long *c)
+{
+	u64 sigma_x, sigma_y;
+	u64 sigma_xy, sigma_xx;
+	long long slope_divisor;
+	int i, next;
+	u64 x_offset;
+
+	next =3D lsq->next++;
+	lsq->x[next] =3D new_x;
+	lsq->y[next] =3D new_y;
+
+	if (lsq->next =3D=3D LSQ_LOOKBACK) {
+		lsq->next =3D 0;
+		/*
+		 * Lookback window is fill which means a reasonable
+		 * best fit line can be computed. Flag enough data
+		 * is available in lookback window now.
+		 */
+		lsq->ready =3D true;
+	}
+
+	/*
+	 * If lookback window is not full, do not continue with
+	 * computing slope and intercept of best fit line.
+	 */
+	if (!lsq->ready)
+		return -1;
+
+	/*
+	 * If lookback window is full, compute slope and intercept
+	 * for the best fit line. In the process of computing those, we need
+	 * to compute squares of values along x-axis. Sqaure values can be
+	 * large enough to overflow 64-bits if they are large enough to
+	 * begin with. To solve this problem, transform the line on
+	 * x-axis so the first point falls at x=3D0. Since lsq->x is a
+	 * circular buffer, lsq->next points to the oldest entry in this
+	 * buffer.
+	 */
+	x_offset =3D lsq->x[lsq->next];
+	for (i =3D 0; i < LSQ_LOOKBACK; i++)
+		lsq->x[i] -=3D x_offset;
+
+	/*
+	 * Lookback window is full. Compute slope and intercept
+	 * for the best fit line
+	 */
+	sigma_x =3D sigma_y =3D sigma_xy =3D sigma_xx =3D 0;
+	for (i =3D 0; i < LSQ_LOOKBACK; i++) {
+		sigma_x +=3D lsq->x[i];
+		sigma_y +=3D lsq->y[i];
+		sigma_xy +=3D (lsq->x[i] * lsq->y[i]);
+		sigma_xx +=3D (lsq->x[i] * lsq->x[i]);
+	}
+
+	/*
+	 * guard against divide-by-zero
+	 */
+	slope_divisor =3D LSQ_LOOKBACK * sigma_xx - sigma_x * sigma_x;
+	if (slope_divisor =3D=3D 0)
+		return -1;
+	*m =3D div64_s64(((LSQ_LOOKBACK * sigma_xy - sigma_x * sigma_y) * 100),
+			slope_divisor);
+
+	*c =3D div64_long((sigma_y - *m * sigma_x), LSQ_LOOKBACK);
+
+	/*
+	 * Restore original values for x-axis
+	 */
+	for (i =3D 0; i < LSQ_LOOKBACK; ++i)
+		lsq->x[i] +=3D x_offset;
+
+	return 0;
+}
+
+/*
+ * This function determines whether it is necessary to begin
+ * reclamation/compaction now in order to avert exhaustion of any of the
+ * free lists.
+ *
+ * Its basis is a simple model in which the total free memory, f_T, is
+ * consumed at a constant rate, R_T, i.e.
+ *
+ *	f_T(t) =3D R_T * t + f_T(0)
+ *
+ * For any given order, o > 0, members of subordinate lists constitute
+ * fragmented free memory, f_f(o): the blocks are notionally free but
+ * they are unavailable for allocation. The fragmented free memory is
+ * also assumed to behave linearly and in the absence of compaction is
+ * given by
+ *
+ *	f_f(o, t) =3D R_f(o) t + f_f(o, 0)
+ *
+ * Order 0 function represents current trend line for total free pages
+ * instead.
+ *
+ * It is assumed that all allocations will be made from contiguous
+ * memory meaning that, under net memory pressure and with no change in
+ * fragmentation, f_T will become equal to f_f and subsequent allocation=
s
+ * will stall in either direct compaction or reclaim. Preemptive compact=
ion
+ * will delay the onset of exhaustion but, to be useful, must begin earl=
y
+ * enough and must proceed at a sufficient rate.
+ *
+ * On each invocation, this function obtains estimates for the
+ * parameters f_T(0), R_T, f_f(o, 0) and R_f(o). Using the best fit
+ * line, it then determines if reclamation or compaction should be start=
ed
+ * now to avert free pages exhaustion or severe fragmentation. Return va=
lue
+ * is a set of bits which represent which condition has been observed -
+ * potential free memory exhaustion, and potential severe fragmentation.
+ */
+int mem_predict(struct frag_info *frag_vec, struct zone *zone)
+{
+	int order, retval =3D 0;
+	long long m[MAX_ORDER];
+	long long c[MAX_ORDER];
+	bool is_ready =3D true;
+	long long x_cross;
+	struct lsq_struct *lsq =3D zone->mem_prediction;
+
+	/*
+	 * Compute the trend line for fragmentation on each order page.
+	 * For order 0 pages, it will be a trend line showing rate
+	 * of consumption of pages. For higher order pages, trend line
+	 * shows loss/gain of pages of that order. When the trend line
+	 * for example for order n pages intersects with trend line for
+	 * total free pages, it means all available pages are of order
+	 * (n-1) or lower and there is 100% fragmentation of order n
+	 * pages. Kernel must compact pages at this point to gain
+	 * new order n pages.
+	 */
+	for (order =3D 0; order < MAX_ORDER; order++) {
+		if (lsq_fit(&lsq[order], frag_vec[order].free_pages,
+				frag_vec[order].time, &m[order],
+				&c[order]) =3D=3D -1)
+			is_ready =3D false;
+	}
+
+	if (!is_ready)
+		return 0;
+
+	/*
+	 * Trend line for each order page is available now. If the trend
+	 * line for overall free pages is trending upwards (positive
+	 * slope), there is no need to reclaim pages but there may be
+	 * need to compact pages if system is running out of contiguous pages
+	 * for higher orders.
+	 */
+	if (m[0] >=3D 0) {
+		for (order =3D 1; order < MAX_ORDER; order++) {
+			/*
+			 * If lines are parallel, then they never intersect.
+			 */
+			if (m[0] =3D=3D m[order])
+				continue;
+			/*
+			 * Find the point of intersection of the two lines.
+			 * The point of intersection represents 100%
+			 * fragmentation for this order.
+			 */
+			x_cross =3D div64_s64(((c[0] - c[order]) * 100),
+					(m[order] - m[0]));
+
+			/*
+			 * If they intersect anytime soon in the future
+			 * or intersected recently in the past, then it
+			 * is time for compaction and there is no need
+			 * to continue evaluating remaining order pages
+			 *
+			 * TODO: Instead of a fixed time threshold,
+			 * track compaction rate on the system and compute
+			 * how soon should compaction be started with the
+			 * current compaction rate to avoid direct
+			 * compaction
+			 */
+			if ((x_cross < mempredict_threshold) &&
+				(x_cross > -mempredict_threshold)) {
+				retval |=3D MEMPREDICT_COMPACT;
+				return retval;
+			}
+		}
+	} else {
+		unsigned long threshold;
+
+		/*
+		 * Trend line for overall free pages is showing a
+		 * negative trend. Check if less than threshold
+		 * pages are free. If so, start reclamation now to stave
+		 * off memory exhaustion
+		 *
+		 * TODO: This is not the best way to use trend analysis.
+		 * The right way to determine if it is time to start
+		 * reclamation to avoid memory exhaustion is to compute
+		 * how far away is exhaustion (least square fit
+		 * line can provide that) and what is the average rate of
+		 * memory reclamation. Using those two rates, compute how
+		 * far in advance of exhaustion should reclamation be
+		 * started to avoid exhaustion. This can be done after
+		 * additional code has been added to keep track of current
+		 * rate of reclamation.
+		 */
+		threshold =3D (zone_managed_pages(zone)*MEMRECLAMATION_THRESHOLD)
+				/100;
+		if (frag_vec[0].free_pages < threshold)
+			retval |=3D MEMPREDICT_RECLAIM;
+	}
+
+	return retval;
+}
--=20
2.20.1


