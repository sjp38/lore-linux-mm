Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63C26C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F705222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="HSEJSvzK";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="IW1zIufo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F705222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06C8F8E0001; Fri, 15 Feb 2019 17:09:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EACCA8E0006; Fri, 15 Feb 2019 17:09:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D272D8E0001; Fri, 15 Feb 2019 17:09:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAC2E8E0004
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:07 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 203so9038258qke.7
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=nAM+pSX97PAFy4Xg9SX78TGwNfne/lhBfg+g4IBK468=;
        b=aTQMhZhkIjxk2xlOVc+Z5YVE6IjBZZA+QtTc7aXkVLlfClV9ezmSyhKqDRTLfdxDgK
         GVGSpe0YKFb4nwya+whiCBabyzxjmclkA6K2OUCYtoToy8irG7svqhfeKZrjxkpXX8VM
         CXyggZhhc/oPuojRSzJD/Brw7LzvT6cdVEoy0RvsGpl4hpgoKJgqhUjQ8h1zLf//wAex
         KSt1C4vdNYggxpmBpNWJi3BNpNv63/vMWUSaz66W65IH0oWGJYuk55X0LSBJhJuzzalg
         TrWDbp8JyIJQkIvQ5roVkaKyDoe/xRIFyx1yusisBP4Y5OxAHkX3e4p4uIvbLVII3MBR
         WvQQ==
X-Gm-Message-State: AHQUAuZMrvFYCUS5qEsvqGWl7pEFoQ/efmbBto1s39gQ7F3quhswZ+i7
	VGVTw+d7pKcx5L6lEZp7CialcuKLiVs3zy5slW97DqEml9ywk8efyHzJ7bZ3NJK8Etxm7FVCall
	I4rj8GyKvhFcSiPKQLGqHWxvaaylXooE8w2u6ze2x84EXKlM0lsZe+u9siksso5JXbQ==
X-Received: by 2002:a37:5c43:: with SMTP id q64mr8433358qkb.329.1550268547409;
        Fri, 15 Feb 2019 14:09:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZXlCmv3NEVOScDNDCyllVz8ZKP3SIbks/69L5fD6MZiZVsqPmmrs45oYbYof6DSYHDnPVS
X-Received: by 2002:a37:5c43:: with SMTP id q64mr8433323qkb.329.1550268546719;
        Fri, 15 Feb 2019 14:09:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268546; cv=none;
        d=google.com; s=arc-20160816;
        b=WMqSHeDppk7dTU+wNZY9k2kPxNuvdluPGMLzsKJxqrfRFs/BhKlCKbu1yKJ5W59Z4o
         23lEmkFZA0lnDzpPuPSsWOA49kxUKseLtE3QMW14PHdzrCG0CaqAdljCLoalgTUieBp6
         hCGal4ETmzrS9ji3HAZUygX0Ul4QSr6WTgJYGe1Oa0shTpW4U/uuaLPy546bFiEg6XnH
         r/3HcgvAYOeOTHjcSOrgKfCHHgugrDep4ccaiAyazpqe3+PS3egjIF7xnOy/SHec2azj
         ZicwlHy+PUpf9M56S/oIfmlwGbT6HIRSJYfVTm6LbaOi+CuAFri3MDJMv6yvdDRgyBfg
         6bqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=nAM+pSX97PAFy4Xg9SX78TGwNfne/lhBfg+g4IBK468=;
        b=ef0rG1piFcpXn6tqahKtGt+7l8nAh+QiIrPlmL5KK68qp49gAOQdN0TuzG16UcRhBa
         MT7cX3M2Icjp+G+sUJdbZqa9imQAdaYnWG+RA6wYcgST3p3l8L/ajAjgPHFKhFEM8mZN
         WEk2M3YLFI3E9TGUzhokJIv7RrevfOQ4y9pWL8B2/nyAEffxvqkA7/fZnESYagtQ72cR
         CWEgiJEnJ8l/GCZOF8qYJHERA8XXpJbgsJEoRzzkI1zO+k0IVal48TLWZmVH+EU9FKU1
         1f5USgy+edZcXMvjq8jABTuqvPAMBhQcmWoCkiBQ7vKqrWa9L5FMO/id8eTTroZkIKoM
         R7bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=HSEJSvzK;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=IW1zIufo;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id i6si971528qkd.16.2019.02.15.14.09.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:06 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=HSEJSvzK;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=IW1zIufo;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id ED436321D;
	Fri, 15 Feb 2019 17:09:04 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:05 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=nAM+pSX97PAFy
	4Xg9SX78TGwNfne/lhBfg+g4IBK468=; b=HSEJSvzKRLMkcD5hknvApfMFk+Cn/
	HDJ7P16WBYgGG71vqLGXuw1xUu+Y8FQhUm6oonaWYIe1WyIo/StE1hDBWHLHo0Ye
	8q1vF6FsXAoCranG8VGu+yfTN6dnm2+B1H5PZ0klBa7jpEJbHKnJ3/yukLqlWSru
	h0rOg8pdHYdzmf9vHsrpAqnmhRPpd13DVFeOg5CMBLnIJC9bnvJOvCoNojouvMUr
	AvCkttqB9e7l3q+e6gCVE6epG7x1SP9cxOJ1nCuxC4y2F2luFF3FWS/86p43hEb9
	wRmjaTJ/YnSJ1rDC9W5UJzN50XngD8GbMuyaaCg46vLczVaEUuMGIAMsQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=nAM+pSX97PAFy4Xg9SX78TGwNfne/lhBfg+g4IBK468=; b=IW1zIufo
	P1Rp8kuXE67Tqh3KSAYNhlYaB1Ycl2Q43Zc1/PrHudXg8HeBx3xW/xWanGcPMYTr
	b14z+AtBYrPr/RzAot96HpH8v2MfRpMBrPkyQImbuqiogLAVJ0Hc/+YIxdloFN6y
	B0a1+Pq4q4JU8xp68B9PQYervjKbqmL8E0he7Rz44dZh8+9TtWEE1EyaLXMDlhL1
	/iyDGgQgsNlDv1wANjkENUxTqbkynqwrZd0iFz6TKziR59XD23vBU535MOYHRxk6
	9FhvfOqjVBEXPY/a6BKDgBYGDntsZj7BhrSTNI2oD6fsYb88pCQwri8IUJv3aVB5
	vai1AtbF8ZHCrw==
X-ME-Sender: <xms:gDhnXPbQPnXETzhTqB0jBaw01sE4_ArLHqgeYCGxIXzdLG5jm9p8SA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedu
X-ME-Proxy: <xmx:gDhnXJa1lsIQXibQCjRPXNdYYO1KGPEDLfJFmUlqyhsExeEQxVeyqg>
    <xmx:gDhnXGaqW71NAc7aljBikLbTBOEGOhVMx6QC1fA4g1umhYdXKTSYYQ>
    <xmx:gDhnXGLbcSJYUQNsHSq-45R4YMXE8XWYzODNtrPZuqQpip2BD4SVdA>
    <xmx:gDhnXPV0quu7T2jNypLeayXvx-UAukc5OTJUuJJk2QgpbvPsD8iFog>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id DCB4CE462B;
	Fri, 15 Feb 2019 17:09:02 -0500 (EST)
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
Subject: [RFC PATCH 02/31] mm: migrate: Add THP exchange support.
Date: Fri, 15 Feb 2019 14:08:27 -0800
Message-Id: <20190215220856.29749-3-zi.yan@sent.com>
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

Add support for exchange between two THPs.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/exchange.c | 47 ++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 38 insertions(+), 9 deletions(-)

diff --git a/mm/exchange.c b/mm/exchange.c
index a607348cc6f4..8cf286fc0f10 100644
--- a/mm/exchange.c
+++ b/mm/exchange.c
@@ -48,7 +48,8 @@ struct page_flags {
 	unsigned int page_swapcache:1;
 	unsigned int page_writeback:1;
 	unsigned int page_private:1;
-	unsigned int __pad:3;
+	unsigned int page_doublemap:1;
+	unsigned int __pad:2;
 };
 
 
@@ -125,20 +126,23 @@ static void exchange_huge_page(struct page *dst, struct page *src)
 static void exchange_page_flags(struct page *to_page, struct page *from_page)
 {
 	int from_cpupid, to_cpupid;
-	struct page_flags from_page_flags, to_page_flags;
+	struct page_flags from_page_flags = {0}, to_page_flags = {0};
 	struct mem_cgroup *to_memcg = page_memcg(to_page),
 					  *from_memcg = page_memcg(from_page);
 
 	from_cpupid = page_cpupid_xchg_last(from_page, -1);
 
-	from_page_flags.page_error = TestClearPageError(from_page);
+	from_page_flags.page_error = PageError(from_page);
+	if (from_page_flags.page_error)
+		ClearPageError(from_page);
 	from_page_flags.page_referenced = TestClearPageReferenced(from_page);
 	from_page_flags.page_uptodate = PageUptodate(from_page);
 	ClearPageUptodate(from_page);
 	from_page_flags.page_active = TestClearPageActive(from_page);
 	from_page_flags.page_unevictable = TestClearPageUnevictable(from_page);
 	from_page_flags.page_checked = PageChecked(from_page);
-	ClearPageChecked(from_page);
+	if (from_page_flags.page_checked)
+		ClearPageChecked(from_page);
 	from_page_flags.page_mappedtodisk = PageMappedToDisk(from_page);
 	ClearPageMappedToDisk(from_page);
 	from_page_flags.page_dirty = PageDirty(from_page);
@@ -148,18 +152,22 @@ static void exchange_page_flags(struct page *to_page, struct page *from_page)
 	clear_page_idle(from_page);
 	from_page_flags.page_swapcache = PageSwapCache(from_page);
 	from_page_flags.page_writeback = test_clear_page_writeback(from_page);
+	from_page_flags.page_doublemap = PageDoubleMap(from_page);
 
 
 	to_cpupid = page_cpupid_xchg_last(to_page, -1);
 
-	to_page_flags.page_error = TestClearPageError(to_page);
+	to_page_flags.page_error = PageError(to_page);
+	if (to_page_flags.page_error)
+		ClearPageError(to_page);
 	to_page_flags.page_referenced = TestClearPageReferenced(to_page);
 	to_page_flags.page_uptodate = PageUptodate(to_page);
 	ClearPageUptodate(to_page);
 	to_page_flags.page_active = TestClearPageActive(to_page);
 	to_page_flags.page_unevictable = TestClearPageUnevictable(to_page);
 	to_page_flags.page_checked = PageChecked(to_page);
-	ClearPageChecked(to_page);
+	if (to_page_flags.page_checked)
+		ClearPageChecked(to_page);
 	to_page_flags.page_mappedtodisk = PageMappedToDisk(to_page);
 	ClearPageMappedToDisk(to_page);
 	to_page_flags.page_dirty = PageDirty(to_page);
@@ -169,6 +177,7 @@ static void exchange_page_flags(struct page *to_page, struct page *from_page)
 	clear_page_idle(to_page);
 	to_page_flags.page_swapcache = PageSwapCache(to_page);
 	to_page_flags.page_writeback = test_clear_page_writeback(to_page);
+	to_page_flags.page_doublemap = PageDoubleMap(to_page);
 
 	/* set to_page */
 	if (from_page_flags.page_error)
@@ -195,6 +204,8 @@ static void exchange_page_flags(struct page *to_page, struct page *from_page)
 		set_page_young(to_page);
 	if (from_page_flags.page_is_idle)
 		set_page_idle(to_page);
+	if (from_page_flags.page_doublemap)
+		SetPageDoubleMap(to_page);
 
 	/* set from_page */
 	if (to_page_flags.page_error)
@@ -221,6 +232,8 @@ static void exchange_page_flags(struct page *to_page, struct page *from_page)
 		set_page_young(from_page);
 	if (to_page_flags.page_is_idle)
 		set_page_idle(from_page);
+	if (to_page_flags.page_doublemap)
+		SetPageDoubleMap(from_page);
 
 	/*
 	 * Copy NUMA information to the new page, to prevent over-eager
@@ -280,6 +293,7 @@ static int exchange_page_move_mapping(struct address_space *to_mapping,
 
 	VM_BUG_ON_PAGE(to_mapping != page_mapping(to_page), to_page);
 	VM_BUG_ON_PAGE(from_mapping != page_mapping(from_page), from_page);
+	VM_BUG_ON(PageCompound(from_page) != PageCompound(to_page));
 
 	if (!to_mapping) {
 		/* Anonymous page without mapping */
@@ -600,7 +614,6 @@ static int unmap_and_exchange(struct page *from_page,
 	to_mapping = to_page->mapping;
 	from_index = from_page->index;
 	to_index = to_page->index;
-
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
@@ -691,6 +704,23 @@ static int unmap_and_exchange(struct page *from_page,
 	return rc;
 }
 
+static bool can_be_exchanged(struct page *from, struct page *to)
+{
+	if (PageCompound(from) != PageCompound(to))
+		return false;
+
+	if (PageHuge(from) != PageHuge(to))
+		return false;
+
+	if (PageHuge(from) || PageHuge(to))
+		return false;
+
+	if (compound_order(from) != compound_order(to))
+		return false;
+
+	return true;
+}
+
 /*
  * Exchange pages in the exchange_list
  *
@@ -751,9 +781,8 @@ static int exchange_pages(struct list_head *exchange_list,
 			continue;
 		}
 
-		/* TODO: compound page not supported */
 		/* to_page can be file-backed page  */
-		if (PageCompound(from_page) ||
+		if (!can_be_exchanged(from_page, to_page) ||
 			page_mapping(from_page)
 			) {
 			++failed;
-- 
2.20.1

