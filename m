Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A925C28CC0
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 00:27:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22B4E24283
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 00:27:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Pj8Wyl2c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22B4E24283
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72CDC6B000E; Thu, 30 May 2019 20:27:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DC7F6B0280; Thu, 30 May 2019 20:27:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CB4B6B0281; Thu, 30 May 2019 20:27:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24D5D6B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 20:27:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d7so5832227pfq.15
        for <linux-mm@kvack.org>; Thu, 30 May 2019 17:27:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=qZkAJpZG6bDCCsOzml7qoqSS4nZt/eDtWBmF7ivil08=;
        b=GBpHE9URIICSdbluqBoYD/QSuFxrCm8SDRcCY6eQ5Auxk1mF/KJo+xr0PALHlsTBzy
         8VQO2FMXz4xlehs5B0goHC+WMyRpecoupy9rFcl/TRiFslJZLrdutRJ9qPltBuyhtH+b
         NL5YOpMFq36M3glUTp/35Abj2XAHtoiG+oMdqw7Q68uLUG6H0LKOXdi9qY1m23GTD8+Q
         WDdYd4DNjfSC79Y8HZfztP5SnruNDWGbI/zJ70T1/PcrB+JV+2SPiTI3gio7qydvOQX2
         i5tc9UhefNx8PsSjgmIkPeOWoagO1ldmDQ+uhKP0QX7vTlOX2a1AEmwJiiOebi7MLhW3
         eSwg==
X-Gm-Message-State: APjAAAXAh70sOZJ1gkdjZR9g+YZzOtTHdO89PHUcAHKiQlXwhVAV3+Oe
	WF7iRAixoDKEQvKgzDEicv3BugKI/TTxg8HS5Ye3t+CQ00rVZE7Zw1hJc3SDqL+Y/qYugC//0BL
	DOuoRb3o6nMh0zvI3ugGV6OZymUeaxS3uw7vjlLYWl1GrOXquBbf28KxihEU8vkICOQ==
X-Received: by 2002:a63:c744:: with SMTP id v4mr6116422pgg.370.1559262446552;
        Thu, 30 May 2019 17:27:26 -0700 (PDT)
X-Received: by 2002:a63:c744:: with SMTP id v4mr6116367pgg.370.1559262445420;
        Thu, 30 May 2019 17:27:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559262445; cv=none;
        d=google.com; s=arc-20160816;
        b=d6cZG7VXIFoA3F1PBgik0e4+KPOYAf50lMAafjDaxN9cFb1AXAdXXob6IBRu/74//g
         isg4PMQCd1/EhMSObJxYkXW+FXc3sfrEvTzXvogAlnCtB/QkMmY6ywr9eL851MJvMnPz
         Bv5Hh9UtOMi3PMi9Cxu1xuodiDIq7kmeuui7hHJo69OCZeifpVNl6PbvcMN8bVdtTd8m
         e6e8xjbzEYLBgFK7T2rXCoZhYffsP+cHfjQ2cevez6ExqTSOVpoKAb4oBPhjeHe0nOUz
         lRIBdfWxOjTC+F83UraYsZBd0T9/XOdxzaBBFtDC3OWg/T32FIImmuZVa/x5V5B7f57k
         bsbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=qZkAJpZG6bDCCsOzml7qoqSS4nZt/eDtWBmF7ivil08=;
        b=RXjqYg8FBWAcDzjYPFo4oT7+9nzPLEamkVHN1weo35yMzI7xWxBJy5Do485Dv77xVP
         DLSkKn57qhnIgHrB9ZshRct2zuIRb3q0VqPAXiIyvW9YGxjABFrIDsIosQNM+RfYU3WR
         tVmKzXZnNOujEHil1sYAnq7Vliv+BDOWMvhUfWWmkziTIeWzsAr+X11R8A4qF4whvs4v
         MVFWcCDBwcLzD/X5o9IfDJclw+HL+T9qm52zS3TXJlCXpbrpPeVMUk0F8mPpoHAbFd5D
         Sma3gKZ8CrJlLOQmN6JkNpuiPlRjdTw4zx6aZs7wKYOUcxm5qG0KUXDetuaIAUVZi6j9
         HwVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Pj8Wyl2c;
       spf=pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v19sor4959378pfe.58.2019.05.30.17.27.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 17:27:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Pj8Wyl2c;
       spf=pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=qZkAJpZG6bDCCsOzml7qoqSS4nZt/eDtWBmF7ivil08=;
        b=Pj8Wyl2cjiuJvw8nR6f+8arEow3ZgQ6gni6xfq60vMKNu26YUo4kBK/wghHivTEt0M
         YZc/Dv+q3RvwZXo8mcxy+lFJGAU2baVbH/AOR/ATNNjDSnfaCKjlGfrwJhANyEthOzx3
         G6sRrnEdI0MXD5oEre/VcJfORdgUqdZcsA8GA=
X-Google-Smtp-Source: APXvYqxNKtllBXJfYySU+sae0FLmVaFYK7w4oRVd2/OlgJFozcHKehvpoMyb2hNFxCndNVJNNFC7qA==
X-Received: by 2002:a62:304:: with SMTP id 4mr6555775pfd.186.1559262444566;
        Thu, 30 May 2019 17:27:24 -0700 (PDT)
Received: from luigi2.mtv.corp.google.com ([2620:15c:202:1:2c30:5512:25f8:631d])
        by smtp.gmail.com with ESMTPSA id h11sm4108369pfn.170.2019.05.30.17.27.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 17:27:24 -0700 (PDT)
From: semenzato@chromium.org
To: linux-mm@kvack.org,
	akpm@linux-foundation.org
Cc: sonnyrao@chromium.org,
	Luigi Semenzato <semenzato@chromium.org>,
	Yu Zhao <yuzhao@chromium.org>
Subject: [PATCH v2 1/1] mm: smaps: split PSS into components
Date: Thu, 30 May 2019 17:26:33 -0700
Message-Id: <20190531002633.128370-1-semenzato@chromium.org>
X-Mailer: git-send-email 2.22.0.rc1.257.g3120a18244-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Luigi Semenzato <semenzato@chromium.org>

Report separate components (anon, file, and shmem)
for PSS in smaps_rollup.

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

Acked-by: Yu Zhao <yuzhao@chromium.org>
Signed-off-by: Luigi Semenzato <semenzato@chromium.org>
---
 fs/proc/task_mmu.c | 91 +++++++++++++++++++++++++++++++---------------
 1 file changed, 61 insertions(+), 30 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 01d4eb0e6bd1..ed3b952f0d30 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -417,17 +417,53 @@ struct mem_size_stats {
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
+		bool dirty, bool locked, bool private)
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
+
+	if (dirty || PageDirty(page)) {
+		if (private)
+			mss->private_dirty += size;
+		else
+			mss->shared_dirty += size;
+	} else {
+		if (private)
+			mss->private_clean += size;
+		else
+			mss->shared_clean += size;
+	}
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
@@ -440,42 +476,24 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
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
+		smaps_page_accumulate(mss, page, size, size << PSS_SHIFT, dirty,
+			locked, true);
 		return;
 	}
-
 	for (i = 0; i < nr; i++, page++) {
 		int mapcount = page_mapcount(page);
-		unsigned long pss = (PAGE_SIZE << PSS_SHIFT);
-
-		if (mapcount >= 2) {
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
-		}
+		unsigned long pss = PAGE_SIZE << PSS_SHIFT;
+
+		smaps_page_accumulate(mss, page, PAGE_SIZE, pss / mapcount,
+			dirty, locked, mapcount < 2);
 	}
 }
 
@@ -754,10 +772,23 @@ static void smap_gather_stats(struct vm_area_struct *vma,
 		seq_put_decimal_ull_width(m, str, (val) >> 10, 8)
 
 /* Show the contents common for smaps and smaps_rollup */
-static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss)
+static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss,
+	bool rollup_mode)
 {
 	SEQ_PUT_DEC("Rss:            ", mss->resident);
 	SEQ_PUT_DEC(" kB\nPss:            ", mss->pss >> PSS_SHIFT);
+	if (rollup_mode) {
+		/*
+		 * These are meaningful only for smaps_rollup, otherwise two of
+		 * them are zero, and the other one is the same as Pss.
+		 */
+		SEQ_PUT_DEC(" kB\nPss_Anon:       ",
+			mss->pss_anon >> PSS_SHIFT);
+		SEQ_PUT_DEC(" kB\nPss_File:       ",
+			mss->pss_file >> PSS_SHIFT);
+		SEQ_PUT_DEC(" kB\nPss_Shmem:      ",
+			mss->pss_shmem >> PSS_SHIFT);
+	}
 	SEQ_PUT_DEC(" kB\nShared_Clean:   ", mss->shared_clean);
 	SEQ_PUT_DEC(" kB\nShared_Dirty:   ", mss->shared_dirty);
 	SEQ_PUT_DEC(" kB\nPrivate_Clean:  ", mss->private_clean);
@@ -794,7 +825,7 @@ static int show_smap(struct seq_file *m, void *v)
 	SEQ_PUT_DEC(" kB\nMMUPageSize:    ", vma_mmu_pagesize(vma));
 	seq_puts(m, " kB\n");
 
-	__show_smap(m, &mss);
+	__show_smap(m, &mss, false);
 
 	seq_printf(m, "THPeligible:    %d\n", transparent_hugepage_enabled(vma));
 
@@ -841,7 +872,7 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
 	seq_pad(m, ' ');
 	seq_puts(m, "[rollup]\n");
 
-	__show_smap(m, &mss);
+	__show_smap(m, &mss, true);
 
 	release_task_mempolicy(priv);
 	up_read(&mm->mmap_sem);
-- 
2.22.0.rc1.257.g3120a18244-goog

