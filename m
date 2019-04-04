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
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBDEEC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C47620820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="YnCSB3YN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="jdmARHKr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C47620820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E86686B026C; Wed,  3 Apr 2019 22:01:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E37AF6B026D; Wed,  3 Apr 2019 22:01:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDC546B026E; Wed,  3 Apr 2019 22:01:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE406B026C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:30 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q21so954432qtf.10
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=VIkgM+882IONo3Guhv/rUEZozu4u9IBUTwV5VJxdnmI=;
        b=N0DW1bHJq4spRT3usTiIrqFQ03pDlT2QppFx2/B+Z/oVFxLezSnFXH+pKqqCB2+j/4
         yHyPOvPYrH2OVQTIVnaD57i68X/XuqwE6PUsvzfxkgt1l3kE///byg9V+pBvcyJr8czD
         qdv4t2VlMihUr8gjKrVluCdVsbHViTVXhSWwyPnJYyYgbsSJJg1oLDI7sGU4c3BfrQgG
         4kfuSWoJOhPk9RZkkje1rNiPjOL7D4QMHA4/7JP/U0hbRra7Kiwi9+i4e10FS8ijhVtn
         VxqmnN9ZUf1tUAs3x7hQhRfaIdSiyuEIMOHZai+u8Sx7PLp3lJDok2EN6f68Vq7XgVgi
         Pscg==
X-Gm-Message-State: APjAAAUSEZGUFdkL6OzDeaxTn6/KibfxwLn3SbQoH40l3RXpyh35NbES
	lGySQnUClSoatPzJvG2TQrxENpx5QYwCskE4JYJxDhqApm9LSAtZQFJHZyap+PtldFxv/ErdOVa
	5otG0okVs0ofCpT+FrmntAPsnC2d2GQH7gO72IxvZXZ0/34VKfQ+8VzZZopjaAaNFXA==
X-Received: by 2002:aed:2196:: with SMTP id l22mr2947532qtc.226.1554343290392;
        Wed, 03 Apr 2019 19:01:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyq5MgJsfL/87NNpSX5/eeP8tmAjwj8BbRJ0J2GVaDaDVOh2tJGrj1a+EctuF6z8uB5uf5W
X-Received: by 2002:aed:2196:: with SMTP id l22mr2947479qtc.226.1554343289580;
        Wed, 03 Apr 2019 19:01:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343289; cv=none;
        d=google.com; s=arc-20160816;
        b=EMNR9gIExzZKBEJSJUdPisFeHKIfmZgDih8hhTsuVVL/mc0Lt4PMaISSnZbLgDE5UJ
         n/6euq4MX0pzVn7grzKcWifjSF9TJdAvavTdH1Chb0PA3JJkW6r5+Yyfuxjc56rOxeNX
         BmrYpg9K6OV0WYTenMk35DQoSGDyQBkkMYUnMoE6VIQRjA2TYmeZoEjrnEHa0oLZLKBA
         lcC7QgUbisUdiN+OhkQkxSL8KUHlel4PeDjKKxgAW73J+xmufxV/5c74+4YpqM6pZfQW
         7F0xz/UZ6ntwuuhKo8JSnDDXLJswKllVopQ6XPNJFPopnkanW5HGpRO2kCURYFfycX6e
         sn1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=VIkgM+882IONo3Guhv/rUEZozu4u9IBUTwV5VJxdnmI=;
        b=EdeR9nf+3kvLz3zN3Vh6L8NUFQzFyIACoT6nsuaGi1ykG3Un4J86CvrIud0dp9T31G
         w/DOEuq56EFNE3KfkZperCWs/PbnKYCtybERPjN1zkY6Acr42tCqMQGMHhVryYxOs7YK
         019SDv3U/1jtcv4/OsyiR1YV6hBgVP7v2FcqSFq6WqqMK780phFS3jYeVhwEtoqDc2NV
         AdW2ZQuGIJw+PHyv+xUtFQ7jt5ZfAQoU/NB0r2BEzQXvDvcO19a1rbqbINjKehY4yzpU
         z07h9Qr6IW/RUB6cX0O50gKnAT0HpJW57c7N+BPvkkdGfX5gJHTa6mwtSbaECDi1J62a
         nhGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=YnCSB3YN;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=jdmARHKr;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id t17si4638019qkt.181.2019.04.03.19.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=YnCSB3YN;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=jdmARHKr;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id BC556226AD;
	Wed,  3 Apr 2019 22:01:28 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=VIkgM+882IONo
	3Guhv/rUEZozu4u9IBUTwV5VJxdnmI=; b=YnCSB3YNRz/K6xN+4chFMo1NLtyZ0
	kfSrQtI9P1RLihuwc5xXZ086brvPD38Tj81bn6cCtVcknYPaPuPm3mzKZEy8TIlI
	brQvSbwJe/XEAqOofxIGsuZNFXSsQV4vJiZZq3Uvko0zNgM2Nt4qS8jxInGurjaa
	M3nMz1hhMw4mRPw31I8o/ONAOLsP371pKpx134KkRijpljihQHgWwQqHkU+uO/tz
	UIF9+XCbyMYto9Lv3LtxTKIyj6YhubPWzxaoSgDnWTccQs856/ISylyoprlXRxhy
	R15JZ0nbIBY+PbPcSI4OZoyYid9V88Y6wHJMt4xDMHfzwHLqNrnccDbkA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=VIkgM+882IONo3Guhv/rUEZozu4u9IBUTwV5VJxdnmI=; b=jdmARHKr
	73TxQMOntRLiEEfU1UDhBk9EGXmzpkGXFKVh4e4cGq7/FmBPaRIRgfXZmNN0cJej
	xyfBRN79joGo30hm1m8rJ9b7sJBMpwZSPRCD0KWO6FezA26TBPU41/dRaEPC9ZSA
	iQ2lMy54De3y7HRMG2ZVBisXUZdRFkPo6T2hKZ8uyptRf1k2W0GtsbUG4KcYoVQ6
	rcD0/L7QOo09OnoVosRDag+/RLLdcYhQPNWVZWb3bUUF7wBuPKTmkEiARvtFZMlV
	grBvJrHk3D2q0cAgz0NKJwMCSXARybhdFybXKKowkjvXra+9JvBXVksHoVX3BbIx
	lHvFwhe9zrgbsQ==
X-ME-Sender: <xms:eGWlXAG8AkZYSt82ETEFehdC-PiWjWrLc27UJXw2pil3iLV9YTBScw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepje
X-ME-Proxy: <xmx:eGWlXDAAUWnSD5rmseVGbFBJfMXVtD_BZ2uVjLzw1twWuI1jFlAaog>
    <xmx:eGWlXBEUYSU_DaHgvrYiCgfVZ4oj96cy8cyAUaO6YrF9etYpLqvdSw>
    <xmx:eGWlXGLuQASrUtnnheDKwlA1iHw7bxs7wlhbf8TFZq-03sUcSPukKA>
    <xmx:eGWlXC8giEOkshyQcTrDY7HrKKM3M1A8EUWa0wHdQWQ89RoFW47hMQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 87CC310316;
	Wed,  3 Apr 2019 22:01:26 -0400 (EDT)
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
Subject: [RFC PATCH 08/25] mm: migrate: Add copy_page_dma into migrate_page_copy.
Date: Wed,  3 Apr 2019 19:00:29 -0700
Message-Id: <20190404020046.32741-9-zi.yan@sent.com>
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

Fallback to copy_highpage when it fails.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/migrate_mode.h   |  1 +
 include/uapi/linux/mempolicy.h |  1 +
 mm/migrate.c                   | 31 +++++++++++++++++++++----------
 3 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 5bc8a77..4f7f5557 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -23,6 +23,7 @@ enum migrate_mode {
 	MIGRATE_MODE_MASK = 3,
 	MIGRATE_SINGLETHREAD	= 0,
 	MIGRATE_MT				= 1<<4,
+	MIGRATE_DMA				= 1<<5,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 890269b..49573a6 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -48,6 +48,7 @@ enum {
 #define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
 #define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
 
+#define MPOL_MF_MOVE_DMA (1<<5)	/* Use DMA page copy routine */
 #define MPOL_MF_MOVE_MT  (1<<6)	/* Use multi-threaded page copy routine */
 
 #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
diff --git a/mm/migrate.c b/mm/migrate.c
index 8a344e2..09114d3 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -553,15 +553,21 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
  * specialized.
  */
 static void __copy_gigantic_page(struct page *dst, struct page *src,
-				int nr_pages)
+				int nr_pages, enum migrate_mode mode)
 {
 	int i;
 	struct page *dst_base = dst;
 	struct page *src_base = src;
+	int rc = -EFAULT;
 
 	for (i = 0; i < nr_pages; ) {
 		cond_resched();
-		copy_highpage(dst, src);
+
+		if (mode & MIGRATE_DMA)
+			rc = copy_page_dma(dst, src, 1);
+
+		if (rc)
+			copy_highpage(dst, src);
 
 		i++;
 		dst = mem_map_next(dst, dst_base, i);
@@ -582,7 +588,7 @@ static void copy_huge_page(struct page *dst, struct page *src,
 		nr_pages = pages_per_huge_page(h);
 
 		if (unlikely(nr_pages > MAX_ORDER_NR_PAGES)) {
-			__copy_gigantic_page(dst, src, nr_pages);
+			__copy_gigantic_page(dst, src, nr_pages, mode);
 			return;
 		}
 	} else {
@@ -597,6 +603,8 @@ static void copy_huge_page(struct page *dst, struct page *src,
 
 	if (mode & MIGRATE_MT)
 		rc = copy_page_multithread(dst, src, nr_pages);
+	else if (mode & MIGRATE_DMA)
+		rc = copy_page_dma(dst, src, nr_pages);
 
 	if (rc)
 		for (i = 0; i < nr_pages; i++) {
@@ -674,8 +682,9 @@ void migrate_page_copy(struct page *newpage, struct page *page,
 {
 	if (PageHuge(page) || PageTransHuge(page))
 		copy_huge_page(newpage, page, mode);
-	else
+	else {
 		copy_highpage(newpage, page);
+	}
 
 	migrate_page_states(newpage, page);
 }
@@ -1511,7 +1520,8 @@ static int store_status(int __user *status, int start, int value, int nr)
 }
 
 static int do_move_pages_to_node(struct mm_struct *mm,
-		struct list_head *pagelist, int node, bool migrate_mt)
+		struct list_head *pagelist, int node,
+		bool migrate_mt, bool migrate_dma)
 {
 	int err;
 
@@ -1519,7 +1529,8 @@ static int do_move_pages_to_node(struct mm_struct *mm,
 		return 0;
 
 	err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
-			MIGRATE_SYNC | (migrate_mt ? MIGRATE_MT : MIGRATE_SINGLETHREAD),
+			MIGRATE_SYNC | (migrate_mt ? MIGRATE_MT : MIGRATE_SINGLETHREAD) |
+			(migrate_dma ? MIGRATE_DMA : MIGRATE_SINGLETHREAD),
 			MR_SYSCALL);
 	if (err)
 		putback_movable_pages(pagelist);
@@ -1642,7 +1653,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 			start = i;
 		} else if (node != current_node) {
 			err = do_move_pages_to_node(mm, &pagelist, current_node,
-				flags & MPOL_MF_MOVE_MT);
+				flags & MPOL_MF_MOVE_MT, flags & MPOL_MF_MOVE_DMA);
 			if (err)
 				goto out;
 			err = store_status(status, start, current_node, i - start);
@@ -1666,7 +1677,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 			goto out_flush;
 
 		err = do_move_pages_to_node(mm, &pagelist, current_node,
-				flags & MPOL_MF_MOVE_MT);
+				flags & MPOL_MF_MOVE_MT, flags & MPOL_MF_MOVE_DMA);
 		if (err)
 			goto out;
 		if (i > start) {
@@ -1682,7 +1693,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 
 	/* Make sure we do not overwrite the existing error */
 	err1 = do_move_pages_to_node(mm, &pagelist, current_node,
-				flags & MPOL_MF_MOVE_MT);
+				flags & MPOL_MF_MOVE_MT, flags & MPOL_MF_MOVE_DMA);
 	if (!err1)
 		err1 = store_status(status, start, current_node, i - start);
 	if (!err)
@@ -1778,7 +1789,7 @@ static int kernel_move_pages(pid_t pid, unsigned long nr_pages,
 	nodemask_t task_nodes;
 
 	/* Check flags */
-	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_MOVE_MT))
+	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_MOVE_MT|MPOL_MF_MOVE_DMA))
 		return -EINVAL;
 
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
-- 
2.7.4

