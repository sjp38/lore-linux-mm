Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EDF6C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3270622387
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3270622387
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEF3D6B000A; Mon, 22 Jul 2019 11:42:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA2288E0003; Mon, 22 Jul 2019 11:42:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB7298E0001; Mon, 22 Jul 2019 11:42:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE666B000A
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so26545326edv.16
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tw4JZILHpRw8yw2ivWns3JMulA885A2eTY+XMl6s8Qw=;
        b=p1Bd/Psxp7yr0EqYF855+lUYWP1KKw5xc0hhZnKCFe0iSUKFB8KbWwJF0lJ6kS6xOG
         F3gT7xiZs2g5aTF7ErIzr8AxlXxjgZFNEPpyOEiCFMywofKwpqA8bXnjtbSxPCeRcl+4
         fKbZPcIpl00EcOjmF99FQ/CPz7GFwm39mXFsJ/bg6tqwOxCns80JIgYamP9Za/7fY/gq
         I4bs/2TgxjuMLT+MoVM9vLkjNMhgTSz5e5/QS4tizAQF7m6/DdvAKK60ajuxKlNgl/o7
         dlwgZEWq7Fql+jkBSdXr3fRkf+gBml/hjn5UgM+0hIlQ8WGqRDHOKKUm2HcvKK1ONnNw
         z+RQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWsQYjrGU/X2GbfaJTmx27abkV80V2hcGdh6sZTIfHFdHq7zlZr
	wyIPGSVfdh7BS8yrqGCigh/C8u0fUx5ey5Lq5b084S0f207G/K8JDXvbt4AETwoJsWiQzo5t+Lq
	Xot4l9TdQVeLivws6RiwQG8z0sbU2gZ/qDqbwbR7FP0cwcSPLjSFVvW2klorDKwjTug==
X-Received: by 2002:a50:e619:: with SMTP id y25mr61053893edm.247.1563810148041;
        Mon, 22 Jul 2019 08:42:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeaVhxn0lS6d30mhvxSJ1/T6C84rH+XhTt+WeaNGGC596vBIxzCPSQEYjDodWGUhBC00OK
X-Received: by 2002:a50:e619:: with SMTP id y25mr61053849edm.247.1563810147379;
        Mon, 22 Jul 2019 08:42:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810147; cv=none;
        d=google.com; s=arc-20160816;
        b=RvEsnAumwbwNE1rLO/db7AaX88WvYWvmNSTrUIxKGIsmZCFLDApbEND+5MtFT4q7+n
         elS6PrCKDIoHa0pNPt/poOaQgHJ/PwXvb//CaEGlg2CIwSFzwlxN8PIWwfbPE4mnq5Ux
         xUmqOS+hwyaEO41OwKH5ZzP9S+6iJYok9PKGzh0REnts2axO/VO+k9Pge+Ynl67E0a8Y
         rCo7ZxuueDEg+S8oIJ1sxmv9i8jZdvGmhjyhtWj3hIc/YNblcOSslsDDX8suftoh9lj3
         YyL3zTesA/HCx/Olph8KzDkE+3Kq6+KBX3AYwz70wme78P0/Vz7khTcuwE5/PlwZNK+8
         6ZKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tw4JZILHpRw8yw2ivWns3JMulA885A2eTY+XMl6s8Qw=;
        b=m61HElqydZdtDaIghOJ1qzNCArznnaQC31pDmmhw88ChtXM2CFlyQ2+PLaR9N//JU/
         JbWY3FqSynpyJ6s1p3zcY5MO9n1NT/nYTM2hlfTVCMmiM+RA+OZiL4kiU8wd+rOkStKz
         1TsEIFQa8ilbCi9KgYqP9n7hsXi4LbhIF/XGpsv2lI2NOBDvVbAyaKCNBXMySqlxtWmG
         +S+x+glc9YCmgKE+slIWlVQB2A2fRxn3LRTsh8+TM62dL6F+/iX1ChNnMfErteAa6qcv
         EHUE7aiPEJuXnjNt7Sm6Vrwojcp76dWI6ualLpS5PDQ6JMu+R01vA6eWlJjJulj6+iQU
         UDoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id m44si5104896edc.110.2019.07.22.08.42.27
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 86D4E1509;
	Mon, 22 Jul 2019 08:42:26 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BA1883F694;
	Mon, 22 Jul 2019 08:42:23 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>,
	Vineet Gupta <vgupta@synopsys.com>,
	linux-snps-arc@lists.infradead.org
Subject: [PATCH v9 01/21] arc: mm: Add p?d_leaf() definitions
Date: Mon, 22 Jul 2019 16:41:50 +0100
Message-Id: <20190722154210.42799-2-steven.price@arm.com>
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

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information will be provided by the
p?d_leaf() functions/macros.

For arc, we only have two levels, so only pmd_leaf() is needed.

CC: Vineet Gupta <vgupta@synopsys.com>
CC: linux-snps-arc@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arc/include/asm/pgtable.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 1d87c18a2976..8c425cf796db 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -274,6 +274,7 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 #define pmd_none(x)			(!pmd_val(x))
 #define	pmd_bad(x)			((pmd_val(x) & ~PAGE_MASK))
 #define pmd_present(x)			(pmd_val(x))
+#define pmd_leaf(x)			(pmd_val(pmd) & _PAGE_HW_SZ)
 #define pmd_clear(xp)			do { pmd_val(*(xp)) = 0; } while (0)
 
 #define pte_page(pte)		pfn_to_page(pte_pfn(pte))
-- 
2.20.1

