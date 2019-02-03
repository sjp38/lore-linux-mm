Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECF43C282DB
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 06:54:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A80A2082E
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 06:54:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="GWHyK0x4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A80A2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34B7F8E001B; Sun,  3 Feb 2019 01:54:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FB008E0001; Sun,  3 Feb 2019 01:54:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C3378E001B; Sun,  3 Feb 2019 01:54:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD13B8E0001
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 01:54:29 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q64so9564573pfa.18
        for <linux-mm@kvack.org>; Sat, 02 Feb 2019 22:54:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ICuNB17w6PrPN6phGSOGL9Fh2axlKpYzYZ29Jq7bzZ0=;
        b=tOEC/mjKvGviUeKVx9V8pDsIhYnwSQzl1+d3gQhbqQBj/nwD7VCp8GA9UF4804mbx1
         aIfj+H6nQv6mlQtK2ZoBGjP0Zu5p/xwYorItzwLwxYAqsQee5xhfAj6xtk5a/k9okwnw
         dl8hF3M0ZwNtenUf+Z6NmpJHmiVoA/f2izyskyCdaaTrFgE6Hygh1ck2Ama+Ys+sdhe2
         16dRX5uusxYMCjvQwv4+ZbJFNVHlMyVRBVMgz4QLvCN/PoNmZMLrqpCTqAUiSoZVj0Bo
         3ibvBZW5ypyfS8UMzDoQWnknutc4z9jiMaGDyAkarTDQiWDB2hqDEU5LoIhY+w3yZWvN
         VXyw==
X-Gm-Message-State: AJcUukfk/94QlxOFpm4CwswjM5W2ebrICD1Aw2HL0SU66sYOX7aXe2GR
	rzDbIhwu3Bg3oFqc1qjN9gNzqzJgEDAaoNH2TVmNhjRhx+NyUyugPooIW+5+Crt9q3vVUjy3OXK
	2t57Upf9ht8PwWHAtjMEhWBnk6upJ1tujR9pG4wOFsPUAP06E6h0647D5U2v9zKH+zQdtevr+HU
	DkYkVmM7AahpiWG311rKL39i+Z/oT0xO+QeNqQ8p88usGQCP3XcLvAGyxXnvRjJvErPLlw285X4
	S1wemGg1Kjx9CbBQ3whzSA8V77/pneshAv//u2ktLL0V44bpd35nvUVC+dA53SuPzCUV4As0rcP
	FfT1vldBmAEheRCePrFDVCv3kSz/UMqVfy0cPcqoL8sBAaYjnr+dKEhfdMteO92vy7AVkcfOurg
	h
X-Received: by 2002:a17:902:541:: with SMTP id 59mr47555613plf.88.1549176869310;
        Sat, 02 Feb 2019 22:54:29 -0800 (PST)
X-Received: by 2002:a17:902:541:: with SMTP id 59mr47555597plf.88.1549176868469;
        Sat, 02 Feb 2019 22:54:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549176868; cv=none;
        d=google.com; s=arc-20160816;
        b=HaGVK5MzQ4fAFaFYGTn9TQCGPgGB0MZZ9RpW859NBDSir+mM1H/z1r0w8Psmth8n5+
         QXMIszUcuuBkaWQLOigL2VZbtBifgIfBwMMhJ2MMH4NT3cIxNa+m79wWvBI9tArdPJO1
         jMF6iETcBl2FhUGFw8YjF6sCAdN0rqwzBRcqtmYNLm9o0H/2p2CapfhaXsB5kIuBdyYr
         sJjLfbSvoC+8ndmc/a0jbZGdLRCCs5v0BOSE/Ul7026SPEJIYfzxXPg+3GwzT3cQI7fP
         ofvkzG2DkKVJX24iZ32LK8cYZlCR6WjDxTz049Sn8jD3cZ3QO8b62ioYfOBzF4i+ITYB
         80tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=ICuNB17w6PrPN6phGSOGL9Fh2axlKpYzYZ29Jq7bzZ0=;
        b=Wj+Hzp8ggV6Y41SG8UeUhRmSQ3tcMvAkU/S1yMCWWxqtcTDzBv073T2PWeS6tC+ZxV
         E8vg+nXXkTQLXyCQzQC9IRXx19C8/fQ00wuyPCTtFWxaHpoyoo/iH/Od8lqIqe18T7bI
         imNZ6mR7RrNAyp5nkfcWvtDdlCOFn4X2e3Sbi3tmTo0x2QQdGSlSaWUFZmE5D9BDMJKN
         ltmpEUMI2irdQ4uYcvps8vgZsZZYaZYoSFnjbK6FdJCQ+bilo//jlPKCnidSoHkNVWIU
         +hZaTt6rTkU1dzSDrRR2uyZY/f+1BoMtu44ypguu/6eTHCB+I5lfHlT67qZNPqNz5Ovc
         cBBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=GWHyK0x4;
       spf=pass (google.com: domain of sspatil@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sspatil@android.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w17sor20997649pga.2.2019.02.02.22.54.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Feb 2019 22:54:28 -0800 (PST)
Received-SPF: pass (google.com: domain of sspatil@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=GWHyK0x4;
       spf=pass (google.com: domain of sspatil@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sspatil@android.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ICuNB17w6PrPN6phGSOGL9Fh2axlKpYzYZ29Jq7bzZ0=;
        b=GWHyK0x49kjObKonHwtpIl5Vl+vV1kLSpiEZA92ogSSBI+NNJsq5SQed+mqfo4nhz0
         hB2Ry6q5MHe0j9/tQPltGBAopLp3VBLMxs+veFjKHc79fXxBgy2q3ySN8klCV75zFfzi
         K2T+nMSGAWs5EmR+ZjrbHgMAFBSBdKD7vAoLeLxSAyhYQWIYAXOzraOj6luU+km39NNv
         UbugfkPObxLSiqUghh5SFie+G1Btplaspxn4Vww7QlGbI2eEIC19NG+CIdyFCN86lgYZ
         x+2qjn9xv0VykNOsYQfYL8Ip4s8QDEHTNBsnHoSXxvI3BRO0xxw8SpMOCsT0jztw2uWt
         hZeg==
X-Google-Smtp-Source: AHgI3Ib2ZLygKEHd7KMJZinYXtBH9sKmiVSjNEvzqS/kf0ZnksfYfwOiVUZ/LEIqxOtAUS4ukzYhsg==
X-Received: by 2002:a65:40ca:: with SMTP id u10mr7500164pgp.321.1549176867992;
        Sat, 02 Feb 2019 22:54:27 -0800 (PST)
Received: from sspatil-glaptop2.roam.corp.google.com (c-73-170-36-70.hsd1.ca.comcast.net. [73.170.36.70])
        by smtp.gmail.com with ESMTPSA id t3sm7363638pgp.5.2019.02.02.22.54.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Feb 2019 22:54:27 -0800 (PST)
From: Sandeep Patil <sspatil@android.com>
To: vbabka@suse.cz,
	adobriyan@gmail.com,
	akpm@linux-foundation.org,
	avagin@openvz.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	kernel-team@android.com,
	dancol@google.com
Subject: [PATCH v2] mm: proc: smaps_rollup: Fix pss_locked calculation
Date: Sat,  2 Feb 2019 22:54:25 -0800
Message-Id: <20190203065425.14650-1-sspatil@android.com>
X-Mailer: git-send-email 2.20.1.611.gfbb209baf1-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The 'pss_locked' field of smaps_rollup was being calculated incorrectly.
It accumulated the current pss everytime a locked VMA was found.  Fix
that by adding to 'pss_locked' the same time as that of 'pss' if the vma
being walked is locked.

Fixes: 493b0e9d945f ("mm: add /proc/pid/smaps_rollup")
Cc: stable@vger.kernel.org # 4.14.y 4.19.y
Signed-off-by: Sandeep Patil <sspatil@android.com>
---

v1->v2
------
- Move pss_locked accounting into smaps_account() inline with pss

 fs/proc/task_mmu.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0ec9edab2f3..85b0ef890b28 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -423,7 +423,7 @@ struct mem_size_stats {
 };
 
 static void smaps_account(struct mem_size_stats *mss, struct page *page,
-		bool compound, bool young, bool dirty)
+		bool compound, bool young, bool dirty, bool locked)
 {
 	int i, nr = compound ? 1 << compound_order(page) : 1;
 	unsigned long size = nr * PAGE_SIZE;
@@ -450,24 +450,31 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 		else
 			mss->private_clean += size;
 		mss->pss += (u64)size << PSS_SHIFT;
+		if (locked)
+			mss->pss_locked += (u64)size << PSS_SHIFT;
 		return;
 	}
 
 	for (i = 0; i < nr; i++, page++) {
 		int mapcount = page_mapcount(page);
+		unsigned long pss = (PAGE_SIZE << PSS_SHIFT);
 
 		if (mapcount >= 2) {
 			if (dirty || PageDirty(page))
 				mss->shared_dirty += PAGE_SIZE;
 			else
 				mss->shared_clean += PAGE_SIZE;
-			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
+			mss->pss += pss / mapcount;
+			if (locked)
+				mss->pss_locked += pss / mapcount;
 		} else {
 			if (dirty || PageDirty(page))
 				mss->private_dirty += PAGE_SIZE;
 			else
 				mss->private_clean += PAGE_SIZE;
-			mss->pss += PAGE_SIZE << PSS_SHIFT;
+			mss->pss += pss;
+			if (locked)
+				mss->pss_locked += pss;
 		}
 	}
 }
@@ -490,6 +497,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 {
 	struct mem_size_stats *mss = walk->private;
 	struct vm_area_struct *vma = walk->vma;
+	bool locked = !!(vma->vm_flags & VM_LOCKED);
 	struct page *page = NULL;
 
 	if (pte_present(*pte)) {
@@ -532,7 +540,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 	if (!page)
 		return;
 
-	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte));
+	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte), locked);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -541,6 +549,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 {
 	struct mem_size_stats *mss = walk->private;
 	struct vm_area_struct *vma = walk->vma;
+	bool locked = !!(vma->vm_flags & VM_LOCKED);
 	struct page *page;
 
 	/* FOLL_DUMP will return -EFAULT on huge zero page */
@@ -555,7 +564,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 		/* pass */;
 	else
 		VM_BUG_ON_PAGE(1, page);
-	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
+	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd), locked);
 }
 #else
 static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
@@ -737,11 +746,8 @@ static void smap_gather_stats(struct vm_area_struct *vma,
 		}
 	}
 #endif
-
 	/* mmap_sem is held in m_start */
 	walk_page_vma(vma, &smaps_walk);
-	if (vma->vm_flags & VM_LOCKED)
-		mss->pss_locked += mss->pss;
 }
 
 #define SEQ_PUT_DEC(str, val) \
-- 
2.20.1.611.gfbb209baf1-goog

