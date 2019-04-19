Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01B0FC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 09:43:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89684218D3
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 09:43:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89684218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E22246B0003; Fri, 19 Apr 2019 05:43:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAA586B0006; Fri, 19 Apr 2019 05:43:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE6DF6B0007; Fri, 19 Apr 2019 05:43:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 829A56B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 05:43:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h10so2609819edn.22
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 02:43:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=2F/CaTAZPpwzryWN9RhoEazZEC7e/YUBD3FHGRt2+ik=;
        b=CnY1Y7hVKdu4CfstWEchiA46X+01lJXILclrHbIjxasrYYYX/sKE02V8la4CbDovES
         b8on30UW1Y26Mf+QRqHhp4Zx1QyomdVRoLtxOyHbmOYUBLqNOm4+0Ffkil4XV6hIu5Vg
         LI+ix1Ab/Ise1oWEPJ9CNsNae4e2JjqCuap4N5uW1hq6ze+WvWbLCe1uSAeQoZER0SW4
         SBwiyPRr2e+O1sy+Q6ZVfIoxn8KwNr94DkhFmqI/K3tFmZMSIJRIy2VJX3Mz+0RVMpVZ
         w/VgWhI6qfFc8/FGPcvd+Cg9u4uaBhBn3jvPM2YUBWyJPTBgVSBHOoNgibXVafyuhbcg
         5c0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXgnRlGQ5zw/6ZbZguuNS/Xa2906+G1+AvxzeZPRDgxr9Gg+eYR
	N2v1bC5OjQW9KCXr+Lzm1bZRwHw20OeflDgLHMXa5iS38hoIaLLJ7r3HOrRFeKVcovb4wj6l8Mo
	j7GDIurBI8FViZCLYS6lDSdsI9rkD2ePJBlc3NxPfbD5eH1GPAsQlBK3oEmKoavcTSw==
X-Received: by 2002:a50:b16c:: with SMTP id l41mr1869050edd.9.1555667018994;
        Fri, 19 Apr 2019 02:43:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAybsPZij+d5yTaFTbNHmw29FPZEFTPyoinbwiSFnt17UlVUjFEtRcPJVP+fFQouq9+hPO
X-Received: by 2002:a50:b16c:: with SMTP id l41mr1869002edd.9.1555667017819;
        Fri, 19 Apr 2019 02:43:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555667017; cv=none;
        d=google.com; s=arc-20160816;
        b=Bu1PKGigqIqXkuMplhwDiTQHUvYedxtBNkYehWtAhU5VqwxASask0rKRPT1RLHr6t9
         m9rXWxhRZaqeElh5+IXf9F3FgegjsVK62C6992TsPb2Tkhe6pn0yCI/lmcoii9qo8WRl
         6jD0muiW+tiA1/3yQo+f/0Owgs7/rD58pxHZqg60cjtDcKQ7bpGUnEJVZFVD/rCoyip1
         v7U4dO44xC2m/Qb6IBjbiWvsmbzIU6kAu5XlY4lZvT/JmYtrlKBrp3mfLLkZg/rPG6oC
         dA4RTIr4/slkW9XimFN48Xpfjj7cthf3lh8cEJFQOv2nM//nV/JFVle8/zCHUwaXY/qm
         NNVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=2F/CaTAZPpwzryWN9RhoEazZEC7e/YUBD3FHGRt2+ik=;
        b=D1M3g8DUgOO7bNU1ol/QoVhVe47HLsHsWKjCfpgi4cjplH+LTKisMxPi+8UsZmC73n
         QB/+QiQng5E87zncc1KmSMZ3h4Las/2D7jbcg6UUrytrWlQLfpmXfuxSCDyTG2BqVKt7
         qW5pDyFqC6fB+cf1FxJzz+ssoVsuiNX2swKlOu0qrJWRJc8ZIfX/HgFUDB40tsKWNIlv
         b6tIc8NIJ210+00q2rRgfbaTRBhF9RsuUpq1zUJ/oFu6jn2jSyiNJZ73es5uuKsf4dU0
         u48fcCGLVVN0tdwcDymszvBj2BMVQIPCsfAndsbbFMwTDDa21E8towpwSRry/W8BjafS
         uIJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp18.blacknight.com (outbound-smtp18.blacknight.com. [46.22.139.245])
        by mx.google.com with ESMTPS id o22si1268875edc.119.2019.04.19.02.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 02:43:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) client-ip=46.22.139.245;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp18.blacknight.com (Postfix) with ESMTPS id 708681C1C9D
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 10:43:37 +0100 (IST)
Received: (qmail 17638 invoked from network); 19 Apr 2019 09:43:37 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 19 Apr 2019 09:43:37 -0000
Date: Fri, 19 Apr 2019 10:43:35 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH] mm: Do not boost watermarks to avoid fragmentation for the
 DISCONTIG memory model
Message-ID: <20190419094335.GJ18914@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mikulas Patocka reported that 1c30844d2dfe ("mm: reclaim small amounts
of memory when an external fragmentation event occurs") "broke" memory
management on parisc. The machine is not NUMA but the DISCONTIG model
creates three pgdats even though it's a UMA machine for the following
ranges

        0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
        1) Start 0x0000000100000000 End 0x00000001bfdfffff Size   3070 MB
        2) Start 0x0000004040000000 End 0x00000040ffffffff Size   3072 MB

From his own report

	With the patch 1c30844d2, the kernel will incorrectly reclaim the
	first zone when it fills up, ignoring the fact that there are two
	completely free zones. Basiscally, it limits cache size to 1GiB.

	For example, if I run:
	# dd if=/dev/sda of=/dev/null bs=1M count=2048

	- with the proper kernel, there should be "Buffers - 2GiB"
	when this command finishes. With the patch 1c30844d2, buffers
	will consume just 1GiB or slightly more, because the kernel was
	incorrectly reclaiming them.

The page allocator and reclaim makes assumptions that pgdats really
represent NUMA nodes and zones represent ranges and makes decisions
on that basis. Watermark boosting for small pgdats leads to unexpected
results even though this would have behaved reasonably on SPARSEMEM.

DISCONTIG is essentially deprecated and even parisc plans to move to
SPARSEMEM so there is no need to be fancy, this patch simply disables
watermark boosting by default on DISCONTIGMEM.

Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
Reported-by: Mikulas Patocka <mpatocka@redhat.com>
Tested-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 Documentation/sysctl/vm.txt | 16 ++++++++--------
 mm/page_alloc.c             | 13 +++++++++++++
 2 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 6af24cdb25cc..3f13d8599337 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -866,14 +866,14 @@ The intent is that compaction has less work to do in the future and to
 increase the success rate of future high-order allocations such as SLUB
 allocations, THP and hugetlbfs pages.
 
-To make it sensible with respect to the watermark_scale_factor parameter,
-the unit is in fractions of 10,000. The default value of 15,000 means
-that up to 150% of the high watermark will be reclaimed in the event of
-a pageblock being mixed due to fragmentation. The level of reclaim is
-determined by the number of fragmentation events that occurred in the
-recent past. If this value is smaller than a pageblock then a pageblocks
-worth of pages will be reclaimed (e.g.  2MB on 64-bit x86). A boost factor
-of 0 will disable the feature.
+To make it sensible with respect to the watermark_scale_factor
+parameter, the unit is in fractions of 10,000. The default value of
+15,000 on !DISCONTIGMEM configurations means that up to 150% of the high
+watermark will be reclaimed in the event of a pageblock being mixed due
+to fragmentation. The level of reclaim is determined by the number of
+fragmentation events that occurred in the recent past. If this value is
+smaller than a pageblock then a pageblocks worth of pages will be reclaimed
+(e.g.  2MB on 64-bit x86). A boost factor of 0 will disable the feature.
 
 =============================================================
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cfaba3889fa2..86c3806f1070 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -266,7 +266,20 @@ compound_page_dtor * const compound_page_dtors[] = {
 
 int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
+#ifdef CONFIG_DISCONTIGMEM
+/*
+ * DiscontigMem defines memory ranges as separate pg_data_t even if the ranges
+ * are not on separate NUMA nodes. Functionally this works but with
+ * watermark_boost_factor, it can reclaim prematurely as the ranges can be
+ * quite small. By default, do not boost watermarks on discontigmem as in
+ * many cases very high-order allocations like THP are likely to be
+ * unsupported and the premature reclaim offsets the advantage of long-term
+ * fragmentation avoidance.
+ */
+int watermark_boost_factor __read_mostly;
+#else
 int watermark_boost_factor __read_mostly = 15000;
+#endif
 int watermark_scale_factor = 10;
 
 static unsigned long nr_kernel_pages __initdata;

