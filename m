Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C91EEC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 08:56:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69A7A21883
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 08:56:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="rMg3sZ/s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69A7A21883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D13156B0003; Tue,  3 Sep 2019 04:56:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC2FC6B0005; Tue,  3 Sep 2019 04:56:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB1CD6B0006; Tue,  3 Sep 2019 04:56:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0155.hostedemail.com [216.40.44.155])
	by kanga.kvack.org (Postfix) with ESMTP id 997DD6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 04:56:42 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1934E180AD7C3
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 08:56:42 +0000 (UTC)
X-FDA: 75893003844.13.book34_407253bdb08
X-HE-Tag: book34_407253bdb08
X-Filterd-Recvd-Size: 4659
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 08:56:41 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x838sUmK007758;
	Tue, 3 Sep 2019 08:56:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : subject :
 date : message-id; s=corp-2019-08-05;
 bh=t0bnF2DBfJuV92/T4lzRA4Bbd3l02LzKq4g2VvZJ1yI=;
 b=rMg3sZ/sft6GLYKc9rbPP26kOw1AoRFMz4EMcBLH+QpoqqyT6sKLTWiboZa5RCF7RQPI
 2WvXJpeZPFamBdQ+Ijz4WbljDmHtAKpG9sj0TIGV2XLooa4QmBbOIwK/ijRlEqgNQwYe
 QyMBrTGJHB7FUEusXns27PXWapXspsHVYG0vBo9KhhV0RFV9bd4ZY3/s6pKQ3LCq7hdM
 kLRfWRYMlgM/MLvLuyVQXUqnWGDUcEsdtz85aXxKTO0Z0JLrmcauDUOsuICzIoJx6hXi
 ZeofU+br5WsoxUF3DQG+525obiecwjTQ/LUicCcfO1/f2aBvzxek6yYRj/QXyw5osXjx tQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2usn2q00s7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 03 Sep 2019 08:56:33 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x838rUol136085;
	Tue, 3 Sep 2019 08:54:32 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2us4wdh7yf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 03 Sep 2019 08:54:32 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x838sRbG000650;
	Tue, 3 Sep 2019 08:54:28 GMT
Received: from oracle.com (/10.182.69.197)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 03 Sep 2019 01:54:27 -0700
From: Honglei Wang <honglei.wang@oracle.com>
To: linux-mm@kvack.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org,
        mhocko@kernel.org
Subject: [PATCH] mm/vmscan: get number of pages on the LRU list in memcgroup base on lru_zone_size
Date: Tue,  3 Sep 2019 16:54:16 +0800
Message-Id: <20190903085416.12059-1-honglei.wang@oracle.com>
X-Mailer: git-send-email 2.17.0
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9368 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1909030094
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9368 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1909030094
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

lruvec_lru_size() is involving lruvec_page_state_local() to get the
lru_size in the current code. It's base on lruvec_stat_local.count[]
of mem_cgroup_per_node. This counter is updated in batch. It won't
do charge if the number of coming pages doesn't meet the needs of
MEMCG_CHARGE_BATCH who's defined as 32 now.

This causes small section of memory can't be handled as expected in
some scenario. For example, if we have only 32 pages madvise free
memory in memcgroup, these pages won't be freed as expected when it
meets memory pressure in this group.

Getting lru_size base on lru_zone_size of mem_cgroup_per_node which
is not updated in batch can make this a bit more accurate.

Signed-off-by: Honglei Wang <honglei.wang@oracle.com>
---
 mm/vmscan.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c77d1e3761a7..c28672460868 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -354,12 +354,13 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
  */
 unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone_idx)
 {
-	unsigned long lru_size;
+	unsigned long lru_size = 0;
 	int zid;
 
-	if (!mem_cgroup_disabled())
-		lru_size = lruvec_page_state_local(lruvec, NR_LRU_BASE + lru);
-	else
+	if (!mem_cgroup_disabled()) {
+		for (zid = 0; zid < MAX_NR_ZONES; zid++)
+			lru_size += mem_cgroup_get_zone_lru_size(lruvec, lru, zid);
+	} else
 		lru_size = node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
 
 	for (zid = zone_idx + 1; zid < MAX_NR_ZONES; zid++) {
-- 
2.17.0


