Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF8F2C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:19:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6976222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:19:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6976222B1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 524B18E0002; Wed, 13 Feb 2019 08:19:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AD5A8E0001; Wed, 13 Feb 2019 08:19:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34F228E0002; Wed, 13 Feb 2019 08:19:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA6BB8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:19:27 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so1015997edi.0
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:19:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=HjifoTFNoXcUSR6pfUGl7Up26NVM4jeXwGC7RtsQlC8=;
        b=VCf9jwfIKWPQoi5Q7HxB/XFbhtA5y0bN1kgQM6B0h8pSxHO2rvchcQcuJEwAn8SB+u
         8sSSGEntUnSoiGGtdmWr10b64FnnFLDLJvwQ/BMwiQsqSwIUA0fFF+Dx05Rt1ap+2gAp
         m8EBYu7tafE8Fat6u9dcVJeVcBKUEaWCaabp/8tl8qgADMo/OYXJAfPxgFJ86qaUPAAm
         5BaKUq/LYqvfLM46J8YiPDzLpFZbXQPnTeQh0QBE8NZoX4QLG+JAU/hnjcwesAgdE6g3
         WJDvQT8AbUSHrQCyKlW/nX0YFgGSojvAHtqe4tjY7cvwGC9n95ryeTkJ4HcaNxBWOejk
         zDzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AHQUAuZ58Ik343B0NceTGd+mNARSwYvg+PGYz0DUsajyV4xINO/hbeJ1
	S7ca/dFts/lrts34IEBAFUXyVHNrB/B7lAJ0ylAsrzCtNkhfVNfMOfnOhotCmiI6RHjTMG61caP
	LyAD4s+rmEmd82bEJoK2fzik3fTYxnIWNZRU5CArSwON5yRPTUjaLnkSQYGPra8Fxlg==
X-Received: by 2002:aa7:cb5a:: with SMTP id w26mr344620edt.261.1550063967283;
        Wed, 13 Feb 2019 05:19:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYId71fp9VV5WibYgJUGmYProCvH1myQ/tI/az7BpEx4fw3eaBgNLO0zpKhlga/ofCLdyrG
X-Received: by 2002:aa7:cb5a:: with SMTP id w26mr344561edt.261.1550063966330;
        Wed, 13 Feb 2019 05:19:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550063966; cv=none;
        d=google.com; s=arc-20160816;
        b=gStGz6PudpTzjr2/DNgztN5jdlC1UBnjUVGFg4KaKZEHOHlNA4V/8FFUblvgCfqcoT
         FBzkKxO4zw7DCARe3/6MOtURu1T4Y/EkzIS31TYHemwE28/YZJxj1kIQvbs07Mbrvhd3
         xzBTHu4pIwEpbV+ubAdeFuE2IrIem0K9yXBRiFjrzHYtGfsdSQAoC1qtV0WMOymOGQD1
         NPI9cTDAc7WeA/MHcW3a0sEhRpE7fdon4BnyguxuJViZsnnrRfjD3hoW2Sfe18PTMfA2
         COMITBQzf8miElc95CoZyW9yDdwHamitSzNXT9FBbmdPpZ99QiYBtO2LK0gAk8i7dkLb
         pP9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=HjifoTFNoXcUSR6pfUGl7Up26NVM4jeXwGC7RtsQlC8=;
        b=UurEy7k9LpGegJstPQ6ip8eG+PsX5V/ISXZ0rWH0iNunn84JckLkwR3upfAICWlFiS
         GdHwdK8qyd75DhDU6ws51LmbAZ6XS93GZw4mKFBPUCtt2bGe/oOpjEf1fUIQfmtfG2WG
         hGvJm3XXMA9H01PvLZXqCRu2OzAkCTQbPvueIX0AK0V3v5vB6/Ok4cRSwajaChM+ouag
         AlvWtgD3Y03anCEiZhCPyY1gGN1HuLdAsa8h1pBCVjE9K48bCfnpNwMs3lNSFzW5p/3i
         Nz2Oxx8sF4+TYCQNMc8sGi0gMgtZ09o/L4T9kQ4mUl9SxOamX5wmdVE0U5AA4qBpYp1j
         3N3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id r10si1609578ejb.72.2019.02.13.05.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:19:26 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id B2A2F1C2405
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:19:25 +0000 (GMT)
Received: (qmail 25019 invoked from network); 13 Feb 2019 13:19:25 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 13 Feb 2019 13:19:25 -0000
Date: Wed, 13 Feb 2019 13:19:23 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yury Norov <yury.norov@gmail.com>, Vlastimil Babka <vbabka@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Michal Hocko <mhocko@kernel.org>, Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org
Subject: [PATCH] mm, page_alloc: Fix a division by zero error when boosting
 watermarks
Message-ID: <20190213131923.GQ9565@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yury Norov reported that an arm64 KVM instance could not boot since after
v5.0-rc1 and could addressed by reverting the patches

1c30844d2dfe272d58c ("mm: reclaim small amounts of memory when an external
73444bc4d8f92e46a20 ("mm, page_alloc: do not wake kswapd with zone lock held")

The problem is that a division by zero error is possible if boosting occurs
either very early in boot or if the high watermark is very small. This
patch checks for the conditions and avoids boosting in those cases.

Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
Reported-and-tested-by: Yury Norov <yury.norov@gmail.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d295c9bc01a8..ae7e4ba5b9f5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2170,6 +2170,11 @@ static inline void boost_watermark(struct zone *zone)
 
 	max_boost = mult_frac(zone->_watermark[WMARK_HIGH],
 			watermark_boost_factor, 10000);
+
+	/* high watermark be be uninitialised or very small */
+	if (!max_boost)
+		return;
+
 	max_boost = max(pageblock_nr_pages, max_boost);
 
 	zone->watermark_boost = min(zone->watermark_boost + pageblock_nr_pages,

-- 
Mel Gorman
SUSE Labs

