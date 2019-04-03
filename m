Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D45B1C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 909B820830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 909B820830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43BEC6B0010; Wed,  3 Apr 2019 10:17:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EAA36B0266; Wed,  3 Apr 2019 10:17:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D8986B026B; Wed,  3 Apr 2019 10:17:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D65776B0010
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w27so7691238edb.13
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SYRxLnl8XLiyLdkh6TtJG1FrMibEOdTkR6dxxuI72gg=;
        b=JA91eqYxfjl0B6PbDAB1vj1DjrAgCkVooYiRmca9WtrGPZPsKp3oqExgY7Gc15snZO
         /U9DU4aurcUmYZSGWADI1PVxHRTajkIAzTWgu4NDwxbqloNA5yF2bLHS5eN1OMEaGEpD
         3KkBR/pygPrTp6ssyHkcRmxaYgFoAUuaHPr5NGN75e3foOSaKSQUG/FP9d7uvfXxH/K4
         2ysZSJd9q5oN2bYXw3CNzQJcLL7w0au4w+vXJJTQWI80oY5mOZx2n1UlfzP52lUF/fXg
         0iefOpdArAqiq1RigTbHHJ5t450Mjk51WF7qeYHkCzyHx6x7MwEEgQzsRqorv//TBtNA
         u6Eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWr8B2eO7slJ4HrlLD6T3cYZXNjG8JNFXHsVeTlEekebDtLqlTf
	F05KCmOFN7JhhYfdehgJ2lSvfu8gAWoM3Gr2pJek7Si5reaEO5GC6DP7Vf7hiLtXSFriroN14jV
	Q5CLKJluy5DYY2Pu5MxmvMAj4sbEHaso9LmwmVx5OpWrAXeZgxT/yewr9YFdwvbfpmA==
X-Received: by 2002:a17:906:3581:: with SMTP id o1mr2935008ejb.163.1554301054378;
        Wed, 03 Apr 2019 07:17:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwI8hh+KzTDIYhDJg3x5DDThpZl39M0AD6RGiarnnjXXfvTtT9Ntr/NvZCKnH08dMwylja3
X-Received: by 2002:a17:906:3581:: with SMTP id o1mr2934943ejb.163.1554301052997;
        Wed, 03 Apr 2019 07:17:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301052; cv=none;
        d=google.com; s=arc-20160816;
        b=brBNlhUaARVV1RLicnDy0YNw+KOEFuvTATUixEloOXTw4pV/INb4339cFtGsYIPcbz
         TcjSefuxKt1UqdSJ7hZBeA6/Op8NN6kod9oYS8ez9H+2OtgIw+WBa+l97BKME01Y6EkC
         4i/CQajkxhGNT/MtJ4VHPRbnFTjw/myhUXTHPHhsjk5G5yIHieJHQzZYwmt1O/hPHLE+
         gDb4H3+UxPQwJh/tIQ/0z9VYOx4JXZiq+e/IU/tJG4pGA059ZASxRBVUPn1cbDznxwZd
         qOJrRBsiNnUb74Nt+/tzh+9xhLFwJzjgLo80jhpm0zqlFoLnM1Xz34zvn7NTFmJIT71i
         hwzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=SYRxLnl8XLiyLdkh6TtJG1FrMibEOdTkR6dxxuI72gg=;
        b=TXrtVMEfFlKOD3dog+kL96DmWDRRWPvRCq5Yz86ztayW1F68eXwVQkKyGGFxQngFMY
         YmesPXa/wrVIiiSX9DwHrM3qNvioKmGlP5AW8IMD3SwDK3LaBPy8UO88Ztbk4DeDPzBp
         1UBLMRhj5Ac3vT0RqXYkRQzHsoebN+XFN26ZkZQC9NojAQXC8PpxT5ZdCcB8m06OHfNz
         FrzTSBeIonDo2Lhj0yuPMz1dHLhCOhXDo5poVCChaX3yFq4/fpXCBQ71bXm84WwhlLer
         +QokShePDbmwuOdE79xKv5/PpAMHbb5zemVbypqcb5iTjYmQ3+MDVe0EizKrJwev/Slk
         4E6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u31si537432edm.308.2019.04.03.07.17.32
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1A197EBD;
	Wed,  3 Apr 2019 07:17:32 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F06A03F68F;
	Wed,  3 Apr 2019 07:17:27 -0700 (PDT)
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
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@ozlabs.org>,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
Subject: [PATCH v8 05/20] KVM: PPC: Book3S HV: Remove pmd_is_leaf()
Date: Wed,  3 Apr 2019 15:16:12 +0100
Message-Id: <20190403141627.11664-6-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since pmd_large() is now always available, pmd_is_leaf() is redundant.
Replace all uses with calls to pmd_large().

CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Michael Ellerman <mpe@ellerman.id.au>
CC: Paul Mackerras <paulus@ozlabs.org>
CC: kvm-ppc@vger.kernel.org
CC: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/powerpc/kvm/book3s_64_mmu_radix.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
index f55ef071883f..1b57b4e3f819 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
@@ -363,12 +363,6 @@ static void kvmppc_pte_free(pte_t *ptep)
 	kmem_cache_free(kvm_pte_cache, ptep);
 }
 
-/* Like pmd_huge() and pmd_large(), but works regardless of config options */
-static inline int pmd_is_leaf(pmd_t pmd)
-{
-	return !!(pmd_val(pmd) & _PAGE_PTE);
-}
-
 static pmd_t *kvmppc_pmd_alloc(void)
 {
 	return kmem_cache_alloc(kvm_pmd_cache, GFP_KERNEL);
@@ -460,7 +454,7 @@ static void kvmppc_unmap_free_pmd(struct kvm *kvm, pmd_t *pmd, bool full,
 	for (im = 0; im < PTRS_PER_PMD; ++im, ++p) {
 		if (!pmd_present(*p))
 			continue;
-		if (pmd_is_leaf(*p)) {
+		if (pmd_large(*p)) {
 			if (full) {
 				pmd_clear(p);
 			} else {
@@ -593,7 +587,7 @@ int kvmppc_create_pte(struct kvm *kvm, pgd_t *pgtable, pte_t pte,
 	else if (level <= 1)
 		new_pmd = kvmppc_pmd_alloc();
 
-	if (level == 0 && !(pmd && pmd_present(*pmd) && !pmd_is_leaf(*pmd)))
+	if (level == 0 && !(pmd && pmd_present(*pmd) && !pmd_large(*pmd)))
 		new_ptep = kvmppc_pte_alloc();
 
 	/* Check if we might have been invalidated; let the guest retry if so */
@@ -662,7 +656,7 @@ int kvmppc_create_pte(struct kvm *kvm, pgd_t *pgtable, pte_t pte,
 		new_pmd = NULL;
 	}
 	pmd = pmd_offset(pud, gpa);
-	if (pmd_is_leaf(*pmd)) {
+	if (pmd_large(*pmd)) {
 		unsigned long lgpa = gpa & PMD_MASK;
 
 		/* Check if we raced and someone else has set the same thing */
-- 
2.20.1

