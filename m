Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9D52C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3F4E2190F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:50:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lkP+47eS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3F4E2190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D93EB8E000B; Wed, 24 Jul 2019 13:50:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D466D8E0005; Wed, 24 Jul 2019 13:50:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C322C8E000B; Wed, 24 Jul 2019 13:50:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3818E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:50:34 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id p13so4782888uad.11
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:50:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NX/s/A5OLVDNZD4fNK87u3UpZfdfRBOaB3nXPLcsPas=;
        b=E3/BVO0tchn7ogJimN9dpVMOjdokSv8yq+vkJJLImwL0gEok8UePxZhe4LtFhZHnRb
         vtLSsVZ+O+P2zGwcJU3Aqqothkt1xgBRfr/slz2EssPghlJkB8xTh9lPGIdsu4cVkESz
         s5sFShbdJWAtGeW4nouePPIhtEyk1UdRUtpYsSscLfBcgdM/bWXI0qymgeyZdJWoyima
         T+q5zArT3H4feYVS8OeFNYI6CMaJGYg1BMoh6/RpPX7F7Yfvmr7dDLbc0HizbaXjDDnC
         HWO3bRrya7y1z0Gm5dcqNmKb9bnYSy/abJSbN/Bx9+XETh2ema/TEoCKqyRS/0qY3Cmv
         9nMA==
X-Gm-Message-State: APjAAAXrJhL7n6a+LX31PfC/MjVFDirMWa0yKB0iOIwWnShnMq7yi6oh
	hnuvc3BoAcqchRJQKw0YGgZSX+GpnCDo4tsB/VLWO08KOBZBGil9N90tdU/25+nQoCSAokDdRWE
	TCG32lLaWYe6ujCVTMHH1Ue06Z4Ry2Eq6clgCiukxEWMm3hU7aaEO0UM+ljOgVMYO/Q==
X-Received: by 2002:a67:d58a:: with SMTP id m10mr54727041vsj.15.1563990634285;
        Wed, 24 Jul 2019 10:50:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvRjxzKbb2lZC8ZAmdao3Mbju+kbxkxlk02s32HOzywS37mtRymLdMpj4FPlJYgCXGsuCo
X-Received: by 2002:a67:d58a:: with SMTP id m10mr54726999vsj.15.1563990633775;
        Wed, 24 Jul 2019 10:50:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563990633; cv=none;
        d=google.com; s=arc-20160816;
        b=IvceYcYVl6YYwEp18Z9dbn/ZCgVFoG4SXgPqzJoDLJWBU7pGYjOSb0YPzBU7WiGAqR
         vJ5Md/gpG3cDtl1ljPK+Nos2Wv7QpgUpwy25anoRgO7wPRVUSQmwciG1aOk38i2C8gAB
         4gYg10x+zC29ItXF4ro5jkXj/W+5F05GA9tjD7hpaH0CdW7JtaLCsjzR7b+q4PDs6P5Z
         glYvknX1hgwRc8v7p3QUYmzXmFcLuGqyeSdGQ+VdFi3P2BQgUtWU7OXkkXdnZiBULmUV
         ucnL13mSTlYzkyTDMmWI07Lsx4edzYgAIltqPVMSKC5A/qXnG0AaV/pqtzAN9z6O6mpZ
         904w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NX/s/A5OLVDNZD4fNK87u3UpZfdfRBOaB3nXPLcsPas=;
        b=ii5JnZ9luFJRXXEjjCxQgovFZNrLPuryQQKpbXmhFQRLKEP3xXHDlbl7+MCO4P+RzI
         T3v9C3g+HPPK9NZ/1o2D7XC5RHAsI3N52zpeMFmkyTYo85T0AmeSG2YY2h0RblojH8ez
         YELp56rO7NRsekSrh6FT7IGfN+iOJ7qk4rU40JtJU5mOMMU/nDqiIh+5ttsTj6XZi0Md
         ho7BSCFkbyr2tVe5ydh+9JmYpEGYMDJwM4Y8BWC1i7wLpw0p5JYo3qJl+lmjLor0VCpx
         Wvk+FrEpdZLqc3otRLgIk7gTvT57IF2gRQ+rkgboeMQ+EltViWeRKnxAYB7S3eIzcmm6
         ZBaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lkP+47eS;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u62si3167436vsu.198.2019.07.24.10.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 10:50:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lkP+47eS;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OHdfUU134750;
	Wed, 24 Jul 2019 17:50:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=NX/s/A5OLVDNZD4fNK87u3UpZfdfRBOaB3nXPLcsPas=;
 b=lkP+47eSi6lNelJK4kH8PvDDkmDI4KwgfHOhbC5Lp/E4hBF1MY44i5mbaW+evRfZPfVk
 R0E2hYBeVSx9InL7HjrmIAPY9jsoPtf007rUUpbwwU4kMeu5SwrRL/OaqngDPPnDxpRy
 AejMJlnkqk7kWLvjxvzRIKfTgu0PhLBMNO6svrheEboBLTglFaBcAp8E2cYbg0nGn284
 JFJedRP7waYMAXMhlD29ywDn9b0RVde89rNmiQn3yImeq7Z8T8QNjtY/7dNVqr76HLnN
 PdLeHUc6OyBQYDGzt2p6cj94UzzJYNWaB+pds0fvtZPlZ+ppJhobynJmlWoICT2GKsSF 4w== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2tx61by15s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 17:50:29 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OHcEMc018710;
	Wed, 24 Jul 2019 17:50:28 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2tx60xv7j9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 17:50:28 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6OHoPsb022353;
	Wed, 24 Jul 2019 17:50:25 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 24 Jul 2019 10:50:25 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
        Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim perform dryrun detection
Date: Wed, 24 Jul 2019 10:50:12 -0700
Message-Id: <20190724175014.9935-2-mike.kravetz@oracle.com>
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
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Hillf Danton <hdanton@sina.com>

Address the issue of should_continue_reclaim continuing true too often
for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
This could happen during hugetlb page allocation causing stalls for
minutes or hours.

Restructure code so that false will be returned in this case even if
there are plenty of inactive pages.

Need better description from Hillf Danton
Need SOB from Hillf Danton
---
 mm/vmscan.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f4fd02ae233e..484b6b1a954e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2673,18 +2673,6 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 			return false;
 	}
 
-	/*
-	 * If we have not reclaimed enough pages for compaction and the
-	 * inactive lists are large enough, continue reclaiming
-	 */
-	pages_for_compaction = compact_gap(sc->order);
-	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
-	if (get_nr_swap_pages() > 0)
-		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
-	if (sc->nr_reclaimed < pages_for_compaction &&
-			inactive_lru_pages > pages_for_compaction)
-		return true;
-
 	/* If compaction would go ahead or the allocation would succeed, stop */
 	for (z = 0; z <= sc->reclaim_idx; z++) {
 		struct zone *zone = &pgdat->node_zones[z];
@@ -2700,7 +2688,21 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 			;
 		}
 	}
-	return true;
+
+	/*
+	 * If we have not reclaimed enough pages for compaction and the
+	 * inactive lists are large enough, continue reclaiming
+	 */
+	pages_for_compaction = compact_gap(sc->order);
+	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
+	if (get_nr_swap_pages() > 0)
+		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
+
+	return inactive_lru_pages > pages_for_compaction &&
+		/*
+		 * avoid dryrun with plenty of inactive pages
+		 */
+		nr_scanned && nr_reclaimed;
 }
 
 static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
-- 
2.20.1

