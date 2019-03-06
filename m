Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C721EC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E3D020663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E3D020663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 227F68E0002; Wed,  6 Mar 2019 10:51:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D75C8E0015; Wed,  6 Mar 2019 10:51:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C7E98E0002; Wed,  6 Mar 2019 10:51:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A27E58E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:33 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f11so6578197edd.2
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZLiKvIskeL3Cb4PQg+kE/Z5W0NNrB9xArSrGZLY/bh0=;
        b=C/2o3JLFH87b4fledh8PXiqRq78r/FHaTDoITKjGO8e7YTCVSPRH9Kj6BX8pfPHNPk
         rEuHFt0D7VhWvm/7gSLf+GeW2gU1jnpq4GFWJR1aNF8ifUMPDuftLnFHWxoRJxa8hi29
         0e/lZPGVkpjodpSnQWdov984lG4kMfjKanfkDa/v1+y2RH7ATXIcpCQMmWpCUFsNfBJ4
         kedpw1pcO4V/Nxe08mDo1Ex2uZmubxAPtIcgviR7IS/ZJeepUSr6VQgdet1Dp343C1i/
         vww4TRXf3vRU+iinTsiqyFZFm3D4FcfVz0TO32ZaFp4qmomN2y/1dkwSqLxOyXlin5Ra
         OrKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWBBN09L4R2uaGgYoBNGS0osUM7K8RhB6N6z9jyxQd72QHzOH9w
	W2CVCZieoLLJR7mTc76yRlCVJ5hqnih2gUfrcQhOtWdKYuYGEJyXCBN8Xm/j6raCO1JdvRC3zyh
	KkrRXpTnwykacmhK4p8c+m9Jlu9PGzzW8mWQhgpe352NQPfcTLOWvGVrx2bZMCr+dxw==
X-Received: by 2002:a50:ac58:: with SMTP id w24mr23492446edc.287.1551887492882;
        Wed, 06 Mar 2019 07:51:32 -0800 (PST)
X-Google-Smtp-Source: APXvYqw5SjIb9/xQiskG6frMkd72eJUi+kTYqevabfa2aF086ahp6QHI9lkSkjbMPzrIQCr37KBh
X-Received: by 2002:a50:ac58:: with SMTP id w24mr23492378edc.287.1551887491740;
        Wed, 06 Mar 2019 07:51:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887491; cv=none;
        d=google.com; s=arc-20160816;
        b=AkqG8CA2FS2hwz8V6zl0X7MBNdxxytLtz7m3xVYzGFBXgVbHUyb2STqTOSYNWljJVy
         2nmveIK5Sx5DzmtQiAQW8B/AyF/89PnwYDJXXCkiEihnt5Eoi/Ki5vnfx6h8boGY1V+N
         0nv8dGG+I7mjQugmphqWzE8M0srgkO/6+ujBu2NDpNvfvtb7y7zLhNVbh6CWAPOlzKst
         DA3N/39F91kerhLyzEFyS5unyQaISlaGmwp4q6JgDOsqfnHonCqysKoC3vjNJjv1isFY
         Z3VJSOPOgymm5ymNgfCJHd3cVaUKKema2j5Me9X9EbH7BXYi1JehT0PjI3WWeR8oDuZk
         ILJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZLiKvIskeL3Cb4PQg+kE/Z5W0NNrB9xArSrGZLY/bh0=;
        b=qMgdcirqLDzNDpJW9uKJef26sCGUtUDd9KaqX8pSnm/vIQ1fo/8cvGSPzx8p+xdfqy
         tKXZrsuwO8gDey5wNh+11KhPMY6c7oiaCElCvgj32lWLLzIKJ2yx7aJaM+uZdluYF1pg
         TXH+Mvrjh51L0Um2GtMxNEnDNGbEyJX2DQ4xfMaBKFTb9FQO8+ErSNJtXUa4OlPPvWar
         1VixiF33geOaGfevv9MFuXlieCopGdpR60fqZDYF/W/EFAarYU7IxXPelXkraPeaIpaI
         PhvqPM9pj3eCq5AyH76QXa0OhL6apiHYr9+KE/hvjkRwEPA9iOpDkwGcn2hoBcJvFPDX
         zk4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 34si751077edu.306.2019.03.06.07.51.31
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:31 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 91B1E1596;
	Wed,  6 Mar 2019 07:51:30 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 572193F738;
	Wed,  6 Mar 2019 07:51:27 -0800 (PST)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v4 12/19] mm: pagewalk: Add test_p?d callbacks
Date: Wed,  6 Mar 2019 15:50:24 +0000
Message-Id: <20190306155031.4291-13-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190306155031.4291-1-steven.price@arm.com>
References: <20190306155031.4291-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is useful to be able to skip parts of the page table tree even when
walking without VMAs. Add test_p?d callbacks similar to test_walk but
which are called just before a table at that level is walked. If the
callback returns non-zero then the entire table is skipped.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/linux/mm.h | 11 +++++++++++
 mm/pagewalk.c      | 24 ++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1a4b1615d012..4755af1779f6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1427,6 +1427,11 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *             value means "do page table walk over the current vma,"
  *             and a negative one means "abort current page table walk
  *             right now." 1 means "skip the current vma."
+ * @test_pmd:  similar to test_walk(), but called for every pmd.
+ * @test_pud:  similar to test_walk(), but called for every pud.
+ * @test_p4d:  similar to test_walk(), but called for every p4d.
+ *             Returning 0 means walk this part of the page tables,
+ *             returning 1 means to skip this range.
  * @mm:        mm_struct representing the target process of page table walk
  * @vma:       vma currently walked (NULL if walking outside vmas)
  * @private:   private data for callbacks' usage
@@ -1451,6 +1456,12 @@ struct mm_walk {
 			     struct mm_walk *walk);
 	int (*test_walk)(unsigned long addr, unsigned long next,
 			struct mm_walk *walk);
+	int (*test_pmd)(unsigned long addr, unsigned long next,
+			pmd_t *pmd_start, struct mm_walk *walk);
+	int (*test_pud)(unsigned long addr, unsigned long next,
+			pud_t *pud_start, struct mm_walk *walk);
+	int (*test_p4d)(unsigned long addr, unsigned long next,
+			p4d_t *p4d_start, struct mm_walk *walk);
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	void *private;
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index dac0c848b458..231655db1295 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -32,6 +32,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	unsigned long next;
 	int err = 0;
 
+	if (walk->test_pmd) {
+		err = walk->test_pmd(addr, end, pmd_offset(pud, 0), walk);
+		if (err < 0)
+			return err;
+		if (err > 0)
+			return 0;
+	}
+
 	pmd = pmd_offset(pud, addr);
 	do {
 again:
@@ -82,6 +90,14 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 	unsigned long next;
 	int err = 0;
 
+	if (walk->test_pud) {
+		err = walk->test_pud(addr, end, pud_offset(p4d, 0), walk);
+		if (err < 0)
+			return err;
+		if (err > 0)
+			return 0;
+	}
+
 	pud = pud_offset(p4d, addr);
 	do {
  again:
@@ -124,6 +140,14 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	unsigned long next;
 	int err = 0;
 
+	if (walk->test_p4d) {
+		err = walk->test_p4d(addr, end, p4d_offset(pgd, 0), walk);
+		if (err < 0)
+			return err;
+		if (err > 0)
+			return 0;
+	}
+
 	p4d = p4d_offset(pgd, addr);
 	do {
 		next = p4d_addr_end(addr, end);
-- 
2.20.1

