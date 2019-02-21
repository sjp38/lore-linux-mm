Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D70CC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1B5A2086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1B5A2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B89D8E007A; Thu, 21 Feb 2019 06:35:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 741258E0075; Thu, 21 Feb 2019 06:35:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E1D78E007A; Thu, 21 Feb 2019 06:35:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 015BB8E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:35:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o9so4885835edh.10
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:35:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5+qDYU4THjLPvNOaZc1aA0s7EjXEEdRbPiGSrygYMH0=;
        b=UXqGMbrF7Coz7sqKrhD7lTYd/onQmkBiuEKTA7c5ykP/4UWNOeCbFs4SdwDFzIDoYk
         vSVjyAR8tJZaXEVuulWgzYNxeXPU9PAgygTbHSluJNPe6epAKBtZikSp1eouny/3s+bY
         ymUQwQLrAJnM+sewx1ATL1qo48SyCq65UbuhS6T44FX0z3GDmsjddFy0huwUQRfl72Fs
         xnL2ekAxt71dr+h0Lbs9arNRqI2aN1uRZaXv0OXR3VQKFdkn1bljuwmr/8KddOUZLr6a
         5UqxIL27QlcvOG6DG+Bzi9cbIQagXFDBXqEFBIPr5bJVFxxuQo+qbMN9F/9+qqUFCqWE
         +Ckw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuanxGgVKOPyD7lZQUefWntCyhgDJKcoQhN7ifng/zqXa2NX4IFl
	g/LNbobJr5iefX9wX1MI+TNPfKNUwiNMAnzx6/9UpO/gwVxeSqt/JKqNJYqt6plnWAqCL7o6Xmn
	y6wjNxZdegU8zHFozoDMggBzF2HWrVN/oyxgMOPKugOcyk2S3JfZjB2njB3oLGLdmig==
X-Received: by 2002:a17:906:6c8f:: with SMTP id s15mr17791236ejr.133.1550748944476;
        Thu, 21 Feb 2019 03:35:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZYmsSNPnMTVOalFQ0KHq9rYn77ezujSl2cyMVA0aeJZAdU+xff1luqI7iFqBhnh9OLSEKW
X-Received: by 2002:a17:906:6c8f:: with SMTP id s15mr17791187ejr.133.1550748943376;
        Thu, 21 Feb 2019 03:35:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748943; cv=none;
        d=google.com; s=arc-20160816;
        b=jLVoYWmugEfEBDWvYz7+u1rTNSd2lfz7mmYwCXVqS9q57puVRILhfA5r56GpjxPRhu
         xc2YvizI96xAM64d2VWMk7Orym8SrpAe6St1xZSTeP25YshIwFKhgB/Jey8CAhwFpjtE
         ITL56M+UuswiIBRuGFEtPxnYagTPFGWppyxNRzkgFMSCgswF28ld7NMzbj/DsHhF+bRj
         Q1IUo6lyweGg5LJAPUijzmo4AzovWDm6YzZetbwIMHH79TsPSSyjNHJSgSlrw/0AI7rs
         nPRZrv32thVl26vGMnmwJ84Ysg3rmJ94/5Fmd421fN9AJFRWS4Nm9XKJjBbSMIW1J23u
         aSdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=5+qDYU4THjLPvNOaZc1aA0s7EjXEEdRbPiGSrygYMH0=;
        b=lHoetEquyiMFV1gJKNmt+XDQjAsnuTX99uYOb3/xOZszRgo5zdTA5Tr6/6YvDdDQVx
         SsnhUJvgn30ZCqpohQF/bE6hA+NeTfQMfF3xDggo1vMwMK8N3/W42Jbj2kW9OpwwStGt
         /BIgSukg0mDXdAxbHsG5bwTYvszGnDV4LBbKVYwHej7fa2a71R12S9FH6XJl5zdBhEq4
         R76cO1F8N/iIRG9gW2m+ZeUsUYBct5o0NpOunpew28LU1V0xgADd/d1f2bYwjP0kkFMS
         +04x/ma+JG2H41Fgy6kGZ3EqCi11yKAkHEbNhXnyhr4lR+Uz5zte1jtP6xRPCMAXs//4
         uuCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y26si3082726edc.439.2019.02.21.03.35.42
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:43 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 328B780D;
	Thu, 21 Feb 2019 03:35:42 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A5CB33F5C1;
	Thu, 21 Feb 2019 03:35:38 -0800 (PST)
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
Subject: [PATCH v2 07/13] mm: pagewalk: Add test_p?d callbacks
Date: Thu, 21 Feb 2019 11:34:56 +0000
Message-Id: <20190221113502.54153-8-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190221113502.54153-1-steven.price@arm.com>
References: <20190221113502.54153-1-steven.price@arm.com>
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
index 4ae3634a9118..581f31c6b6d9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1429,6 +1429,11 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
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
@@ -1453,6 +1458,12 @@ struct mm_walk {
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
index 57946bcd810c..ff2fc8490435 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -49,6 +49,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	int err = 0;
 	int depth = real_depth(3);
 
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
@@ -100,6 +108,14 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 	int err = 0;
 	int depth = real_depth(2);
 
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
@@ -143,6 +159,14 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	int err = 0;
 	int depth = real_depth(1);
 
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

