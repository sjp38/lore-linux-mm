Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B38EC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 11:54:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70A822190D
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 11:54:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="qdKsbIZ+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70A822190D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD2C56B0003; Tue, 23 Jul 2019 07:54:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B83BE6B0005; Tue, 23 Jul 2019 07:54:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A72C58E0002; Tue, 23 Jul 2019 07:54:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4041B6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 07:54:29 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id s10so4087842lfp.14
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:54:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=T+5ed5Bo1rCY2ZZgAuiYr0Ic9RXyb17hEruVBk9wrEk=;
        b=tSllyLgSQ3s63WwV5rkgCrVms2it0zrm8hUf46Nx4O+lDyrVH5a+OLnA/X8UKWBp+u
         f5wVJHWUFlkEK8IeK0bysCK8wTwcXK8tJgBBInjOhkkHdRhHmzokhLn4QyviAQPes8/N
         U3rm5NNpUgeD9Mu+/f8mrYcbHD0xORyk45wMHMMpPQL9lQnBm7tlN8qsLXw2sN6b7lwq
         T1MxSzFeNEVWRV1PMSWLeFtLsJdFPO3HZznFEGbs1yf52aXj4CB6HgJ976OlLoILZYyE
         0Bq6632+e9OFVAvph2KT2eqGwfA+hvgfhrXYVYSsc9I1/qvOhUhFX1uQxlnlWG0hYhdS
         ubvA==
X-Gm-Message-State: APjAAAU51mt2IhLsgXHSBJwddbA4Ik6tEmlbY2rgSUJ2ZI2cYIkeuCsA
	nvr0/6WsrxH5kGApaOpST9EfbH5zsf+QflaYX4mT3cvzzPupch112aW1pruyjd/ewqFKOzdxVCL
	XehZXr/mYHFrmnVCmaxjdcwIUAAOdat34wYRpxRkppKgTC7wTstISS55fu0VSyysJQA==
X-Received: by 2002:a2e:9048:: with SMTP id n8mr20055260ljg.37.1563882868487;
        Tue, 23 Jul 2019 04:54:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqe6h3CZdZTdCgc5ZU4Yp/V8O8poPtjBDC+iCo/YusUptOj7GxuyipNeoXQ/IqIjVqepKM
X-Received: by 2002:a2e:9048:: with SMTP id n8mr20055224ljg.37.1563882867433;
        Tue, 23 Jul 2019 04:54:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563882867; cv=none;
        d=google.com; s=arc-20160816;
        b=ZnUFqPnDxdvPWCUjE/awR63t0KnkDE1XaS52X0Px+ipni4Yioo3Y57IUtTnfak81P4
         dx5Zlbqq2PFy9Acyr/lDUhI/z2aOvJU4bMEOxruMDDHeGg8N9EGHYGHL0VhL9/mcSgVj
         tMEyGKzx1fAx86HiwUiDzrGMzx7M5Ghx5YECzECveVrMF0JfWiRxxKJsFKuipTKSDIGn
         GlpAJXUyC9w5lbYDmzHHeBhOZIYHsCElfHtZqUr8wA5mSFsR/6zB8cBXqchPwtInxWf6
         /ycyWJBMxhsKTXqojAN92UUJiizN7wjSQGrcV37vtVdlzij4Ufs2JroHmICtgF3TF+dr
         e7xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :to:from:subject:dkim-signature;
        bh=T+5ed5Bo1rCY2ZZgAuiYr0Ic9RXyb17hEruVBk9wrEk=;
        b=SekmbNkwLPtE81SG8timdQhOtjSNPFMt+9crwVxCwqXrms+zLgU+lMUiVbJ5kSa9Hz
         WLI7TC0AIa50yr4mPI1saGn3IwZXJ32MnpowK0dL1FVAs/Y0+82cFiLUwiAS+yH/YPrQ
         o+XFNVoiD9QwYUBFi3FJwEXrgzmVvKNvfz85p6aF9Z6PItVbQ06+9sGAcZ4ETrxEE3uX
         Ux4GhoAm48CohBmAEOIR03bvDZ1lvGG5KyLbfOmoY711GJjWPHdvNJ4V7P4hPh7cmEah
         kF23W4xCjjSM4pc5nNvDEB6xBmcITA44rpLHRs2BJrAdoQGK1viOWbyPcAv16hj3Hn8y
         Hhmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=qdKsbIZ+;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [5.45.199.163])
        by mx.google.com with ESMTPS id u2si38139018ljg.30.2019.07.23.04.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 04:54:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) client-ip=5.45.199.163;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=qdKsbIZ+;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id D13FC2E14B4;
	Tue, 23 Jul 2019 14:54:26 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id CI3Q5EYUQ1-sQmKhOhY;
	Tue, 23 Jul 2019 14:54:26 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1563882866; bh=T+5ed5Bo1rCY2ZZgAuiYr0Ic9RXyb17hEruVBk9wrEk=;
	h=Message-ID:Date:To:From:Subject;
	b=qdKsbIZ+meQFXOt1fp5UV0Hmi6LqCjJ+7Uw1bD1E3u0sUH1qqpEEwvF1dMFd73Nuv
	 6/pcLc+INjVCdn+xWJzIbEvhAhMOxydig8WP7tL7f4Y4XX9AkxSnvQtaK8nVyRXsOQ
	 HYRz48PMZVDN9TzijJ0rKVbn7Sw/WzkjDp1BNffc=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38b3:1cdf:ad1a:1fe1])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id cFlEU0zMy0-sQAOafUw;
	Tue, 23 Jul 2019 14:54:26 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH RFC] mm/page_idle: simple idle page tracking for virtual
 memory
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
 "Joel Fernandes \(Google\)" <joel@joelfernandes.org>,
 Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 23 Jul 2019 14:54:26 +0300
Message-ID: <156388286599.2859.5353604441686895041.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The page_idle tracking feature currently requires looking up the pagemap
for a process followed by interacting with /sys/kernel/mm/page_idle.
This is quite cumbersome and can be error-prone too. If between
accessing the per-PID pagemap and the global page_idle bitmap, if
something changes with the page then the information is not accurate.
More over looking up PFN from pagemap in Android devices is not
supported by unprivileged process and requires SYS_ADMIN and gives 0 for
the PFN.

This patch adds simplified interface which works only with mapped pages:
Run: "echo 6 > /proc/pid/clear_refs" to mark all mapped pages as idle.
Pages that still idle are marked with bit 57 in /proc/pid/pagemap.
Total size of idle pages is shown in /proc/pid/smaps (_rollup).

Piece of comment is stolen from Joel Fernandes <joel@joelfernandes.org>

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Link: https://lore.kernel.org/lkml/20190722213205.140845-1-joel@joelfernandes.org/
---
 Documentation/admin-guide/mm/pagemap.rst |    3 ++-
 Documentation/filesystems/proc.txt       |    3 +++
 fs/proc/task_mmu.c                       |   33 ++++++++++++++++++++++++++++--
 3 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/Documentation/admin-guide/mm/pagemap.rst b/Documentation/admin-guide/mm/pagemap.rst
index 340a5aee9b80..d7ee60287584 100644
--- a/Documentation/admin-guide/mm/pagemap.rst
+++ b/Documentation/admin-guide/mm/pagemap.rst
@@ -21,7 +21,8 @@ There are four components to pagemap:
     * Bit  55    pte is soft-dirty (see
       :ref:`Documentation/admin-guide/mm/soft-dirty.rst <soft_dirty>`)
     * Bit  56    page exclusively mapped (since 4.2)
-    * Bits 57-60 zero
+    * Bit  57    page is idle
+    * Bits 58-60 zero
     * Bit  61    page is file-page or shared-anon (since 3.5)
     * Bit  62    page swapped
     * Bit  63    page present
diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 99ca040e3f90..d222be8b4eb9 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -574,6 +574,9 @@ To reset the peak resident set size ("high water mark") to the process's
 current value:
     > echo 5 > /proc/PID/clear_refs
 
+To mark all mapped pages as idle:
+    > echo 6 > /proc/PID/clear_refs
+
 Any other value written to /proc/PID/clear_refs will have no effect.
 
 The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 731642e0f5a0..6da952574a1f 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -413,6 +413,7 @@ struct mem_size_stats {
 	unsigned long private_clean;
 	unsigned long private_dirty;
 	unsigned long referenced;
+	unsigned long idle;
 	unsigned long anonymous;
 	unsigned long lazyfree;
 	unsigned long anonymous_thp;
@@ -479,6 +480,10 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 	if (young || page_is_young(page) || PageReferenced(page))
 		mss->referenced += size;
 
+	/* Not accessed and still idle. */
+	if (!young && page_is_idle(page))
+		mss->idle += size;
+
 	/*
 	 * Then accumulate quantities that may depend on sharing, or that may
 	 * differ page-by-page.
@@ -799,6 +804,9 @@ static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss,
 	SEQ_PUT_DEC(" kB\nPrivate_Clean:  ", mss->private_clean);
 	SEQ_PUT_DEC(" kB\nPrivate_Dirty:  ", mss->private_dirty);
 	SEQ_PUT_DEC(" kB\nReferenced:     ", mss->referenced);
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+	SEQ_PUT_DEC(" kB\nIdle:           ", mss->idle);
+#endif
 	SEQ_PUT_DEC(" kB\nAnonymous:      ", mss->anonymous);
 	SEQ_PUT_DEC(" kB\nLazyFree:       ", mss->lazyfree);
 	SEQ_PUT_DEC(" kB\nAnonHugePages:  ", mss->anonymous_thp);
@@ -969,6 +977,7 @@ enum clear_refs_types {
 	CLEAR_REFS_MAPPED,
 	CLEAR_REFS_SOFT_DIRTY,
 	CLEAR_REFS_MM_HIWATER_RSS,
+	CLEAR_REFS_SOFT_ACCESS,
 	CLEAR_REFS_LAST,
 };
 
@@ -1045,6 +1054,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 	pte_t *pte, ptent;
 	spinlock_t *ptl;
 	struct page *page;
+	int young;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
@@ -1058,8 +1068,16 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 
 		page = pmd_page(*pmd);
 
+		young = pmdp_test_and_clear_young(vma, addr, pmd);
+
+		if (cp->type == CLEAR_REFS_SOFT_ACCESS) {
+			if (young)
+				set_page_young(page);
+			set_page_idle(page);
+			goto out;
+		}
+
 		/* Clear accessed and referenced bits. */
-		pmdp_test_and_clear_young(vma, addr, pmd);
 		test_and_clear_page_young(page);
 		ClearPageReferenced(page);
 out:
@@ -1086,8 +1104,16 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 		if (!page)
 			continue;
 
+		young = ptep_test_and_clear_young(vma, addr, pte);
+
+		if (cp->type == CLEAR_REFS_SOFT_ACCESS) {
+			if (young)
+				set_page_young(page);
+			set_page_idle(page);
+			continue;
+		}
+
 		/* Clear accessed and referenced bits. */
-		ptep_test_and_clear_young(vma, addr, pte);
 		test_and_clear_page_young(page);
 		ClearPageReferenced(page);
 	}
@@ -1253,6 +1279,7 @@ struct pagemapread {
 #define PM_PFRAME_MASK		GENMASK_ULL(PM_PFRAME_BITS - 1, 0)
 #define PM_SOFT_DIRTY		BIT_ULL(55)
 #define PM_MMAP_EXCLUSIVE	BIT_ULL(56)
+#define PM_IDLE			BIT_ULL(57)
 #define PM_FILE			BIT_ULL(61)
 #define PM_SWAP			BIT_ULL(62)
 #define PM_PRESENT		BIT_ULL(63)
@@ -1326,6 +1353,8 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
 		page = vm_normal_page(vma, addr, pte);
 		if (pte_soft_dirty(pte))
 			flags |= PM_SOFT_DIRTY;
+		if (!pte_young(pte) && page && page_is_idle(page))
+			flags |= PM_IDLE;
 	} else if (is_swap_pte(pte)) {
 		swp_entry_t entry;
 		if (pte_swp_soft_dirty(pte))

