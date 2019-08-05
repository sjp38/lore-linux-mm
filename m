Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30906C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 10:57:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAF2820880
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 10:57:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAF2820880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B4A36B0003; Mon,  5 Aug 2019 06:57:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 163C76B0005; Mon,  5 Aug 2019 06:57:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02D646B0006; Mon,  5 Aug 2019 06:57:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A4E7B6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 06:57:57 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y15so51310230edu.19
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 03:57:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=0VN52/LJgn1shDqtBlz7fZKLxhCRXnUcD70BD9CImmc=;
        b=GpwWtsUxpoaaLQo5eeMplTrrBH+aHCGWeE1w5MQXdApE6o/6BDeXiJQ2jM6UAY98Qw
         JZc/lXoXlpEJ9XXKKMhGJ9xTnK+givTLIDlyPAZSg++0C0spRZFxfpcDBuBkyf4/rKpo
         lVbxaL6m0hSlnSavlCTrrWvJuMIaDblcRbp4rC2XoR9egUjwZrl/7lFw45ma/k2QoLM6
         L+SCNHI3WTrIauz9APLrzXSutIurPMqVeGt52HF2U4M9QPJayCIWoAdtSxmIVA5uQi4d
         +MIW+d3zhnz8+1FrfkCiSfZkzIPmRneM44n2P6BNii9fDngMtmBSmDG3B9Y0nwyEF5xv
         gaog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUpx7WiTfgWifChkB8uyI1TfOnv+cItVoENnh0fN5aOykHOBNNi
	T3Z3H7CnXXz8/7lh92RG0+EfaXcUu9kqCmtdmUtACYf+CuzWXTSwPQOWMfOXRUt6Lv6CG15dm2h
	dun2pEpcSbKmDUs4uTjYYT+zCzZ96PSc/lHr4Z/p5NYcHDELhRGBawnw0i3DQs8vtDQ==
X-Received: by 2002:a17:906:ad82:: with SMTP id la2mr50904049ejb.123.1565002677199;
        Mon, 05 Aug 2019 03:57:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/NPMicZOxpBYhD10P3UIL0W4JDiFz4Ab1nYFZ7CYMC9mFl+uqOCq5SulDaOzna65lvxGn
X-Received: by 2002:a17:906:ad82:: with SMTP id la2mr50903989ejb.123.1565002675803;
        Mon, 05 Aug 2019 03:57:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565002675; cv=none;
        d=google.com; s=arc-20160816;
        b=o6Tu2Z3g/WkqtAsUdFJy0wxxUJhRYeoslPi2srAr9igh9RkTzO6MT1OdNEAYTljLRX
         FIAoKyhWFf6IV6VZ51smroi8+24rdD3BT5HHj03NVspJ0Hd4aY7cKxspSeurK/D47abS
         8s01Yl64+Hd3dAdfmsrzkHwZfZInMQp5ebg5dS2NNQ7n3XywE17CnzvIvMEN0km6iZAj
         d277iEGpSTYSPOmtRH6lk2d/G1t5sB+LAZzNWWUb74n+qIt80IVAu53h0N6JuqXWegd2
         U4uY3eawDBe0kvrNKt4ului+GzZg3Tb4/NLApi1lSjOuF063YvWExvepNYymS1cC0+PT
         Wd6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:references:cc:to:from
         :subject;
        bh=0VN52/LJgn1shDqtBlz7fZKLxhCRXnUcD70BD9CImmc=;
        b=x1cHgfugEFx62Jnl0beayJ6LJ/+qCDDanLBmsEnYTRi0SpwmrlUo8YUl8Jc7k8Hrfk
         Wz7yu60/2n9UYFXVJDIzmTD9C37oX4tF7+wcpep8v42wGpfVSKgQHRVFUc9wkTw6Gr65
         9VU+Wdukkb130yzzf7JTKXHilBNRCW1h8/6BQg0BoPozyfJfERZ2bpMkkdh3CXyaNJyg
         8t1zR9LXWLg3fME4HwY9HvhNC6Hq8Xn5u8mBUN+DWRP49NV29QCfgFpPmtH4liqZ7LU0
         4EO2djKoLHyv4cdvl7xXf4fu5YMjiOyK0bvBApjxJPGPkxMdFr3ODcv7jReJK8SdGCo7
         ZBzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f6si17782458edd.395.2019.08.05.03.57.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 03:57:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 907BFB623;
	Mon,  5 Aug 2019 10:57:54 +0000 (UTC)
Subject: Re: [PATCH 1/3] mm, reclaim: make should_continue_reclaim perform
 dryrun detection
From: Vlastimil Babka <vbabka@suse.cz>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
 Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrea Arcangeli <aarcange@redhat.com>, David Rientjes
 <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190802223930.30971-1-mike.kravetz@oracle.com>
 <20190802223930.30971-2-mike.kravetz@oracle.com>
 <bb16d3f0-0984-be32-4346-358abad92c4c@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <0d31cc14-13cd-13e0-cf2d-dd8a8d3049ff@suse.cz>
Date: Mon, 5 Aug 2019 12:57:53 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <bb16d3f0-0984-be32-4346-358abad92c4c@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/5/19 10:42 AM, Vlastimil Babka wrote:
> On 8/3/19 12:39 AM, Mike Kravetz wrote:
>> From: Hillf Danton <hdanton@sina.com>
>>
>> Address the issue of should_continue_reclaim continuing true too often
>> for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
>> This could happen during hugetlb page allocation causing stalls for
>> minutes or hours.
>>
>> We can stop reclaiming pages if compaction reports it can make a progress.
>> A code reshuffle is needed to do that.
> 
>> And it has side-effects, however,
>> with allocation latencies in other cases but that would come at the cost
>> of potential premature reclaim which has consequences of itself.
> 
> Based on Mel's longer explanation, can we clarify the wording here? e.g.:
> 
> There might be side-effect for other high-order allocations that would
> potentially benefit from more reclaim before compaction for them to be
> faster and less likely to stall, but the consequences of
> premature/over-reclaim are considered worse.
> 
>> We can also bail out of reclaiming pages if we know that there are not
>> enough inactive lru pages left to satisfy the costly allocation.
>>
>> We can give up reclaiming pages too if we see dryrun occur, with the
>> certainty of plenty of inactive pages. IOW with dryrun detected, we are
>> sure we have reclaimed as many pages as we could.
>>
>> Cc: Mike Kravetz <mike.kravetz@oracle.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Signed-off-by: Hillf Danton <hdanton@sina.com>
>> Tested-by: Mike Kravetz <mike.kravetz@oracle.com>
>> Acked-by: Mel Gorman <mgorman@suse.de>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> I will send some followup cleanup.

How about this?
----8<----
From 0040b32462587171ad22395a56699cc036ad483f Mon Sep 17 00:00:00 2001
From: Vlastimil Babka <vbabka@suse.cz>
Date: Mon, 5 Aug 2019 12:49:40 +0200
Subject: [PATCH] mm, reclaim: cleanup should_continue_reclaim()

After commit "mm, reclaim: make should_continue_reclaim perform dryrun
detection", closer look at the function shows, that nr_reclaimed == 0 means
the function will always return false. And since non-zero nr_reclaimed implies
non_zero nr_scanned, testing nr_scanned serves no purpose, and so does the
testing for __GFP_RETRY_MAYFAIL.

This patch thus cleans up the function to test only !nr_reclaimed upfront, and
remove the __GFP_RETRY_MAYFAIL test and nr_scanned parameter completely.
Comment is also updated, explaining that approximating "full LRU list has been
scanned" with nr_scanned == 0 didn't really work.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 43 ++++++++++++++-----------------------------
 1 file changed, 14 insertions(+), 29 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ad498b76e492..db3c9e06a888 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2582,7 +2582,6 @@ static bool in_reclaim_compaction(struct scan_control *sc)
  */
 static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 					unsigned long nr_reclaimed,
-					unsigned long nr_scanned,
 					struct scan_control *sc)
 {
 	unsigned long pages_for_compaction;
@@ -2593,28 +2592,18 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
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
@@ -2641,11 +2630,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
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
@@ -2810,7 +2795,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			wait_iff_congested(BLK_RW_ASYNC, HZ/10);
 
 	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
-					 sc->nr_scanned - nr_scanned, sc));
+					 sc));
 
 	/*
 	 * Kswapd gives up on balancing particular nodes after too
-- 
2.22.0


