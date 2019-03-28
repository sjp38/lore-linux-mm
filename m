Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35ABBC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCC50206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCC50206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45C826B026C; Thu, 28 Mar 2019 11:22:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E6556B026D; Thu, 28 Mar 2019 11:22:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2376B6B026E; Thu, 28 Mar 2019 11:22:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE0076B026C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t4so8281086eds.1
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=R0+mDUGg1Ak1pVP4iC7Dj6pIbpcwhG5wwqV4iIviRKc=;
        b=hmGhtIjBc9C7y/7jqw+cXv+V7EHVf8VLRn42kasP4wJRF418HWuipj1mfynWBrCqyS
         Qr90CLvdcswUoJ4EUGceYY7dRFYJYcDGikP0Cjgtq0wUMhCniG12OVNR34ZGkEnKophQ
         tWc0tJ/WaObmXY5NYBAcCYR8gohn0N9AC0VkXy0JUK7Gspd7yWLiOlSvtmtmoJQSKtF4
         fNmneD8LOfmZybfAJsVq0Z+EtYIMUJX+XhhQPpeQJt+50G5s/JyFl0eczKbOHGqsSE3R
         h4cpfeUXSqJh2hP9hVuoRTQNJbFpl6YXx9F2ci7uXWlCvFF88ENEcVR9C+m7oayV90++
         PeFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVaIPwjwznW5iSuWR/cAw21U6YFVmCrk/Of7cQt2IgjV6P6VA8n
	XJRM+c+zXnjzVGUMRj3jTJuDx2E9xYPPhJ9YpWlDKFan/YIkmp3Vf4QZfeZ1wLBRm9jNGswIEVv
	cg5IMVsI+dU1nAsLfGptyoaOFPt0eRXLlm+zemZJ6L0EwyagcuVSfsQTejm8YXFHpXA==
X-Received: by 2002:a50:b6f2:: with SMTP id f47mr29375351ede.240.1553786565288;
        Thu, 28 Mar 2019 08:22:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUmJkK8ED1VRo/tvxw3CRAN0mnvWFgYVnVLikBor/TtIvUAiNiv8Wr7KZQu16OibW4H904
X-Received: by 2002:a50:b6f2:: with SMTP id f47mr29375306ede.240.1553786564375;
        Thu, 28 Mar 2019 08:22:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786564; cv=none;
        d=google.com; s=arc-20160816;
        b=Oyzcun9DSETYwtLOL00rFFznfvdlMq4n9z0Ifw0DoQMqK4Cs7d2mfMNbLzc02HrRz3
         nrHFrqD4j+QO6s3Wy48l1X9L4ltolU+Q330ljcCbi6MXlX5o+ZBrzTHnS4dZt7wC85zp
         BVHyYeV3MK3QZJ1aTDNsMcckrpn5i62pcQOD4swbNXBJ1xCq+jzZW7tcMOnExg269T4A
         7tzl6APbsot8wdoL/GxbvFbcHNaH/XYe7KkgOX7jEEQXDTOejs/WJuMwSAU9SEabvByL
         oFoJRY0zaH1Lfz84gbQHki/ijxQwKhaINWmswfghTzkc8vdCoYhUE106427QhJh+/Hct
         o1zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=R0+mDUGg1Ak1pVP4iC7Dj6pIbpcwhG5wwqV4iIviRKc=;
        b=dpz0h1vn79V833a6VUt+V+gI6itScmYbu0cuHHB71IGDiWVVXi4OgPPNMj9NNM6BtJ
         EDoNEO9lPyQYpJIQyBXSVjXHU15ICEGcHt8S1t+rUc36uXKFV4XUQbQOxv8CYn0bPE8g
         0qcc/2MnzJatJxi55SpYwMX2OQ+3FiU+xFzwKnDS1cjKvyGv6mBA1sXBgjFvkuaIAiFk
         7kfextGjLORuwFIaUsF0rXw9rZmCNzJtAs8LyXp0yhZaLtxjc+dJZbltw8Ub6M7VHgf1
         3LNI1OqILOhDRypGKV9dyOoUep8y8eRRQojCnJeCNYP5ok1ik46yQwx7oQLJGPFspqcS
         MMsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 37si952901edz.304.2019.03.28.08.22.43
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 428BE1715;
	Thu, 28 Mar 2019 08:22:43 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EF9053F557;
	Thu, 28 Mar 2019 08:22:39 -0700 (PDT)
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
Subject: [PATCH v7 13/20] mm: pagewalk: Add test_p?d callbacks
Date: Thu, 28 Mar 2019 15:20:57 +0000
Message-Id: <20190328152104.23106-14-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328152104.23106-1-steven.price@arm.com>
References: <20190328152104.23106-1-steven.price@arm.com>
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

