Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2C80C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B36FF20863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B36FF20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BDAC6B027B; Tue, 26 Mar 2019 12:27:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56C026B027C; Tue, 26 Mar 2019 12:27:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 434706B027D; Tue, 26 Mar 2019 12:27:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D91806B027B
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x13so5489452edq.11
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=R0+mDUGg1Ak1pVP4iC7Dj6pIbpcwhG5wwqV4iIviRKc=;
        b=M8/7EkpByep7vMyPQI5zBEz2X5w+fNRYy+q/vbpO9IHlKfsO2Qj7bQ8aA7iT3tWcy3
         llT8W1pAqzCnvIBnHYJ/LsBDGvx4FzOMkYgb+gkRcROMGPt7Enol9DvXgskk/Tk0EFhJ
         HGKr2aqek4sAtDizrRu7Ok3gRZ+Gl7j4JEjWaJv+0McBaThoYKwKNaEUS4K6EGDuomdq
         3dvjlw7gbtfnI5cRgSgUDjScHmA619LyfIa0wy79Y1I+I9QEeDkhUkKykfjY7knCYO8N
         ITJoDaDvgkCIJR6WoCKSyXDZUNN8jkv+vZwgAQmc+atCppDkbIiTOEvTGIiReoIdlj07
         d1vA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXur3042XBt6w1BSSPgyvKh+6a3npDMlcjiUi4uzthRgFeRhZQt
	ryQgfO5oEtjTGZ3pU7zBQy7/1XssTVDDFtkVDE3gG7MAFyOjh3xY4uU+VTyHoG9rl9ryJ6QdvRe
	y90V3hwrMbW+PE4zb+MIjqh0nfNSe/Mf2CKBFIJTps/dLALdxicWwpcz+MDAJMv8gzQ==
X-Received: by 2002:a50:9284:: with SMTP id k4mr20525294eda.216.1553617642368;
        Tue, 26 Mar 2019 09:27:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypHzQNlwPWmDCAveU7mfQ4SkYlNDaHUAF6nzHUpv1ZzaRUkwzLE3fQm8aCBwbg68oJnG7C
X-Received: by 2002:a50:9284:: with SMTP id k4mr20525239eda.216.1553617641369;
        Tue, 26 Mar 2019 09:27:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617641; cv=none;
        d=google.com; s=arc-20160816;
        b=udRWcBG/DOlasejyWy8EkbHDNctWreDr0XUqlZeqPbHn2+cd7wtr7UnWG/q5POj2t3
         u+sT14qs0e69NDdIeCF02ShitCGUjHc5nM2RJ7P8WgP31WvGM3aZiOrhNjBDsTR+XERp
         ahC2bpFOFz62GKx4vcs+RIir/RmFfNHg0/qn+eqfq+frkCB7pmIp0bqy9sGrbqXsOCPL
         azzoIghloiBcmCdnJGV9MTx+UXACnARH/sfpKhoW+MKcs23WgJLo7kG6KngJ4T2GPaLx
         btn24lMWb0oHnmiUBudFBsNk6VVP02j0UCeIOg4orLkmLpA6nJPgKS/WVF5wp2zYzuK1
         bFkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=R0+mDUGg1Ak1pVP4iC7Dj6pIbpcwhG5wwqV4iIviRKc=;
        b=ewSBx/Tq+B02u60ZqCFO9te5RnumAZvkA0HMFmlrb2eYo2ZAGUfDnsSDVPZ3n+8//5
         F1pVZTX+Lfp/5v0vlc17XWtSWIElKbrM9dfJmgPdQs+QNGYothM980k9wMuTOZVAb81m
         aYedEhuBhVO6Q6w/7ZOX2OELLQCRoYRNVk5JDQDKwJLNu+wz6Z1aRvYxr0HjISdAE7+m
         ZG1V7CzNZLP/M68xSBjkZiRYiexkGSYGD/oTA76U+EBZL7wdRqXiVAvV/vJ+nv3F+YWS
         WKgbp1Caw4V84KOhkTU6iFC9/GU5APgCjm9z/z4OPm5VrxkPobtA3WsXpJ2zTUk5wf0H
         XYKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n25si507575ejh.319.2019.03.26.09.27.20
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 451DD1993;
	Tue, 26 Mar 2019 09:27:20 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 07A753F614;
	Tue, 26 Mar 2019 09:27:16 -0700 (PDT)
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
Subject: [PATCH v6 12/19] mm: pagewalk: Add test_p?d callbacks
Date: Tue, 26 Mar 2019 16:26:17 +0000
Message-Id: <20190326162624.20736-13-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
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
index f6de08c116e6..a4c1ed255455 100644
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

