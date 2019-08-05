Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8764C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:05:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CF28216B7
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:05:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="QEOkJI1u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CF28216B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B6776B0007; Mon,  5 Aug 2019 13:05:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13BF86B0008; Mon,  5 Aug 2019 13:05:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 050B36B000A; Mon,  5 Aug 2019 13:05:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C50746B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:05:13 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h5so53105728pgq.23
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:05:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RUBxnyz640QfvTz6lz/Tqs2pyOPmGqnxC24rkQCQqR8=;
        b=na0PCIfQMuguP1IMHH4obnWUUuqjHLGeu0WpVfYYFawIBZ+jnqzAt++5C0WUKPXlNK
         s29Ii+WxN1dxDKP+v1RDXJ5wHAF5Oa4n0qltJx85rI5wbR9TmTKuRVFLHMhN9WulKP5H
         Z2ZtdePhzN9eZt/4KxjuIMBo6qvlHOSGmjhs1VD6UGQOLXXd1Ot49EehIZ34bbMBjzIX
         b98J1/h/8gtPZVsMAgltUerOIXiWzPE4wGYkmrZSJ/OBKeAPnIIcZOeWuOislUZp/lIy
         AJ0Gqqzpspnx1Sw0w9blbKFLcAx5UET+zK6mCKFQSrIwKKPR8vSNdGLEDgvz+dLrk39V
         vFjg==
X-Gm-Message-State: APjAAAWs0BsRssCeYR8zL/Zoj5IrFs5/LrjbMjcrzi4DpoYz61BP3iQp
	JlYyhGsn5jJ6dyGSzibJ7EolNpRuvk9p5Sqmx/56uTL1V0jx4BGTLirSQt0BWCrDbDR8tFxITcs
	vVjEznn5bHvsEs3N3cgHhyAoFNlcpufror2hVTFkABt9vqmjlXCzv9PnKF6gD5nLVKw==
X-Received: by 2002:a17:90a:8c0c:: with SMTP id a12mr19080164pjo.67.1565024713497;
        Mon, 05 Aug 2019 10:05:13 -0700 (PDT)
X-Received: by 2002:a17:90a:8c0c:: with SMTP id a12mr19080102pjo.67.1565024712782;
        Mon, 05 Aug 2019 10:05:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565024712; cv=none;
        d=google.com; s=arc-20160816;
        b=izDuJjQD0FGo5tOHGTKBRIbsBp1/bSDmmzI8X/SyCR2Ajsn/GkonGdN0sHGuo8Rnej
         pUKzJPMtCFJit6BfgDYGzHmiVK8/ZZrn1CsyBx5TAfuBrOO2sTRN8Tv8bK/sQE0osqz8
         hMOldzsYKRGqF+f54UGu5R4E1XvnAgebDAa42rx9bzzOlCzqeu2eGUUht8OhQqU5hMa/
         Jtk9Q8pCb5dtPwgL2SoMZTiWJe5DjEUR2cM3htiZ2Nr865Au5am96iZVxF6MTAhIbu40
         lqzdHMjGeO5/sWxu+v8icOWZ3rr1tflc5Vn2bkjzPAvqWZE+ZfZKSW91AnsEKnr5jgpa
         OhKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=RUBxnyz640QfvTz6lz/Tqs2pyOPmGqnxC24rkQCQqR8=;
        b=X/2gKtNAalKFtd/rcPzKfHAHOznT03ac3Z12MlciTljMvhOCzTEi+qAbStS4jFJJmv
         +g3u3EQrRfrNsmkoMmJyLEe6SWVSYvocerN57sSajh6iFavriM7U0MJIdFE+H7xlSRJE
         y5Te1czjbHuKJonUK2FhJ7UQCuiqmARgawScl0RVUmzuMkP2xirC8hJcmdBvBio9bE6d
         JCX2HgzZBANPzWiXODO6kx30fKPtZ4oZGKmiY9qp4X19rQMgfkxLBVAf9kF953wd/LHt
         DR2bou+Bjo8IYdbNVkjl4EhSexKgrpkZ3XTzQbzF7k2qJYVHizmvYkEKypIaPTRuTz4f
         W5Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=QEOkJI1u;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor64905367pfd.59.2019.08.05.10.05.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 10:05:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=QEOkJI1u;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=RUBxnyz640QfvTz6lz/Tqs2pyOPmGqnxC24rkQCQqR8=;
        b=QEOkJI1uuZ+jSdOl6tBfEcxS4lwaMuWo43bvHb8IEHarKAyNN0MWV5t12h+iKsm8dO
         J7HViNVcJnELGFCNRTAE5kuQ6V6zX93lvwyuOag45IAvbLYcCRmpuzE0Y8TZwWBke/rZ
         +zU9hexd9hgPeIjOktomqrMSW7rr5L8f+KbsU=
X-Google-Smtp-Source: APXvYqwnR2jAWfV7TWIbHzeRGGMkSbdfN64oix1so/G/sVSVrD4k1Fz1wn7L6kV9yuqrFmYXXVE03A==
X-Received: by 2002:a62:7a8a:: with SMTP id v132mr73809561pfc.103.1565024712416;
        Mon, 05 Aug 2019 10:05:12 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id p23sm89832934pfn.10.2019.08.05.10.05.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 10:05:11 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>,
	Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>,
	dancol@google.com,
	fmayer@google.com,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	kernel-team@android.com,
	linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	minchan@kernel.org,
	namhyung@google.com,
	paulmck@linux.ibm.com,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>,
	tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Will Deacon <will@kernel.org>
Subject: [PATCH v4 3/5] [RFC] arm64: Add support for idle bit in swap PTE
Date: Mon,  5 Aug 2019 13:04:49 -0400
Message-Id: <20190805170451.26009-3-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
In-Reply-To: <20190805170451.26009-1-joel@joelfernandes.org>
References: <20190805170451.26009-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This bit will be used by idle page tracking code to correctly identify
if a page that was swapped out was idle before it got swapped out.
Without this PTE bit, we lose information about if a page is idle or not
since the page frame gets unmapped.

In this patch we reuse PTE_DEVMAP bit since idle page tracking only
works on user pages in the LRU. Device pages should not consitute those
so it should be unused and safe to use.

Cc: Robin Murphy <robin.murphy@arm.com>
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 arch/arm64/Kconfig                    |  1 +
 arch/arm64/include/asm/pgtable-prot.h |  1 +
 arch/arm64/include/asm/pgtable.h      | 15 +++++++++++++++
 3 files changed, 17 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3adcec05b1f6..9d1412c693d7 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -128,6 +128,7 @@ config ARM64
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
 	select HAVE_ARCH_PREL32_RELOCATIONS
+	select HAVE_ARCH_PTE_SWP_PGIDLE
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_STACKLEAK
 	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
diff --git a/arch/arm64/include/asm/pgtable-prot.h b/arch/arm64/include/asm/pgtable-prot.h
index 92d2e9f28f28..917b15c5d63a 100644
--- a/arch/arm64/include/asm/pgtable-prot.h
+++ b/arch/arm64/include/asm/pgtable-prot.h
@@ -18,6 +18,7 @@
 #define PTE_SPECIAL		(_AT(pteval_t, 1) << 56)
 #define PTE_DEVMAP		(_AT(pteval_t, 1) << 57)
 #define PTE_PROT_NONE		(_AT(pteval_t, 1) << 58) /* only when !PTE_VALID */
+#define PTE_SWP_PGIDLE		PTE_DEVMAP		 /* for idle page tracking during swapout */
 
 #ifndef __ASSEMBLY__
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 3f5461f7b560..558f5ebd81ba 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -212,6 +212,21 @@ static inline pte_t pte_mkdevmap(pte_t pte)
 	return set_pte_bit(pte, __pgprot(PTE_DEVMAP));
 }
 
+static inline int pte_swp_page_idle(pte_t pte)
+{
+	return 0;
+}
+
+static inline pte_t pte_swp_mkpage_idle(pte_t pte)
+{
+	return set_pte_bit(pte, __pgprot(PTE_SWP_PGIDLE));
+}
+
+static inline pte_t pte_swp_clear_page_idle(pte_t pte)
+{
+	return clear_pte_bit(pte, __pgprot(PTE_SWP_PGIDLE));
+}
+
 static inline void set_pte(pte_t *ptep, pte_t pte)
 {
 	WRITE_ONCE(*ptep, pte);
-- 
2.22.0.770.g0f2c4a37fd-goog

