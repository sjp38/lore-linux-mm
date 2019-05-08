Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEC89C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 21:09:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53A8520989
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 21:09:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53A8520989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB0AA6B0003; Wed,  8 May 2019 17:09:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A61036B0005; Wed,  8 May 2019 17:09:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 978106B0007; Wed,  8 May 2019 17:09:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 622AF6B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 17:09:49 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h14so66662pgn.23
        for <linux-mm@kvack.org>; Wed, 08 May 2019 14:09:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ckBUHMj1Z4j4bpbSvdniJulF0vTFfoo/5G9/hFQjeN8=;
        b=OBy5FueYZZuT4t3ST0gxQGUOoLI4my4UhHcCTGoeutIkGnuqv0U18aCojiNcV8zr/C
         DgCrfZwNK0PDSY6v+XFXHAjxQ9U9EKnGthnlMF0G5LkXKRy6ggKV3daCKd5HuzyxvzsU
         Pvc2/SgKl3PoDC7+W2GteBf1knuGGAlvaF9h5aoBfG58eKokSMCsaIi8IfCJu4fbCEcp
         GvZFOGscDQdd11HSIbthS0bMmOl9St9eihtR6qrQH+ZCVR1eoDWEztlGiglN5A1/trOl
         eq1ZMAeyrmPpOUsv6E851jc3BPnvur6H+SMTJ0BAzDhka5DzVdp9PGG875CVljCAkiMB
         qVQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVOptnonOEIgN6D6wde9mkx8F1oTKAsjqZDgOJUhx0YnJdLOZCC
	jHRtpFQ/H3V8pCHiypYVG/fwAMEOC7FibhUiyme7qG491QX/q97pXzeDQSrptcYfBl8Tm+MTvMm
	abEcf2v84hWrjzlI3C/0ykooQFfZn+Cj4sqMTpxEXwPNj4RvQsTjoq1r/z1kFpMVJEg==
X-Received: by 2002:a17:902:4a:: with SMTP id 68mr35959846pla.235.1557349788842;
        Wed, 08 May 2019 14:09:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYw/P4ahYY4vrHFue0v4enohn3nh1F6Nu4rqrXYoDSHDE9umBXFbkNRflCbXMvDtrZovOk
X-Received: by 2002:a17:902:4a:: with SMTP id 68mr35959722pla.235.1557349787883;
        Wed, 08 May 2019 14:09:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557349787; cv=none;
        d=google.com; s=arc-20160816;
        b=js3xepg4zm6iOOztzceDjP9ldVt/6Aw6vNFFbntswzq8Pa+8ZpbrzF/t11uDc4l1Xw
         XkdqWXY0WAb1KTV7B9i4Vg4+QdljTahRWHk3L3/RKJP9rwdUYyRqOTY9tt/q2GHE5HH5
         PIcjV1ioLI7f6+ad7BjWXhyi3REa3c+LgIqDkoqOWAsWN6W+t8euWyBXrTubPaj3F0R0
         TLwA5YTYVhW1YUeKkrIvNYyuBHumTzHksBDuHu9ZdIsdd1TDxCje5BhKYMQ07VNIMV/c
         hqMrGZotAz9Bff0gisMFyPdsfjA2ZfF4sZ4pVMd1rC1QIEYGwlSM+/+a5HMJVNWvW6tJ
         DocA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ckBUHMj1Z4j4bpbSvdniJulF0vTFfoo/5G9/hFQjeN8=;
        b=MybIawiNwZ/qsMDqC9VSG7I/Zu+b3Y6Y7sWIsyId3bFxL0E+3wodrEEGMrBpo1lnGx
         KFezl2Kpm3NOrCLqML5k1ZWtyebNmqHmVgusyeWQbX/gaHINE1Ma7lQeetTwbxBZepaQ
         iGbo7PzwLA10E5yhmMak+LUOyl8lZnJPikAIvJMWWM4Aou+qsmaDKktihk3Nukywt/RR
         hLQcYLlinwRvHyWoD8/3BsqYCT3JZQGaaJ6PSKfXnRUkns86hz9zenYyXN1z+aKiJr5h
         N0B89gQcYusMOYkrNAcxF1aA25XwDQBtS1Zwl4ErEm91wDA00eSQCnw3ONOeq28SNpsW
         nRUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id n1si23872220plp.272.2019.05.08.14.09.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 14:09:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 14:09:47 -0700
X-ExtLoop1: 1
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga005.jf.intel.com with ESMTP; 08 May 2019 14:09:46 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCH] mm: migrate: remove unused mode argument
Date: Wed,  8 May 2019 15:03:01 -0600
Message-Id: <20190508210301.8472-1-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

migrate_page_move_mapping() doesn't use the mode argument. Remove it
and update callers accordingly.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 fs/aio.c                | 2 +-
 fs/f2fs/data.c          | 2 +-
 fs/iomap.c              | 2 +-
 fs/ubifs/file.c         | 2 +-
 include/linux/migrate.h | 3 +--
 mm/migrate.c            | 7 +++----
 6 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 3490d1fa0e16..1a1568861b4e 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -425,7 +425,7 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	BUG_ON(PageWriteback(old));
 	get_page(new);
 
-	rc = migrate_page_move_mapping(mapping, new, old, mode, 1);
+	rc = migrate_page_move_mapping(mapping, new, old, 1);
 	if (rc != MIGRATEPAGE_SUCCESS) {
 		put_page(new);
 		goto out_unlock;
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 9727944139f2..0eb7a8cd3138 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -2801,7 +2801,7 @@ int f2fs_migrate_page(struct address_space *mapping,
 	/* one extra reference was held for atomic_write page */
 	extra_count = atomic_written ? 1 : 0;
 	rc = migrate_page_move_mapping(mapping, newpage,
-				page, mode, extra_count);
+				page, extra_count);
 	if (rc != MIGRATEPAGE_SUCCESS) {
 		if (atomic_written)
 			mutex_unlock(&fi->inmem_lock);
diff --git a/fs/iomap.c b/fs/iomap.c
index abdd18e404f8..f26f4846a00b 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -571,7 +571,7 @@ iomap_migrate_page(struct address_space *mapping, struct page *newpage,
 {
 	int ret;
 
-	ret = migrate_page_move_mapping(mapping, newpage, page, mode, 0);
+	ret = migrate_page_move_mapping(mapping, newpage, page, 0);
 	if (ret != MIGRATEPAGE_SUCCESS)
 		return ret;
 
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 5d2ffb1a45fc..d906ebc24049 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1481,7 +1481,7 @@ static int ubifs_migrate_page(struct address_space *mapping,
 {
 	int rc;
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, mode, 0);
+	rc = migrate_page_move_mapping(mapping, newpage, page, 0);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e13d9bf2f9a5..7f04754c7f2b 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -77,8 +77,7 @@ extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
 extern int migrate_page_move_mapping(struct address_space *mapping,
-		struct page *newpage, struct page *page, enum migrate_mode mode,
-		int extra_count);
+		struct page *newpage, struct page *page, int extra_count);
 #else
 
 static inline void putback_movable_pages(struct list_head *l) {}
diff --git a/mm/migrate.c b/mm/migrate.c
index 663a5449367a..85f46bfcf141 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -397,8 +397,7 @@ static int expected_page_refs(struct address_space *mapping, struct page *page)
  * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
  */
 int migrate_page_move_mapping(struct address_space *mapping,
-		struct page *newpage, struct page *page, enum migrate_mode mode,
-		int extra_count)
+		struct page *newpage, struct page *page, int extra_count)
 {
 	XA_STATE(xas, &mapping->i_pages, page_index(page));
 	struct zone *oldzone, *newzone;
@@ -684,7 +683,7 @@ int migrate_page(struct address_space *mapping,
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, mode, 0);
+	rc = migrate_page_move_mapping(mapping, newpage, page, 0);
 
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
@@ -783,7 +782,7 @@ static int __buffer_migrate_page(struct address_space *mapping,
 		}
 	}
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, mode, 0);
+	rc = migrate_page_move_mapping(mapping, newpage, page, 0);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		goto unlock_buffers;
 
-- 
2.14.4

