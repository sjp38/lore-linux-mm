Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41B7CC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D88DA20820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="J5GTuTLS";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ebgaOEje"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D88DA20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D8D06B0275; Wed,  3 Apr 2019 22:01:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75B166B0276; Wed,  3 Apr 2019 22:01:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4616B0277; Wed,  3 Apr 2019 22:01:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE4E6B0275
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:44 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id q127so958751qkd.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=6c2RdtcLhR3zr/QIZTKdBARjyyIAyxC57tVZiXAXuu4=;
        b=I6R3SfvAMT8toV3P1v9/lmyachzkTf4zyLwTKkcm4uO304Hwq922QyB2MVS3adFoIc
         7Nz9ddLoSSTC9oKclD4WqSE0ZegROlcoGDO4vZ32m3Ai8F+zfebv0qqooeqgvnXR/gjM
         rJXS+d1UyVshO07qzymXEnWcrpXcS5qlIG9xs/ORTjbO/jzDuCV0weDi5UUfn6//2juM
         7/Oz9r2858jxXLwxO3qTZZj5vrUOv/BnpOEgs4EoPRAinhDp7c9o5t3ZFet2EvDDhw9B
         CfJsGcnBGLQ5EWKrILF/AFRtUYnoP8+pagC2OzIWoTARk5i1wdl3MFkP4gqMbuH9W4Li
         tmTw==
X-Gm-Message-State: APjAAAVIwFhL+dHc0di49IKyTg6o7jVtWP0k7crJbhF68NvlznPzfi0h
	1FugOohTvw6wml+qTzNhQX8QhsWXAUZ/TWWYz535g4u+m+fDfB28tTBsfU7wL+jf+LWEnQRn/L2
	Hcvhr9RZaybHyxy13TXBtYUxlAQeEiwT+P6JXGG110RujLnYrQGNC+0HaPgy7iMZt4A==
X-Received: by 2002:a05:620a:12ea:: with SMTP id f10mr2864236qkl.86.1554343303990;
        Wed, 03 Apr 2019 19:01:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyu0qiRU9BKfL24/g/A8cUad94d3kBtnQmbLPrLMBfNfErAC+VVZJfaZGiSczJl0Kfiezqk
X-Received: by 2002:a05:620a:12ea:: with SMTP id f10mr2864157qkl.86.1554343302628;
        Wed, 03 Apr 2019 19:01:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343302; cv=none;
        d=google.com; s=arc-20160816;
        b=PgZ9b3OcZGCHGnTAdr3VH4x2YfeELobpYoqPs5kWn2DwslEz3Y6pheSxaA5Bm37JQQ
         gNBcAijNiS21s+gcX33fuRCP7HJ7o4H4UbN/tUiPAiIs7bL24aL6tu0HvhQGJ+e0Vypc
         QL7Ge/fM/91fn7Kf8CbBVUkdttCIBBTktfMbHPPTQSqZjlMOj3ajiQ3vTkzYXNCvaciX
         1eLVwJo2+owSm1P1qVsLJqu9WleC4dQ4dyxdZCPsZUnCP1LmaNuRR+GGGrHggcWWgQ6k
         RBuZlNz6bCXhPo9lZt/+pFYWPxq5i3ApXBJYPbQxUbLf4U35EHNfX5cAN82u7xCUt1YF
         RnOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=6c2RdtcLhR3zr/QIZTKdBARjyyIAyxC57tVZiXAXuu4=;
        b=qdGsgbiMnb+74Xy7Oi7uKINMRSaF2hooCN9x/UuF27EADZDA/HYfKLeus5kDRsfWoR
         XzxT9tTuMAoKalJk8E3WunMFKaZvqj1zpEKVoMmximFYIQz/eRPSsARSuRwc51T8+7Ml
         Mk90fvzq9zAVPiMbsuVKovf6PZzkjF/GbGt3Q79nClifPXqu0LBinZl6931NQSb9sSi6
         3WGqhHAbC7rcvL9ZR1opk/qhCjW10SBzyi0weWpK88pnJJoHTiGWK4JPdbHTIc+HuK/Q
         PCEiJGz8p6YDjenbXNt9aFJWpxYIuZJRxwrgyHwQYP8N+6zEr9y1U3Bl5rwfahvBWXTh
         IzlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=J5GTuTLS;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ebgaOEje;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id c197si6198289qkb.179.2019.04.03.19.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=J5GTuTLS;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ebgaOEje;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 5244B21D72;
	Wed,  3 Apr 2019 22:01:42 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=6c2RdtcLhR3zr
	/QIZTKdBARjyyIAyxC57tVZiXAXuu4=; b=J5GTuTLSH8I1aHJyQfQrBoaGcvamV
	Iy8yv5kFP32GM5ir8TPfMhhCPPk3V+sNQppl24SNqLUbOygmeyWSCzyQjonRsOnl
	tcSWm+2A7L458T+/mandh3ct2dyEGuYUpIs62fpBvTKjtENPvFlIDu6f2HJDu1UK
	4KH8zOxES+AX896LvQ4WVZfyxejccMtQawEM2rt7hN5IaH7VWtDv5+05bQv7tFIr
	IQnA+iGpPB7BxJ982qBwgvksaGAYmjUPS8HRqb3/P3hhHWkL3iIp/FXyRx97ZkLQ
	friDO8GWmqJ/1M5tITTcmJSiauq4zI9FzbN2iAS3FZcPBeJB++vs+buHw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=6c2RdtcLhR3zr/QIZTKdBARjyyIAyxC57tVZiXAXuu4=; b=ebgaOEje
	XfLeeFoFbbWGsCIilHerM8zpmpJy9VuAqUO8SPANbdWIprBpImwjQmdZrH9GhpvA
	8y22W/Wbc/CMgPkQ7+k0faTquoLFuevD9AjwlQ63EfXd+Y1wrTLE0ZfKH0VUhShI
	dJ5kANFw0ck1R3xaJJZeupCViLpQn2+MH8mAN6VLz/6fQocCYM0g/qo1lRfhFAjO
	F0z1lvMra0Cnmab/qAoltLHx75BjisDU2yXcVz4N9+Vz44Et5eOoxHY0Cfo7dgLe
	/SRmB7VMc6yETKQshlBMU15sjPcoO2PI0zneCamMhkQzLJ4Yn7PoWOobQJEEFgTh
	QlriM+MpCcwWfA==
X-ME-Sender: <xms:hmWlXM9FYH_7Ot7DjZaYgh-NQjV7GXv91JpomDjv6lFU8NVUSGKK2A>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepudeg
X-ME-Proxy: <xmx:hmWlXCr7wu0uJB3DkKEAaD9fevhaMZQ-K40RlWpNK9bwuWu2SJFj0A>
    <xmx:hmWlXEXu1Vfr5Zqvnw9L5wf4lxn4Nvcyn0vZlOCUh3dOQcF4VEpqjA>
    <xmx:hmWlXBDMh2B-J5XnjjjZHXFfAPegU3l_3Yq-d_9l8Jd14dc92p8fzw>
    <xmx:hmWlXDQD-RvQadjRdtSkwgg6SMy5WewPJa-MpyAxgbg1B8_lkPF1Ig>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 5D7D01030F;
	Wed,  3 Apr 2019 22:01:40 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 16/25] exchange page: Add THP exchange support.
Date: Wed,  3 Apr 2019 19:00:37 -0700
Message-Id: <20190404020046.32741-17-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

Enable exchange THPs in the process. It also need to take care of
exchanging PTE-mapped THPs.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/exchange.h |  2 ++
 mm/exchange.c            | 73 +++++++++++++++++++++++++++++++++++++-----------
 mm/migrate.c             |  2 +-
 3 files changed, 60 insertions(+), 17 deletions(-)

diff --git a/include/linux/exchange.h b/include/linux/exchange.h
index 20d2184..8785d08 100644
--- a/include/linux/exchange.h
+++ b/include/linux/exchange.h
@@ -14,6 +14,8 @@ struct exchange_page_info {
 	int from_page_was_mapped;
 	int to_page_was_mapped;
 
+	pgoff_t from_index, to_index;
+
 	struct list_head list;
 };
 
diff --git a/mm/exchange.c b/mm/exchange.c
index 555a72c..45c7013 100644
--- a/mm/exchange.c
+++ b/mm/exchange.c
@@ -51,7 +51,8 @@ struct page_flags {
 	unsigned int page_swapcache:1;
 	unsigned int page_writeback:1;
 	unsigned int page_private:1;
-	unsigned int __pad:3;
+	unsigned int page_doublemap:1;
+	unsigned int __pad:2;
 };
 
 
@@ -127,20 +128,23 @@ static void exchange_huge_page(struct page *dst, struct page *src)
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
@@ -150,18 +154,22 @@ static void exchange_page_flags(struct page *to_page, struct page *from_page)
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
@@ -171,6 +179,7 @@ static void exchange_page_flags(struct page *to_page, struct page *from_page)
 	clear_page_idle(to_page);
 	to_page_flags.page_swapcache = PageSwapCache(to_page);
 	to_page_flags.page_writeback = test_clear_page_writeback(to_page);
+	to_page_flags.page_doublemap = PageDoubleMap(to_page);
 
 	/* set to_page */
 	if (from_page_flags.page_error)
@@ -197,6 +206,8 @@ static void exchange_page_flags(struct page *to_page, struct page *from_page)
 		set_page_young(to_page);
 	if (from_page_flags.page_is_idle)
 		set_page_idle(to_page);
+	if (from_page_flags.page_doublemap)
+		SetPageDoubleMap(to_page);
 
 	/* set from_page */
 	if (to_page_flags.page_error)
@@ -223,6 +234,8 @@ static void exchange_page_flags(struct page *to_page, struct page *from_page)
 		set_page_young(from_page);
 	if (to_page_flags.page_is_idle)
 		set_page_idle(from_page);
+	if (to_page_flags.page_doublemap)
+		SetPageDoubleMap(from_page);
 
 	/*
 	 * Copy NUMA information to the new page, to prevent over-eager
@@ -599,7 +612,6 @@ static int unmap_and_exchange(struct page *from_page, struct page *to_page,
 
 	from_index = from_page->index;
 	to_index = to_page->index;
-
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
@@ -673,8 +685,6 @@ static int unmap_and_exchange(struct page *from_page, struct page *to_page,
 			swap(from_page->index, from_index);
 	}
 
-
-
 out_unlock_both:
 	if (to_anon_vma)
 		put_anon_vma(to_anon_vma);
@@ -689,6 +699,23 @@ static int unmap_and_exchange(struct page *from_page, struct page *to_page,
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
@@ -745,7 +772,8 @@ int exchange_pages(struct list_head *exchange_list,
 		}
 
 		/* TODO: compound page not supported */
-		if (PageCompound(from_page) || page_mapping(from_page)) {
+		if (!can_be_exchanged(from_page, to_page) ||
+		    page_mapping(from_page)) {
 			++failed;
 			goto putback;
 		}
@@ -784,6 +812,8 @@ static int unmap_pair_pages_concur(struct exchange_page_info *one_pair,
 	struct page *from_page = one_pair->from_page;
 	struct page *to_page = one_pair->to_page;
 
+	one_pair->from_index = from_page->index;
+	one_pair->to_index = to_page->index;
 	/* from_page lock down  */
 	if (!trylock_page(from_page)) {
 		if (!force || ((mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC))
@@ -903,7 +933,6 @@ static int exchange_page_mapping_concur(struct list_head *unmapped_list_ptr,
 					   struct list_head *exchange_list_ptr,
 						enum migrate_mode mode)
 {
-	int rc = -EBUSY;
 	int nr_failed = 0;
 	struct address_space *to_page_mapping, *from_page_mapping;
 	struct exchange_page_info *one_pair, *one_pair2;
@@ -911,6 +940,7 @@ static int exchange_page_mapping_concur(struct list_head *unmapped_list_ptr,
 	list_for_each_entry_safe(one_pair, one_pair2, unmapped_list_ptr, list) {
 		struct page *from_page = one_pair->from_page;
 		struct page *to_page = one_pair->to_page;
+		int rc = -EBUSY;
 
 		VM_BUG_ON_PAGE(!PageLocked(from_page), from_page);
 		VM_BUG_ON_PAGE(!PageLocked(to_page), to_page);
@@ -926,8 +956,9 @@ static int exchange_page_mapping_concur(struct list_head *unmapped_list_ptr,
 		BUG_ON(PageWriteback(to_page));
 
 		/* actual page mapping exchange */
-		rc = exchange_page_move_mapping(to_page_mapping, from_page_mapping,
-							to_page, from_page, NULL, NULL, mode, 0, 0);
+		if (!page_mapped(from_page) && !page_mapped(to_page))
+			rc = exchange_page_move_mapping(to_page_mapping, from_page_mapping,
+								to_page, from_page, NULL, NULL, mode, 0, 0);
 
 		if (rc) {
 			if (one_pair->from_page_was_mapped)
@@ -954,7 +985,7 @@ static int exchange_page_mapping_concur(struct list_head *unmapped_list_ptr,
 			one_pair->from_page = NULL;
 			one_pair->to_page = NULL;
 
-			list_move(&one_pair->list, exchange_list_ptr);
+			list_del(&one_pair->list);
 			++nr_failed;
 		}
 	}
@@ -1026,8 +1057,18 @@ static int remove_migration_ptes_concur(struct list_head *unmapped_list_ptr)
 	struct exchange_page_info *iterator;
 
 	list_for_each_entry(iterator, unmapped_list_ptr, list) {
-		remove_migration_ptes(iterator->from_page, iterator->to_page, false);
-		remove_migration_ptes(iterator->to_page, iterator->from_page, false);
+		struct page *from_page = iterator->from_page;
+		struct page *to_page = iterator->to_page;
+
+		swap(from_page->index, iterator->from_index);
+		if (iterator->from_page_was_mapped)
+			remove_migration_ptes(iterator->from_page, iterator->to_page, false);
+		swap(from_page->index, iterator->from_index);
+
+		swap(to_page->index, iterator->to_index);
+		if (iterator->to_page_was_mapped)
+			remove_migration_ptes(iterator->to_page, iterator->from_page, false);
+		swap(to_page->index, iterator->to_index);
 
 
 		if (iterator->from_anon_vma)
diff --git a/mm/migrate.c b/mm/migrate.c
index a0ca817..da7af68 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -229,7 +229,7 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		if (PageKsm(page))
 			new = page;
 		else
-			new = page - pvmw.page->index +
+			new = page - page->index +
 				linear_page_index(vma, pvmw.address);
 
 #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
-- 
2.7.4

