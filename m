Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABAA5C0650F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 585F120C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="D8oNjiVe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 585F120C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D49FD6B0003; Mon,  5 Aug 2019 21:48:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF9D16B0006; Mon,  5 Aug 2019 21:48:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9AC46B0008; Mon,  5 Aug 2019 21:48:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 99F746B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 21:48:11 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id m198so74172704qke.22
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fr5eyPRRWPi1rDqCT8/skQQ0aW1iOdHkBGzG8QNDcy4=;
        b=AB9LSFZ0XzLJbkkwitumNhcFBADuuMhnwCZ8OjyngChXbZjW7iMnV28a/18IV/WKTc
         4TqwiIbIc9FDgz5Q1QvUoiIrJEEF7JkaYDjP/WlAEqvr5/RN9rK5wKDnNZxdGY285ytE
         iP6+nU1AaY6y31PwmLVflpFKwxeR7UxwuwQwFOyZ0ozqca54JtgMPLnU4muINaOmNzq/
         ZeWWMunNqu9YRx/jmWW15d8O0q2d/3DgG8IStNrnYSW0F6fVnI3Yd6jWh3JLoyFHL75I
         ie2M03xBTO5wMUyNaO/mSaPccVIjvT7xdZd9bAxpn5XVZ8EBIRvDjNHK85fLgviBt76V
         amyw==
X-Gm-Message-State: APjAAAXYAZrXj5Q8KH6llBD4xG7bLOZD5EhHZUlMGnQ0n4jRhYXUh03I
	wIK8hvzGQrDT0Z7SqVrP42TZKkc5JO3+0zH9CWEXb33Cv64IS2DVmGUMGfjdafXaSCXA3VyY1ej
	j+o1+zBlI4/AirmaL7ADoaJnsVafBKPi4404N+40E6ZRGBGUwedULpguJeUTF6bKOhw==
X-Received: by 2002:ac8:2225:: with SMTP id o34mr953264qto.222.1565056091375;
        Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjZggzlt2FDTobnn3FltRTjirjtuzGfcU0BjoJg/VXB1BnJofrv0m8hZc3Ftbza3ibYAjS
X-Received: by 2002:ac8:2225:: with SMTP id o34mr953242qto.222.1565056090677;
        Mon, 05 Aug 2019 18:48:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565056090; cv=none;
        d=google.com; s=arc-20160816;
        b=bOavXC42efqLX4gAPGi9fSVoFj1Mm3O09bkRDeERCQAJ+sHZOrufSvllpt6dVWs7ew
         SDYAMIkbpeoAUxuk8wslr+yWAzFD4dc/QEH3EJYliueApqkkW9FgbxBPJBBFppjZBF2X
         +BgMQzH4rHRHIr3vP9/IzY81FkcBUvAgCjTTMxmKK0guPqlPBAGFBMvqMAxDX6bE68oW
         3/LBxZhSJyimruGG0kbukikcUQQ0UBJc4bAaaMGUgdW4LFJu8B3dngxBSc/qAtJwVocT
         No/nk9VVGPc79uJ7+3h6OZTiAHouaca0ovGaZAkIFWczz6egI/xi/bmYr/tQn7g9f0sF
         C6Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=fr5eyPRRWPi1rDqCT8/skQQ0aW1iOdHkBGzG8QNDcy4=;
        b=gGDPAg+PRSndJYZ4qUG0/FC+LLzCmn8xIyAxvOMDZa0qzWCkwmuFxQSDcXA5qINI2V
         51/mmSegUXmazUZho9eRU68JW1u3ZbYmMTVj983VpFFcer3/4Pncg3nMpYxXlKGhwt86
         D6HAeFGWd1de5fA0gxQOUckfNmStdk8vQKbyC0Q3RFX2/2dBjoxzeBTkzlo1UPHZsLtH
         wDVZiREl0c7AY/OJAP7wjRbmDSK1HQ/65jnO1BvZbOVKLAArwov4SSbV/q1MF0XSjX1w
         nVS76stRUFu/7ynbGNt2ot77uAHRMDlkKvYvfMd4Edd8SlzoiQuEXZZQ3Tm1njMl8T9T
         W+gA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=D8oNjiVe;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id q203si4347142qke.253.2019.08.05.18.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 18:48:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=D8oNjiVe;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x761jJ5f152854;
	Tue, 6 Aug 2019 01:48:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=fr5eyPRRWPi1rDqCT8/skQQ0aW1iOdHkBGzG8QNDcy4=;
 b=D8oNjiVeBbBG2MWiIYLecowUjrtkG6Oal3VR7bQ6Tq4XmhC3HUSvX6hveVydUDg+uCSf
 fKsU20yt/rHoLw6ROp/IekRVGI4s/cWGUmKBSV7E8/r7r/O2wc1tbqncE7nR6+Yu66hj
 1qJvG2d/5kbJSHgu3Un/N1D+KaOJXSGD1SzDh7SVXW6cfVCl6R6JAnJFoc4vKwwNQlqN
 s9Hb0KVzO9OZdGzBATWoa1/t84ZevYXdnjOvmoB7ZbtVUdiJTy5OA7qOqvWX8RaT+UkC
 9v6Wrar1BRo08b+nRfu68R4Ga8X0BI0eFRjdsT+zcX2559xT3mapK8BHVejeI9Dkppus Ag== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2u527pjm9r-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 01:48:06 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x761m4bW086383;
	Tue, 6 Aug 2019 01:48:05 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2u51kn4a0w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 01:48:05 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x761ludm016081;
	Tue, 6 Aug 2019 01:47:56 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 05 Aug 2019 18:47:55 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 2/4] mm, reclaim: cleanup should_continue_reclaim()
Date: Mon,  5 Aug 2019 18:47:42 -0700
Message-Id: <20190806014744.15446-3-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806014744.15446-1-mike.kravetz@oracle.com>
References: <20190806014744.15446-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060020
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060019
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Vlastimil Babka <vbabka@suse.cz>

After commit "mm, reclaim: make should_continue_reclaim perform dryrun
detection", closer look at the function shows, that nr_reclaimed == 0
means the function will always return false. And since non-zero
nr_reclaimed implies non_zero nr_scanned, testing nr_scanned serves no
purpose, and so does the testing for __GFP_RETRY_MAYFAIL.

This patch thus cleans up the function to test only !nr_reclaimed upfront,
and remove the __GFP_RETRY_MAYFAIL test and nr_scanned parameter
completely.  Comment is also updated, explaining that approximating "full
LRU list has been scanned" with nr_scanned == 0 didn't really work.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
Commit message reformatted to avoid line wrap.

 mm/vmscan.c | 43 ++++++++++++++-----------------------------
 1 file changed, 14 insertions(+), 29 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a386c5351592..227d10cd704b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2704,7 +2704,6 @@ static bool in_reclaim_compaction(struct scan_control *sc)
  */
 static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 					unsigned long nr_reclaimed,
-					unsigned long nr_scanned,
 					struct scan_control *sc)
 {
 	unsigned long pages_for_compaction;
@@ -2715,28 +2714,18 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	if (!in_reclaim_compaction(sc))
 		return false;
 
-	/* Consider stopping depending on scan and reclaim activity */
-	if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
-		/*
-		 * For __GFP_RETRY_MAYFAIL allocations, stop reclaiming if the
-		 * full LRU list has been scanned and we are still failing
-		 * to reclaim pages. This full LRU scan is potentially
-		 * expensive but a __GFP_RETRY_MAYFAIL caller really wants to succeed
-		 */
-		if (!nr_reclaimed && !nr_scanned)
-			return false;
-	} else {
-		/*
-		 * For non-__GFP_RETRY_MAYFAIL allocations which can presumably
-		 * fail without consequence, stop if we failed to reclaim
-		 * any pages from the last SWAP_CLUSTER_MAX number of
-		 * pages that were scanned. This will return to the
-		 * caller faster at the risk reclaim/compaction and
-		 * the resulting allocation attempt fails
-		 */
-		if (!nr_reclaimed)
-			return false;
-	}
+	/*
+	 * Stop if we failed to reclaim any pages from the last SWAP_CLUSTER_MAX
+	 * number of pages that were scanned. This will return to the caller
+	 * with the risk reclaim/compaction and the resulting allocation attempt
+	 * fails. In the past we have tried harder for __GFP_RETRY_MAYFAIL
+	 * allocations through requiring that the full LRU list has been scanned
+	 * first, by assuming that zero delta of sc->nr_scanned means full LRU
+	 * scan, but that approximation was wrong, and there were corner cases
+	 * where always a non-zero amount of pages were scanned.
+	 */
+	if (!nr_reclaimed)
+		return false;
 
 	/* If compaction would go ahead or the allocation would succeed, stop */
 	for (z = 0; z <= sc->reclaim_idx; z++) {
@@ -2763,11 +2752,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	if (get_nr_swap_pages() > 0)
 		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
 
-	return inactive_lru_pages > pages_for_compaction &&
-		/*
-		 * avoid dryrun with plenty of inactive pages
-		 */
-		nr_scanned && nr_reclaimed;
+	return inactive_lru_pages > pages_for_compaction;
 }
 
 static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
@@ -2936,7 +2921,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			wait_iff_congested(BLK_RW_ASYNC, HZ/10);
 
 	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
-					 sc->nr_scanned - nr_scanned, sc));
+					 sc));
 
 	/*
 	 * Kswapd gives up on balancing particular nodes after too
-- 
2.20.1

