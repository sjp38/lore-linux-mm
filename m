Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1AD1C742A8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 05:47:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DAB9208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 05:47:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DAB9208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEA958E0118; Fri, 12 Jul 2019 01:47:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9B1A8E00DB; Fri, 12 Jul 2019 01:47:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B88EC8E0118; Fri, 12 Jul 2019 01:47:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 996E08E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 01:47:45 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id v11so9385603iop.7
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 22:47:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=8OLKcbVWPvJJCtLr5NdjYRJiYSbF6ytOOEReUfz0SUE=;
        b=V/kyF72JSuS8VJ4xv72V4bXMDypyJWIkIATHStY/3TmPINd+iJhzZWNv/wiJf/mxR6
         ezC+uIE/nuOYzi5jqAM5bdA6UIuD6MeGTH2cz4XpbMLRoWIIEgVHD8Xt48bhGY0/Pyzh
         qEoze5WLAl4Ro2cR7hUrGy0Xz+RT4py9Q6fEoh5lHEry6LWS3idda2VNSzAC8dVCCGm/
         cFdG6n2nhqF7WyaXgf04/CMlxvXmdsufqUAnUWSSWGxOcWS01gIW2mIicfUsUagqGVPZ
         8JgMYkwoI3kBPYXiumojztd8JwugzxZCchEO6o2s+dDIbZFvvGxwUvbcEIzTjkf9OyRd
         8Iqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAV/+25ZbmqneSXR2c9p6RFm1VW75LdTf/PsiuwTAIX7aDag+r9W
	sQ9Pa+vyNoMfsA8DxwDos7D7+nSMXTMcaU2XGy6LDCUMlA68Od93q3Iurv7zBgKqc7bnGTjrK/z
	mUNG818xEKgkFzZSs6DYLMzquQdIRwQEDxfHsu98o+5nDIVcqdoTJK7VGt8I/JjOJBA==
X-Received: by 2002:a6b:5115:: with SMTP id f21mr9015047iob.173.1562910465380;
        Thu, 11 Jul 2019 22:47:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAPfwrWy5tWEKH6a53uvbi2ZtFl8GyMTHkAMzLy1qA2x2F7ISbecTFwqXqje2A7EEweRQG
X-Received: by 2002:a6b:5115:: with SMTP id f21mr9015011iob.173.1562910464705;
        Thu, 11 Jul 2019 22:47:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562910464; cv=none;
        d=google.com; s=arc-20160816;
        b=aiTA45uceOvdULTIvL7VYUjfvIr4fvkHcgKJV2hWUnhelT6F6C420WG5LkUbBKdCkS
         2ntmZVcp9YSuLQG8I3ADFG37Qh2hLA7cOtaUZPHc/2cDe/UAVLhrea3/6Gs8cjCYn5vT
         w3ld2q0i3VGY4qo6Hof2tMHnpJ3eVmMecpm9KBbfBoagvrCPXIJxu7EVMGC0gNdsVmYV
         dAoXSovBoDSUTjxfA4vptE6uj09LO9UJrmkQ5J/kxcjAmUAOfTlFxbnP1h74wFtuGH0O
         qnTKWK9dLWto44TLpq48jg/1bJMJsffPEJ8lY2cvEw6Nfe0zhaYa+2EZ+u9EVmDsC07r
         5odw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=8OLKcbVWPvJJCtLr5NdjYRJiYSbF6ytOOEReUfz0SUE=;
        b=B90XwTVTUSfNNBKl0gS14Fupn37Etl9o9rjuI9DdC5MeGLcEHl0zUPOJRdOKBM3+wi
         F8CecepCMMlKxEwXetPbo6kN9j+5gt/mhpXdTg8Q83O8BaKZ2+JDtItuPtD9uR+Nuz+/
         +EZUYOYtSIelbn2nYJDBO9EAzRegunYO0OdcYguivGpu/ob1+yJUpxEGBT8VhoFDwvC/
         hyLmCkV+ajDJIrsx8mvS1lzc68hvQBkyyokEWskrKApsmDHXNAebj3UB1UFxWVjTR6+v
         PlkvyqQ6PZzK50LOeb4OLbBEMmu/T2ntRGZQQfSWFwox9hj9/qpgqYeWJoj/k1lfpjEL
         mLwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-165.sinamail.sina.com.cn (mail3-165.sinamail.sina.com.cn. [202.108.3.165])
        by mx.google.com with SMTP id g24si13105638jao.59.2019.07.11.22.47.43
        for <linux-mm@kvack.org>;
        Thu, 11 Jul 2019 22:47:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) client-ip=202.108.3.165;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([221.219.5.31])
	by sina.com with ESMTP
	id 5D281EFC00005C54; Fri, 12 Jul 2019 13:47:42 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 27811245089754
From: Hillf Danton <hdanton@sina.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@suse.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Question] Should direct reclaim time be bounded?
Date: Fri, 12 Jul 2019 13:47:32 +0800
Message-Id: <20190712054732.7264-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: [Question] Should direct reclaim time be bounded?
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001443, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 11 Jul 2019 02:42:56 +0800 Mike Kravetz wrote:
>
> It is quite easy to hit the condition where:
> nr_reclaimed == 0  && nr_scanned == 0 is true, but we skip the previous test
>
Then skipping check of __GFP_RETRY_MAYFAIL makes no sense in your case.
It is restored in respin below.

> and the compaction check:
> sc->nr_reclaimed < pages_for_compaction &&
> 	inactive_lru_pages > pages_for_compaction
> is true, so we return true before the below check of costly_fg_reclaim
>
This check is placed after COMPACT_SUCCESS; the latter is used to
replace sc->nr_reclaimed < pages_for_compaction.

And dryrun detection is added based on the result of last round of
shrinking of inactive pages, particularly when their number is large
enough.


--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2571,18 +2571,6 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
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
@@ -2598,7 +2586,21 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
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

