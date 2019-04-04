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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A38EEC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DE3A20820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="V0JIpLVR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kwN41DXj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DE3A20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DE4A6B0266; Wed,  3 Apr 2019 22:01:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18CDD6B0269; Wed,  3 Apr 2019 22:01:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 007E86B026A; Wed,  3 Apr 2019 22:01:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D09416B0266
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:20 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 77so942259qkd.9
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=sTcFdQ0uTFmNEqF/buqEuv4aNZlA40xkHnCTG+zeMnI=;
        b=BKFFXFSUXH2aIGQDPot0UOjIwSse2CrkO+PsrPzsWpzaZJTud1brDEScaIB7b8TrGw
         QsFUPIOAeH6VmWP+ezgRu38NzvwuvORUW0BlBRyCns+sWsyxD+MC1XXRxn4Cy0cTOCfU
         ROdO8lFY5QsC1VwXgceKAJfmsWcLUZHD1Fw+GZFyFVBzLULi25YzNlpOFwgid6lG6Fop
         /QfE1iEfXHk+ilqo12FS25dgESMtSFMoSLAA3et24d+V9TEBotT0gqyiPwaeho8stfJz
         669CTV1/eOClYZHj26pIBZUqesDKim3/QjEe/dBaJT4OIEqjGy1xydWI+AdobDvqr0n5
         OpDA==
X-Gm-Message-State: APjAAAUJFISRGHiWjP08g5Q+gf2lgTw8htzTjqaeIFzmaASgj5S1m2Oy
	rAqIJ9GNnsNmBvboTlCsglbr/nafN7odZwofjiPOX4NDfyofw2ei23FRg7HLxBPstR4V60Fctoy
	nkdLEV7BSfwHKKf6ykf1XEYvuIMAVFwhV5mBPt9afl5PIicZgi68X54gNg2/gFt7wKQ==
X-Received: by 2002:ac8:2de7:: with SMTP id q36mr3023094qta.3.1554343280557;
        Wed, 03 Apr 2019 19:01:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy39vXIqXru2GmNHldv70bAIrmJnzf1lYkt7slQ6+loiMlhxTFvjQfz5Wty6PaD/ihSg79p
X-Received: by 2002:ac8:2de7:: with SMTP id q36mr3023061qta.3.1554343279862;
        Wed, 03 Apr 2019 19:01:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343279; cv=none;
        d=google.com; s=arc-20160816;
        b=nZY4PGIWWvDW2Vtc+y43zp2EqUwTY7Tlmo22vfJqusQ8APXh4gPnN5bbozGT7iYyzY
         +pQXzWqo8pLfKjIdpIi3l4WYE6GIs1041EWj9GWW8QpY+ogjATFS9lAQfnCgjR31UK6k
         Ys6+QvstL8qybM/KdX7/5yIAymg4CssfiS/Yr0Rf3m+4XMO4TnyFwCWJn4jIAIKk72nx
         6+RHDv9utm28pcHHQtASkqxaaU06OPzHeD8yKAuO4cwYlaR+ns5GpTUvO8ITv5MQ9u8S
         erpbBGNMK2MysvsyF/3098e6eDrXl0PkW9oenQKhnouWnoFfcphDFHHBM++YfqcJJMcO
         zdNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=sTcFdQ0uTFmNEqF/buqEuv4aNZlA40xkHnCTG+zeMnI=;
        b=khQNHX8DhKs/JH/dR32QC0I+b4ilOv5MGFiinFecFigNwVkKBNi+FxMbK69qZib8Zu
         ODnbhNjPZO85I/VtWmBau0nA3Jy/HD6VdSirEMXdORrHm3q3nSEORLUq0EIeobYfH5Oe
         NGl7By+BLikt/TPn3kNQsyEyfLRmJbIazzamK8NJNHRlzXO+prKx1lmqFD7vdr6fkrtJ
         1W10rUozRJxeSONiuRTY85YXJ8sksWBblH+OxNmoHMfk3cT5sPbT1q9Clt+WPpfmNbFk
         tqs37TUIWA8xyUmsV+7QhYaYbPLfEAW3UtD1jRlyNtPWi3sEgekgU9F1+t/DinLXnytR
         z1HQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=V0JIpLVR;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kwN41DXj;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id a29si8169888qte.337.2019.04.03.19.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=V0JIpLVR;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kwN41DXj;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 8F98A2257C;
	Wed,  3 Apr 2019 22:01:19 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=sTcFdQ0uTFmNE
	qF/buqEuv4aNZlA40xkHnCTG+zeMnI=; b=V0JIpLVR1+jFUK3V21cuqVcW5pHEz
	EjA/Azwlmjyub9N3bs1MsXPgbBsO2TbK48M6mumUTV6WCI5VuqZYbRO+GKb/F2T2
	Vjd2VxpLT5dcKrq5JWA4CIlwCOot8ZdU6Zmwu5DyJLLe1fAQfq+XaO0/mHN97L7p
	YC4X04nk0pRDz0tbycrlOugeHPKN7jLOUHyb9Wl6UCug0pM0yQ8SbaCQ/vvCdVRP
	OHuhIP2qIUYE/YZrDf/47drANb1XAr4qHcJ1ChcZ/Z1cqry5k+pBRCptIjE/yqZZ
	Lxni0AmzKX5tCCHhHXao1ySlxQRlPOnWX9cXwelHJVeYAdC6lFbQMbqJw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=sTcFdQ0uTFmNEqF/buqEuv4aNZlA40xkHnCTG+zeMnI=; b=kwN41DXj
	0DXVNlAxGxdTXxrF5A2KNJ+rdQQp1auwloTcMOilZmB5wftzWBgF7+BDjm+haTXZ
	wY29smEaDNOa3uKbyjcnfL8JvksBch6T2C7Ad10foa0wKFC7NGFnytKrGpR5BF1j
	oLXtBZaMW3XgQa44IumNHFDXQQYLe4L12argM29pFDY/tnqldRBoMba9+CmEEWNx
	R2A2J4fg64nzem4SqoPRSUl+IvAHSHBse7s1+SairkNqiGloxy0aNrqhwaUv/ah4
	7zWfKW37ypooI9QzHt3wWiNkuwK3fkvoK75RkCnuRRm3eJhdgW66K2a4BC3uPOzv
	0A3gJOEARFO6gg==
X-ME-Sender: <xms:b2WlXJ8bA-lDT3VHdgPRjn_5Hsp3Mqwi9lpR8mBd0euFcUeWgvbLiA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepud
X-ME-Proxy: <xmx:b2WlXOFQxiOiliFuPG8mH7q2qS5LiXwJTaGh8BGrA9sOcl9__tyYOA>
    <xmx:b2WlXIKjQJTn-jjyrRRDe2uzqLM9dfeD3aGjnIic17b7oFwT3WS6hA>
    <xmx:b2WlXJcbFkgxahdc-KRWChWnzGPG8pOBdTCPfWDMrGAHqpez3U_gfA>
    <xmx:b2WlXJe2T1qRo07QZEcV4zvxgONBjyDRWPRRQjMoHqq5Q3EVexhH0w>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id B33B51030F;
	Wed,  3 Apr 2019 22:01:17 -0400 (EDT)
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
Subject: [RFC PATCH 04/25] mm: migrate: Add copy_page_multithread into migrate_pages.
Date: Wed,  3 Apr 2019 19:00:25 -0700
Message-Id: <20190404020046.32741-5-zi.yan@sent.com>
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

An option is added to move_pages() syscall to use multi-threaded
page migration.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/migrate_mode.h   |  1 +
 include/uapi/linux/mempolicy.h |  2 ++
 mm/migrate.c                   | 29 +++++++++++++++++++----------
 3 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index da44940..5bc8a77 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -22,6 +22,7 @@ enum migrate_mode {
 
 	MIGRATE_MODE_MASK = 3,
 	MIGRATE_SINGLETHREAD	= 0,
+	MIGRATE_MT				= 1<<4,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 3354774..890269b 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -48,6 +48,8 @@ enum {
 #define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
 #define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
 
+#define MPOL_MF_MOVE_MT  (1<<6)	/* Use multi-threaded page copy routine */
+
 #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
 			 MPOL_MF_MOVE     | 	\
 			 MPOL_MF_MOVE_ALL)
diff --git a/mm/migrate.c b/mm/migrate.c
index 2b2653e..dd6ccbe 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -572,6 +572,7 @@ static void copy_huge_page(struct page *dst, struct page *src,
 {
 	int i;
 	int nr_pages;
+	int rc = -EFAULT;
 
 	if (PageHuge(src)) {
 		/* hugetlbfs page */
@@ -588,10 +589,14 @@ static void copy_huge_page(struct page *dst, struct page *src,
 		nr_pages = hpage_nr_pages(src);
 	}
 
-	for (i = 0; i < nr_pages; i++) {
-		cond_resched();
-		copy_highpage(dst + i, src + i);
-	}
+	if (mode & MIGRATE_MT)
+		rc = copy_page_multithread(dst, src, nr_pages);
+
+	if (rc)
+		for (i = 0; i < nr_pages; i++) {
+			cond_resched();
+			copy_highpage(dst + i, src + i);
+		}
 }
 
 /*
@@ -1500,7 +1505,7 @@ static int store_status(int __user *status, int start, int value, int nr)
 }
 
 static int do_move_pages_to_node(struct mm_struct *mm,
-		struct list_head *pagelist, int node)
+		struct list_head *pagelist, int node, bool migrate_mt)
 {
 	int err;
 
@@ -1508,7 +1513,8 @@ static int do_move_pages_to_node(struct mm_struct *mm,
 		return 0;
 
 	err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
-			MIGRATE_SYNC, MR_SYSCALL);
+			MIGRATE_SYNC | (migrate_mt ? MIGRATE_MT : MIGRATE_SINGLETHREAD),
+			MR_SYSCALL);
 	if (err)
 		putback_movable_pages(pagelist);
 	return err;
@@ -1629,7 +1635,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 			current_node = node;
 			start = i;
 		} else if (node != current_node) {
-			err = do_move_pages_to_node(mm, &pagelist, current_node);
+			err = do_move_pages_to_node(mm, &pagelist, current_node,
+				flags & MPOL_MF_MOVE_MT);
 			if (err)
 				goto out;
 			err = store_status(status, start, current_node, i - start);
@@ -1652,7 +1659,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		if (err)
 			goto out_flush;
 
-		err = do_move_pages_to_node(mm, &pagelist, current_node);
+		err = do_move_pages_to_node(mm, &pagelist, current_node,
+				flags & MPOL_MF_MOVE_MT);
 		if (err)
 			goto out;
 		if (i > start) {
@@ -1667,7 +1675,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		return err;
 
 	/* Make sure we do not overwrite the existing error */
-	err1 = do_move_pages_to_node(mm, &pagelist, current_node);
+	err1 = do_move_pages_to_node(mm, &pagelist, current_node,
+				flags & MPOL_MF_MOVE_MT);
 	if (!err1)
 		err1 = store_status(status, start, current_node, i - start);
 	if (!err)
@@ -1763,7 +1772,7 @@ static int kernel_move_pages(pid_t pid, unsigned long nr_pages,
 	nodemask_t task_nodes;
 
 	/* Check flags */
-	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
+	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_MOVE_MT))
 		return -EINVAL;
 
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
-- 
2.7.4

