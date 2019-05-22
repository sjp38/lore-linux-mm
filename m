Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DE0AC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 23:54:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE55520665
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 23:54:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="jNaH/TUq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE55520665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B00F6B0003; Wed, 22 May 2019 19:54:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 660466B0006; Wed, 22 May 2019 19:54:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54FEF6B0007; Wed, 22 May 2019 19:54:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDF36B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 19:54:18 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id h12so2262335pll.20
        for <linux-mm@kvack.org>; Wed, 22 May 2019 16:54:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=pCFCyy+pn8NS0YDu+xqpV15sb+NHXjz/amNbL2oRXkE=;
        b=Lo/lQmJeAtqOr3aVJFO6eXaJxwtUzMmFH327XtCwvJ9X65a+gKcx4WbFeRoPSQ/4Tb
         beXMXgM5yiW4xbQnOOOwQQAMhkz60YesNrLazGJLTmQEdTJlokyJuzOK1E36a95I29Y8
         0bup0q/LhLs4pXs7PxMuROMnhBL75IcspvSvaIu16grvNsxJk32LO03vpjJYECZIGEur
         RxDprw8fDmeXZl7H2d7mb+Aa8HIOmcp8unLlz6K15IGreboci2JZyoJhAwxrvJ20lbqe
         MHJwOa51Z71dJZJSeGYp8NEoteCkuS3ruOlbT8WlcPgle7iiMuaeGG8pDoCC+0WFNV40
         mLrw==
X-Gm-Message-State: APjAAAX1VkFVbx8ADSX9FCNrwZJz/QUDSLm8qZZohPUIIPU4FKR/mLCA
	pvSakzydH9/8OPJhYWDdKdiQ2u8lAtIMBm5ICtI68txU98oQ5X3CMVi28bv9vkdky8szFgwdfpW
	nvtMU0M3GNLoALxqKxDbtYaJ4X2an3FqgoHcK+0nfh0ZJWUSF3nycs75Ol64ZltT2Ag==
X-Received: by 2002:a63:d652:: with SMTP id d18mr77174757pgj.112.1558569257485;
        Wed, 22 May 2019 16:54:17 -0700 (PDT)
X-Received: by 2002:a63:d652:: with SMTP id d18mr77174707pgj.112.1558569256630;
        Wed, 22 May 2019 16:54:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558569256; cv=none;
        d=google.com; s=arc-20160816;
        b=j2itTpovC7Zt9eR0d2gwildSd+w+XiWQWSlqGZN+e9+KULZCGwCx8zfk/n0FNc0/6A
         lEXsDpQUwUOVRlcN71OgJLkdOE6z+awO6RCYvsuQxahECQxrpzJYXsIty5OtYiFO+xO/
         jzdLupTKrcQ7kzlsFJHGYaEDj0ffBKlnzvaEkmNq9c8ivQdS1l8cL+L6uTap97oXNby/
         z+M8H+HeoYjnrqu8/JcWDa//YAtH6sbFHxlXzRJTxyMShMHPAQbJAXy8WCVd89qkyvwf
         bysP0qqq0wKbBmORvlmP1iNPLDvmohQsnBf5jYHJMU1vFc4UAUUYpQ8EHVKHnh8mvv3P
         ze7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=pCFCyy+pn8NS0YDu+xqpV15sb+NHXjz/amNbL2oRXkE=;
        b=L4R4Y+t3J2ht5SuoIrodliLg6YymxRFXJxmxtkR4PafbA381DJpZP8meIU9wG1OVuq
         /4B1RnlYbnTPF2bE8H5+H2NmgW28Gx8fHUHCbfy2L6iSLinqryQKsBL+dQpKKXcX36UL
         88EA3e4TWvBswcsN304sparUESBVwCKUSw1Mwqy+3LNtF38WbqFw3SKzhcs7gdUq6uei
         ElvV/KIBHZ2aYQFYpbFbZoxkYHpLvIDIkmIMATTWgQ5hiLJLqURquWCjlhH5CoOLeG2B
         0snw356Z/zoLrF7kboHCPzdTEELaqkZONOe/P9yl2BQTr3FBx4Hur2RZ6utWv6Nv3G4K
         uRIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="jNaH/TUq";
       spf=pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4sor8472237plk.55.2019.05.22.16.54.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 16:54:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="jNaH/TUq";
       spf=pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=pCFCyy+pn8NS0YDu+xqpV15sb+NHXjz/amNbL2oRXkE=;
        b=jNaH/TUqg08glj2u7iarGmoWFHEMoLChm4sIRDsKSjt8w3keAAVridKO2rRIziSzg6
         6K0qIf8KKspOc3iQk53JrV/C/rb8ct8BLzQNbfOdhXBLbAancqAlttvn8yAAxeU15O+o
         JLxislj6ZWnxZsDnMgfVFa8MdyZlUmEnIKV2U=
X-Google-Smtp-Source: APXvYqybpLhAy1BLM4IW8EFclBBoHY2HzZhtAEx8aUJLlDnYEi00GabDEmYdaEbRgAXp8IWuaw1tvQ==
X-Received: by 2002:a17:902:4481:: with SMTP id l1mr80425911pld.121.1558569255997;
        Wed, 22 May 2019 16:54:15 -0700 (PDT)
Received: from luigi2.mtv.corp.google.com ([2620:15c:202:1:2c30:5512:25f8:631d])
        by smtp.gmail.com with ESMTPSA id e14sm29745947pff.60.2019.05.22.16.54.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 16:54:15 -0700 (PDT)
From: semenzato@chromium.org
To: linux-mm@kvack.org
Cc: minchan@kernel.org,
	sonnyrao@chromium.org,
	dtor@chromium.org,
	Luigi Semenzato <semenzato@chromium.org>
Subject: [PATCH 1/1] mm: smaps: split PSS into components
Date: Wed, 22 May 2019 16:53:56 -0700
Message-Id: <20190522235356.153671-1-semenzato@chromium.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Luigi Semenzato <semenzato@chromium.org>

Report separate components (anon, file, and shmem)
for PSS in smaps and smaps_rollup.

This helps understand and tune the memory manager behavior
in consumer devices, particularly mobile devices.  Many of
them (e.g. chromebooks and Android-based devices) use zram
for anon memory, and perform disk reads for discarded file
pages.  The difference in latency is large (e.g. reading
a single page from SSD is 30 times slower than decompressing
a zram page on one popular device), thus it is useful to know
how much of the PSS is anon vs. file.

This patch also removes a small code duplication in smaps_account,
which would have gotten worse otherwise.

Signed-off-by: Luigi Semenzato <semenzato@chromium.org>
---
 fs/proc/task_mmu.c | 61 ++++++++++++++++++++++++++++------------------
 1 file changed, 37 insertions(+), 24 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 01d4eb0e6bd1..4b586c4d27b0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -417,17 +417,45 @@ struct mem_size_stats {
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
 	u64 pss;
+	u64 pss_anon;
+	u64 pss_file;
+	u64 pss_shmem;
 	u64 pss_locked;
 	u64 swap_pss;
 	bool check_shmem_swap;
 };
 
+static void smaps_page_accumulate(struct mem_size_stats *mss,
+		struct page *page, unsigned long size, unsigned long pss,
+		bool dirty, bool locked)
+{
+	mss->pss += pss;
+
+	if (PageAnon(page))
+		mss->pss_anon += pss;
+	else if (PageSwapBacked(page))
+		mss->pss_shmem += pss;
+	else
+		mss->pss_file += pss;
+
+	if (locked)
+		mss->pss_locked += pss;
+	if (dirty || PageDirty(page))
+		mss->shared_dirty += size;
+	else
+		mss->shared_clean += size;
+}
+
 static void smaps_account(struct mem_size_stats *mss, struct page *page,
 		bool compound, bool young, bool dirty, bool locked)
 {
 	int i, nr = compound ? 1 << compound_order(page) : 1;
 	unsigned long size = nr * PAGE_SIZE;
 
+	/*
+	 * First accumulate quantities that depend only on |size| and the type
+	 * of the compound page.
+	 */
 	if (PageAnon(page)) {
 		mss->anonymous += size;
 		if (!PageSwapBacked(page) && !dirty && !PageDirty(page))
@@ -440,42 +468,24 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 		mss->referenced += size;
 
 	/*
+	 * Then accumulate quantities that may depend on sharing, or that may
+	 * differ page-by-page.
+	 *
 	 * page_count(page) == 1 guarantees the page is mapped exactly once.
 	 * If any subpage of the compound page mapped with PTE it would elevate
 	 * page_count().
 	 */
 	if (page_count(page) == 1) {
-		if (dirty || PageDirty(page))
-			mss->private_dirty += size;
-		else
-			mss->private_clean += size;
-		mss->pss += (u64)size << PSS_SHIFT;
-		if (locked)
-			mss->pss_locked += (u64)size << PSS_SHIFT;
+		smaps_page_accumulate(mss, page, size, size, dirty, locked);
 		return;
 	}
-
 	for (i = 0; i < nr; i++, page++) {
 		int mapcount = page_mapcount(page);
 		unsigned long pss = (PAGE_SIZE << PSS_SHIFT);
-
 		if (mapcount >= 2) {
-			if (dirty || PageDirty(page))
-				mss->shared_dirty += PAGE_SIZE;
-			else
-				mss->shared_clean += PAGE_SIZE;
-			mss->pss += pss / mapcount;
-			if (locked)
-				mss->pss_locked += pss / mapcount;
-		} else {
-			if (dirty || PageDirty(page))
-				mss->private_dirty += PAGE_SIZE;
-			else
-				mss->private_clean += PAGE_SIZE;
-			mss->pss += pss;
-			if (locked)
-				mss->pss_locked += pss;
+			pss /= mapcount;
 		}
+		smaps_page_accumulate(mss, page, PAGE_SIZE, pss, dirty, locked);
 	}
 }
 
@@ -758,6 +768,9 @@ static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss)
 {
 	SEQ_PUT_DEC("Rss:            ", mss->resident);
 	SEQ_PUT_DEC(" kB\nPss:            ", mss->pss >> PSS_SHIFT);
+	SEQ_PUT_DEC(" kB\nPss_Anon:       ", mss->pss_anon >> PSS_SHIFT);
+	SEQ_PUT_DEC(" kB\nPss_File:       ", mss->pss_file >> PSS_SHIFT);
+	SEQ_PUT_DEC(" kB\nPss_Shmem:      ", mss->pss_shmem >> PSS_SHIFT);
 	SEQ_PUT_DEC(" kB\nShared_Clean:   ", mss->shared_clean);
 	SEQ_PUT_DEC(" kB\nShared_Dirty:   ", mss->shared_dirty);
 	SEQ_PUT_DEC(" kB\nPrivate_Clean:  ", mss->private_clean);
-- 
2.21.0.1020.gf2820cf01a-goog

