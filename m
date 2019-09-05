Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73149C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 07:10:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 338A42168B
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 07:10:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="VTCkE6uk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 338A42168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B80D56B000C; Thu,  5 Sep 2019 03:10:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B32336B000E; Thu,  5 Sep 2019 03:10:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A205C6B0010; Thu,  5 Sep 2019 03:10:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0198.hostedemail.com [216.40.44.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1576B000C
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 03:10:55 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 08B7E3CF9
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 07:10:55 +0000 (UTC)
X-FDA: 75899994870.24.cover83_421e61ca58726
X-HE-Tag: cover83_421e61ca58726
X-Filterd-Recvd-Size: 5128
Received: from userp2120.oracle.com (userp2120.oracle.com [156.151.31.85])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 07:10:54 +0000 (UTC)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8579bpw037447;
	Thu, 5 Sep 2019 07:10:49 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : subject :
 date : message-id; s=corp-2019-08-05;
 bh=XiyjKYQy8+uJ+2ctmAZIojaWdlJs1GDac0V7FFhEAZk=;
 b=VTCkE6ukZqxP0idgbwWPMOirWqBfxyuxrhGnXxNaXS0dK+sgcs/nShj7T86CSVqZuKIy
 vOAMvlJ6WgZrOi6B6fBDXAFm2Rt7x7eRoB6DdBwl7Z0dwOdjQBd2wS27mr4YkTWZuM/8
 i5NyS2eTOKU1b93oz9+sZdcvwt2ZQSFxVEdgStT0kQdbDDrWEj2ogEJsnLJBzC7yBLCF
 TfXE6SlFQOWHAmbOgvMgtrMfrQH8RSI+WhcYY2IL3qGRoylpmyUFEHlTQqu5LEjRuC2y
 ij+VtWssz/mvcD9MVFx18BPn4lJHw/1xTKcykWI8wQsXco9l0spT8YPfjRfQUUDyWo6W Wg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2utwcf048r-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 05 Sep 2019 07:10:49 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8578bnE030485;
	Thu, 5 Sep 2019 07:10:46 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2utvr32vb7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 05 Sep 2019 07:10:45 +0000
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x857Aebo012585;
	Thu, 5 Sep 2019 07:10:41 GMT
Received: from oracle.com (/10.182.69.197)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 05 Sep 2019 00:10:40 -0700
From: Honglei Wang <honglei.wang@oracle.com>
To: linux-mm@kvack.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org,
        mhocko@kernel.org
Subject: [PATCH v2] mm/vmscan: get number of pages on the LRU list in memcgroup base on lru_zone_size
Date: Thu,  5 Sep 2019 15:10:34 +0800
Message-Id: <20190905071034.16822-1-honglei.wang@oracle.com>
X-Mailer: git-send-email 2.17.0
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9370 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1909050074
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9370 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1909050074
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

lruvec_lru_size() is involving lruvec_page_state_local() to get the
lru_size in the current code. It's base on lruvec_stat_local.count[]
of mem_cgroup_per_node. This counter is updated in batch. It won't
do charge if the number of coming pages doesn't meet the needs of
MEMCG_CHARGE_BATCH who's defined as 32 now.

The testcase in LTP madvise09[1] fails due to small block memory is
not charged. It creates a new memcgroup and sets up 32 MADV_FREE
pages. Then it forks child who will introduce memory pressure in the
memcgroup. The MADV_FREE pages are expected to be released under the
pressure, but 32 is not more than MEMCG_CHARGE_BATCH and these pages
won't be charged in lruvec_stat_local.count[] until some more pages
come in to satisfy the needs of batch charging. So these MADV_FREE
pages can't be freed in memory pressure which is a bit conflicted
with the definition of MADV_FREE.

Getting lru_size base on lru_zone_size of mem_cgroup_per_node which
is not updated in batch can make it a bit more accurate in similar
scenario.

[1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/madvise/madvise09.c

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


