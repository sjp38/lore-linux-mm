Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2185EC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:40:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA6B52189F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:40:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA6B52189F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 540346B0003; Fri, 26 Jul 2019 03:40:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F2FF6B0005; Fri, 26 Jul 2019 03:40:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 408AF8E0002; Fri, 26 Jul 2019 03:40:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BCC66B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:40:58 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y22so27900079plr.20
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 00:40:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-disposition:user-agent:sender:precedence:list-id
         :archived-at:list-archive:list-post:content-transfer-encoding;
        bh=Qn/vwGMKril4+brhs7YdD8gVUZdmnWF0QCvdeG363FM=;
        b=dHeuT1vAEx1a1Vae+phmCUVE/MlbauTPDvQR5UVvcKBYVE7fFfW+g8tJVnh/0JtALM
         UON94rINyqty7JJSu2f1kFB7gMgawEBiEJkAq6Zio53bqodHsfIrwVBUOnRgnJmCq+sI
         g9pFmAvuKJmH/v4g6twfYxgZz89tln3wBGwELkntGWPUNGGVy7X8KewvnyXoe1vRDMw6
         zZ4mOtj3BJcExRFvNOLR8PSDSHAHzXMLOYA0KWH4qKI8JMvNZyYEBvYrsXRpydfqx/Bf
         iRE4Yl3vGGAqLA3qIe7wMZ9Y75tBIZcr2t51KYxb+w9l72rpE3Auu/wlSiN7jCAFu2LD
         wonA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.211 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVZTLdRjmWy7qr0p8/Vfe3U1OSGe9cyn+Cnxi7OnvoQ115Qiao/
	z4qzabRj/IQV1aayr9heaCuzJARS7erWoqs3gwYxOLU0N2JSOtL2+UDFkjMQnYuRFrKtGkNZf3U
	/Mb2hwVTfLzYnbNtwAvboqGtDdu34XT4tEWt8I+svLtFXsUQVhtn8N7DLFNnAx2VGuw==
X-Received: by 2002:a63:3dc9:: with SMTP id k192mr49979370pga.428.1564126857603;
        Fri, 26 Jul 2019 00:40:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9ILH34rD9r6mYPqIfCpvdj6qq9wcKIWzU19d9TivBMIUmsQVsOgSmUi/LQ2LY42WL5Rdk
X-Received: by 2002:a63:3dc9:: with SMTP id k192mr49979330pga.428.1564126856814;
        Fri, 26 Jul 2019 00:40:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564126856; cv=none;
        d=google.com; s=arc-20160816;
        b=IAMPLJDYnCprWOmZ0K/YJ4oWX4ohAibr0pmvNV8E2Fu+WzOm9uREJeb9Uas57sV6Hk
         rSIHQKm0m7cnugQ6MFJLBxR5RUx7TAg1FTW3XhTsQHnRnDXbfeSOPPHemmKVNQO6Qrc4
         v3WWtlEBG9l3emWppOsQHdWP2eW8I4/gmj5BHzetafjTqCwmo0zioKSr7sj6ZYDALWq5
         jxGflca6SPfbeaqKz39OcGtxXipv/eOGHoBEegXtpDV9sRqndFDXYAQMpyCbfy3T3/x3
         /EZM2qwZPVXManwUhbS6zxOz0s9jCEeDrHgVhVg2W+E36tHRsAxrbRYT4tikGV+QI0yf
         sSDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:user-agent:content-disposition
         :mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=Qn/vwGMKril4+brhs7YdD8gVUZdmnWF0QCvdeG363FM=;
        b=osM9N5ClDfmVjHwo4pFRwX87OQ+rgyR67u9hF3Cnumms0idCkFVicru1R3/t+8u450
         VZM9ALLEhhkdhSLzDHOlBIP4VYScZojzHy14obqxCPB5rpkJG4LvniYFqmF59WSx6CHo
         i8bIOBE+Kmfg5nQJA0QmMhFTWxJMctu+4y0E602JT/rzERie0vuesXl1/r4r/UyHD/ky
         W7jHNp2OLR/mUkXeRnlTGtgrWT6FNq/Tn/4gXSWK3jAtA+P/E0D2MVcZMWFl0jp6hfsk
         BAg+0ZLfYXL5NzfKI/V5+z3L8NWMF59T2ScdKvOutksHp+iKfTFMHrOtzz9VJXe2Plb8
         u8ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.211 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-211.sinamail.sina.com.cn (mail7-211.sinamail.sina.com.cn. [202.108.7.211])
        by mx.google.com with SMTP id z62si20206307pgz.143.2019.07.26.00.40.56
        for <linux-mm@kvack.org>;
        Fri, 26 Jul 2019 00:40:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.211 as permitted sender) client-ip=202.108.7.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.211 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([111.194.180.182])
	by sina.com with ESMTP
	id 5D3AAE850000362D; Fri, 26 Jul 2019 15:40:55 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 1932450200725
From: Hillf Danton <hdanton@sina.com>
To: Mel Gorman <mgorman@suse.de>,
	Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hillf Danton <hdanton@sina.com>
Subject: Re: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim perform dryrun detection
Date: Fri, 26 Jul 2019 15:40:45 +0800
Message-Id: <20190725080551.GB2708@suse.de>
In-Reply-To: <20190724175014.9935-2-mike.kravetz@oracle.com>
References: <20190724175014.9935-1-mike.kravetz@oracle.com> <20190724175014.9935-2-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190725080551.GB2708@suse.de/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190726074045.TY9-cub0eubi17-SduRO4mgC2H9jx79IiwS7IOyvrk8@z>


On Thu, 25 Jul 2019 08:05:55 +0000 (UTC) Mel Gorman wrote:
> 
> Agreed that the description could do with improvement. However, it
> makes sense that if compaction reports it can make progress that it is
> unnecessary to continue reclaiming.

Thanks Mike and Mel.

Hillf
---8<---
From: Hillf Danton <hdanton@sina.com>
Subject: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim perform dryrun detection

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
---
 mm/vmscan.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f4fd02a..484b6b1 100644
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

