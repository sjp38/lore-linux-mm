Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FF1CC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8876219BE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8876219BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D1698E000F; Mon, 22 Jul 2019 11:43:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 835DC8E000E; Mon, 22 Jul 2019 11:43:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6383F8E000F; Mon, 22 Jul 2019 11:43:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2088E000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:43:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so26540976eds.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:43:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=krhSst1Rr/sUlZpo7CKXyP+sWCPROlf89rJ0GXnJMfE=;
        b=aZ43IRFbvSsTYSddxAP7ippyNZFkY3shilYKs97jOf5qkFJowh2nlReIk4MF43avuA
         gMuXo+EMIWdNoN0hQj/f1RWnHr9lyQJRv3rHA5XYi1j1A4wwpnBQf6/H2LzDON/2aNSq
         5wF/Tm+nxgCUMAkucP+TKpOC4njn+iaL51OGmMeazMR8te9URv42ORJ5MoReReNlSotJ
         Xbu6tSIMrhXsS/JFRZYfRmxFjdotCN6JVqw7IbcRDXdNssol7z5l91NHxCTovzMNGOQO
         B10tUpMP0MHYAhkQh6oFwtEQKNAoEshLJOrgsMSGGDAWcB5SCam2cG/qGw6taS1tAK1A
         GZug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVesmaR90Y9TquSWCleHqsrAO+wNhYZBKfKYJUSZf0YdIMgJGb/
	Aj28rOhI1WchzZvspczyzP5EvN0CJTh74RZYqzkoA3upetdG9E/hvw3pJaa4drJyX9Wr/60zRlo
	sLkipjKqfkVxXQ8xSy+u10aoZGfxBnTSiCUjBCiGq5K/fndGuNVKOjrUpp+QrttGFmQ==
X-Received: by 2002:aa7:d0cc:: with SMTP id u12mr61516236edo.212.1563810183626;
        Mon, 22 Jul 2019 08:43:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygWNehDzd8X1OGJBbDJlmPTNX7KVskcgwpHKRHDPFUkTlZNyeztqjF/d40ElLxRRNAEEAI
X-Received: by 2002:aa7:d0cc:: with SMTP id u12mr61516181edo.212.1563810182878;
        Mon, 22 Jul 2019 08:43:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810182; cv=none;
        d=google.com; s=arc-20160816;
        b=YVf8M+OkHpVW8TMfSk/I7DTVCwLT74cVs+VL+EQUhs0APQ7xiY0iPoyFHmaha7OhRU
         IVh3lVppzX1FaD+NnsVE4TtJxM0OT3PrwPpFQgnpRRt8wccDfDLknvuN8iFFzVe0qPpf
         Og4e1v+K898+Djs7jVG5idHDBuv20sNLRtoNMgmy+IYX+mU/DRPsGLVT6q/ZAZeut5l3
         RlCE1dt2FyB39IImk+C5IrdV5hjal9o7btKrbmEPDP/5ISf/1UQ1U5nDnn+ZKgZ1W+VO
         QtvkThcwaiswHFt3qrOqYhvzrbZMMtkCw9GPEWl2bQ0Pqny1F4iIaxDmOBslYZDrQH4N
         eOiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=krhSst1Rr/sUlZpo7CKXyP+sWCPROlf89rJ0GXnJMfE=;
        b=NvpPQqdrOPT5HOW/48eNVG+KuSeATNvY+pRls92wEmDiK/B8BDEYFNwdzR2EUu/gEk
         7UWZzfkJnkRAIkwJb/reJJD3sQnWrV37FFj213sgfaCDLRyRxfn5b4viPyB1smlFRIuU
         E72fZ9Z9AyzJviKMvhd0Nt5KKyxBzHu87EECgWgMmB8eLHmBCgius7Tim0GGi04pvhP2
         xbdtsYj/PLEp0OS7TR95A1FFm7pTQv10WIGPy+2KPcwA4VskIc/VJXJqmjy66eSwxPXL
         OtelAxYGz39bViOKUhNvLS2bbdGb+Uf1ZQW9eOMQCxE9QlvrOZ02mJItZwxuDstRt7C/
         3hjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w25si4820009edt.27.2019.07.22.08.43.02
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:43:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EFE9E1509;
	Mon, 22 Jul 2019 08:43:01 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 66A7A3F694;
	Mon, 22 Jul 2019 08:42:59 -0700 (PDT)
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
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v9 13/21] mm: pagewalk: Add test_p?d callbacks
Date: Mon, 22 Jul 2019 16:42:02 +0100
Message-Id: <20190722154210.42799-14-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
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
index b22799129128..325a1ca6f820 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1447,6 +1447,11 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
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
@@ -1471,6 +1476,12 @@ struct mm_walk {
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
index 1cbef99e9258..6bea79b95be3 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -32,6 +32,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	unsigned long next;
 	int err = 0;
 
+	if (walk->test_pmd) {
+		err = walk->test_pmd(addr, end, pmd_offset(pud, 0UL), walk);
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
+		err = walk->test_pud(addr, end, pud_offset(p4d, 0UL), walk);
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
+		err = walk->test_p4d(addr, end, p4d_offset(pgd, 0UL), walk);
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

