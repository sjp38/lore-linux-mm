Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B1EBC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16F6C206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16F6C206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9B0E6B000C; Thu, 28 Mar 2019 11:22:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A25E56B000D; Thu, 28 Mar 2019 11:22:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C6F66B000E; Thu, 28 Mar 2019 11:22:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3557D6B000C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h27so8208367eda.8
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SYRxLnl8XLiyLdkh6TtJG1FrMibEOdTkR6dxxuI72gg=;
        b=bP7C+YwhxNHHhqfZu5gKo1y/dLlmwj1Bq9lNolu/6R2zX6gAQREmhAOR2rV75hblmI
         +21tbL9t9EPzoy65Y6dg0Oe40G2i3DI1m9RaqTE1so/AdctiuAIAuCmJN9GprmI6wWDO
         8L2VB+X+RetC6NpCdEhZm/9H/XJ2XiH8/0XxnCZOvs6qjDDL5HWVTHsFfDCO6Wre5vK8
         K7GjfBok4fYUx9DgSNJLNd8z0M6RLeOc7JJa+BJWnJUY1xizWj/KCYoLnm+GOWJQbqeY
         VEW40oMrtgc99FcVOENLtcBvnxqeZUYHFJ18ALjyYjhfMAAkoOEJ6vQw5hHw6pihbCsP
         TOdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAU4hHOTCjbluANLCyBHyURJqsdPsC8SjYepaFQ4NUzUpNqwEEJZ
	yQr3Rr3KXU7xyUo9Rp/mEeC1O/KFwRZUldgQCtrvFwAj0drMWBttMOam6lvdDkt+tNAUpMxUYRb
	KgknW+xvU6BBUFuB0SzEioGS+7j62bZJJ9XbhKSu0foilbzTU5u1NbF8L9K0crkV+eQ==
X-Received: by 2002:a50:b6a9:: with SMTP id d38mr28117069ede.98.1553786535735;
        Thu, 28 Mar 2019 08:22:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRiipBNLC1DscJhfnr6Pktya0KeBkYgV1WkPyyDQL7bvXqGCCWzjBj3ThYuwQ86Y4BksBT
X-Received: by 2002:a50:b6a9:: with SMTP id d38mr28116996ede.98.1553786534552;
        Thu, 28 Mar 2019 08:22:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786534; cv=none;
        d=google.com; s=arc-20160816;
        b=LAfWTOpFhXKYOESHJzbfV2A5VGSj0p7qvc+AgWyVlKNQyPvOE2PB3hi3Cygk/fRafC
         lS92gt5bEV/IduhvYGLaelcYPdVa/5HPdrSKV+3v7B+R+4IHmt14+vp+wrQUuIOu0K3r
         tH8Cstdwo/MHXO8FEXLNMWPKLLwYXgy1hFMzmyCDg0H9Eu+QviPVzPMXQW0ywp0JuUq4
         dmDLD8qyqp325OfCmmcMzTTMBvrGiWahSvRpxc4za6WcLM5qMJ/jFvdxV/evLz/2yR0W
         g2NClA8P5bpClhpwwi/mFDwMdmvZe52mxRgMaPCwswUg0myXzUNf74NsB6iiydICF+pA
         DPtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=SYRxLnl8XLiyLdkh6TtJG1FrMibEOdTkR6dxxuI72gg=;
        b=xv0V/WnCS26xzZqaX+/EoU77UhH5GmwSNtpgaxeO3RD/HV6iQSsjCn0wJ6ZqE9cJMt
         lRrOI3S4v/1vLbpkDPnq7QFaogMDaGpZ1oRSRN6pPRjwOBINbBZlfLZnjznW4AU8uQQS
         0TMb+n8+Cf2UYho/QPkMeig8YHHU32/82nK0s/b0mGif4Av+mMd7GVle/Pbm6XEzKlLh
         kgQGKycEuaXi5nBvKI900xa+WVUwqo4fBW2/ZYrCD0EHs5KorzuRz+vBQlNDQayELLT4
         f6Hj5mhrZaxxpe7OF3sAVRrsGeY4WGVw1m8Zr+M6/deowszOEv5m4EWhAXTw2r9c9z4f
         FG4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c20si1662691eda.94.2019.03.28.08.22.14
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9FA4915BF;
	Thu, 28 Mar 2019 08:22:13 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 98B3F3F557;
	Thu, 28 Mar 2019 08:22:09 -0700 (PDT)
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
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@ozlabs.org>,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
Subject: [PATCH v7 05/20] KVM: PPC: Book3S HV: Remove pmd_is_leaf()
Date: Thu, 28 Mar 2019 15:20:49 +0000
Message-Id: <20190328152104.23106-6-steven.price@arm.com>
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

