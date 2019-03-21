Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48F4DC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:03:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08F5B2175B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:03:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08F5B2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 490F16B000D; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32AF36B0010; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F38796B000D; Thu, 21 Mar 2019 16:03:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7FCF6B0007
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:03:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z14so1763845pgv.0
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:03:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=gmhbQpGGOf5KS7QcODtDEeapu1XYScq6rBODur+OmoM=;
        b=uUMs2B4/cDoby+ZupTROjDhUDFXuP8vISOZM/t+NIT33NEWvxWXBGneN56BYHuwkVG
         zTuvpLHsPDIDojsdLTu82epwtyjPaxxhc7e4g1PQhiU6x7to7q3dD+qPdwdAppcf5sBR
         m53TqksLg1PzkokniwPI9qDcQakMNFx1IGsB4zTwSISuGK4VLhRkmGkJffKDSFlXAyQa
         jIQ1izM9/vvQ297liQF3IAJswHN9/4qTn41RlIjvurP6/7JwSgYINIBccl1x/LnNyTlO
         zx/Wm1lrgSTjfJFZA1ylPBhV/fUl19+dlfjjsqNTXS6Z8dxvtSjHjNhKkZqDBz63m6YL
         vGJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWJk5jvybW/hMA90IbwLqSdfDOixQGJ/0r/B7oZFuOayJQwN2jI
	wQm9nCTXDDyEX2zJk+dL+uGroNg0C4HMysj1QeUehEhqDlKtU57hqKmWshN2zcE+FYYitclr2+s
	34vwUG+pLbvIKy5nmma2ZwGCZstUOcrgCUGImmO7Gg7BbYRMsvFdwN0bJbXq5dBlZ+g==
X-Received: by 2002:a17:902:d24:: with SMTP id 33mr5392012plu.246.1553198579227;
        Thu, 21 Mar 2019 13:02:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKFAI6GsuS1bcrFFlzrrHgG0GxEGUUf462weOn1rqOA0FWnFN3Hi2u2E1uGgnvpyAdCHO4
X-Received: by 2002:a17:902:d24:: with SMTP id 33mr5391885plu.246.1553198577720;
        Thu, 21 Mar 2019 13:02:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553198577; cv=none;
        d=google.com; s=arc-20160816;
        b=09p6GImtIgYGv/1iR1saT1px6IAtQe06LxkUcmsf9ARibOn6+QaSWhBWTvxUsByfL8
         CshdkGSkVwn+p8By8cZaniGK4pewj3JvZPibtVKINPdAhQrGUsLJHAg+RQKGOnDQ/n+r
         5y6xbI3T7zRrQD7UGU7c+zV8BlPm/pg22nIKpYGmcw2mAr9j8NI8/iQ8zbvuKOWi2ULR
         MQCS+tBUA6Y+7MLP4B13iRyKgrlZIGOJZEGDUoidvBIAW/P6AvDGICCX7zuqgF+p7ZON
         ZRo3lQFTKFrED8E6YEG0V8oQ06ioeIj3uirinrS60qUBkjIHA8AK5GZaA+v9nzsEFz96
         OwLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=gmhbQpGGOf5KS7QcODtDEeapu1XYScq6rBODur+OmoM=;
        b=XO8y8SYIK9G61HKMGNSpcNnYk1vGL3qAHs/ik8aBL7V8vjXUQRi94ZtybgAWAxRTOC
         AYN1MM3j9t1va/5GUd58ukWj3LXaCulz5RBptOv5MvjAGts7UIFq2/hgMSzFdMc1KlXy
         8DMx7LYM3P2mWZhKOFvXeoMKVEqcBVxZgjvNGJe7fvkCdtueSpiQktj9ZLrkZPx6Ig4f
         o1BmRk3qFy3CUGXgaavWqL5MC/Vxk0qVAYUeRScfv0ERkGiMItomyhHZVhOfv5Wp4qt+
         C61u3icyF58WnZb9X891nOaqlLWUPp47VinkecHncXMffPythVQsSy2v4G1GLrB4hPOT
         4tpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r25si4703408pfd.91.2019.03.21.13.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 13:02:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Mar 2019 13:02:57 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,254,1549958400"; 
   d="scan'208";a="309246237"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga005.jf.intel.com with ESMTP; 21 Mar 2019 13:02:56 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCH 2/5] mm: Split handling old page for migration
Date: Thu, 21 Mar 2019 14:01:54 -0600
Message-Id: <20190321200157.29678-3-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190321200157.29678-1-keith.busch@intel.com>
References: <20190321200157.29678-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Refactor unmap_and_move() handling for the new page into a separate
function from locking and preparing the old page.

No functional change here: this is just making it easier to reuse this
part of the page migration from contexts that already locked the old page.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 mm/migrate.c | 115 +++++++++++++++++++++++++++++++----------------------------
 1 file changed, 61 insertions(+), 54 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index ac6f4939bb59..705b320d4b35 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1000,57 +1000,14 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 	return rc;
 }
 
-static int __unmap_and_move(struct page *page, struct page *newpage,
-				int force, enum migrate_mode mode)
+static int __unmap_and_move_locked(struct page *page, struct page *newpage,
+				   enum migrate_mode mode)
 {
 	int rc = -EAGAIN;
 	int page_was_mapped = 0;
 	struct anon_vma *anon_vma = NULL;
 	bool is_lru = !__PageMovable(page);
 
-	if (!trylock_page(page)) {
-		if (!force || mode == MIGRATE_ASYNC)
-			goto out;
-
-		/*
-		 * It's not safe for direct compaction to call lock_page.
-		 * For example, during page readahead pages are added locked
-		 * to the LRU. Later, when the IO completes the pages are
-		 * marked uptodate and unlocked. However, the queueing
-		 * could be merging multiple pages for one bio (e.g.
-		 * mpage_readpages). If an allocation happens for the
-		 * second or third page, the process can end up locking
-		 * the same page twice and deadlocking. Rather than
-		 * trying to be clever about what pages can be locked,
-		 * avoid the use of lock_page for direct compaction
-		 * altogether.
-		 */
-		if (current->flags & PF_MEMALLOC)
-			goto out;
-
-		lock_page(page);
-	}
-
-	if (PageWriteback(page)) {
-		/*
-		 * Only in the case of a full synchronous migration is it
-		 * necessary to wait for PageWriteback. In the async case,
-		 * the retry loop is too short and in the sync-light case,
-		 * the overhead of stalling is too much
-		 */
-		switch (mode) {
-		case MIGRATE_SYNC:
-		case MIGRATE_SYNC_NO_COPY:
-			break;
-		default:
-			rc = -EBUSY;
-			goto out_unlock;
-		}
-		if (!force)
-			goto out_unlock;
-		wait_on_page_writeback(page);
-	}
-
 	/*
 	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
 	 * we cannot notice that anon_vma is freed while we migrates a page.
@@ -1077,11 +1034,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	 * This is much like races on refcount of oldpage: just don't BUG().
 	 */
 	if (unlikely(!trylock_page(newpage)))
-		goto out_unlock;
+		goto out;
 
 	if (unlikely(!is_lru)) {
 		rc = move_to_new_page(newpage, page, mode);
-		goto out_unlock_both;
+		goto out_unlock;
 	}
 
 	/*
@@ -1100,7 +1057,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		VM_BUG_ON_PAGE(PageAnon(page), page);
 		if (page_has_private(page)) {
 			try_to_free_buffers(page);
-			goto out_unlock_both;
+			goto out_unlock;
 		}
 	} else if (page_mapped(page)) {
 		/* Establish migration ptes */
@@ -1110,22 +1067,19 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 		page_was_mapped = 1;
 	}
-
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page, mode);
 
 	if (page_was_mapped)
 		remove_migration_ptes(page,
 			rc == MIGRATEPAGE_SUCCESS ? newpage : page, false);
-
-out_unlock_both:
-	unlock_page(newpage);
 out_unlock:
+	unlock_page(newpage);
 	/* Drop an anon_vma reference if we took one */
+out:
 	if (anon_vma)
 		put_anon_vma(anon_vma);
-	unlock_page(page);
-out:
+
 	/*
 	 * If migration is successful, decrease refcount of the newpage
 	 * which will not free the page because new page owner increased
@@ -1141,7 +1095,60 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		else
 			putback_lru_page(newpage);
 	}
+	return rc;
+}
+
+static int __unmap_and_move(struct page *page, struct page *newpage,
+				int force, enum migrate_mode mode)
+{
+	int rc = -EAGAIN;
+
+	if (!trylock_page(page)) {
+		if (!force || mode == MIGRATE_ASYNC)
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
 
+	if (PageWriteback(page)) {
+		/*
+		 * Only in the case of a full synchronous migration is it
+		 * necessary to wait for PageWriteback. In the async case,
+		 * the retry loop is too short and in the sync-light case,
+		 * the overhead of stalling is too much
+		 */
+		switch (mode) {
+		case MIGRATE_SYNC:
+		case MIGRATE_SYNC_NO_COPY:
+			break;
+		default:
+			rc = -EBUSY;
+			goto out_unlock;
+		}
+		if (!force)
+			goto out_unlock;
+		wait_on_page_writeback(page);
+	}
+	rc = __unmap_and_move_locked(page, newpage, mode);
+out_unlock:
+	unlock_page(page);
+out:
 	return rc;
 }
 
-- 
2.14.4

