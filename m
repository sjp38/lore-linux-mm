Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95438C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 454EB222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="hFnIT5Aa";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Z2stXGOb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 454EB222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7DB78E0017; Fri, 15 Feb 2019 17:09:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2C3B8E0014; Fri, 15 Feb 2019 17:09:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CBA88E0017; Fri, 15 Feb 2019 17:09:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 733368E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:32 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id m34so10401389qtb.14
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=FiyxBlqHBRuB2dgup3XVTlpHV28/2P36o4TG2N7q4n0=;
        b=RT0q1RA+Pl3naEnh+8LyIOrOSeHahU+zLshI/oXl9lj0hoV+2wVLkhrxjqAvnidKwV
         LoGuVxWEfo5utvt6wgT6/5Nc+SymEZuN5Ms02e9KZ05wwS6O0CdJAvLSWO9RROIJyMkt
         TWxm/n21VA0kGw8L2HnPZilEOnfynRK9lGa9+imeIWTWtrRUzhsj8fjScBwbPXDXh0pg
         ev5G7sLASAjW7p0t5tkpmMEFNCyyfxyHYWbMpyxcUNP2lGj+efoG0mb/PkwuwqXflHzd
         QSpKYOJsxgeTxuN9nAAqb4wqATiYhSNaRwC570GjF3I/D4rFkilMBeGxL8qUuclqUfpo
         FNng==
X-Gm-Message-State: AHQUAuazHy9JtAXNtDtFUmoGZqWLLOab/Muq4G1O89J106+JAC/1HMks
	96JBDKzrjFMf/reZNqe+w/CLVBVznRhHX8u+017F7NIYR1Ynnz/tECj29vF5YCYASm/bZVCWqq+
	oyfr37rTW38nNW7S62WpTpEoSfrDR7yvv3X3emUiqfVKoI+7ESpRI0SYy8HcqwowP9A==
X-Received: by 2002:aed:234d:: with SMTP id i13mr9599582qtc.367.1550268572267;
        Fri, 15 Feb 2019 14:09:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaHxHhurRpJP/lOIU8cn5hkNTd0Zlkz+fUdVvRHyuaM033gWJrK2rH5IcocAo90m2tGb+JQ
X-Received: by 2002:aed:234d:: with SMTP id i13mr9599548qtc.367.1550268571680;
        Fri, 15 Feb 2019 14:09:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268571; cv=none;
        d=google.com; s=arc-20160816;
        b=kwIgeStgZTNZb4J0lcgYHcKDeY5pY/D1/0GIJfAceOpeYK2z8emVLQh6xtDMiYgrHh
         EOeLlwn9lTEsGydbghxZZ5fjuS4larsttb3VsmYOHOJmHVKFOqfLk3jRTSgoz1vBNZa1
         8FnphH6yJkMCM3gcCxSB5g6PNFH3RzmYAW7NkTA9zOILPLm0ePEEviSBGmpuLT6hWp4Q
         /AkCFtAV7WF9BTANmHfq+IGb044e3Ypo24ccdFfpAuXjo5iD37uoBmSzM0E2AYCt2gnD
         gF8qlryQZktGeB6WHDpiXLI5r5xVFQOw+rdnTi38q4wFo0bbJpBTujH0ABEJmxWy+dJJ
         dgnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=FiyxBlqHBRuB2dgup3XVTlpHV28/2P36o4TG2N7q4n0=;
        b=YMmZA/R8uxPkDarn5Ref8+y9pm3nTflYaptZ5pBh8kY+uSQFcgU+SLR//KWHHHXJEn
         iz5+A1oDo0AiZwAW3E0pUz565+Q21dnU+0c3v6OpyWEEXjJZLs+aD+aCcmqCyF8CI096
         AeJ6mv49CDVG74c6DdgZcryfqEF+jhUjSiZ2SwyZC98BMgnx9yw8E+aOaZ1DxoX3pqb0
         tWRMm7qP7uEeDPhJC+e/WG0NkxSLuzBgWhGi6bmI5Rhp8qNnPMbHog9daEk1nqQWDn0h
         uHq5UGk6KOgIQDcVF3S4IqQadiOTeTX5g3k5/mVuHADWmpZgZ3jLWzpOYkhR/cMvo3tp
         q0EQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=hFnIT5Aa;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Z2stXGOb;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id o190si4374737qkf.141.2019.02.15.14.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:31 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=hFnIT5Aa;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Z2stXGOb;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id E1B5F3016;
	Fri, 15 Feb 2019 17:09:29 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:30 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=FiyxBlqHBRuB2
	dgup3XVTlpHV28/2P36o4TG2N7q4n0=; b=hFnIT5Aat3OtrEQ7DS0ABokwDm7No
	icKjz/BCt4fW+B1LJ53VLZSVtGhx2aG21Ih+xGdu3cBOeP+aNsa6Ltg3S0b/Eifq
	BAM7u0GnDA/GCY5jdC1FxPfjAudYFw5krumJHia8w1KMtT79XeF4XArd3qLciYug
	NHUmio3kvhCaYEhvBLET1sr/O2TJ+AYaKglEqFeyv+q8Y3OyBJfs/MmG1s11HvvE
	Qp9E18dNYbA6G3yvEm2bRBWpGY3C70hpMIiqOK79Rq4Ds8JRrb1qEZnNnb6w7T0i
	sfpxQteCPfRvQNNveQ6HtH9DJRzc8Ad119wrS8k+hntA535W1Dx2YryCQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=FiyxBlqHBRuB2dgup3XVTlpHV28/2P36o4TG2N7q4n0=; b=Z2stXGOb
	xyQ1GRz0Xeoz+I9aOw0h8VR+Trx0R8H8QeDTCpaSKrOh4qRuSIKzrtbycQvB+zGC
	ohXuOdMde935KPdEXb30mdfJO8RRbL4FM3h8m6IPZJQ9piyMKj+LBlSXnHkKHIC2
	Gah9RCajQGpw5xGxy+lImBmALr/jeGhxTIiwCSnTsgVX5N9XzYSFyqi3D6s0cQg5
	KOjDmbtBKjIR1TLHXRFOXoqacLhQLVGRQAErPPUkKuLgCDdlnyspfSUVqqejgI0Q
	wud5qwmWHG0qNtyIWvcVNUXt/0rm70V8rHobvUFksSdmzi15BFYnxifYNT5hI5rS
	7hghfTL5RfIuFQ==
X-ME-Sender: <xms:mThnXDYKynMq3H5k2tdVpbnREZQ0UG6CKgeLodIoyTFNNXSvL-gBPQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeduke
X-ME-Proxy: <xmx:mThnXJjjlz2YUjyApg7fmZy5ZAMo-uTdwyjpAARqwLL1kTlF5l4xAw>
    <xmx:mThnXIRO3hM9wiMK6fHtE014tEJxjs6TWZlM0yN9_ubctT5t6ql9kg>
    <xmx:mThnXCapI6MrrUcQyHLkdXnw1NLgXc9C3rAMM9wdkcS-vbL6T1I74g>
    <xmx:mThnXOGKx--YjXMjd1YuyRbvbXhPghtY6QwFrxsScUj-OWWjTWAO0w>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id D59AAE462B;
	Fri, 15 Feb 2019 17:09:27 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 20/31] mm: thp: split 1GB THPs at page reclaim.
Date: Fri, 15 Feb 2019 14:08:45 -0800
Message-Id: <20190215220856.29749-21-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

We cannot swap 1GB THPs, so split them before swap them out.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/swap_slots.c |  2 ++
 mm/vmscan.c     | 55 ++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 63a7b4563a57..797c804ff905 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -315,6 +315,8 @@ swp_entry_t get_swap_page(struct page *page)
 	entry.val = 0;
 
 	if (PageTransHuge(page)) {
+		if (compound_order(page) == HPAGE_PUD_ORDER)
+			return entry;
 		if (IS_ENABLED(CONFIG_THP_SWAP))
 			get_swap_pages(1, &entry, HPAGE_PMD_NR);
 		goto out;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a714c4f800e9..a2a91c1d3dae 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1288,25 +1288,47 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				if (!(sc->gfp_mask & __GFP_IO))
 					goto keep_locked;
 				if (PageTransHuge(page)) {
-					/* cannot split THP, skip it */
-					if (!can_split_huge_page(page, NULL))
-						goto activate_locked;
-					/*
-					 * Split pages without a PMD map right
-					 * away. Chances are some or all of the
-					 * tail pages can be freed without IO.
-					 */
-					if (!compound_mapcount(page) &&
-					    split_huge_page_to_list(page,
-								    page_list))
+					if (compound_order(page) == HPAGE_PUD_ORDER) {
+						/* cannot split THP, skip it */
+						if (!can_split_huge_pud_page(page, NULL))
+							goto activate_locked;
+						/*
+						 * Split pages without a PMD map right
+						 * away. Chances are some or all of the
+						 * tail pages can be freed without IO.
+						 */
+						if (!compound_mapcount(page) &&
+							split_huge_pud_page_to_list(page,
+										page_list))
+							goto activate_locked;
+					}
+					if (compound_order(page) == HPAGE_PMD_ORDER) {
+						/* cannot split THP, skip it */
+						if (!can_split_huge_page(page, NULL))
+							goto activate_locked;
+						/*
+						 * Split pages without a PMD map right
+						 * away. Chances are some or all of the
+						 * tail pages can be freed without IO.
+						 */
+						if (!compound_mapcount(page) &&
+							split_huge_page_to_list(page,
+										page_list))
+							goto activate_locked;
+					}
+				}
+				if (compound_order(page) == HPAGE_PUD_ORDER) {
+					if (split_huge_pud_page_to_list(page,
+									page_list))
 						goto activate_locked;
 				}
 				if (!add_to_swap(page)) {
 					if (!PageTransHuge(page))
 						goto activate_locked;
 					/* Fallback to swap normal pages */
+					VM_BUG_ON_PAGE(compound_order(page) != HPAGE_PMD_ORDER, page);
 					if (split_huge_page_to_list(page,
-								    page_list))
+									page_list))
 						goto activate_locked;
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 					count_vm_event(THP_SWPOUT_FALLBACK);
@@ -1321,6 +1343,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				mapping = page_mapping(page);
 			}
 		} else if (unlikely(PageTransHuge(page))) {
+			VM_BUG_ON_PAGE(compound_order(page) != HPAGE_PMD_ORDER, page);
 			/* Split file THP */
 			if (split_huge_page_to_list(page, page_list))
 				goto keep_locked;
@@ -1333,8 +1356,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (page_mapped(page)) {
 			enum ttu_flags flags = ttu_flags | TTU_BATCH_FLUSH;
 
-			if (unlikely(PageTransHuge(page)))
-				flags |= TTU_SPLIT_HUGE_PMD;
+			if (unlikely(PageTransHuge(page))) {
+				if (compound_order(page) == HPAGE_PMD_ORDER)
+					flags |= TTU_SPLIT_HUGE_PMD;
+				else if (compound_order(page) == HPAGE_PUD_ORDER)
+					flags |= TTU_SPLIT_HUGE_PUD;
+			}
 			if (!try_to_unmap(page, flags)) {
 				nr_unmap_fail++;
 				goto activate_locked;
-- 
2.20.1

