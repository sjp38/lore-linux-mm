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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F223C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49F9820820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="ZTcljXgK";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FQOkb9gU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49F9820820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 204826B027A; Wed,  3 Apr 2019 22:01:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18DE16B027B; Wed,  3 Apr 2019 22:01:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02CA76B027C; Wed,  3 Apr 2019 22:01:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE65C6B027A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e31so992355qtb.0
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=90OfIYrsLVV/XL3gUGgucTsSXTyMHPlo/8YAawvSo30=;
        b=n3grSJwMfbjEwDW8H2n/eobdlhda1UmMg8GE/MbZDrP9wtFk9Pjrf8BC5VDLcqOJ0H
         ZSK+xx7I62U6DUHdW1r15XoB7kZypxN+9BhsoubSC3x51uhdFKr2hAFx/sOJ/eFXmTJo
         CSUDxTAvq6UKpOMSz0gcDPXZzp67pbHpeDlWIxT0e5tjhSimJl98KTskBafiBZxbzqxK
         u9nBM5Mp4zRqrkOLqHOjf5wqqkifrLMT7hIB32329a8Xek5bhiROqcCGdeWgKHelM7YI
         jt7aVsMN3mXDOQLaZgDIxMvqH/KPW6RbOnSUFGO1xHPoLO6NEJGHOrutZCYQRlm86Sce
         E1fQ==
X-Gm-Message-State: APjAAAX7WmUrsA3hUeVMtt3d5C795UbPTTxRMW0LpVGSs8+0BfHT192L
	o+/hXyWSU46kSgIZfbjTjtr34Ddy41hMO/gjJdYKABL6jxzsLRSvv7Ib7DOMUeDXsRqrKScTL8N
	Mq5tXVtDOZUJceOnO7EYhWDlh+fdgbfiZOZpt4qUc6Y0QUoj2IiEctMQgRBbydxXF2w==
X-Received: by 2002:a37:a951:: with SMTP id s78mr3017943qke.156.1554343311611;
        Wed, 03 Apr 2019 19:01:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjn258cLnJ7bgvm+aa4cBXXdg/woh58sSDbcEimezbePKmO2yA3ZyewQa1gnm6yWr6WgaG
X-Received: by 2002:a37:a951:: with SMTP id s78mr3017906qke.156.1554343310995;
        Wed, 03 Apr 2019 19:01:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343310; cv=none;
        d=google.com; s=arc-20160816;
        b=tyaZMvfRRGMFELbNjhsmZ01JGoj8mQBq7CDmdZ8OVkqwXJahrh9knppdgQc3OORhlL
         Z4PvQ3JvSscOcmvzfECBereLlQjt8vYpkDqWiURjFXJWi1PtaluPax6u5MTAl+ux6TFU
         yp14TJA/UQQbo3drItmOSPGeLMie/JtuXDK4RnEMXoi2LzHj09z9AG+W+Ni/zRnwYGxJ
         rEt7+heHtRPQDh9+0R3pT1Ntu7+7ZfvGBKpd3nivVVnmARCURMv46ytNFKa/FGqc48ZM
         Qq6wAQlLGlOBjipOkZOVhWXRLU0jqd3yUH/5FbEjEUOJgdHGeVucsL2CV66xJGo7Qyx3
         Sh5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=90OfIYrsLVV/XL3gUGgucTsSXTyMHPlo/8YAawvSo30=;
        b=Rila6CRvYblPJhzjZPpVRHjjAgbU7L+XLmvAF75cV494Ld9pRt5EBStEbcK+Xd8bas
         Wk+Vjvg99k6qQtZ7tq8QYoh3tiqT0hmbnPR8Hirg7VSZrPlTnBHgOVlQWlqWlDBx5xqz
         jwCtX/g6h+GNJAKLYMscBMw/pYD+zFN4JFq0Y25VPVHg+wXASA9uzRVPjd/QM89nhW8k
         1tQ9Rs9Kw8BiFTwCwKYUuKZ2jCQ6beCr0Wy/YGK0Iwa5fr3nMN3/1mOTmT6HeHZzihxW
         RE7WKyclUPXXM20cowun6zLdj4Hey0882C+xo9K8uO5B0XwKXLw01Wvd3+VYUlYdNAsV
         a8TQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=ZTcljXgK;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FQOkb9gU;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id h37si422424qvh.81.2019.04.03.19.01.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=ZTcljXgK;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FQOkb9gU;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id B644522AB8;
	Wed,  3 Apr 2019 22:01:50 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=90OfIYrsLVV/X
	L3gUGgucTsSXTyMHPlo/8YAawvSo30=; b=ZTcljXgKyrhIcGFZqw0NEMiVpsJTj
	WIedhk8FmwdAwNdcO/lmKhbASK3zQyp8yrVxgQiD9s80HAVdqAxKpAXfrUwQgwDS
	HgjyFJJtczMeURxtFvM3M5d9ca37WW0IaGa+7sRAGhTZBv+q1lOX2o7q8mzaWX5y
	/wc/XLxzzCJtsPDZUaf+ZX5sulfsDLUVeQAOMAB1GROLM370bU+EU5LVZ2Or6n0Y
	a5PK3Zx9vxs3sgzGvieVLHnMK57yuhLB3QuzYX8XxPpsLxGFvAmwg7YYsCBPFUcQ
	vR/sZSU4THIU844zmdtAJMJ27ZujmNsbFVEvUkqlq8rhZZhksVXBf/SSQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=90OfIYrsLVV/XL3gUGgucTsSXTyMHPlo/8YAawvSo30=; b=FQOkb9gU
	Wkt8yUg1JLS3hUvT+MWCzBfCq1LO4fDjtBiCZmKlCrIXPv9WDGmMQQTncX5wHiI0
	DSYBHbRosU5Mu8R+OPCgLMc5VDnC9PiMahmjzc+tNFdNQw8tPpvof+UMuCFZ3A8V
	Gkk3N7WpIe1eJ7y6oljn0705l7NXHq1RE/rm8Y7oFB3Xqod0Q9liAKUeVmQ/I38H
	/KybQVLISD/6fmLiBCGgLOy2OyLz7GQwlGiSyBHJJSterSdu4vFe1iZSrjwzJrkf
	hZVH+e71873++cIHWH9Gp+0SNUk4PquC3YQfZ37jddtruYC4WXKR1MpK8Vg/ICUJ
	9Xrbp/lZmiGkjw==
X-ME-Sender: <xms:jmWlXI21YMUy-NkqF5sIY94mnxzC9yuEY2itFq1iMfMCv2zYxd2_wQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepudej
X-ME-Proxy: <xmx:jmWlXCWcQvBdep_5Xt5M9GEirHaCL6cEZj4Rtzt5xTZ6WUQ7e_rn7w>
    <xmx:jmWlXNFOImtnJ2yMEV10OTu7o3F7AFNFrNH14qSY_RwadUI-_JTLcg>
    <xmx:jmWlXMmNCPMatjKWNCaiS4QQttcTF_BZteQmjgY0VGCT8bMDDryVQQ>
    <xmx:jmWlXLQLAR1dJJL9H5zw9yaRR7MBbU97X3zXyD9vI7psQS1y2otA1w>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id C4EE61030F;
	Wed,  3 Apr 2019 22:01:48 -0400 (EDT)
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
Subject: [RFC PATCH 21/25] mm: move update_lru_sizes() to mm_inline.h for broader use.
Date: Wed,  3 Apr 2019 19:00:42 -0700
Message-Id: <20190404020046.32741-22-zi.yan@sent.com>
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

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/mm_inline.h | 21 +++++++++++++++++++++
 mm/vmscan.c               | 25 ++-----------------------
 2 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 04ec454..b9fbd0b 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -44,6 +44,27 @@ static __always_inline void update_lru_size(struct lruvec *lruvec,
 #endif
 }
 
+/*
+ * Update LRU sizes after isolating pages. The LRU size updates must
+ * be complete before mem_cgroup_update_lru_size due to a santity check.
+ */
+static __always_inline void update_lru_sizes(struct lruvec *lruvec,
+			enum lru_list lru, unsigned long *nr_zone_taken)
+{
+	int zid;
+
+	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+		if (!nr_zone_taken[zid])
+			continue;
+
+		__update_lru_size(lruvec, lru, zid, -nr_zone_taken[zid]);
+#ifdef CONFIG_MEMCG
+		mem_cgroup_update_lru_size(lruvec, lru, zid, -nr_zone_taken[zid]);
+#endif
+	}
+
+}
+
 static __always_inline void add_page_to_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a5ad0b3..1d539d6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1593,27 +1593,6 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 }
 
 
-/*
- * Update LRU sizes after isolating pages. The LRU size updates must
- * be complete before mem_cgroup_update_lru_size due to a santity check.
- */
-static __always_inline void update_lru_sizes(struct lruvec *lruvec,
-			enum lru_list lru, unsigned long *nr_zone_taken)
-{
-	int zid;
-
-	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-		if (!nr_zone_taken[zid])
-			continue;
-
-		__update_lru_size(lruvec, lru, zid, -nr_zone_taken[zid]);
-#ifdef CONFIG_MEMCG
-		mem_cgroup_update_lru_size(lruvec, lru, zid, -nr_zone_taken[zid]);
-#endif
-	}
-
-}
-
 /**
  * pgdat->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
@@ -1804,7 +1783,7 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
 	return isolated > inactive;
 }
 
-static noinline_for_stack void
+noinline_for_stack void
 putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
@@ -2003,7 +1982,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
  * Returns the number of pages moved to the given lru.
  */
 
-static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
+unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 				     struct list_head *list,
 				     struct list_head *pages_to_free,
 				     enum lru_list lru)
-- 
2.7.4

