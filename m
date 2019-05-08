Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C6FFC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAB9420656
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:38:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="wH2CxJQ0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAB9420656
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A0D26B02BD; Wed,  8 May 2019 11:38:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 653266B02C0; Wed,  8 May 2019 11:38:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 541176B02C1; Wed,  8 May 2019 11:38:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 223416B02BD
	for <linux-mm@kvack.org>; Wed,  8 May 2019 11:38:15 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id w13so3711280oih.22
        for <linux-mm@kvack.org>; Wed, 08 May 2019 08:38:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=T6bgGq2KcJ4pPFly2xX3mqEDKu0BtnCpkaNCQLXnqH4=;
        b=RC4m7d0zbLED2G1LaxHwlAFeHDCd6NsnF0ImyFaghfC8/3VhmFg5MIFQVQtcyMJwEP
         w2ps2qrMMS0NjbgiHhU63LWN5f5YJ8OxPDUo61xjA61uglRXJQzrVG+BaXckCL9vgeFR
         aR1ZDcSowaYQSmYvOtIpSJ+8GK5KE7cOH/aS5Q9KdZLiU44LNt7SVx9D9vb5onGxDtZE
         Uago7Cb8ICWNCDsyr5EH3elJ4GrkOoW2wfkY4p5sGobPNhatZJ9izAuJBRzXvuefz/2b
         Ho0uwDjef6rpLfg9lxHkp4a09Kax9ln4HycmvIzVX0XcocUVPKwn3wpf0YwM74dZ5g0o
         mUqg==
X-Gm-Message-State: APjAAAVVKK6pmaRsUOU3o/UFwu1xvKH6+HfEtzoiDsGrSKbHpPwuQxEK
	p6KF+ux7Y+8epePpQv2nOvLVkt9/0QZBlg4xzcGmoXlhJEEtseA5v94UWJw0V458gsc9OcDnWvr
	YJtpEv9TvvV8bkSeTqFQSw9ONcwMemRL2ia5aRXGpTGCm42f/EmwyIImcBn5lgRCJmA==
X-Received: by 2002:aca:4455:: with SMTP id r82mr2488232oia.165.1557329894715;
        Wed, 08 May 2019 08:38:14 -0700 (PDT)
X-Received: by 2002:aca:4455:: with SMTP id r82mr2488175oia.165.1557329893532;
        Wed, 08 May 2019 08:38:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557329893; cv=none;
        d=google.com; s=arc-20160816;
        b=eTdXYKbzKWHaACDqiVmwbzyBMopBxTv46WyuecxLFRhKzNQVbchmUO/lE+Hm1Ladm/
         Aqki9BhC6l3+LWM6AIKkxACEk2lBa9XaQUrCnnwmTAH2guZ5Ot6W1mYmcPTYSvk3JKT4
         xcyoSrtIpgqlnpbAIGx2LLL2mqGM3U0nhiz2jxKimOOZvNgNd7HVntVwj9QLBhKYDpOh
         M1UbKqbSZ0dD9dzbjn823WpEo1eQMUkcRx0XC1TQr346F4tzaL3ZXUI+Bz9ixsu44qYb
         BbsiVa5kOcWw9UhrF5GTysIPECorXrX4hyFL+EdtWg9W5orgCb8abxiXIjDelpTqld0d
         3DgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=T6bgGq2KcJ4pPFly2xX3mqEDKu0BtnCpkaNCQLXnqH4=;
        b=iyMgW27yjDmGJnd3RqJK8cgty4YLLHUVRt4NQSlqPY2LKyCRnAjr0+lh2h+HggzQIf
         4wHHSOLP+pOSLU41q7xrtDLyRKnAebblsLpvvhdzynFjN27JFRH0X6fWjO3AelOfuah8
         tzMcabePOp+b+JK/7SUC2jz/Aiy7Q1pYmoK6zqE1HUNyt/032Cv95nvvWsDWcaBsLMtz
         UGFTAVAKjT1oF0l5ygQL1aChZf+mDX/Z6e7BZ9XzeuijU6sSF8/cXpZJvLDkkhBv1ggH
         oMLcVwZe2wssCnSPt4nfsTM/FrT3HmJI3ALaXkBB2XyPiE0K6QNnlBlZMu8X9hvTYKvV
         oIZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wH2CxJQ0;
       spf=pass (google.com: domain of 35ffsxaykca4uzwrs5u22uzs.q20zw18b-00y9oqy.25u@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35ffSXAYKCA4uzwrs5u22uzs.q20zw18B-00y9oqy.25u@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b68sor7875886otc.167.2019.05.08.08.38.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 08:38:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of 35ffsxaykca4uzwrs5u22uzs.q20zw18b-00y9oqy.25u@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wH2CxJQ0;
       spf=pass (google.com: domain of 35ffsxaykca4uzwrs5u22uzs.q20zw18b-00y9oqy.25u@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35ffSXAYKCA4uzwrs5u22uzs.q20zw18B-00y9oqy.25u@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=T6bgGq2KcJ4pPFly2xX3mqEDKu0BtnCpkaNCQLXnqH4=;
        b=wH2CxJQ0LJBXY1TvGY3OcOpyfwtylgUuk2+9DyjsTA+ma+0tYYjwIBVZuz7/E3XME7
         3piZenwMsFocc9ZSXKEiBVamiIX11Y46IZ4lX1HOfexWkW3t4aQcCoLZfZaQjyYM88fh
         2Hech/znC431NNtHcp60xHhbOh+4yL9JdiES2f5pPtPHkwKcOOhoVLN8hwqY9CWexBhI
         o9s+tpG1bSCDvnqirQ5d9OkbiGSKFnYU1MzrVyacUOkblJAP6ZGhuQy/J0i8vX/of+Er
         BgsmArWRXxZRJ7LhHJZ2U3YTjM9QFdnW0UnrlMZnNqQKywgHwQDpVJ+qh0PC37EF13c7
         adfw==
X-Google-Smtp-Source: APXvYqwR2q6ouUYtuF+R5DXO7FsieffV/w4i42wkW9TNYoHHZPE0YWZDP1jRRK5WG09x2hALr9NWFX8Vpg4=
X-Received: by 2002:a9d:37ca:: with SMTP id x68mr7031896otb.347.1557329893204;
 Wed, 08 May 2019 08:38:13 -0700 (PDT)
Date: Wed,  8 May 2019 17:37:33 +0200
In-Reply-To: <20190508153736.256401-1-glider@google.com>
Message-Id: <20190508153736.256401-2-glider@google.com>
Mime-Version: 1.0
References: <20190508153736.256401-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org, 
	labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org, 
	kernel-hardening@lists.openwall.com, yamada.masahiro@socionext.com, 
	jmorris@namei.org, serge@hallyn.com, ndesaulniers@google.com, kcc@google.com, 
	dvyukov@google.com, sspatil@android.com, rdunlap@infradead.org, 
	jannh@google.com, mark.rutland@arm.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The new options are needed to prevent possible information leaks and
make control-flow bugs that depend on uninitialized values more
deterministic.

init_on_alloc=1 makes the kernel initialize newly allocated pages and heap
objects with zeroes. Initialization is done at allocation time at the
places where checks for __GFP_ZERO are performed.

init_on_free=1 makes the kernel initialize freed pages and heap objects
with zeroes upon their deletion. This helps to ensure sensitive data
doesn't leak via use-after-free accesses.

Both init_on_alloc=1 and init_on_free=1 guarantee that the allocator
returns zeroed memory. The only exception is slab caches with
constructors. Those are never zero-initialized to preserve their semantics.

For SLOB allocator init_on_free=1 also implies init_on_alloc=1 behavior,
i.e. objects are zeroed at both allocation and deallocation time.
This is done because SLOB may otherwise return multiple freelist pointers
in the allocated object. For SLAB and SLUB enabling either init_on_alloc
or init_on_free leads to one-time initialization of the object.

Both init_on_alloc and init_on_free default to zero, but those defaults
can be overridden with CONFIG_INIT_ON_ALLOC_DEFAULT_ON and
CONFIG_INIT_ON_FREE_DEFAULT_ON.

Slowdown for the new features compared to init_on_free=0,
init_on_alloc=0:

hackbench, init_on_free=1:  +7.62% sys time (st.err 0.74%)
hackbench, init_on_alloc=1: +7.75% sys time (st.err 2.14%)

Linux build with -j12, init_on_free=1:  +8.38% wall time (st.err 0.39%)
Linux build with -j12, init_on_free=1:  +24.42% sys time (st.err 0.52%)
Linux build with -j12, init_on_alloc=1: -0.13% wall time (st.err 0.42%)
Linux build with -j12, init_on_alloc=1: +0.57% sys time (st.err 0.40%)

The slowdown for init_on_free=0, init_on_alloc=0 compared to the
baseline is within the standard error.

Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: James Morris <jmorris@namei.org>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Desaulniers <ndesaulniers@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Sandeep Patil <sspatil@android.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Jann Horn <jannh@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com
---
 .../admin-guide/kernel-parameters.txt         |  8 +++
 drivers/infiniband/core/uverbs_ioctl.c        |  2 +-
 include/linux/mm.h                            | 22 +++++++
 kernel/kexec_core.c                           |  2 +-
 mm/dmapool.c                                  |  2 +-
 mm/page_alloc.c                               | 62 +++++++++++++++++--
 mm/slab.c                                     | 16 ++++-
 mm/slab.h                                     | 16 +++++
 mm/slob.c                                     | 22 ++++++-
 mm/slub.c                                     | 27 ++++++--
 net/core/sock.c                               |  2 +-
 security/Kconfig.hardening                    | 16 +++++
 12 files changed, 179 insertions(+), 18 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 2b8ee90bb644..be1b66685784 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1671,6 +1671,14 @@
 
 	initrd=		[BOOT] Specify the location of the initial ramdisk
 
+	init_on_alloc=	[MM] Fill newly allocated pages and heap objects with
+			zeroes.
+			Format: 0 | 1
+			Default set by CONFIG_INIT_ON_ALLOC_DEFAULT_ON.
+	init_on_free=	[MM] Fill freed pages and heap objects with zeroes.
+			Format: 0 | 1
+			Default set by CONFIG_INIT_ON_FREE_DEFAULT_ON.
+
 	init_pkru=	[x86] Specify the default memory protection keys rights
 			register contents for all processes.  0x55555554 by
 			default (disallow access to all but pkey 0).  Can
diff --git a/drivers/infiniband/core/uverbs_ioctl.c b/drivers/infiniband/core/uverbs_ioctl.c
index e1379949e663..c03c92cdd1a2 100644
--- a/drivers/infiniband/core/uverbs_ioctl.c
+++ b/drivers/infiniband/core/uverbs_ioctl.c
@@ -127,7 +127,7 @@ __malloc void *_uverbs_alloc(struct uverbs_attr_bundle *bundle, size_t size,
 	res = (void *)pbundle->internal_buffer + pbundle->internal_used;
 	pbundle->internal_used =
 		ALIGN(new_used, sizeof(*pbundle->internal_buffer));
-	if (flags & __GFP_ZERO)
+	if (want_init_on_alloc(flags))
 		memset(res, 0, size);
 	return res;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b10c21630f5..ee1a1092679c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2610,6 +2610,28 @@ static inline void kernel_poison_pages(struct page *page, int numpages,
 					int enable) { }
 #endif
 
+#ifdef CONFIG_INIT_ON_ALLOC_DEFAULT_ON
+DECLARE_STATIC_KEY_TRUE(init_on_alloc);
+#else
+DECLARE_STATIC_KEY_FALSE(init_on_alloc);
+#endif
+static inline bool want_init_on_alloc(gfp_t flags)
+{
+	if (static_branch_unlikely(&init_on_alloc))
+		return true;
+	return flags & __GFP_ZERO;
+}
+
+#ifdef CONFIG_INIT_ON_FREE_DEFAULT_ON
+DECLARE_STATIC_KEY_TRUE(init_on_free);
+#else
+DECLARE_STATIC_KEY_FALSE(init_on_free);
+#endif
+static inline bool want_init_on_free(void)
+{
+	return static_branch_unlikely(&init_on_free);
+}
+
 #ifdef CONFIG_DEBUG_PAGEALLOC
 extern bool _debug_pagealloc_enabled;
 extern void __kernel_map_pages(struct page *page, int numpages, int enable);
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index d7140447be75..f19d1a91190b 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -315,7 +315,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
 		arch_kexec_post_alloc_pages(page_address(pages), count,
 					    gfp_mask);
 
-		if (gfp_mask & __GFP_ZERO)
+		if (want_init_on_alloc(gfp_mask))
 			for (i = 0; i < count; i++)
 				clear_highpage(pages + i);
 	}
diff --git a/mm/dmapool.c b/mm/dmapool.c
index 76a160083506..493d151067cb 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -381,7 +381,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
 #endif
 	spin_unlock_irqrestore(&pool->lock, flags);
 
-	if (mem_flags & __GFP_ZERO)
+	if (want_init_on_alloc(mem_flags))
 		memset(retval, 0, pool->size);
 
 	return retval;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c02cff1ed56e..d8b5bf9da08a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -133,6 +133,48 @@ unsigned long totalcma_pages __read_mostly;
 
 int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
+#ifdef CONFIG_INIT_ON_ALLOC_DEFAULT_ON
+DEFINE_STATIC_KEY_TRUE(init_on_alloc);
+#else
+DEFINE_STATIC_KEY_FALSE(init_on_alloc);
+#endif
+#ifdef CONFIG_INIT_ON_FREE_DEFAULT_ON
+DEFINE_STATIC_KEY_TRUE(init_on_free);
+#else
+DEFINE_STATIC_KEY_FALSE(init_on_free);
+#endif
+
+static int __init early_init_on_alloc(char *buf)
+{
+	int ret;
+	bool bool_result;
+
+	if (!buf)
+		return -EINVAL;
+	ret = kstrtobool(buf, &bool_result);
+	if (bool_result)
+		static_branch_enable(&init_on_alloc);
+	else
+		static_branch_disable(&init_on_alloc);
+	return ret;
+}
+early_param("init_on_alloc", early_init_on_alloc);
+
+static int __init early_init_on_free(char *buf)
+{
+	int ret;
+	bool bool_result;
+
+	if (!buf)
+		return -EINVAL;
+	ret = kstrtobool(buf, &bool_result);
+	if (bool_result)
+		static_branch_enable(&init_on_free);
+	else
+		static_branch_disable(&init_on_free);
+	return ret;
+}
+early_param("init_on_free", early_init_on_free);
 
 /*
  * A cached value of the page's pageblock's migratetype, used when the page is
@@ -1092,6 +1134,15 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 	return ret;
 }
 
+static void kernel_init_free_pages(struct page *page, int numpages)
+{
+	int i;
+
+	if (want_init_on_free())
+		for (i = 0; i < numpages; i++)
+			clear_highpage(page + i);
+}
+
 static __always_inline bool free_pages_prepare(struct page *page,
 					unsigned int order, bool check_free)
 {
@@ -1144,6 +1195,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	}
 	arch_free_page(page, order);
 	kernel_poison_pages(page, 1 << order, 0);
+	kernel_init_free_pages(page, 1 << order);
 	kernel_map_pages(page, 1 << order, 0);
 	kasan_free_nondeferred_pages(page, order);
 
@@ -1450,8 +1502,10 @@ meminit_pfn_in_nid(unsigned long pfn, int node,
 void __init memblock_free_pages(struct page *page, unsigned long pfn,
 							unsigned int order)
 {
-	if (early_page_uninitialised(pfn))
+	if (early_page_uninitialised(pfn)) {
+		kernel_init_free_pages(page, 1 << order);
 		return;
+	}
 	__free_pages_core(page, order);
 }
 
@@ -1969,8 +2023,8 @@ static inline int check_new_page(struct page *page)
 
 static inline bool free_pages_prezeroed(void)
 {
-	return IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) &&
-		page_poisoning_enabled();
+	return (IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) &&
+		page_poisoning_enabled()) || want_init_on_free();
 }
 
 #ifdef CONFIG_DEBUG_VM
@@ -2027,7 +2081,7 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
 
 	post_alloc_hook(page, order, gfp_flags);
 
-	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
+	if (!free_pages_prezeroed() && want_init_on_alloc(gfp_flags))
 		for (i = 0; i < (1 << order); i++)
 			clear_highpage(page + i);
 
diff --git a/mm/slab.c b/mm/slab.c
index 9142ee992493..fc5b3b81db60 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1891,6 +1891,14 @@ static bool set_objfreelist_slab_cache(struct kmem_cache *cachep,
 
 	cachep->num = 0;
 
+	/*
+	 * If slab auto-initialization on free is enabled, store the freelist
+	 * off-slab, so that its contents don't end up in one of the allocated
+	 * objects.
+	 */
+	if (unlikely(slab_want_init_on_free(cachep)))
+		return false;
+
 	if (cachep->ctor || flags & SLAB_TYPESAFE_BY_RCU)
 		return false;
 
@@ -3330,7 +3338,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
 
-	if (unlikely(flags & __GFP_ZERO) && ptr)
+	if (unlikely(slab_want_init_on_alloc(flags, cachep)) && ptr)
 		memset(ptr, 0, cachep->object_size);
 
 	slab_post_alloc_hook(cachep, flags, 1, &ptr);
@@ -3387,7 +3395,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	prefetchw(objp);
 
-	if (unlikely(flags & __GFP_ZERO) && objp)
+	if (unlikely(slab_want_init_on_alloc(flags, cachep)) && objp)
 		memset(objp, 0, cachep->object_size);
 
 	slab_post_alloc_hook(cachep, flags, 1, &objp);
@@ -3508,6 +3516,8 @@ void ___cache_free(struct kmem_cache *cachep, void *objp,
 	struct array_cache *ac = cpu_cache_get(cachep);
 
 	check_irq_off();
+	if (unlikely(slab_want_init_on_free(cachep)))
+		memset(objp, 0, cachep->object_size);
 	kmemleak_free_recursive(objp, cachep->flags);
 	objp = cache_free_debugcheck(cachep, objp, caller);
 
@@ -3595,7 +3605,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	cache_alloc_debugcheck_after_bulk(s, flags, size, p, _RET_IP_);
 
 	/* Clear memory outside IRQ disabled section */
-	if (unlikely(flags & __GFP_ZERO))
+	if (unlikely(slab_want_init_on_alloc(flags, s)))
 		for (i = 0; i < size; i++)
 			memset(p[i], 0, s->object_size);
 
diff --git a/mm/slab.h b/mm/slab.h
index 43ac818b8592..24ae887359b8 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -524,4 +524,20 @@ static inline int cache_random_seq_create(struct kmem_cache *cachep,
 static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
 #endif /* CONFIG_SLAB_FREELIST_RANDOM */
 
+static inline bool slab_want_init_on_alloc(gfp_t flags, struct kmem_cache *c)
+{
+	if (static_branch_unlikely(&init_on_alloc))
+		return !(c->ctor);
+	else
+		return flags & __GFP_ZERO;
+}
+
+static inline bool slab_want_init_on_free(struct kmem_cache *c)
+{
+	if (static_branch_unlikely(&init_on_free))
+		return !(c->ctor);
+	else
+		return false;
+}
+
 #endif /* MM_SLAB_H */
diff --git a/mm/slob.c b/mm/slob.c
index 307c2c9feb44..351d3dfee000 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -212,6 +212,19 @@ static void slob_free_pages(void *b, int order)
 	free_pages((unsigned long)b, order);
 }
 
+/*
+ * init_on_free=1 also implies initialization at allocation time.
+ * This is because newly allocated objects may contain freelist pointers
+ * somewhere in the middle.
+ */
+static inline bool slob_want_init_on_alloc(gfp_t flags, struct kmem_cache *c)
+{
+	if (static_branch_unlikely(&init_on_alloc) ||
+	    static_branch_unlikely(&init_on_free))
+		return c ? (!c->ctor) : true;
+	return flags & __GFP_ZERO;
+}
+
 /*
  * Allocate a slob block within a given slob_page sp.
  */
@@ -330,8 +343,6 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		BUG_ON(!b);
 		spin_unlock_irqrestore(&slob_lock, flags);
 	}
-	if (unlikely(gfp & __GFP_ZERO))
-		memset(b, 0, size);
 	return b;
 }
 
@@ -366,6 +377,9 @@ static void slob_free(void *block, int size)
 		return;
 	}
 
+	if (unlikely(want_init_on_free()))
+		memset(block, 0, size);
+
 	if (!slob_page_free(sp)) {
 		/* This slob page is about to become partially free. Easy! */
 		sp->units = units;
@@ -461,6 +475,8 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 	}
 
 	kmemleak_alloc(ret, size, 1, gfp);
+	if (unlikely(slob_want_init_on_alloc(gfp, 0)))
+		memset(ret, 0, size);
 	return ret;
 }
 
@@ -559,6 +575,8 @@ static void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 		WARN_ON_ONCE(flags & __GFP_ZERO);
 		c->ctor(b);
 	}
+	if (unlikely(slob_want_init_on_alloc(flags, c)))
+		memset(b, 0, c->size);
 
 	kmemleak_alloc_recursive(b, c->size, 1, c->flags, flags);
 	return b;
diff --git a/mm/slub.c b/mm/slub.c
index d30ede89f4a6..cc091424c593 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1432,6 +1432,19 @@ static __always_inline bool slab_free_hook(struct kmem_cache *s, void *x)
 static inline bool slab_free_freelist_hook(struct kmem_cache *s,
 					   void **head, void **tail)
 {
+
+	void *object;
+	void *next = *head;
+	void *old_tail = *tail ? *tail : *head;
+
+	if (slab_want_init_on_free(s))
+		do {
+			object = next;
+			next = get_freepointer(s, object);
+			memset(object, 0, s->size);
+			set_freepointer(s, object, next);
+		} while (object != old_tail);
+
 /*
  * Compiler cannot detect this function can be removed if slab_free_hook()
  * evaluates to nothing.  Thus, catch all relevant config debug options here.
@@ -1441,9 +1454,7 @@ static inline bool slab_free_freelist_hook(struct kmem_cache *s,
 	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
 	defined(CONFIG_KASAN)
 
-	void *object;
-	void *next = *head;
-	void *old_tail = *tail ? *tail : *head;
+	next = *head;
 
 	/* Head and tail of the reconstructed freelist */
 	*head = NULL;
@@ -2749,8 +2760,14 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 		prefetch_freepointer(s, next_object);
 		stat(s, ALLOC_FASTPATH);
 	}
+	/*
+	 * If the object has been wiped upon free, make sure it's fully
+	 * initialized by zeroing out freelist pointer.
+	 */
+	if (slab_want_init_on_free(s))
+		*(void **)object = 0;
 
-	if (unlikely(gfpflags & __GFP_ZERO) && object)
+	if (unlikely(slab_want_init_on_alloc(gfpflags, s)) && object)
 		memset(object, 0, s->object_size);
 
 	slab_post_alloc_hook(s, gfpflags, 1, &object);
@@ -3172,7 +3189,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	local_irq_enable();
 
 	/* Clear memory outside IRQ disabled fastpath loop */
-	if (unlikely(flags & __GFP_ZERO)) {
+	if (unlikely(slab_want_init_on_alloc(flags, s))) {
 		int j;
 
 		for (j = 0; j < i; j++)
diff --git a/net/core/sock.c b/net/core/sock.c
index 067878a1e4c5..bd03e3a52f9d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1601,7 +1601,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		sk = kmem_cache_alloc(slab, priority & ~__GFP_ZERO);
 		if (!sk)
 			return sk;
-		if (priority & __GFP_ZERO)
+		if (want_init_on_alloc(priority))
 			sk_prot_clear_nulls(sk, prot->obj_size);
 	} else
 		sk = kmalloc(prot->obj_size, priority);
diff --git a/security/Kconfig.hardening b/security/Kconfig.hardening
index 0a1d4ca314f4..4a4001f5ad25 100644
--- a/security/Kconfig.hardening
+++ b/security/Kconfig.hardening
@@ -159,6 +159,22 @@ config STACKLEAK_RUNTIME_DISABLE
 	  runtime to control kernel stack erasing for kernels built with
 	  CONFIG_GCC_PLUGIN_STACKLEAK.
 
+config INIT_ON_ALLOC_DEFAULT_ON
+	bool "Set init_on_alloc=1 by default"
+	default false
+	help
+	  Enable init_on_alloc=1 by default, making the kernel initialize every
+	  page and heap allocation with zeroes.
+	  init_on_alloc can be overridden via command line.
+
+config INIT_ON_FREE_DEFAULT_ON
+	bool "Set init_on_free=1 by default"
+	default false
+	help
+	  Enable init_on_free=1 by default, making the kernel initialize freed
+	  pages and slab memory with zeroes.
+	  init_on_free can be overridden via command line.
+
 endmenu
 
 endmenu
-- 
2.21.0.1020.gf2820cf01a-goog

