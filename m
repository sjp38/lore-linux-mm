Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BD16C43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 02:57:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F15912146F
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 02:57:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F15912146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D7D98E009D; Tue,  8 Jan 2019 21:57:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 587258E0038; Tue,  8 Jan 2019 21:57:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 478248E009D; Tue,  8 Jan 2019 21:57:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB2498E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 21:57:01 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so2368268edq.4
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 18:57:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:content-transfer-encoding:mime-version;
        bh=igOEgkrKiIpGXo5UrLOBR4UOq3p0/vKuaMXWYwgXv6g=;
        b=r/IWK94kOXEaGHRGVAcXDxdw2hSqm6/FXmgWK0HNG3jsb5Ft7wh7A1bzhrN7ADaSXE
         CjXbCDbvsM6CDFfNilOkBLhF4/Ud7FPR5vFX4iqMRMHmURhmUjpzXsKxo6voXtSodQ8J
         AsiDR7GWjW0cQHtSq3aYum9eTl3e7SlUPMR1wKBkKnVzdsVebmVv/qtzG4++iHpQlLDU
         TTpU/7kpNIcahmvJlPFwRO/Fuyu8WAQMVI4IMtmcPAZaIrpXqC5gbR2FoO5Id4Pxw234
         kfaplQF564Gv/B3sDXvW0M2nPdHmIZr2LvZse7FR9JThzwIcRUogLgn7RVVEZBjf9txh
         kXtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
X-Gm-Message-State: AJcUukcI/qjPTsU9Yd/T0snC19gHb8lILO9J43VKHP1Ovs61Q43Ue2ff
	/IT+ahN4l1AxLzh+t0LNctJkA6GRt61FWZPeWKT4mSl5mtPWbpW1E0cZG2NRPVX15mxntFrUnJS
	9l1CXTeSmym1p9ogVyntBUBfus2xhBTxcZAaEr1407uO0TAEHQ+phMby2G35rhgmgTQ==
X-Received: by 2002:a50:a8a4:: with SMTP id k33mr4318861edc.109.1547002621445;
        Tue, 08 Jan 2019 18:57:01 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7EtWkD6GOPKq/+sz2Km8QwDPyHiPydlRiYxsP3Gg/l/U6jIzM89PfW/4vyL4hjln/8Gcvz
X-Received: by 2002:a50:a8a4:: with SMTP id k33mr4318835edc.109.1547002620588;
        Tue, 08 Jan 2019 18:57:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547002620; cv=none;
        d=google.com; s=arc-20160816;
        b=jtBCL+5bVLW9XTsEtb7nTY8/GcY1HhYhwyOEMxe4bQ3yseoTXyDSV2bjt5VBeU+Th6
         HsrNPDolIdU1Wef+sW5Nm/KO1wTJ7IQGeSpzRZ/u0AWZMc1HTpGaRMCU5bLSEhJhzBg8
         /VSZLNa2Ce7hlvC8b63SY747onibZFQFRGnQVzp6OiSRXoh2+OWg8MDrsO2RqwfzYvO7
         Rd+foMn0eUh7FG9HUK9Rf7aXqpxa+yxHz++hOSHdxrl4AyuBJs0yvvB24bm7plEf3Vvb
         KcVRo0E/epYOFNh9JyKOcEx9StZ6+QS6Rxx4o50WKK8zJ6y5pz9Dr+PJ46O12xS14cC8
         NDEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:message-id:date:subject:cc
         :to:from;
        bh=igOEgkrKiIpGXo5UrLOBR4UOq3p0/vKuaMXWYwgXv6g=;
        b=NRQIxjUNGO5rtmisNuALGpb9r0eTRF1LuLJp3YgY0IdfX4qggFmi0I1zehCGlyyt0a
         duOVsFaBo1UXWzYm1Q9njFRcZm/2Ewvok//4oIdtB9YFYIgjVraciX40yQDFgo3IxiO7
         iN6X3cGUkToaLX4WjeTApHCvIFWjCTvJQZYfsr3Og9HeSUct7htZqtKfBCsK9fv2ZDLc
         XMNZvjLppWVrkeQg4kylVElpY45ljj+bDzBbvICeB85gLaGJ8FzoW/x1QMYCjEgagQoT
         FHTjUa88nnJMJHaUPRs+3zpGs2PDyGrmc08DirJqeba8wfhMDFYP4hr3tCf2wH80mNDy
         jG1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id e22-v6si356385ejs.224.2019.01.08.18.57.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 18:57:00 -0800 (PST)
Received-SPF: pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 51E308BAB234272D1035;
	Wed,  9 Jan 2019 10:56:26 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS406-HUB.china.huawei.com (10.3.19.206) with Microsoft SMTP Server id
 14.3.408.0; Wed, 9 Jan 2019 10:56:18 +0800
From: YueHaibing <yuehaibing@huawei.com>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton
	<akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>
CC: YueHaibing <yuehaibing@huawei.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
Subject: [PATCH -next] mm, compaction: remove set but not used variables 'a, b, c'
Date: Wed, 9 Jan 2019 03:02:47 +0000
Message-ID: <1547002967-6127-1-git-send-email-yuehaibing@huawei.com>
X-Mailer: git-send-email 1.8.3.1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109030247.S3y4PhG28KGZXVekfK_8DnC-ufxpiyYCREL8htyQamE@z>

Fixes gcc '-Wunused-but-set-variable' warning:

mm/compaction.c: In function 'compact_zone':
mm/compaction.c:2063:22: warning:
 variable 'c' set but not used [-Wunused-but-set-variable]
mm/compaction.c:2063:19: warning:
 variable 'b' set but not used [-Wunused-but-set-variable]
mm/compaction.c:2063:16: warning:
 variable 'a' set but not used [-Wunused-but-set-variable]

This never used since 94d5992baaa5 ("mm, compaction: finish pageblock
scanning on contention")

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 mm/compaction.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index f73fe07..529f19a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2060,7 +2060,6 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 	unsigned long last_migrated_pfn;
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 	bool update_cached;
-	unsigned long a, b, c;
 
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
@@ -2106,10 +2105,6 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 			cc->whole_zone = true;
 	}
 
-	a = cc->migrate_pfn;
-	b = cc->free_pfn;
-	c = (cc->free_pfn - cc->migrate_pfn) / pageblock_nr_pages;
-
 	last_migrated_pfn = 0;
 
 	/*



