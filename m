Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14E32C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5F5721916
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5F5721916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC4656B026F; Thu, 21 Mar 2019 10:20:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9C3F6B0270; Thu, 21 Mar 2019 10:20:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C64766B0271; Thu, 21 Mar 2019 10:20:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7226B6B026F
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:53 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o27so2279478edc.14
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iuMdLE8+u1uoSAbvOzwF5G8gMH8Pp5jo2G4hJiPSSFc=;
        b=UFwiCOndqDPPd2lFamNyB7ERUtGe93gubWyAWZgHLxZfepp621ShO8boJd0cpkHsoY
         vqmF+3o/5Fhw6jGylP3wcxc2nWG6yMKWl0TbChgvUwcbfdtsAIb+lUKfh4kUzChjug4E
         dhOMPI/AzEaAfETOUsVDC4BPwpYZgb6kvfUVjRL3VT+BtLtSgUz9Ma5Tew3T8hmsaw5G
         U+0c71wz5n12dOgbXMXgGHd/E2U4LWTrWWZqkBj7eDMzdaEBRN3r9x5K98OYb5CXELhz
         q9oqJlmQ0FRjOqKgQeSKRMg1jZ1/dWFKqvXu9ezQAU5kLUqXWUE4MnI7MQGupgEWEPki
         500g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAV70qaCNJpviEistMNBKssjJZcFTX2HtlThwkcteCRWxsvAFiQ7
	WZhaWetzcQ9sbPGZvWSlEErquaLdkiWtkTnmuIuBGi8LgxwV2CsFAQTwT+B+xANK5QyAQ79bkbL
	LHLBQbzJEFblxnsYYx3k10HMlFNWzgWFLmzRrMVHQPnm4BlUUl0t9b+2OSjdl26gFqQ==
X-Received: by 2002:a17:906:1d0f:: with SMTP id n15mr2519233ejh.102.1553178052986;
        Thu, 21 Mar 2019 07:20:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6lZdAZvmcrlQm8c2K5Ooh1tG3DK0lTs3Tc12SCSoCN4C8QEefrRESC5Sz3hlwh3kmcRnH
X-Received: by 2002:a17:906:1d0f:: with SMTP id n15mr2519173ejh.102.1553178051843;
        Thu, 21 Mar 2019 07:20:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178051; cv=none;
        d=google.com; s=arc-20160816;
        b=wpNUrkbFQpvWUIpBWx6SsnmypmcE5z/YRxaosWLdMC0AI1DlruMixEurFMES++KlTt
         gkPzxLJexZDMluvj7vomunt39wCHv9YmuTzBS0VAIP62/0pi6MRsnYyV05PFXN9Osen6
         zh03F9MmQNhw0xat3t+3VHU7Xlyy8RdC1JaM5fV0dga2XN5PybOzdQckwuU8/8FX0aRd
         B746LUWYe6G5RWIPKYUXy8G8EdPGDkFp78JMbaiB1k1kjMkiPPTIBVYGRdqsvCmdZBQj
         OAQjOVrSWYSRNoFr1a79bE/JLqtvzXB3CLhWWbgVn1p10qhWNxMQ1SJ5fEbqkrhMp8Lm
         cgHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=iuMdLE8+u1uoSAbvOzwF5G8gMH8Pp5jo2G4hJiPSSFc=;
        b=Rr1KqYaGDO647Q+fEuGzKDIxgdRs7/aV5MpMk71fmvNtIgyT2x46O/BvOOwaVGdK+v
         iWXVBeCEQzshoAX+K7h2k+ceXM5YJjmfDn708fR815MdGOrHDF4wyDZUDTQL1UODXkaa
         6+X0dPV7Y2jT+HC7Nw2SU2AKa2cK4sQzlkXAaBU0Etdy+pQ66e+FQ8mRyWzxiuErBEKp
         4TifvcrR+uuPZ8IVEQEczs4TnhmmyvBkJhnFNgrRtXc6NklEUbLQXjYWJq7g6fv5BbPD
         KEIZrDujNB+osPmjoGGNyZSuu+IxDBdtAObGMxeWjgWX/IyPRUawTikK8dWN8y00ft27
         fwvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e14si2086882edb.137.2019.03.21.07.20.51
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C04AB80D;
	Thu, 21 Mar 2019 07:20:50 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8596F3F575;
	Thu, 21 Mar 2019 07:20:47 -0700 (PDT)
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
Subject: [PATCH v5 12/19] mm: pagewalk: Add test_p?d callbacks
Date: Thu, 21 Mar 2019 14:19:46 +0000
Message-Id: <20190321141953.31960-13-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190321141953.31960-1-steven.price@arm.com>
References: <20190321141953.31960-1-steven.price@arm.com>
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
index 2983f2396a72..49a04cc9ee84 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1382,6 +1382,11 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
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
@@ -1406,6 +1411,12 @@ struct mm_walk {
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

