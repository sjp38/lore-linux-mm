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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97A4DC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D4EC20820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="xvGijxix";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Z1hOWcZu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D4EC20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D0EA6B026F; Wed,  3 Apr 2019 22:01:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AA516B0270; Wed,  3 Apr 2019 22:01:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6239C6B0271; Wed,  3 Apr 2019 22:01:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 30B2D6B026F
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:36 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f89so981772qtb.4
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=N+F/W2v9sslMyn5Wy884Xor9GycaYH25VDUebD4fYj4=;
        b=Peyb9aqwIJKFWGeuqUMYCf6qVLy0Gh/qOdVsumYRdWVMoz6+aTTcilK6aBans4CKJi
         mPjoI0aVx1vIAtKR8BznzAW/2N0Jpa4foxSbv3s1mC6QFTjddgG/LlJww1fpKehueo65
         v5sAvm+lRGVDeG5JgumWoxSUSndzgXhMg6JSSl/YmTdlmy+UYLK/ZTozNBj7eMNZxS5F
         0Hkl2VFetL/riG+2ZxD8LcP/ZxK8eJgsVmRnJs+AgPowkVyoY/iLD4pu3nr9Jh3lSQfa
         9p3Ku6TdExD9qNWnIdA0pGrSHhlr73/Tfr+fYmxDJBXJUWA+O7La7xNE0AsmGRWMbB50
         ufnQ==
X-Gm-Message-State: APjAAAU4jdqSu/Se0ATJ/oBM3hPtpQRCBebx7fmdNFV6lKFOeQLkNeMY
	omTt8RqDvzWap391IDGeKgTyLJqv649ntN2IuyLiXGhWOPeEggalKh1KgBazFseleLyqPUss6n7
	8FJKlQAMMudT+c6Lk86ZAAdwYMOY0I13i3xx17IuCslm+IvoB4qE9EhQwoZq5MW5ZMQ==
X-Received: by 2002:ae9:e916:: with SMTP id x22mr2852148qkf.66.1554343295891;
        Wed, 03 Apr 2019 19:01:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5IGUqxnumQAjoqlOhhqXAoJ3UtmOyOd+WGJGUeCAXvS0slJNJpqG3FwoEDwfSqGALT2c1
X-Received: by 2002:ae9:e916:: with SMTP id x22mr2852031qkf.66.1554343294020;
        Wed, 03 Apr 2019 19:01:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343294; cv=none;
        d=google.com; s=arc-20160816;
        b=Cf/kbSccAY4iWiLIiNEsM2gBK0Csi2NFH79TyW5vwVZnDv3Wy0QFF1hPI+CLc85zm0
         FbaetCW+12DrHmH5PTBck2/IftaW2nzollbInxeIo77GEItyguN77kQy3JRWzrea9zQQ
         Dopi/JZsvh2sgLSDVjA8MhXNJbfgQ0uW6JRPm/9PYV2wgKF8y533UvpWL5RKtp0/jM9e
         5ZO/UUHkXJoQPjzHXxiFBRHA2aM0oucSjWX3SbdZSiYGUhhOH3ViEoo/oP5t/6VQtNTf
         x7iA6kmrkAa2dOl8bwdYwdW7a8elNNrUgGmd+fFcqJ7eiKNzrb55dH5dq4Mqr/ITixkW
         M22g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=N+F/W2v9sslMyn5Wy884Xor9GycaYH25VDUebD4fYj4=;
        b=sRQEcUYrwTJYqcjRgGCy93zAW3iorGVLEaoIoaJHEUr2AxWdGP8/XSY9OTgyTrcQ6c
         hAivVPgREV1yrjIUX8WM2LzybXfXzFhK6ZWuIKH1vxE9nDh7E4wNVRYqeYV9Kd90J+V7
         sD7lPMn8lum54H2UTqVK4XzCkWZEvMr3vugnRtLL4TyZgR/9aZ2+d+N+De04HgHCuhN9
         Sqizdt/Q0S9vXZqaXN55axg96UJ1K9IfWtj6KKu5F8kLxFUM9gusUNEQnll9MmVQ+rP+
         R3AH7lgn5I9Q8VMkXStvxtpk9AQ4D6f33An5iR27iBI5efII6sIQEY7waoZGH6bT+ZCW
         WmCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=xvGijxix;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Z1hOWcZu;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id x37si2172391qtj.307.2019.04.03.19.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=xvGijxix;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Z1hOWcZu;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id A7F5D2258E;
	Wed,  3 Apr 2019 22:01:33 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:33 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=N+F/W2v9sslMy
	n5Wy884Xor9GycaYH25VDUebD4fYj4=; b=xvGijxixMYAIGuaZ8Ss8BIFrOKt5j
	Z3EgjAmS0gEwqkrciPnlP5vFRhwAfsH4zwnTCxdyULIIC8vqD6UcAnsYePDCQR1N
	QN9xxVk5DTs0alpYSNxYlt5lwhkFP/nxIjDadkgWNxNYt9HGl6oyjYDoeg7UTDQn
	g41bLRJIMuR6bbnaneRqvBcDliTyGYJJZW6lsuVrAneoXZFWSKm5mhhjrOEIipby
	A3sHCB33PTpOvE1diIlx7Kj0SQPyueV78Gv2SK716h+SQ/7XI9jVAfazsYv2UgSW
	aE49smEx73ZGLhKm8NqYDBJPBnli4EEsTUdJbic00LFqO1LyBBXXjc+Kg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=N+F/W2v9sslMyn5Wy884Xor9GycaYH25VDUebD4fYj4=; b=Z1hOWcZu
	1LE4neVBqzhgmo/mlyPStSz5HFVWLsdHHyEZSCuiDiK6TaSxJaC1nr/DnjqVxH2V
	3bqLgkTjaAhW5u0IhBwn79uZrmIIpZoy/1CAEZ1ZGswE3Vopi0gn/y+3vGylVg+N
	nLcCLlBFGDSDmBtQd99iZSe9MDnc+5M84jo8USvd/gU5R8aFpTcxTdyneNbm1Fok
	B8LsiJ73deVGikFeW2JLu67QhEL6YFalpy2Bp5t65Sh4rwm6LjL0vC2GmbPrpeM2
	r9X7BjgYnQv6F9pEsVxmqXZqRxUyAXwxXfSY6096RvbcbHGRrc7eq/0aTBC0dWa3
	RGtDbRafO9g7Fg==
X-ME-Sender: <xms:fWWlXK_TkUctG_h4nmmg0q33AY4E0Peujv_OEqn4agCmvEZ10n_qrA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepuddt
X-ME-Proxy: <xmx:fWWlXNxcD5WHo3ekoRbtW09zEK_IW6-Hi1OOL-0AplR0dpri_5rfWA>
    <xmx:fWWlXKoJ5gOkoSa7LVCBlQkuwpqO7htjCv-Tip9mh1LOsSEBc4X93w>
    <xmx:fWWlXOpQW4Oc4_lsBd6AITwPj6iOycVSt8AIb1xqu2B6I23eMXM8vA>
    <xmx:fWWlXAbkriGqViElULgn2TCW2UxyfDbKmBm2_6NOUzobn5TJTgRjVA>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id B1E0910390;
	Wed,  3 Apr 2019 22:01:31 -0400 (EDT)
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
Subject: [RFC PATCH 11/25] mm: migrate: Add concurrent page migration into move_pages syscall.
Date: Wed,  3 Apr 2019 19:00:32 -0700
Message-Id: <20190404020046.32741-12-zi.yan@sent.com>
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

Concurrent page migration unmaps all pages in a list, copy all pages
in one function (copy_page_list*), finally remaps all new pages.
This is different from existing page migration process which migrate
one page at a time.

Only anonymous pages are supported. All file-backed pages are still
migrated sequentially. Because locking becomes more complicated when
a list of file-backed pages belong to different files, which might
cause deadlocks if locks on each file are not done properly.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/migrate.h        |   6 +
 include/linux/migrate_mode.h   |   1 +
 include/uapi/linux/mempolicy.h |   1 +
 mm/migrate.c                   | 543 ++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 542 insertions(+), 9 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 5218a07..1001a1c 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -67,6 +67,8 @@ extern int migrate_page(struct address_space *mapping,
 			enum migrate_mode mode);
 extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
 		unsigned long private, enum migrate_mode mode, int reason);
+extern int migrate_pages_concur(struct list_head *l, new_page_t new, free_page_t free,
+		unsigned long private, enum migrate_mode mode, int reason);
 extern int isolate_movable_page(struct page *page, isolate_mode_t mode);
 extern void putback_movable_page(struct page *page);
 
@@ -87,6 +89,10 @@ static inline int migrate_pages(struct list_head *l, new_page_t new,
 		free_page_t free, unsigned long private, enum migrate_mode mode,
 		int reason)
 	{ return -ENOSYS; }
+static inline int migrate_pages_concur(struct list_head *l, new_page_t new,
+		free_page_t free, unsigned long private, enum migrate_mode mode,
+		int reason)
+	{ return -ENOSYS; }
 static inline int isolate_movable_page(struct page *page, isolate_mode_t mode)
 	{ return -EBUSY; }
 
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 4f7f5557..68263da 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -24,6 +24,7 @@ enum migrate_mode {
 	MIGRATE_SINGLETHREAD	= 0,
 	MIGRATE_MT				= 1<<4,
 	MIGRATE_DMA				= 1<<5,
+	MIGRATE_CONCUR			= 1<<6,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 49573a6..eb6560e 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -50,6 +50,7 @@ enum {
 
 #define MPOL_MF_MOVE_DMA (1<<5)	/* Use DMA page copy routine */
 #define MPOL_MF_MOVE_MT  (1<<6)	/* Use multi-threaded page copy routine */
+#define MPOL_MF_MOVE_CONCUR  (1<<7)	/* Move pages in a batch */
 
 #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
 			 MPOL_MF_MOVE     | 	\
diff --git a/mm/migrate.c b/mm/migrate.c
index 09114d3..ad02797 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -57,6 +57,15 @@
 
 int accel_page_copy = 1;
 
+
+struct page_migration_work_item {
+	struct list_head list;
+	struct page *old_page;
+	struct page *new_page;
+	struct anon_vma *anon_vma;
+	int page_was_mapped;
+};
+
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
@@ -1396,6 +1405,509 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	return rc;
 }
 
+static int __unmap_page_concur(struct page *page, struct page *newpage,
+				struct anon_vma **anon_vma,
+				int *page_was_mapped,
+				int force, enum migrate_mode mode)
+{
+	int rc = -EAGAIN;
+	bool is_lru = !__PageMovable(page);
+
+	*anon_vma = NULL;
+	*page_was_mapped = 0;
+
+	if (!trylock_page(page)) {
+		if (!force || ((mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC))
+			goto out;
+
+		/*
+		 * It's not safe for direct compaction to call lock_page.
+		 * For example, during page readahead pages are added locked
+		 * to the LRU. Later, when the IO completes the pages are
+		 * marked uptodate and unlocked. However, the queueing
+		 * could be merging multiple pages for one bio (e.g.
+		 * mpage_readpages). If an allocation happens for the
+		 * second or third page, the process can end up locking
+		 * the same page twice and deadlocking. Rather than
+		 * trying to be clever about what pages can be locked,
+		 * avoid the use of lock_page for direct compaction
+		 * altogether.
+		 */
+		if (current->flags & PF_MEMALLOC)
+			goto out;
+
+		lock_page(page);
+	}
+
+	/* We are working on page_mapping(page) == NULL */
+	VM_BUG_ON_PAGE(PageWriteback(page), page);
+#if 0
+	if (PageWriteback(page)) {
+		/*
+		 * Only in the case of a full synchronous migration is it
+		 * necessary to wait for PageWriteback. In the async case,
+		 * the retry loop is too short and in the sync-light case,
+		 * the overhead of stalling is too much
+		 */
+		if ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC) {
+			rc = -EBUSY;
+			goto out_unlock;
+		}
+		if (!force)
+			goto out_unlock;
+		wait_on_page_writeback(page);
+	}
+#endif
+
+	/*
+	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
+	 * we cannot notice that anon_vma is freed while we migrates a page.
+	 * This get_anon_vma() delays freeing anon_vma pointer until the end
+	 * of migration. File cache pages are no problem because of page_lock()
+	 * File Caches may use write_page() or lock_page() in migration, then,
+	 * just care Anon page here.
+	 *
+	 * Only page_get_anon_vma() understands the subtleties of
+	 * getting a hold on an anon_vma from outside one of its mms.
+	 * But if we cannot get anon_vma, then we won't need it anyway,
+	 * because that implies that the anon page is no longer mapped
+	 * (and cannot be remapped so long as we hold the page lock).
+	 */
+	if (PageAnon(page) && !PageKsm(page))
+		*anon_vma = page_get_anon_vma(page);
+
+	/*
+	 * Block others from accessing the new page when we get around to
+	 * establishing additional references. We are usually the only one
+	 * holding a reference to newpage at this point. We used to have a BUG
+	 * here if trylock_page(newpage) fails, but would like to allow for
+	 * cases where there might be a race with the previous use of newpage.
+	 * This is much like races on refcount of oldpage: just don't BUG().
+	 */
+	if (unlikely(!trylock_page(newpage)))
+		goto out_unlock;
+
+	if (unlikely(!is_lru)) {
+		/* Just migrate the page and remove it from item list */
+		VM_BUG_ON(1);
+		rc = move_to_new_page(newpage, page, mode);
+		goto out_unlock_both;
+	}
+
+	/*
+	 * Corner case handling:
+	 * 1. When a new swap-cache page is read into, it is added to the LRU
+	 * and treated as swapcache but it has no rmap yet.
+	 * Calling try_to_unmap() against a page->mapping==NULL page will
+	 * trigger a BUG.  So handle it here.
+	 * 2. An orphaned page (see truncate_complete_page) might have
+	 * fs-private metadata. The page can be picked up due to memory
+	 * offlining.  Everywhere else except page reclaim, the page is
+	 * invisible to the vm, so the page can not be migrated.  So try to
+	 * free the metadata, so the page can be freed.
+	 */
+	if (!page->mapping) {
+		VM_BUG_ON_PAGE(PageAnon(page), page);
+		if (page_has_private(page)) {
+			try_to_free_buffers(page);
+			goto out_unlock_both;
+		}
+	} else if (page_mapped(page)) {
+		/* Establish migration ptes */
+		VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !*anon_vma,
+				page);
+		try_to_unmap(page,
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		*page_was_mapped = 1;
+	}
+
+	return MIGRATEPAGE_SUCCESS;
+
+out_unlock_both:
+	unlock_page(newpage);
+out_unlock:
+	/* Drop an anon_vma reference if we took one */
+	if (*anon_vma)
+		put_anon_vma(*anon_vma);
+	unlock_page(page);
+out:
+	return rc;
+}
+
+static int unmap_pages_and_get_new_concur(new_page_t get_new_page,
+				free_page_t put_new_page, unsigned long private,
+				struct page_migration_work_item *item,
+				int force,
+				enum migrate_mode mode, enum migrate_reason reason)
+{
+	int rc = MIGRATEPAGE_SUCCESS;
+
+	if (!thp_migration_supported() && PageTransHuge(item->old_page))
+		return -ENOMEM;
+
+	item->new_page = get_new_page(item->old_page, private);
+	if (!item->new_page)
+		return -ENOMEM;
+
+	if (page_count(item->old_page) == 1) {
+		/* page was freed from under us. So we are done. */
+		ClearPageActive(item->old_page);
+		ClearPageUnevictable(item->old_page);
+		if (unlikely(__PageMovable(item->old_page))) {
+			lock_page(item->old_page);
+			if (!PageMovable(item->old_page))
+				__ClearPageIsolated(item->old_page);
+			unlock_page(item->old_page);
+		}
+		if (put_new_page)
+			put_new_page(item->new_page, private);
+		else
+			put_page(item->new_page);
+		item->new_page = NULL;
+		goto out;
+	}
+
+	rc = __unmap_page_concur(item->old_page, item->new_page, &item->anon_vma,
+							&item->page_was_mapped,
+							force, mode);
+	if (rc == MIGRATEPAGE_SUCCESS)
+		return rc;
+
+out:
+	if (rc != -EAGAIN) {
+		list_del(&item->old_page->lru);
+
+		if (likely(!__PageMovable(item->old_page)))
+			mod_node_page_state(page_pgdat(item->old_page), NR_ISOLATED_ANON +
+					page_is_file_cache(item->old_page),
+					-hpage_nr_pages(item->old_page));
+	}
+
+	if (rc == MIGRATEPAGE_SUCCESS) {
+		/* only for pages freed under us  */
+		VM_BUG_ON(page_count(item->old_page) != 1);
+		put_page(item->old_page);
+		item->old_page = NULL;
+
+	} else {
+		if (rc != -EAGAIN) {
+			if (likely(!__PageMovable(item->old_page))) {
+				putback_lru_page(item->old_page);
+				goto put_new;
+			}
+
+			lock_page(item->old_page);
+			if (PageMovable(item->old_page))
+				putback_movable_page(item->old_page);
+			else
+				__ClearPageIsolated(item->old_page);
+			unlock_page(item->old_page);
+			put_page(item->old_page);
+		}
+
+		/*
+		 * If migration was not successful and there's a freeing callback, use
+		 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
+		 * during isolation.
+		 */
+put_new:
+		if (put_new_page)
+			put_new_page(item->new_page, private);
+		else
+			put_page(item->new_page);
+		item->new_page = NULL;
+
+	}
+
+	return rc;
+}
+
+static int move_mapping_concurr(struct list_head *unmapped_list_ptr,
+					   struct list_head *wip_list_ptr,
+					   free_page_t put_new_page, unsigned long private,
+					   enum migrate_mode mode)
+{
+	struct page_migration_work_item *iterator, *iterator2;
+	struct address_space *mapping;
+
+	list_for_each_entry_safe(iterator, iterator2, unmapped_list_ptr, list) {
+		VM_BUG_ON_PAGE(!PageLocked(iterator->old_page), iterator->old_page);
+		VM_BUG_ON_PAGE(!PageLocked(iterator->new_page), iterator->new_page);
+
+		mapping = page_mapping(iterator->old_page);
+
+		VM_BUG_ON(mapping);
+
+		VM_BUG_ON(PageWriteback(iterator->old_page));
+
+		if (page_count(iterator->old_page) != 1) {
+			list_move(&iterator->list, wip_list_ptr);
+			if (iterator->page_was_mapped)
+				remove_migration_ptes(iterator->old_page,
+					iterator->old_page, false);
+			unlock_page(iterator->new_page);
+			if (iterator->anon_vma)
+				put_anon_vma(iterator->anon_vma);
+			unlock_page(iterator->old_page);
+
+			if (put_new_page)
+				put_new_page(iterator->new_page, private);
+			else
+				put_page(iterator->new_page);
+			iterator->new_page = NULL;
+			continue;
+		}
+
+		iterator->new_page->index = iterator->old_page->index;
+		iterator->new_page->mapping = iterator->old_page->mapping;
+		if (PageSwapBacked(iterator->old_page))
+			SetPageSwapBacked(iterator->new_page);
+	}
+
+	return 0;
+}
+
+static int copy_to_new_pages_concur(struct list_head *unmapped_list_ptr,
+				enum migrate_mode mode)
+{
+	struct page_migration_work_item *iterator;
+	int num_pages = 0, idx = 0;
+	struct page **src_page_list = NULL, **dst_page_list = NULL;
+	unsigned long size = 0;
+	int rc = -EFAULT;
+
+	if (list_empty(unmapped_list_ptr))
+		return 0;
+
+	list_for_each_entry(iterator, unmapped_list_ptr, list) {
+		++num_pages;
+		size += PAGE_SIZE * hpage_nr_pages(iterator->old_page);
+	}
+
+	src_page_list = kzalloc(sizeof(struct page *)*num_pages, GFP_KERNEL);
+	if (!src_page_list) {
+		BUG();
+		return -ENOMEM;
+	}
+	dst_page_list = kzalloc(sizeof(struct page *)*num_pages, GFP_KERNEL);
+	if (!dst_page_list) {
+		BUG();
+		return -ENOMEM;
+	}
+
+	list_for_each_entry(iterator, unmapped_list_ptr, list) {
+		src_page_list[idx] = iterator->old_page;
+		dst_page_list[idx] = iterator->new_page;
+		++idx;
+	}
+
+	BUG_ON(idx != num_pages);
+
+	if (mode & MIGRATE_DMA)
+		rc = copy_page_lists_dma_always(dst_page_list, src_page_list,
+							num_pages);
+	else if (mode & MIGRATE_MT)
+		rc = copy_page_lists_mt(dst_page_list, src_page_list,
+							num_pages);
+
+	if (rc) {
+		list_for_each_entry(iterator, unmapped_list_ptr, list) {
+			if (PageHuge(iterator->old_page) ||
+				PageTransHuge(iterator->old_page))
+				copy_huge_page(iterator->new_page, iterator->old_page, 0);
+			else
+				copy_highpage(iterator->new_page, iterator->old_page);
+		}
+	}
+
+	kfree(src_page_list);
+	kfree(dst_page_list);
+
+	list_for_each_entry(iterator, unmapped_list_ptr, list) {
+		migrate_page_states(iterator->new_page, iterator->old_page);
+	}
+
+	return 0;
+}
+
+static int remove_migration_ptes_concurr(struct list_head *unmapped_list_ptr)
+{
+	struct page_migration_work_item *iterator, *iterator2;
+
+	list_for_each_entry_safe(iterator, iterator2, unmapped_list_ptr, list) {
+		if (iterator->page_was_mapped)
+			remove_migration_ptes(iterator->old_page, iterator->new_page, false);
+
+		unlock_page(iterator->new_page);
+
+		if (iterator->anon_vma)
+			put_anon_vma(iterator->anon_vma);
+
+		unlock_page(iterator->old_page);
+
+		list_del(&iterator->old_page->lru);
+		mod_node_page_state(page_pgdat(iterator->old_page), NR_ISOLATED_ANON +
+				page_is_file_cache(iterator->old_page),
+				-hpage_nr_pages(iterator->old_page));
+
+		put_page(iterator->old_page);
+		iterator->old_page = NULL;
+
+		if (unlikely(__PageMovable(iterator->new_page)))
+			put_page(iterator->new_page);
+		else
+			putback_lru_page(iterator->new_page);
+		iterator->new_page = NULL;
+	}
+
+	return 0;
+}
+
+int migrate_pages_concur(struct list_head *from, new_page_t get_new_page,
+		free_page_t put_new_page, unsigned long private,
+		enum migrate_mode mode, int reason)
+{
+	int retry = 1;
+	int nr_failed = 0;
+	int nr_succeeded = 0;
+	int pass = 0;
+	struct page *page;
+	int swapwrite = current->flags & PF_SWAPWRITE;
+	int rc;
+	int total_num_pages = 0, idx;
+	struct page_migration_work_item *item_list;
+	struct page_migration_work_item *iterator, *iterator2;
+	int item_list_order = 0;
+
+	LIST_HEAD(wip_list);
+	LIST_HEAD(unmapped_list);
+	LIST_HEAD(serialized_list);
+	LIST_HEAD(failed_list);
+
+	if (!swapwrite)
+		current->flags |= PF_SWAPWRITE;
+
+	list_for_each_entry(page, from, lru)
+		++total_num_pages;
+
+	item_list_order = get_order(total_num_pages *
+		sizeof(struct page_migration_work_item));
+
+	if (item_list_order > MAX_ORDER) {
+		item_list = alloc_pages_exact(total_num_pages *
+			sizeof(struct page_migration_work_item), GFP_ATOMIC);
+		memset(item_list, 0, total_num_pages *
+			sizeof(struct page_migration_work_item));
+	} else {
+		item_list = (struct page_migration_work_item *)__get_free_pages(GFP_ATOMIC,
+						item_list_order);
+		memset(item_list, 0, PAGE_SIZE<<item_list_order);
+	}
+
+	idx = 0;
+	list_for_each_entry(page, from, lru) {
+		item_list[idx].old_page = page;
+		item_list[idx].new_page = NULL;
+		INIT_LIST_HEAD(&item_list[idx].list);
+		list_add_tail(&item_list[idx].list, &wip_list);
+		idx += 1;
+	}
+
+	for(pass = 0; pass < 1 && retry; pass++) {
+		retry = 0;
+
+		/* unmap and get new page for page_mapping(page) == NULL */
+		list_for_each_entry_safe(iterator, iterator2, &wip_list, list) {
+			cond_resched();
+
+			if (iterator->new_page) {
+				pr_info("%s: iterator already has a new page?\n", __func__);
+				VM_BUG_ON_PAGE(1, iterator->old_page);
+			}
+
+			/* We do not migrate huge pages, file-backed, or swapcached pages */
+			if (PageHuge(iterator->old_page)) {
+				rc = -ENODEV;
+			}
+			else if ((page_mapping(iterator->old_page) != NULL)) {
+				rc = -ENODEV;
+			}
+			else
+				rc = unmap_pages_and_get_new_concur(get_new_page, put_new_page,
+						private, iterator, pass > 2, mode,
+						reason);
+
+			switch(rc) {
+			case -ENODEV:
+				list_move(&iterator->list, &serialized_list);
+				break;
+			case -ENOMEM:
+				if (PageTransHuge(page))
+					list_move(&iterator->list, &serialized_list);
+				else
+					goto out;
+				break;
+			case -EAGAIN:
+				retry++;
+				break;
+			case MIGRATEPAGE_SUCCESS:
+				if (iterator->old_page) {
+					list_move(&iterator->list, &unmapped_list);
+					nr_succeeded++;
+				} else { /* pages are freed under us */
+					list_del(&iterator->list);
+				}
+				break;
+			default:
+				/*
+				 * Permanent failure (-EBUSY, -ENOSYS, etc.):
+				 * unlike -EAGAIN case, the failed page is
+				 * removed from migration page list and not
+				 * retried in the next outer loop.
+				 */
+				list_move(&iterator->list, &failed_list);
+				nr_failed++;
+				break;
+			}
+		}
+out:
+		if (list_empty(&unmapped_list))
+			continue;
+
+		/* move page->mapping to new page, only -EAGAIN could happen  */
+		move_mapping_concurr(&unmapped_list, &wip_list, put_new_page, private, mode);
+		/* copy pages in unmapped_list */
+		copy_to_new_pages_concur(&unmapped_list, mode);
+		/* remove migration pte, if old_page is NULL?, unlock old and new
+		 * pages, put anon_vma, put old and new pages */
+		remove_migration_ptes_concurr(&unmapped_list);
+	}
+	nr_failed += retry;
+	rc = nr_failed;
+
+	if (!list_empty(from))
+		rc = migrate_pages(from, get_new_page, put_new_page, 
+				private, mode, reason);
+
+	if (nr_succeeded)
+		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
+	if (nr_failed)
+		count_vm_events(PGMIGRATE_FAIL, nr_failed);
+	trace_mm_migrate_pages(nr_succeeded, nr_failed, mode, reason);
+
+	if (item_list_order >= MAX_ORDER) {
+		free_pages_exact(item_list, total_num_pages *
+			sizeof(struct page_migration_work_item));
+	} else {
+		free_pages((unsigned long)item_list, item_list_order);
+	}
+
+	if (!swapwrite)
+		current->flags &= ~PF_SWAPWRITE;
+
+	return rc;
+}
+
 /*
  * migrate_pages - migrate the pages specified in a list, to the free pages
  *		   supplied as the target for the page migration
@@ -1521,17 +2033,25 @@ static int store_status(int __user *status, int start, int value, int nr)
 
 static int do_move_pages_to_node(struct mm_struct *mm,
 		struct list_head *pagelist, int node,
-		bool migrate_mt, bool migrate_dma)
+		bool migrate_mt, bool migrate_dma, bool migrate_concur)
 {
 	int err;
 
 	if (list_empty(pagelist))
 		return 0;
 
-	err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
-			MIGRATE_SYNC | (migrate_mt ? MIGRATE_MT : MIGRATE_SINGLETHREAD) |
-			(migrate_dma ? MIGRATE_DMA : MIGRATE_SINGLETHREAD),
-			MR_SYSCALL);
+	if (migrate_concur) {
+		err = migrate_pages_concur(pagelist, alloc_new_node_page, NULL, node,
+				MIGRATE_SYNC | (migrate_mt ? MIGRATE_MT : MIGRATE_SINGLETHREAD) |
+				(migrate_dma ? MIGRATE_DMA : MIGRATE_SINGLETHREAD),
+				MR_SYSCALL);
+
+	} else {
+		err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
+				MIGRATE_SYNC | (migrate_mt ? MIGRATE_MT : MIGRATE_SINGLETHREAD) |
+				(migrate_dma ? MIGRATE_DMA : MIGRATE_SINGLETHREAD),
+				MR_SYSCALL);
+	}
 	if (err)
 		putback_movable_pages(pagelist);
 	return err;
@@ -1653,7 +2173,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 			start = i;
 		} else if (node != current_node) {
 			err = do_move_pages_to_node(mm, &pagelist, current_node,
-				flags & MPOL_MF_MOVE_MT, flags & MPOL_MF_MOVE_DMA);
+				flags & MPOL_MF_MOVE_MT, flags & MPOL_MF_MOVE_DMA,
+				flags & MPOL_MF_MOVE_CONCUR);
 			if (err)
 				goto out;
 			err = store_status(status, start, current_node, i - start);
@@ -1677,7 +2198,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 			goto out_flush;
 
 		err = do_move_pages_to_node(mm, &pagelist, current_node,
-				flags & MPOL_MF_MOVE_MT, flags & MPOL_MF_MOVE_DMA);
+				flags & MPOL_MF_MOVE_MT, flags & MPOL_MF_MOVE_DMA,
+				flags & MPOL_MF_MOVE_CONCUR);
 		if (err)
 			goto out;
 		if (i > start) {
@@ -1693,7 +2215,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 
 	/* Make sure we do not overwrite the existing error */
 	err1 = do_move_pages_to_node(mm, &pagelist, current_node,
-				flags & MPOL_MF_MOVE_MT, flags & MPOL_MF_MOVE_DMA);
+				flags & MPOL_MF_MOVE_MT, flags & MPOL_MF_MOVE_DMA,
+				flags & MPOL_MF_MOVE_CONCUR);
 	if (!err1)
 		err1 = store_status(status, start, current_node, i - start);
 	if (!err)
@@ -1789,7 +2312,9 @@ static int kernel_move_pages(pid_t pid, unsigned long nr_pages,
 	nodemask_t task_nodes;
 
 	/* Check flags */
-	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_MOVE_MT|MPOL_MF_MOVE_DMA))
+	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|
+				  MPOL_MF_MOVE_DMA|MPOL_MF_MOVE_MT|
+				  MPOL_MF_MOVE_CONCUR))
 		return -EINVAL;
 
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
-- 
2.7.4

