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
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB2D9C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4838B2133D
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="VQPd0O7h";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="wEDUiOU+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4838B2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCD8E6B000A; Wed,  3 Apr 2019 22:01:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B04FD6B000D; Wed,  3 Apr 2019 22:01:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97DC46B0266; Wed,  3 Apr 2019 22:01:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7309B6B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:18 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id o135so932344qke.11
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=ihM+5l/zyd7XBvRYBdStqW9O8n8lQHe/JBYsxvDJM5o=;
        b=kYmZbPYPBd5WbRtzZUcScIqbworKgVwlAdovxZUp3FaNiqlkvGKamPzd/tNuIrI1FD
         cRuxWf7IUCXj03Rm3SRqt2UUDyvIZfksXpnMXZwQw19qaXgrhErrLkzcstBUEzBs4p8J
         Wf3UJdlyGhPDFfy9Lh0DqDM8VcTr18qhIVjeZNiX0UqdTV6w1XyQ1liw06MM6bvyLm+U
         o0wCn4tWSzebh6qyFn++gInSeIRoxXhqs73hDKIZ/CoYYjTuJ6GcjJ9HFZs+nSVsqrnQ
         3TpHONpC4Oa5pPqMkN9vHgxpHxtknNAsJySha9XSPvGNfVBXJV3M03ML2jWts0Mlbon4
         Z7zQ==
X-Gm-Message-State: APjAAAXnUu93etVAJ6Q4L1CXbnJLxOXFoxvnCRx8WZxHAwyMRjaTs+wt
	5ExsfVeFfvXuptoJhQe0UFaV08mfbpAhxjOGwaAlx7tJkA/Y0BpUj2fITgWfdPBI5rnT1jK1js2
	7JjdZkQfnVSDithSGUg+CNwvio0IVabxAaCKzV2giVn5i4rv+5RGJLA+wPFlXM1a1KA==
X-Received: by 2002:ac8:1bba:: with SMTP id z55mr3043121qtj.354.1554343278187;
        Wed, 03 Apr 2019 19:01:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvHJwlXgvFPS76SdV3xYurAx9dH5exx2Wkuye+TV8M8G59KBPli29b2nnm41op2B6AjWW3
X-Received: by 2002:ac8:1bba:: with SMTP id z55mr3043039qtj.354.1554343276885;
        Wed, 03 Apr 2019 19:01:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343276; cv=none;
        d=google.com; s=arc-20160816;
        b=LjIcxHK8ZVnahuCvEPTDsReysQjp8oK7j9iRZ5JnLPsZgmd6GjB9fq3dFDLca3rSxW
         U0J7DqQdIX+8D7krKWEcmYCQfcts9WPZtLmjzsAOqjbeOS4L0FqFf5Oyg1kfdZhNGatt
         CxtRjncVW56QBUjLX4V79H6gVRITqKqMFs9pCH1npCW/JyNpLLCZNUECnyrDtXipEPig
         h32KgwD2taEH5UnVAj5/Qz3HjNTWKUm0Z2zUFaJ6q03teFeJjMvbDU6keK7qrh4hua9t
         NyU9nodaPNAVgx4Oe3OjtECxfC9t/sHWrH1teLeI1XeMO275T8AIBCyk/t584I9RXWvX
         FlYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=ihM+5l/zyd7XBvRYBdStqW9O8n8lQHe/JBYsxvDJM5o=;
        b=U/8W7voInszlDhXMmpBl0pSdqHaMimqCXjnFP4SQAm6FzKF++bEvqAZvRi2AuG1U+H
         0xdItlnn9oYIdlBY4mJ7CtYyAR9Fzwf7tLhruxNW3BV0p+si3+Of2mwOI3gj7qaxPVC1
         9GclUlznFw+2Wq2H0rXhH9NiP/n6VF9lxMFssNVMcrau7xdM2vwBwjJE7/IMlkK4Q48O
         kfomp3h79164lQUfAUtTKYZOlPS+fJ6f5PNf5VRBbGUXaA644A0Iznb0U7OH28vtM6ZM
         NF/TyPUaPr1LPNCZXsYXvWb9SrUl5jVZwL+w6ZfI9nOIJgIH10parX4plCIEMt/Fqgjo
         gbyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=VQPd0O7h;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=wEDUiOU+;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id y7si8667453qty.257.2019.04.03.19.01.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=VQPd0O7h;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=wEDUiOU+;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 7375122525;
	Wed,  3 Apr 2019 22:01:16 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:16 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=ihM+5l/zyd7XB
	vRYBdStqW9O8n8lQHe/JBYsxvDJM5o=; b=VQPd0O7hJ0wvsMutCNmD78faZPZ5E
	FcEPvoAd7Xjju9weyKnmAElxvDbqB1bHoXgsC2+QHRKTN+fameCnUyeTwgNwb9Z2
	SH2yYSBnBh46c9YFeLWXZpNzWm+j32E+oNDXHCc6U1d34PJYkSDMzt5DGM2Qz1QN
	Tbann4HmlYW88Og5rD86lUCqyqwOtXUc4QrTJgQ9X3bW8XLl/mM89KCJb2AtllwH
	qTaWMb8BM/noaYd2lkeZ7OiTMgoUfum7rgp1T2qqEJ4MKErjr4tfP6RDkwVBX/pr
	iMF5HBeEVdWsMXFWHP/XOZEP9paSDOyaeZyf13T16m8x3mdTAc4hVeY9g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=ihM+5l/zyd7XBvRYBdStqW9O8n8lQHe/JBYsxvDJM5o=; b=wEDUiOU+
	XucSrcKL+pGCjAdhb2GEEwivLv8ggXuPckHBFYVugrbr/hAyoeUpAZhgdmoR0QP0
	G4n3B3iLo4uL3tajbYleVaZIZrg7j+YXrDCPX75ip4LMeW56EID6gUJQXEEG4wUU
	ud9CedxwOfnuOT0e2H4MzXs056FqRdCjOf7HFb7115e22yr0W2R6Re/fZfcJX+Us
	+vOVD5oRRYjN6/uuKr7btlTWxZBbKXxAXpYQr+xsgfvW9uDIjGJLIi0W585hGjeU
	PGQauqdYZImfeI2KZf6K4Ks/iUgSWrTDzy3yBKj5IJXEq18sHP7R7YmmshBv02I1
	egaYHWkrpm2XHw==
X-ME-Sender: <xms:bGWlXB7ieGyIjavygQxXB_f1SpdB_mJAkLVfcHvrWJWG4vF0XMu-0g>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepud
X-ME-Proxy: <xmx:bGWlXLKVXVYKg4GoxOYXyqR4_9X8PmxsnFlKKec2gK4hmMTmI257mA>
    <xmx:bGWlXOtmBgRoPTZNEUvWFPT3R4xL16D7noZlPxU5s7E8h1NtPMJkcA>
    <xmx:bGWlXHyViH_oGhM4_hmvxraGUERASHg3ZNlFZnUhbK7DPhsMgOnLHA>
    <xmx:bGWlXPW9Z0pIrXlPP3FTGltOD-etq_9sbTp0NhF8T2PFIC2kk7tBKQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6372E1031A;
	Wed,  3 Apr 2019 22:01:14 -0400 (EDT)
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
Subject: [RFC PATCH 02/25] mm: migrate: Add mode parameter to support future page copy routines.
Date: Wed,  3 Apr 2019 19:00:23 -0700
Message-Id: <20190404020046.32741-3-zi.yan@sent.com>
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

MIGRATE_SINGLETHREAD is added as the default behavior.
migrate_page_copy() and copy_huge_page() are changed.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 fs/aio.c                     |  2 +-
 fs/f2fs/data.c               |  2 +-
 fs/hugetlbfs/inode.c         |  2 +-
 fs/iomap.c                   |  2 +-
 fs/ubifs/file.c              |  2 +-
 include/linux/migrate.h      |  6 ++++--
 include/linux/migrate_mode.h |  3 +++
 mm/migrate.c                 | 14 ++++++++------
 8 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 0a88dfd..986d21e 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -437,7 +437,7 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	 * events from being lost.
 	 */
 	spin_lock_irqsave(&ctx->completion_lock, flags);
-	migrate_page_copy(new, old);
+	migrate_page_copy(new, old, MIGRATE_SINGLETHREAD);
 	BUG_ON(ctx->ring_pages[idx] != old);
 	ctx->ring_pages[idx] = new;
 	spin_unlock_irqrestore(&ctx->completion_lock, flags);
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index e7f0e3a..6a419a9 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -2826,7 +2826,7 @@ int f2fs_migrate_page(struct address_space *mapping,
 	}
 
 	if ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC_NO_COPY)
-		migrate_page_copy(newpage, page);
+		migrate_page_copy(newpage, page, MIGRATE_SINGLETHREAD);
 	else
 		migrate_page_states(newpage, page);
 
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 04ba8bb..03dfa49 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -886,7 +886,7 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
 	}
 
 	if ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC_NO_COPY)
-		migrate_page_copy(newpage, page);
+		migrate_page_copy(newpage, page, MIGRATE_SINGLETHREAD);
 	else
 		migrate_page_states(newpage, page);
 
diff --git a/fs/iomap.c b/fs/iomap.c
index 8ee3f9f..a6e0456 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -585,7 +585,7 @@ iomap_migrate_page(struct address_space *mapping, struct page *newpage,
 	}
 
 	if ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC_NO_COPY)
-		migrate_page_copy(newpage, page);
+		migrate_page_copy(newpage, page, MIGRATE_SINGLETHREAD);
 	else
 		migrate_page_states(newpage, page);
 	return MIGRATEPAGE_SUCCESS;
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 2bb8788..3a3dbbd 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1491,7 +1491,7 @@ static int ubifs_migrate_page(struct address_space *mapping,
 	}
 
 	if ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC_NO_COPY)
-		migrate_page_copy(newpage, page);
+		migrate_page_copy(newpage, page, MIGRATE_SINGLETHREAD);
 	else
 		migrate_page_states(newpage, page);
 	return MIGRATEPAGE_SUCCESS;
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e13d9bf..5218a07 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -73,7 +73,8 @@ extern void putback_movable_page(struct page *page);
 extern int migrate_prep(void);
 extern int migrate_prep_local(void);
 extern void migrate_page_states(struct page *newpage, struct page *page);
-extern void migrate_page_copy(struct page *newpage, struct page *page);
+extern void migrate_page_copy(struct page *newpage, struct page *page,
+				  enum migrate_mode mode);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
 extern int migrate_page_move_mapping(struct address_space *mapping,
@@ -97,7 +98,8 @@ static inline void migrate_page_states(struct page *newpage, struct page *page)
 }
 
 static inline void migrate_page_copy(struct page *newpage,
-				     struct page *page) {}
+				     struct page *page,
+				     enum migrate_mode mode) {}
 
 static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page)
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 59d75fc..da44940 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -11,6 +11,8 @@
  *	with the CPU. Instead, page copy happens outside the migratepage()
  *	callback and is likely using a DMA engine. See migrate_vma() and HMM
  *	(mm/hmm.c) for users of this mode.
+ * MIGRATE_SINGLETHREAD uses a single thread to move pages, it is the default
+ *	behavior
  */
 enum migrate_mode {
 	MIGRATE_ASYNC,
@@ -19,6 +21,7 @@ enum migrate_mode {
 	MIGRATE_SYNC_NO_COPY,
 
 	MIGRATE_MODE_MASK = 3,
+	MIGRATE_SINGLETHREAD	= 0,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/migrate.c b/mm/migrate.c
index c161c03..2b2653e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -567,7 +567,8 @@ static void __copy_gigantic_page(struct page *dst, struct page *src,
 	}
 }
 
-static void copy_huge_page(struct page *dst, struct page *src)
+static void copy_huge_page(struct page *dst, struct page *src,
+				enum migrate_mode mode)
 {
 	int i;
 	int nr_pages;
@@ -657,10 +658,11 @@ void migrate_page_states(struct page *newpage, struct page *page)
 }
 EXPORT_SYMBOL(migrate_page_states);
 
-void migrate_page_copy(struct page *newpage, struct page *page)
+void migrate_page_copy(struct page *newpage, struct page *page,
+		enum migrate_mode mode)
 {
 	if (PageHuge(page) || PageTransHuge(page))
-		copy_huge_page(newpage, page);
+		copy_huge_page(newpage, page, mode);
 	else
 		copy_highpage(newpage, page);
 
@@ -692,7 +694,7 @@ int migrate_page(struct address_space *mapping,
 		return rc;
 
 	if ((mode & MIGRATE_MODE_MASK) !=  MIGRATE_SYNC_NO_COPY)
-		migrate_page_copy(newpage, page);
+		migrate_page_copy(newpage, page, mode);
 	else
 		migrate_page_states(newpage, page);
 	return MIGRATEPAGE_SUCCESS;
@@ -805,7 +807,7 @@ static int __buffer_migrate_page(struct address_space *mapping,
 	SetPagePrivate(newpage);
 
 	if ((mode & MIGRATE_MODE_MASK) !=  MIGRATE_SYNC_NO_COPY)
-		migrate_page_copy(newpage, page);
+		migrate_page_copy(newpage, page, MIGRATE_SINGLETHREAD);
 	else
 		migrate_page_states(newpage, page);
 
@@ -2024,7 +2026,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	new_page->index = page->index;
 	/* flush the cache before copying using the kernel virtual address */
 	flush_cache_range(vma, start, start + HPAGE_PMD_SIZE);
-	migrate_page_copy(new_page, page);
+	migrate_page_copy(new_page, page, MIGRATE_SINGLETHREAD);
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-- 
2.7.4

