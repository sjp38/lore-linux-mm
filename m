Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62E84C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:50:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C7DA2190F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:50:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nLcnZKWZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C7DA2190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68EF58E0008; Wed, 24 Jul 2019 13:50:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6193E8E0005; Wed, 24 Jul 2019 13:50:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52E618E0008; Wed, 24 Jul 2019 13:50:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 316E58E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:50:34 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id s22so42029175qtb.22
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:50:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xjcDfF8Fr9jyitkNJdHzu+KgDQ97o2yz26S0HowRWGs=;
        b=UKeUCimo2gF5Jtk+6hNU8qcg/dNaVM9Vjr3P6LsqZGAsI2h6EdR8t05bFNImBCCOcR
         eRb+vucOQQl3pXjcbGtuoUnCSIW9M7p0yGvwREOanq2IiWiZWvvJsicL8q5EojXQO9MP
         aYHUeYQVhNz34vNN/gpzZ2+/6rVFkukeeJH+wM9HLZKoHWLDCcFvv7G+XBYc/LRThsLr
         j+WE9EtqKv2fay/3FFDe3z6bK2gyVKwrl3HJbfRpi6ztqwNGZQn6PRkvpPrJ6VE8jivw
         fVhmbYP/DnINc+q+W8HPWjighBHVvc4QcQvwKCiCMtpF3unQdS+7aoFWxzSD6VmXt6rh
         m1jw==
X-Gm-Message-State: APjAAAW+kltpuCoo60vRZq8tzClZSP8WezkVaxPh5GHZyywYuA0usl9A
	lB/zmMn1VYMQD3/fTYXyrJTltOIPOSzUEcLohq4R057yxtTldg3mwdqHwWZJYofdqgzm/b8rTyH
	2kt04z36+sHrxH0GCqoDyKbAAubDlQ7UElEtdhMonoy49VdVBzcVhFzBsKSRJ3o7dvg==
X-Received: by 2002:a0c:b758:: with SMTP id q24mr59714795qve.45.1563990633856;
        Wed, 24 Jul 2019 10:50:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjXb5NzIk3WvlgThaOqwiGSiBLU3Ce6rR3O+MnJoK5IjWcExByBTpKORJCHBaDM1hh5xRB
X-Received: by 2002:a0c:b758:: with SMTP id q24mr59714764qve.45.1563990633168;
        Wed, 24 Jul 2019 10:50:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563990633; cv=none;
        d=google.com; s=arc-20160816;
        b=SwOLIeJQKTU4yb8VzA2vNMLXaW7gJ0DplZUDruPyzf2CwUY1IIhiPgmGcygUM1n3Tq
         rowRuBeT7wS332bCL8kMYeSXG6nuL4bYpee7O1OW8iH9lGjEoflQ5VnJ8GQXu1Om/l8E
         0suiI35xzyGMhXbSq17dcLpWCUesyDnKS+kshDPsR9Z7RL5uO/xceqSz1Eg0oN8wJz73
         uxgdkA5Z5wEvV2B4nBGhvn4iiUYPvth6Ft4VeTt58ckqss0/vNHqESbwMIUWNkjr9fap
         W+KHIhLihQ00/ZhMKF/wFIMxEoC4BXEvk6KccriMGaykPEv4cxTpKc7f0im0mUwAA/IH
         OFcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xjcDfF8Fr9jyitkNJdHzu+KgDQ97o2yz26S0HowRWGs=;
        b=ZLHLrPjERSBTeBf0Of69Hzg3ueLzPQXMHjqSIuzoAqV5sGhyhT5ONanunbV+3AZCbC
         qHmScVskTSzdelzA3Sgj7MvhDYBKpZRzEAyuCSPYdRmKJV/n7FDGGBdy8FxZ3MbiRuu6
         xXXCDiMXmfaxjjau4/VWkWr7GbBVW9Su5q6XBU6ZWBjA6ymlW1+JgktvrEzhkvc8ioIJ
         K7aOCE5HEMvC5sd15xNtiKDljR4NPNaYg/GPLUyuDc262pjPoQ30zdYMwk3d5RhT+dTS
         Ye4iWfJ8OcszuJWpbeoCTjlS1GZXpDBRfSSRL+BE6+SDf47xjyOy3sjMavTWEWf4Hu9v
         Em7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nLcnZKWZ;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q2si31326548qtj.247.2019.07.24.10.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 10:50:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nLcnZKWZ;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OHdh19049727;
	Wed, 24 Jul 2019 17:50:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=xjcDfF8Fr9jyitkNJdHzu+KgDQ97o2yz26S0HowRWGs=;
 b=nLcnZKWZmIDZkJO16y1rVlECVuxXnpR7rtJtjGqGPqJ2Qg/lJjudSK3kHaSvvH/9tyum
 x3e1DdU7/YablO/0JGCSCoeO4c+JYMTdssHb9oTEE87kVSmJWlTz3/UBjVUM4NmAie59
 3jJ3t5gL+10Iv1TcFHdG0j8ui5+ZL6wVfGNkR3DXw7ipvRWNkRdEI436Arvz/MGFQeGb
 Zx2x/yjd0MdD1kloFtVfjxUARVLdS2xlmvx+88n7WnxFp5Ix1giYemD4PGpdkXNzhZCM
 R/oNLLxifaajAOQkUlG5tHiMaWJng58PAMCXH0jKnU8fTlzUwMgTSVFdqrjwCWjVJg3y aQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2tx61by0ug-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 17:50:28 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OHcB6L188598;
	Wed, 24 Jul 2019 17:50:28 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2tx60y698f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 17:50:28 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6OHoRTh022364;
	Wed, 24 Jul 2019 17:50:27 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 24 Jul 2019 10:50:27 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
        Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 2/3] mm, compaction: use MIN_COMPACT_COSTLY_PRIORITY everywhere for costly orders
Date: Wed, 24 Jul 2019 10:50:13 -0700
Message-Id: <20190724175014.9935-3-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724175014.9935-1-mike.kravetz@oracle.com>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907240191
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907240191
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For PAGE_ALLOC_COSTLY_ORDER allocations, MIN_COMPACT_COSTLY_PRIORITY is
minimum (highest priority).  Other places in the compaction code key off
of MIN_COMPACT_PRIORITY.  Costly order allocations will never get to
MIN_COMPACT_PRIORITY.  Therefore, some conditions will never be met for
costly order allocations.

This was observed when hugetlb allocations could stall for minutes or
hours when should_compact_retry() would return true more often then it
should.  Specifically, this was in the case where compact_result was
COMPACT_DEFERRED and COMPACT_PARTIAL_SKIPPED and no progress was being
made.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/compaction.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 952dc2fb24e5..325b746068d1 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2294,9 +2294,15 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 		.alloc_flags = alloc_flags,
 		.classzone_idx = classzone_idx,
 		.direct_compaction = true,
-		.whole_zone = (prio == MIN_COMPACT_PRIORITY),
-		.ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY),
-		.ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY)
+		.whole_zone = ((order > PAGE_ALLOC_COSTLY_ORDER) ?
+				(prio == MIN_COMPACT_COSTLY_PRIORITY) :
+				(prio == MIN_COMPACT_PRIORITY)),
+		.ignore_skip_hint = ((order > PAGE_ALLOC_COSTLY_ORDER) ?
+				(prio == MIN_COMPACT_COSTLY_PRIORITY) :
+				(prio == MIN_COMPACT_PRIORITY)),
+		.ignore_block_suitable = ((order > PAGE_ALLOC_COSTLY_ORDER) ?
+				(prio == MIN_COMPACT_COSTLY_PRIORITY) :
+				(prio == MIN_COMPACT_PRIORITY))
 	};
 	struct capture_control capc = {
 		.cc = &cc,
@@ -2338,6 +2344,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 	int may_perform_io = gfp_mask & __GFP_IO;
 	struct zoneref *z;
 	struct zone *zone;
+	int min_priority;
 	enum compact_result rc = COMPACT_SKIPPED;
 
 	/*
@@ -2350,12 +2357,13 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, prio);
 
 	/* Compact each zone in the list */
+	min_priority = (order > PAGE_ALLOC_COSTLY_ORDER) ?
+			MIN_COMPACT_COSTLY_PRIORITY : MIN_COMPACT_PRIORITY;
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		enum compact_result status;
 
-		if (prio > MIN_COMPACT_PRIORITY
-					&& compaction_deferred(zone, order)) {
+		if (prio > min_priority && compaction_deferred(zone, order)) {
 			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
 			continue;
 		}
-- 
2.20.1

