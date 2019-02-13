Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF8BAC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:30:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1977222B2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:30:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1977222B2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B5AE8E0001; Wed, 13 Feb 2019 09:30:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33E228E0002; Wed, 13 Feb 2019 09:30:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 216FB8E0001; Wed, 13 Feb 2019 09:30:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B743C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:30:16 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id 39so1097053edq.13
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:30:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dtc3EyfyX1FH5CqyQiLh4jgZbUQ/wmh+CZJZ4rLGRzk=;
        b=OTLyzaCi4EImXWzeW3WXlu15oYkwgaufVMiCJEnwGt8zdG4eu0almaJouOeXqzvRIh
         IVZX8aDDPvsjU8gEkZsypCdFyYUtpH99BPiEm4OMlGBN+mrqpmJX2Tugpkhtk8ndYBIU
         xD7XlUYHh+KMiINeYPY+TE+UK2haTPqhF9JUsvr5p+DpdtntWQPF4Rx10DmrHelB4of1
         uIcst8wWoC5QT/PbKQuyI1Pwxf+4brcG5TLh8JHYwXygnBo7tjd43+zpKyv/xXHAKKfh
         BPzmOl7LzsPhu3gLcVhtIUZ7HAXx5GFvQht+5eBmJVybepJWOPhMKwucVZuHuweOrfkU
         Jy6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AHQUAuZi/n9eDtRqjZxK4etjo985RDCqapfmBDtb7pPqwFI0NToe1ZQZ
	AKj154PALKcOmMLthgEKlq3PXqZN56ghEvLZePyJZUZG4yDdihf2kFebAcNhJmnvZ1dqZhk2ShY
	7UlCoQA55q4ZzsNTCG7HysOU90zcgiIEzHC0Tj1u7tEAkFyfPJHjE56vN/kIuLFZeKQ==
X-Received: by 2002:a17:906:2643:: with SMTP id i3mr560811ejc.157.1550068216222;
        Wed, 13 Feb 2019 06:30:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY5gzgC+8cRi64v2/HiL43l5eCK3G/cPlB7P8R0WkLgQpMsKSGqZALoPPLrhJvYdqfemd5/
X-Received: by 2002:a17:906:2643:: with SMTP id i3mr560735ejc.157.1550068215144;
        Wed, 13 Feb 2019 06:30:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550068215; cv=none;
        d=google.com; s=arc-20160816;
        b=zl9CIKezXZ12WlqdUIiP03Q1paIt6Nwj1bx39p1TVYO1f/NMkUik7D08vmHcSMxB3P
         QGkSdreGRoObSwnpCbMa+EslXAaMQTsdyo4X2VTLanMKgkHwHKh/bQnqD8Wo/PhZx1zA
         wTrww7cduUwM5bRPY2zr6xzXDX3KmyUG0WIJB/QS4Q5Ezvcec1ZBy17qawcAXMNAn2rX
         mAkDbKcP9IRgdRg33NHPSQfzzoAp8RltXm2VhjHagrq2FAQHWkDPzmkVsAhELgN+lJxC
         4F2YIMLmVsfYOqjmgArKuXo4IvqMyMcMy1sggU2YoT7ByCBL9KZdPQAyeBzApNzs20Ce
         ZoMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dtc3EyfyX1FH5CqyQiLh4jgZbUQ/wmh+CZJZ4rLGRzk=;
        b=UJoBiPuj6yZ+DXAlqDQ5RVDstWEQc/l2iuO34mPHTAZVhgRjB5UulzHcg5VH7by0Fc
         k8vaLdp7j3RNSlgI2C93RjHLHV4HB1aHPYrTjpTxrgRnyvTPkyDObwJx8Dz31aY4H3w0
         UFhfDwOz+4/T3QUsYxMubIOjOHte7GZSf4bosNnfzbJFID3TygZte2QZgqK35cf04wrB
         lUU3wHNCXxL/O8sN4tW9bW396LNld2zzkRPbSn/PaU0HDX5asGcANy2+JGbc4peMB1ju
         +dKkdgMvsNMutzU32xF21sFWTsufL2Gy3hDNLioFw8RbWIbOMw3wdGY557eYmpRumkM9
         +jzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id d6si418048edo.325.2019.02.13.06.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 06:30:15 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) client-ip=46.22.139.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 94F781C1C0B
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:30:14 +0000 (GMT)
Received: (qmail 2776 invoked from network); 13 Feb 2019 14:30:14 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 13 Feb 2019 14:30:14 -0000
Date: Wed, 13 Feb 2019 14:30:13 +0000
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
 watermarks v2
Message-ID: <20190213143012.GT9565@techsingularity.net>
References: <20190213131923.GQ9565@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190213131923.GQ9565@techsingularity.net>
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

The problem is that a division by zero error is possible if boosting
occurs very early in boot if the system has very little memory. This
patch avoids the division by zero error.

Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
Reported-and-tested-by: Yury Norov <yury.norov@gmail.com>
Tested-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d295c9bc01a8..bb1c7d843ebf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2170,6 +2170,18 @@ static inline void boost_watermark(struct zone *zone)
 
 	max_boost = mult_frac(zone->_watermark[WMARK_HIGH],
 			watermark_boost_factor, 10000);
+
+	/*
+	 * high watermark may be uninitialised if fragmentation occurs
+	 * very early in boot so do not boost. We do not fall
+	 * through and boost by pageblock_nr_pages as failing
+	 * allocations that early means that reclaim is not going
+	 * to help and it may even be impossible to reclaim the
+	 * boosted watermark resulting in a hang.
+	 */
+	if (!max_boost)
+		return;
+
 	max_boost = max(pageblock_nr_pages, max_boost);
 
 	zone->watermark_boost = min(zone->watermark_boost + pageblock_nr_pages,

-- 
Mel Gorman
SUSE Labs

