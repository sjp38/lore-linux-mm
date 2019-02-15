Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4112C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:03:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 970452192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:03:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="llx8nrNY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 970452192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 849E68E0003; Fri, 15 Feb 2019 17:03:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F9828E0001; Fri, 15 Feb 2019 17:03:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 672488E0006; Fri, 15 Feb 2019 17:03:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB4B8E0003
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:03:51 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id x64so6906223ywc.6
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:03:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=AK8H5tpJ34j47t7xdPUWcNrKavgktr5lUYER4OwE6o4=;
        b=T4R1e3luEeHPfNcf0KsRLAK/LPrdI8nVGZL72sV79d99T3W0N1ftDhO91PPXqz1cY0
         h/gTL21Z+cmvlfNbzfoDOkp01w5lspBCiM33s8/7C1W5f3QsNI2RAC7lYPmpTgMSd6OB
         1+uZxFqesN4PRIL787czcMq916wXfYUnsfHcmVStOPtP4xUeFonK7nBfoKoxWAnYlbXN
         oI+8LmJCMR/4iT6IAuSDXVAUSIBSXKExEtRjCoDi+J5w5LipbSjWUAUqfUCG9JqrfzUi
         e44DHcehpzIZ36fVi4YaLA2V6oa6yPEcq7wxk0/iVP9lMHqNziresD6UcITGrgZ64s9i
         2B1g==
X-Gm-Message-State: AHQUAuYDnNpjfNRZPT8ZmKuV6lPc5mXYNP68bwthWPAexbzfstuPNCgj
	sd7EoO4ONJQtY0Tek8cAaELU5bTKdyUQiYP6jC3/K5SQGZr+Qhr6QY7eZ6xAysSEkFZcsitWehE
	u/IgsfRMV2tDrvKETf9HJVdJe2smytH8Nrt6H8F91iBvKHCls3MJeZvIRlUZf3XWrtQ==
X-Received: by 2002:a81:e0d:: with SMTP id 13mr9862544ywo.61.1550268230803;
        Fri, 15 Feb 2019 14:03:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZB6kd9HlNDbKx0V74xfCA9MSogTWvWZJME10yRjIv2bN2oZSYnGRDv0iOKqDiiKqCc/2z/
X-Received: by 2002:a81:e0d:: with SMTP id 13mr9862458ywo.61.1550268229652;
        Fri, 15 Feb 2019 14:03:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268229; cv=none;
        d=google.com; s=arc-20160816;
        b=o9xzDf4N0+iULgZLb7faUO5YE/2ZKl6xHqLp0Kru8Q/LvxE6FpNPZRYSGo9insCIsC
         FJOdCP0RGurTsHyU+SJbliYK62tjCWzl2HrLgnJQA3hFkT/sA7qtVO56uOzQOsZ3brju
         bAKeaOkYG3oR2WNgKffx5Zqjs7cF63iO3ACR5kKLANjXdDRzLgfhn+pBZ3LNtdAmSye6
         eBxdwXGk8K+Tk3RAlAf6UPCM9T6c2pm6cbdXLdK34w49Kf8v006I/p58TjgvlMyPeLbH
         BFp78u9efLlFyadGj3klML8wAFyOmD9qAbdWggeOEYSldE5+WAZOKhkleTWdJRz2rHJX
         tpmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=AK8H5tpJ34j47t7xdPUWcNrKavgktr5lUYER4OwE6o4=;
        b=PrjsdfzQhiB7dZslpgE7amVSN5qrMGAWUuDAMBAOKUWgqweJtMnV+Dmw6bxP867q9C
         SA+PrWtfSPbwP3tbcd9IsgnkzPOLcbMM5p1jAXJOgZRlUQSThyxCwHpVVODb6AmvqSax
         /snreYcSuoEPpIDLRtbH/DDe/7g631++CZIhGwo7OJXYl3xuMoPjamkY5RIfkd6O3fxA
         oiGO5/ppS+lbw1YYrSrNcr00i2YgytyEq6vArBof9+YeVpYlBXuLd9VrKADoyJzRDJKv
         xprGRydpovJJulD8aAZaqNG6MXk4K8+T2GuiRV+lWCxEP6EcWmR1mRs1iBYt9VWhT6QO
         FuZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=llx8nrNY;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id b5si3852075ybo.313.2019.02.15.14.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:03:49 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=llx8nrNY;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6737470002>; Fri, 15 Feb 2019 14:03:51 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 15 Feb 2019 14:03:48 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 15 Feb 2019 14:03:48 -0800
Received: from nvrsysarch5.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 15 Feb
 2019 22:03:48 +0000
From: Zi Yan <ziy@nvidia.com>
To: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko
	<mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>, John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>, Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>, Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 02/31] mm: migrate: Add THP exchange support.
Date: Fri, 15 Feb 2019 14:03:05 -0800
Message-ID: <20190215220334.29298-3-ziy@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220334.29298-1-ziy@nvidia.com>
References: <20190215220334.29298-1-ziy@nvidia.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550268231; bh=AK8H5tpJ34j47t7xdPUWcNrKavgktr5lUYER4OwE6o4=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Transfer-Encoding:Content-Type;
	b=llx8nrNYNyWAE9nMxnvaGVyiU6nNWXM9c63gW31afUQku2afncl5z2iFqFdrFKAdW
	 MBkHBNmhaxoQw2LCootR2cHJ0kqgsQO0OjfABw7A9iuSucSndYl0ZcSfKg56AVzJSv
	 NKy87FTDJ2owxBMBT14yW9N0n3n2ZYfK+1oBB5Huf9R6HCm4ey7MxK5XKvIiE0BQzh
	 gJW0b/b+Jx2Xoen9iWY0845hNMm84tuHAgqHha9mh4qdQO3lawBmjTTo30uAygaKu8
	 iMAtqmtpUcv784RnR4Nk5i/nC0PqIMWgPxucrbFc4rd7/KTQk3FlOPvCopGP1yFkwX
	 VnNhO1hCqWkTw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
=20
=20
@@ -125,20 +126,23 @@ static void exchange_huge_page(struct page *dst, stru=
ct page *src)
 static void exchange_page_flags(struct page *to_page, struct page *from_pa=
ge)
 {
 	int from_cpupid, to_cpupid;
-	struct page_flags from_page_flags, to_page_flags;
+	struct page_flags from_page_flags =3D {0}, to_page_flags =3D {0};
 	struct mem_cgroup *to_memcg =3D page_memcg(to_page),
 					  *from_memcg =3D page_memcg(from_page);
=20
 	from_cpupid =3D page_cpupid_xchg_last(from_page, -1);
=20
-	from_page_flags.page_error =3D TestClearPageError(from_page);
+	from_page_flags.page_error =3D PageError(from_page);
+	if (from_page_flags.page_error)
+		ClearPageError(from_page);
 	from_page_flags.page_referenced =3D TestClearPageReferenced(from_page);
 	from_page_flags.page_uptodate =3D PageUptodate(from_page);
 	ClearPageUptodate(from_page);
 	from_page_flags.page_active =3D TestClearPageActive(from_page);
 	from_page_flags.page_unevictable =3D TestClearPageUnevictable(from_page);
 	from_page_flags.page_checked =3D PageChecked(from_page);
-	ClearPageChecked(from_page);
+	if (from_page_flags.page_checked)
+		ClearPageChecked(from_page);
 	from_page_flags.page_mappedtodisk =3D PageMappedToDisk(from_page);
 	ClearPageMappedToDisk(from_page);
 	from_page_flags.page_dirty =3D PageDirty(from_page);
@@ -148,18 +152,22 @@ static void exchange_page_flags(struct page *to_page,=
 struct page *from_page)
 	clear_page_idle(from_page);
 	from_page_flags.page_swapcache =3D PageSwapCache(from_page);
 	from_page_flags.page_writeback =3D test_clear_page_writeback(from_page);
+	from_page_flags.page_doublemap =3D PageDoubleMap(from_page);
=20
=20
 	to_cpupid =3D page_cpupid_xchg_last(to_page, -1);
=20
-	to_page_flags.page_error =3D TestClearPageError(to_page);
+	to_page_flags.page_error =3D PageError(to_page);
+	if (to_page_flags.page_error)
+		ClearPageError(to_page);
 	to_page_flags.page_referenced =3D TestClearPageReferenced(to_page);
 	to_page_flags.page_uptodate =3D PageUptodate(to_page);
 	ClearPageUptodate(to_page);
 	to_page_flags.page_active =3D TestClearPageActive(to_page);
 	to_page_flags.page_unevictable =3D TestClearPageUnevictable(to_page);
 	to_page_flags.page_checked =3D PageChecked(to_page);
-	ClearPageChecked(to_page);
+	if (to_page_flags.page_checked)
+		ClearPageChecked(to_page);
 	to_page_flags.page_mappedtodisk =3D PageMappedToDisk(to_page);
 	ClearPageMappedToDisk(to_page);
 	to_page_flags.page_dirty =3D PageDirty(to_page);
@@ -169,6 +177,7 @@ static void exchange_page_flags(struct page *to_page, s=
truct page *from_page)
 	clear_page_idle(to_page);
 	to_page_flags.page_swapcache =3D PageSwapCache(to_page);
 	to_page_flags.page_writeback =3D test_clear_page_writeback(to_page);
+	to_page_flags.page_doublemap =3D PageDoubleMap(to_page);
=20
 	/* set to_page */
 	if (from_page_flags.page_error)
@@ -195,6 +204,8 @@ static void exchange_page_flags(struct page *to_page, s=
truct page *from_page)
 		set_page_young(to_page);
 	if (from_page_flags.page_is_idle)
 		set_page_idle(to_page);
+	if (from_page_flags.page_doublemap)
+		SetPageDoubleMap(to_page);
=20
 	/* set from_page */
 	if (to_page_flags.page_error)
@@ -221,6 +232,8 @@ static void exchange_page_flags(struct page *to_page, s=
truct page *from_page)
 		set_page_young(from_page);
 	if (to_page_flags.page_is_idle)
 		set_page_idle(from_page);
+	if (to_page_flags.page_doublemap)
+		SetPageDoubleMap(from_page);
=20
 	/*
 	 * Copy NUMA information to the new page, to prevent over-eager
@@ -280,6 +293,7 @@ static int exchange_page_move_mapping(struct address_sp=
ace *to_mapping,
=20
 	VM_BUG_ON_PAGE(to_mapping !=3D page_mapping(to_page), to_page);
 	VM_BUG_ON_PAGE(from_mapping !=3D page_mapping(from_page), from_page);
+	VM_BUG_ON(PageCompound(from_page) !=3D PageCompound(to_page));
=20
 	if (!to_mapping) {
 		/* Anonymous page without mapping */
@@ -600,7 +614,6 @@ static int unmap_and_exchange(struct page *from_page,
 	to_mapping =3D to_page->mapping;
 	from_index =3D from_page->index;
 	to_index =3D to_page->index;
-
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
@@ -691,6 +704,23 @@ static int unmap_and_exchange(struct page *from_page,
 	return rc;
 }
=20
+static bool can_be_exchanged(struct page *from, struct page *to)
+{
+	if (PageCompound(from) !=3D PageCompound(to))
+		return false;
+
+	if (PageHuge(from) !=3D PageHuge(to))
+		return false;
+
+	if (PageHuge(from) || PageHuge(to))
+		return false;
+
+	if (compound_order(from) !=3D compound_order(to))
+		return false;
+
+	return true;
+}
+
 /*
  * Exchange pages in the exchange_list
  *
@@ -751,9 +781,8 @@ static int exchange_pages(struct list_head *exchange_li=
st,
 			continue;
 		}
=20
-		/* TODO: compound page not supported */
 		/* to_page can be file-backed page  */
-		if (PageCompound(from_page) ||
+		if (!can_be_exchanged(from_page, to_page) ||
 			page_mapping(from_page)
 			) {
 			++failed;
--=20
2.20.1

