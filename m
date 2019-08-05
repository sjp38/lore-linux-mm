Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ECC9C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:05:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23A7D2147A
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:05:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="aRQhDf6h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23A7D2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B74E16B0006; Mon,  5 Aug 2019 13:05:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B59706B0007; Mon,  5 Aug 2019 13:05:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A0846B0008; Mon,  5 Aug 2019 13:05:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 613B86B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:05:10 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w5so53097570pgs.5
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:05:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1UeFCEkBe8WB1WXsCYwcP/7nKnryRnwhqxRiHu1oF/s=;
        b=L+4Z1EJEzwfTpKuZAuh08jeQFveOhON/UTPPpmst/iGWq3HrJE8gol4U1j/TAp5LH4
         uRMNG0qXhiJiG110tMCpbeyd+EhR9XunpVRnAxJQxqdJzV27/7Lng2XmOxlzwq1p/Qop
         w1nRcjaoNM581k7gw+AgSL/oeRDB481zSPXKVscRgfGOB9NAuijVoYxemMGhw1wQpRqH
         mz4wOO5HICZmgQ8casw68Xg+33+l31/GDdpcgU3KTCaX3LAJVDyV5tZKTxshp3wA859d
         VNw2qqb5ODnSQ/dWlMeBwF7GL5rIECUrjatR6Bv3E34/IONdIQ109T7AgpAZWsxI+uEm
         xw6w==
X-Gm-Message-State: APjAAAVz4ilLwXD5hBH6DXmjgOi9T4PbPcaXWDuCKPy/z6EepxQwLCJO
	Ccs86+AYE3LLJ4Mz3IvSdaH4lU+SqHv3NfKS4m+NVtY3AjddjEsstYfw4fIdOYAH6m7kZA6izHk
	s+jABEwqWq+JCmMOJoKP95MoOAfGH9x1En5NRTBFLdjPmOMz9H6bMLwmdzPbpuvu87A==
X-Received: by 2002:a63:30c6:: with SMTP id w189mr132761463pgw.398.1565024709939;
        Mon, 05 Aug 2019 10:05:09 -0700 (PDT)
X-Received: by 2002:a63:30c6:: with SMTP id w189mr132761409pgw.398.1565024709172;
        Mon, 05 Aug 2019 10:05:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565024709; cv=none;
        d=google.com; s=arc-20160816;
        b=ahQvAJRhVBgOa+vVhSCNfbTyKYa7tS0U9XNIwymeg6p0AuUbX0Ovv7OHWaUjBnohnw
         UK2a4BN6EPY0nzDdd3EfIwF+R4cz9UwsEI2CvEm8jZHixDg8YT/Bp0m+AiLJjHEv55yi
         iiX6f0gvUHy9tMDbhmSGyBHoF9bFwSOrEGdqmhUNBLtTorSnrl44ryNMJv9UXxbQZ/uI
         4AEjuozvTtxZ8p0ubsldd77eC4kNAQlWz5WBomk91J9wtN5izC9NATnanSk4m+9sRAlq
         /uCYMC34TOmN5PALi4hEB9tpnE97LjOOrS1xo1W7Cj0M+mF2wAQR2HhzGnUQWEHe2ZDr
         mDPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1UeFCEkBe8WB1WXsCYwcP/7nKnryRnwhqxRiHu1oF/s=;
        b=ytEQnRz4ceqJGoDF09EnLYXxi7syXTNZI4QdBK60TVc1rDipEuKuaXUT7XaUAAoKQf
         nBPNHzlTzM9NgEtCw9lUfwXEtH8l2eLvGlGU/2grlr00fiECfypqkHZZyTUU5fXH5GvN
         Qmv+SXjtX8R/A2V9H8l08jFL6f9HvQnop6CwwWHyq+otOwNJqBO/zDXUJrmrYF553C47
         ySL3Uhh0MyN/RY/TpsJwFGBvXbOjkJMZCNs57FX6QusmPTn6G2t9ET2f5Iae58dxlf/0
         VT2EAiYFqLsosYoiUH9OoEnb5I34U3i2YVltk6GWLJ9/VOt32Mim69Zkr5ThBMSXftZ5
         YPtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=aRQhDf6h;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3sor47569212pgn.56.2019.08.05.10.05.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 10:05:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=aRQhDf6h;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1UeFCEkBe8WB1WXsCYwcP/7nKnryRnwhqxRiHu1oF/s=;
        b=aRQhDf6hWMIwFNIsdofuz4dUydkk4193Ae5APGLROO3pABy9OrZWfS49Oc1/HtwlK8
         zBW4GUhb8QcOqCuMoUCb51aRgkOp2HCURDKAYJrVPy5wQgbMci9jK3qx0YEVG/MV2GGY
         McthzaBpFY1H9f9O58G6IjguBX4lH5u33NOZo=
X-Google-Smtp-Source: APXvYqw1Ogbi2keaae7q+qwAyhHLlLrbTZ8++SpJb3M0ShcnSkOoRtFslH3qoL66EjinazduvqoRuQ==
X-Received: by 2002:a63:ff65:: with SMTP id s37mr94810810pgk.102.1565024708684;
        Mon, 05 Aug 2019 10:05:08 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id p23sm89832934pfn.10.2019.08.05.10.05.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 10:05:07 -0700 (PDT)
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
Subject: [PATCH v4 2/5] [RFC] x86: Add support for idle bit in swap PTE
Date: Mon,  5 Aug 2019 13:04:48 -0400
Message-Id: <20190805170451.26009-2-joel@joelfernandes.org>
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

