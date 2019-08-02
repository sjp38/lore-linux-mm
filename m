Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9D54C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:39:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BB492067D
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:39:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="qtHtHKtJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BB492067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B88D46B0008; Fri,  2 Aug 2019 18:39:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B135C6B000A; Fri,  2 Aug 2019 18:39:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98C1F6B000C; Fri,  2 Aug 2019 18:39:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 747886B000A
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 18:39:49 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h47so69350502qtc.20
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 15:39:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=i3VDfrdTxe/wuzKQ7zGTLnN8YuBNc3qCXHzmo68f0Ho=;
        b=tl8iKbaE6jWkguWO61WjZ794MNFzQ1otrSOR8ZYRL+cbOk7Cw9gS3HAb9yZpFFZ0+S
         qU+nYeGcgLL19TNGT+EV+pgPC+jWV0qn24Pe6xe1ioKKu3dEHksj4e/V7HMcyG2yKnRN
         h6DOAci3Ev2oKna3Rb8o9FnGFcsbcjnBdgTKQts+6tXpij42YHD0guqY/HkTSgGyz+8R
         iZhTr2JCVvJDNTRSVqT+zDd4Pb2nFJIXAg/5K4HBzkW6VxEiV/Rtj6CWyNKGHVs0Yp1j
         wW+Io+uAOIU/5U93l2N3GMPNkwh8XXKoEdqL92wOFJs40CLj2uz/kCJpvbt/pY+Z4XqN
         a1ig==
X-Gm-Message-State: APjAAAXoC1vlKFtz+n21HxOujynRM7d8tK8vZjB0O4ktvNd3UfQMbkL3
	FI8JAo+xiZxZ0bwQMeMj8lcKAmuU9clOUzI8cW86hM1pCMZizFphjHudgDAxM2MecO6zlSnJIae
	IyFizeLoFZntbletfvey4pdwcu2buI4Y4fpXr4+uVNwEd9yXEMQlTxabgAfjnJZfidQ==
X-Received: by 2002:ac8:2e59:: with SMTP id s25mr95628995qta.94.1564785589211;
        Fri, 02 Aug 2019 15:39:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRBW5M+dOyhGG95FjrFgIAMUdmAxJsnXikkfQsPH1o48FrnSa73QMnvBRViDVgHnfesXqG
X-Received: by 2002:ac8:2e59:: with SMTP id s25mr95628970qta.94.1564785588657;
        Fri, 02 Aug 2019 15:39:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564785588; cv=none;
        d=google.com; s=arc-20160816;
        b=uu5jMfegZ6GuKwJoL0GhzuPfr3ggS44CVetdNizBSBdrzBx/BXtfagRCR0QH7lohxR
         lF+KrCMmdfd28Rq48BIjdl7o3Sghg32va3gEQZ3NRLslC9zJ5NgoqXBWsd8JPMKTd29c
         IMPhTtAOJPAdVb58WX2fdaypEWIRsXe04rc/VbqfCSEju+rGfgtE2v1kEAjhwo5vW1Bn
         S+RyX2ggjTBHKz1auZNZfzWCRaLxi2GC92Tb/u7SUPEU+Hayt51R3e9EeOeBjF5WKrwf
         hwIbYjAsUmirync8jJHzBOniDY8h+Yy44Ych4/Tff1Dz80Qm/unbUkNtIvbeseILGkI/
         n2MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=i3VDfrdTxe/wuzKQ7zGTLnN8YuBNc3qCXHzmo68f0Ho=;
        b=t0tUCVJ6W8Tbq9ONy/wAXgmMoaOV4i5xbE1aqK1XVeGVadJSkhIXDtGGAhzEcocZZP
         jcK48tU5M42nup6g4OBhyugLAJbYQyiRPdUdVfDEJr1Axt8V7+e1T0oCy5+izgOHoVTp
         kLfslGRENL4CJpK0hHQLbedW5wHxvnBezW5BePAZ/uiBy3PLfc9btB7sojdyoGT4y8dO
         vzEH0gA0egUTqb0oBGMErvA9lbFpmRv2L3HCXQVu15P3GzQcwfuXbmxOZSXe3QybtLhC
         tLK1tD4j8/vfr0mdt4lH2K168ii4dYMES7CqMgSvMCz4a+ro5BpZKclbIvCt/enEwXxk
         AqLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qtHtHKtJ;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v54si46819036qvc.169.2019.08.02.15.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 15:39:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qtHtHKtJ;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72Mcrws121628;
	Fri, 2 Aug 2019 22:39:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=i3VDfrdTxe/wuzKQ7zGTLnN8YuBNc3qCXHzmo68f0Ho=;
 b=qtHtHKtJ128Htg1F2LqpKvwARk4kkr9i/AC2+Jqiae0dYYGxU0YXHUAMVuL6SsdI23eF
 vtMk1OtPjkmmakhXOgJSrutwSiKpLSOs70/Z/N2GWdZjl3Gt5CNnNh0YjWzXmzfsuoL8
 SVHTojg9FKZGXJUElDXLv9GYD9DjPJKnfGTBG9MfJJjgu8ba1sfUr1mYXcM/mjoMe0ia
 62PPDv6Mdcvuesb7kTI6nUbTO67UBZH4zczsRu+IaaewoJNtBpv+ELs5ehLblOHq+FHF
 3rUon932rBv7RhYi9vJ7PIjGJVbfnMFSy603UEVQzUwEpp6yxH0y+rNAEMdOdWotroya iQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2u0e1ucydt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 22:39:42 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72Mbe7w019249;
	Fri, 2 Aug 2019 22:39:41 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2u49hunsqf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 22:39:41 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x72MdbLN006549;
	Fri, 2 Aug 2019 22:39:37 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 02 Aug 2019 15:39:37 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/3] mm, reclaim: make should_continue_reclaim perform dryrun detection
Date: Fri,  2 Aug 2019 15:39:28 -0700
Message-Id: <20190802223930.30971-2-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190802223930.30971-1-mike.kravetz@oracle.com>
References: <20190802223930.30971-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908020238
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908020238
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Hillf Danton <hdanton@sina.com>

Address the issue of should_continue_reclaim continuing true too often
for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
This could happen during hugetlb page allocation causing stalls for
minutes or hours.

We can stop reclaiming pages if compaction reports it can make a progress.
A code reshuffle is needed to do that. And it has side-effects, however,
with allocation latencies in other cases but that would come at the cost
of potential premature reclaim which has consequences of itself.

We can also bail out of reclaiming pages if we know that there are not
enough inactive lru pages left to satisfy the costly allocation.

We can give up reclaiming pages too if we see dryrun occur, with the
certainty of plenty of inactive pages. IOW with dryrun detected, we are
sure we have reclaimed as many pages as we could.

Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Hillf Danton <hdanton@sina.com>
Tested-by: Mike Kravetz <mike.kravetz@oracle.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 47aa2158cfac..a386c5351592 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2738,18 +2738,6 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
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
@@ -2765,7 +2753,21 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
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

