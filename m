Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D01D9C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 17:16:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86A1821EF2
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 17:16:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="HcPjW0Di"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86A1821EF2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12A3C6B000A; Wed,  7 Aug 2019 13:16:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B5EC6B000C; Wed,  7 Aug 2019 13:16:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E70886B000D; Wed,  7 Aug 2019 13:16:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE1E66B000A
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 13:16:17 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q11so53076739pll.22
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 10:16:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1UeFCEkBe8WB1WXsCYwcP/7nKnryRnwhqxRiHu1oF/s=;
        b=bMPI7TQcegACxKx5eSCMeCDIF5ZVVKiQ24BC09vig0tOhNzu9++GRP/hRAW1WXe/cB
         hrQP5347NIfrTWcqwG84FFlw5kkDlaTwePce6Bz/C9u/q9DRSvYjAQmUcqBryu5syC0y
         Bhlzi4v9zjGrN2hyLD1WN5d469kOgoWvMogXhzt127kgitoPrem8V7c6kfa5rqHi6ntw
         Q6gzEEFAi4v/+H150rUAMPn04RclShn+KRx4kCQTUSm3pnHGAo6tnR0DDOXQtQbA2rUs
         q7phVWYJ4lOZbF1S4zJ+q4/x1uV1UbFHVBcG5WFOx2257LfD52hU5qfu3X2YA0oAkVIo
         ZqiQ==
X-Gm-Message-State: APjAAAVD8KwqsxldcnbIV+Au4GsSO6CTKz+7vMbqxmO3QMdPUnbMVVZH
	GR37GSpmqAy1HzQbHm/14qRgeIQKE3C0FXh4fvD0SalpmkpqJrjSvS1AkuthLj9Nx2qx6NYIvTy
	+wpPM2s/QOsTped5GGtf7QpXNElt+Z2bgWBLX8zmDFWQXZ6rX4sa0DCNw1hs5jfTqSA==
X-Received: by 2002:a65:65c5:: with SMTP id y5mr8547437pgv.342.1565198177287;
        Wed, 07 Aug 2019 10:16:17 -0700 (PDT)
X-Received: by 2002:a65:65c5:: with SMTP id y5mr8547371pgv.342.1565198176363;
        Wed, 07 Aug 2019 10:16:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565198176; cv=none;
        d=google.com; s=arc-20160816;
        b=zNa+a8U2OW9IFQvQrJSWPQ+MQbUyDVNoeS7xx7FKEvsJYHbDFR1/CHUAtryhMmJ9ek
         vP2wASutO5CAmmLlTm6vmu8miQv+y7KuCOXNj2SnbHxl0ZV8WqFibPw25++uXHPZ1uY1
         uolaN88KGGDgEGUk1Z0USXHAIF+8S/OOx1UKCAvg3hGHwsC1k7rBxMWw8u+0CTCs9pKv
         veI/3GZ84BjSQlJ3NEiJt4ygIBP+MVpQIVuFyvTGbiqf2uNEr21s8ExGpYbI88TruSvB
         GpHYhQDQjZUIDESNWWgi96doe3CceNVb6wmpCV8VC5PgxkMDgsDNCWB4QgYJ7ePVnemk
         W9Ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1UeFCEkBe8WB1WXsCYwcP/7nKnryRnwhqxRiHu1oF/s=;
        b=d3Oxf6fMMMOHt+B0RY71zOsfT99+H6m/jIIOHlo96WI8Nz1NKd83rKTW2vOE+4TJKV
         7NsvK1js9hzLXrSg5WMltpaWssK/Go9bK5hcLzuUR3tWT7WKIS2kHypCWxuNKxFs4F6W
         e6aGLACGiLwj0gsTGL7PFGKdVi7scVFaA2fsudWWnG+dXdqGHIdc0gKHJHAJznEp0XkL
         e4WEa61SayyzUKZNHpRUc+XUlZXXhcPrUCCs2vdFElx3pI8SLiVyT8onBuVW4g9H/0D7
         /q8qPF/Cw8gBgGrgcvEIQ3YQqzULB2Fn1rCkwJP4D9da+80XJWfNklmBgQcqx1QCmHg2
         0PFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=HcPjW0Di;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r202sor72818011pfr.51.2019.08.07.10.16.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 10:16:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=HcPjW0Di;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1UeFCEkBe8WB1WXsCYwcP/7nKnryRnwhqxRiHu1oF/s=;
        b=HcPjW0DivADdEfHkyp4B3Mi8RU+x160HluTp+508rUVD+SzJgBrJq6t1BUOsPiC8sf
         fsTMIHTi5sb49Zvfxvz+q0a3vrz9N1UySTOGDCYAfcU7uD8iy1sWRdXzXXFJ6HB9lday
         L8GmF1g24wM+UOHJXMd0arOKopP7Q91uFDxtM=
X-Google-Smtp-Source: APXvYqwHVvygOlXUtIZKyi/92023MeWzg0pU1BdqY1xO4rXhd1tufTZGiEHLR2SPeSZbDPbxKba8KQ==
X-Received: by 2002:aa7:8817:: with SMTP id c23mr10572797pfo.146.1565198175976;
        Wed, 07 Aug 2019 10:16:15 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id a1sm62692130pgh.61.2019.08.07.10.16.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 10:16:15 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
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
	Robin Murphy <robin.murphy@arm.com>,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>,
	tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Will Deacon <will@kernel.org>
Subject: [PATCH v5 3/6] [RFC] x86: Add support for idle bit in swap PTE
Date: Wed,  7 Aug 2019 13:15:56 -0400
Message-Id: <20190807171559.182301-3-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
In-Reply-To: <20190807171559.182301-1-joel@joelfernandes.org>
References: <20190807171559.182301-1-joel@joelfernandes.org>
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
since the page frame gets unmapped and the page gets freed.

Bits 2-6 are unused in the swap PTE (see the comment in
arch/x86/include/asm/pgtable_64.h). Bit 2 corresponds to _PAGE_USER. Use
it for swap PTE purposes.

Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 arch/x86/Kconfig                     |  1 +
 arch/x86/include/asm/pgtable.h       | 15 +++++++++++++++
 arch/x86/include/asm/pgtable_types.h |  6 ++++++
 3 files changed, 22 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 222855cc0158..728f22370f17 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -139,6 +139,7 @@ config X86
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
 	select HAVE_ARCH_COMPAT_MMAP_BASES	if MMU && COMPAT
 	select HAVE_ARCH_PREL32_RELOCATIONS
+	select HAVE_ARCH_PTE_SWP_PGIDLE
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
 	select HAVE_ARCH_STACKLEAK
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0bc530c4eb13..ef3e662cee4a 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1371,6 +1371,21 @@ static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
 #endif
 #endif
 
+static inline pte_t pte_swp_mkpage_idle(pte_t pte)
+{
+	return pte_set_flags(pte, _PAGE_SWP_PGIDLE);
+}
+
+static inline int pte_swp_page_idle(pte_t pte)
+{
+	return pte_flags(pte) & _PAGE_SWP_PGIDLE;
+}
+
+static inline pte_t pte_swp_clear_mkpage_idle(pte_t pte)
+{
+	return pte_clear_flags(pte, _PAGE_SWP_PGIDLE);
+}
+
 #define PKRU_AD_BIT 0x1
 #define PKRU_WD_BIT 0x2
 #define PKRU_BITS_PER_PKEY 2
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index b5e49e6bac63..6739cba4c900 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -100,6 +100,12 @@
 #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
 #endif
 
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+#define _PAGE_SWP_PGIDLE	_PAGE_USER
+#else
+#define _PAGE_SWP_PGIDLE	(_AT(pteval_t, 0))
+#endif
+
 #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
 #define _PAGE_NX	(_AT(pteval_t, 1) << _PAGE_BIT_NX)
 #define _PAGE_DEVMAP	(_AT(u64, 1) << _PAGE_BIT_DEVMAP)
-- 
2.22.0.770.g0f2c4a37fd-goog

