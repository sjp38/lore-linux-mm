Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8773CC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43C24206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43C24206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F2F28E001E; Wed, 31 Jul 2019 11:46:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37BE48E0003; Wed, 31 Jul 2019 11:46:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26AC78E001E; Wed, 31 Jul 2019 11:46:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CEE868E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:52 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so42643786edm.21
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tfQclRJFdWfuHFy/tc7DxTTKm79xYcooIC8rpGbhg7A=;
        b=rbZp71MbTJCnolwHrzur3nrWNSAOVUjP/ZZmNAvH+EXzo6dVeqzoWKtYBwXF+RxaMC
         c9JRv94pzWWrp+5cr8j1hJIDYharrUgyTBMqnO/rLLojlbmyIztZaktQak+6RcHQVcq6
         bslajAGZzyEiYzx+imOihaxVQ8P9JeKbFrB5QzOWmnDJh2+7riR8PsemOPzWeyHDyYi5
         5wWCICpKwpPEZToLX78YLmQvjUZcoS5twpXy5U7V4RbNade5LT6AfDeEKcVDgLDDTNDh
         vx1kTMsZzpjRnwZNSbOC5xInztsLb2l1AVsZ8is9l0zfs7p9iR428Yjh34Cg5/R9Grsr
         AAmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWPCHle9g+LoV3Q/JIOp5dbLF0Ec11SOEZ6EBawSLpKKYYRqGcp
	x7aeGkGwpd+ek4zmmMmklIKSFW+enslMhO1hvUoAWODskG0vStlpOHUjpRt5oXnfK+fGiTQlift
	BcsgKUUgT6pwXgQuSntVst9ptW3gJCiBrWoGQ2cewmkFSdew/Dq1fw23J46nGX52n0A==
X-Received: by 2002:a17:906:4e95:: with SMTP id v21mr95419079eju.105.1564588012386;
        Wed, 31 Jul 2019 08:46:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwE7heEYXpPKb6EMpo7VRanjstKbLN+HokGQ9JdTMA6lOPaZV/8NprQBsSieR9Mjo+v7zl8
X-Received: by 2002:a17:906:4e95:: with SMTP id v21mr95419000eju.105.1564588011215;
        Wed, 31 Jul 2019 08:46:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588011; cv=none;
        d=google.com; s=arc-20160816;
        b=o39K/1fxkmpTjLBzQVvMDYomQNP+GkJlI33qAKtUFOWKJZ8hKYX4tmu8WySG7vkeTG
         NakGfY7N38haSYr6ZzImaVA7dez+Q1dYINOuil/OjrISqe8ZxO+UxElTIl8nBK0JQyU4
         dEwIlM3YL6EDNZpxLuofUz1kuqU6vt8MkG3eoyRp1Djoatx79ryamPFnogjBE6qpjJwR
         2K+zY4cvuAy+1fcun37D70go1h5+EmvO6NwynlhB1QhBf0HHkQV5BxdI/HQw2lzHz149
         mSPasrquNWcq2cm/pf5X9eP+rCqaA1smUX0UCWe3t3zgk1nrT/yXBroU5zZGGcdmIvfS
         Ui7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tfQclRJFdWfuHFy/tc7DxTTKm79xYcooIC8rpGbhg7A=;
        b=N5aHL4Xfy6Wdpidh6TvEDfVY/zB43y/Lv7fbc7ciBYYUyjJrRp1c1z01JMqk9RtrPO
         nBoRfxGF4EiN3GkKdfVYHN2zXNUa8f+ABTb799BykNgz0l3BBegRqywTrsRcyl/+0AOx
         GxjpBk1hhbyFUVu5hE4ltvFxTullUB46LOl0TuMcZ8xd4i+3qVWaW3+iZmnUk6R0I/VF
         YMmOV63uYdoRu0KEiVCm5j7m36EbjaBumVXwHwGajUIqG/BE1h0X+R+88uFNKlbbgSvM
         1wkg+uPGQwjwmoCJS+lHrKFuubfBgiRkvAMa+nNGNzo9NJaiTiv+i80cO3zfhyGvDjM2
         qtIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id nw22si19699764ejb.388.2019.07.31.08.46.50
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4AB4115AB;
	Wed, 31 Jul 2019 08:46:50 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B46AD3F694;
	Wed, 31 Jul 2019 08:46:47 -0700 (PDT)
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
Subject: [PATCH v10 13/22] mm: pagewalk: Add test_p?d callbacks
Date: Wed, 31 Jul 2019 16:45:54 +0100
Message-Id: <20190731154603.41797-14-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
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
index 0a1e83c4e267..e2581ec5324e 100644
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
@@ -1474,6 +1479,12 @@ struct mm_walk {
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

