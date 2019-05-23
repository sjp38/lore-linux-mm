Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B07EC46460
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:42:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B791921019
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:42:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WChDJcTZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B791921019
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B9C26B0006; Thu, 23 May 2019 08:42:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6438B6B0007; Thu, 23 May 2019 08:42:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BF766B0008; Thu, 23 May 2019 08:42:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2363B6B0006
	for <linux-mm@kvack.org>; Thu, 23 May 2019 08:42:33 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l37so5192132qtc.8
        for <linux-mm@kvack.org>; Thu, 23 May 2019 05:42:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=zZVC/4k73iNfGOK0eskSt0mbdzi7I7K1yUBw5U05vrg=;
        b=EpsCHle7F6HzdzPlfDeqvoZW8W+Ued4j0WHjGbZ2+lBBSxEjxj1teiXz2vMuJA2gJu
         xnxkAkcxdvZvQLPQaBJhvrm7VB6xDYRyEqMMw+m/T/hUIOkP7156HXJXqwRciEg0twgl
         j4RPV5X/l1NhoQ3Z1wa2pI6CpulpP1+82sthwTlcADn3Z5clAbKv0JkfXDOvcfNii7X7
         5ZmQ5N5rHzvUv/7yjmwx2urnlUt4F3QM2qXgE2RrFLGfKOk7l/xOkIGo7IaAhKC4V2ut
         Qzu2gtEvd1pmEdLTRwWyD4I+kyRBp03WqerCShMXnxNVFJ9dUq0AowOugugveCXGAexo
         UA3Q==
X-Gm-Message-State: APjAAAU/79aBpR5muZ4zscLVNzjmSqjSzCZYqgea0g5qklLEBVDTfMKW
	FK0pw+Bh//VzuMJAGfmMiCi2lGlFEFc1zdOcYJsmn78lqGsdTffNYa7ctNtf6iO0Wj4sQwkG1mI
	s7/Uw5UAI/vKYopoToFbWHTTdXpZk5INTJVAG4k975HjpdaCgVSVMxU6dfFBWGugU4Q==
X-Received: by 2002:aed:2a25:: with SMTP id c34mr81700857qtd.62.1558615352826;
        Thu, 23 May 2019 05:42:32 -0700 (PDT)
X-Received: by 2002:aed:2a25:: with SMTP id c34mr81700775qtd.62.1558615351746;
        Thu, 23 May 2019 05:42:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558615351; cv=none;
        d=google.com; s=arc-20160816;
        b=FPFXAzHJxYWeSDnYEFF0M+E0Kf6dXhPQIGrJa6vO0P6TzH8PZ6mg9MBtcDyDu/cqu6
         ywijaN4k4A/sUpV8YtbZwr/xKJO6AZTiIu2Ujm2YsLuv3t6s+YTpr2TJVSjvFdcUfiuJ
         H1RdLSe37BcT8LvPJF3S+JXwaT2XwP7DSqmRZTASb+I0pqz5eVgyEdaS1iBU59uikskL
         Zt/N07b68ww99kgXbckNPkoNpPHRQs5r4o2Iv/j7Ocr2/3AbAS+lEDehVw/AR+H0CafQ
         K85Cg/3dYrPkLHBiFeuTXioAju4EJaq3cNF7kiWOZaACkWqLa0nQXyVv+nT+dYcDBO68
         v55w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=zZVC/4k73iNfGOK0eskSt0mbdzi7I7K1yUBw5U05vrg=;
        b=nAgNM34TRqBko1Bs453N0dwDLHmLqhDCxzVOhjJlMR2koEqutlPjlpP/uw0aRTE6wN
         RgWb7ALZAuSI2S+5Hb2oxBSq+WOoVgWxluM7t3fmAQleSy3QxN+sitHwzobk65atmncT
         RNSXpMjtNiSRmzGA09PKiyvJ2eFjt8oSXEEznF5gsBkPVh1KGZlUvOD2ZvlVk7Bxh09X
         pfo6k4DKD7HfvmyKM+2CJvyfbKX3C7tRmIEdrGIcjtF4vfGam14sdayL05lDiE0CfdeV
         /ZrWJoTUpQdF1DVDFSFuDnSN9Q9whLOYOg5wisxdDNyyhYpyRGbeH6K44GKNsq+TYhIm
         EXsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WChDJcTZ;
       spf=pass (google.com: domain of 3n5xmxaykcogqvsnobqyyqvo.mywvsxeh-wwufkmu.ybq@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3N5XmXAYKCOgQVSNObQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w3sor7783006qtj.41.2019.05.23.05.42.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 05:42:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3n5xmxaykcogqvsnobqyyqvo.mywvsxeh-wwufkmu.ybq@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WChDJcTZ;
       spf=pass (google.com: domain of 3n5xmxaykcogqvsnobqyyqvo.mywvsxeh-wwufkmu.ybq@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3N5XmXAYKCOgQVSNObQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=zZVC/4k73iNfGOK0eskSt0mbdzi7I7K1yUBw5U05vrg=;
        b=WChDJcTZORO+XxYcC+WHCJMGDoAOZjJ7+JFNXSO30DPSdAgnED/1KuRUVEk15yU83c
         S+SsXffR2WeFvCI7gH9XbT3+DDhb/oRwzIdB7JWTii74mKveVsdtb/HzAGcpb/TVHiD1
         NV0JRKYs1lGI9KOF9toLWSp1tKsFf07Zv9Ta9byP7Qqzj4yvoRTFDB8YTnxN6RShvz5w
         AupM8c+0TO+z+DaJvLbRgU7wYVd9rGJbeX/V/+1d3cBBinW5gIMURf24/a7Sd0PUJviV
         zJgycbneliwoRTXHLEgN2Ujr8qsAloZTK2o/Hn4OZHoqsxA6jYStsw0//QIC4W0XYUYF
         09Fg==
X-Google-Smtp-Source: APXvYqzZdKkEEMPp4TTIbPbUoXPUj9ZL1RAfC1aAJDEPWuw4SNFtmMDnIdSlaOfdJUm4TDf7SfAEIoia+mw=
X-Received: by 2002:ac8:2418:: with SMTP id c24mr39788983qtc.37.1558615351325;
 Thu, 23 May 2019 05:42:31 -0700 (PDT)
Date: Thu, 23 May 2019 14:42:14 +0200
In-Reply-To: <20190523124216.40208-1-glider@google.com>
Message-Id: <20190523124216.40208-2-glider@google.com>
Mime-Version: 1.0
References: <20190523124216.40208-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v3 1/3] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org
Cc: kernel-hardening@lists.openwall.com, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Hocko <mhocko@kernel.org>, 
	James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>
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

The new features are also going to pave the way for hardware memory
tagging (e.g. arm64's MTE), which will require both on_alloc and on_free
hooks to set the tags for heap objects. With MTE, tagging will have the
same cost as memory initialization.

Although init_on_free is rather costly, there are paranoid use-cases where
in-memory data lifetime is desired to be minimized. There are various
arguments for/against the realism of the associated threat models, but
given that we'll need the infrastructre for MTE anyway, and there are
people who want wipe-on-free behavior no matter what the performance cost,
it seems reasonable to include it in this series.

Signed-off-by: Alexander Potapenko <glider@google.com>
To: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Lameter <cl@linux.com>
To: Kees Cook <keescook@chromium.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: James Morris <jmorris@namei.org>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Desaulniers <ndesaulniers@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Sandeep Patil <sspatil@android.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Jann Horn <jannh@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com
---
 v2:
  - unconditionally initialize pages in kernel_init_free_pages()
  - comment from Randy Dunlap: drop 'default false' lines from Kconfig.hardening
 v3:
  - don't call kernel_init_free_pages() from memblock_free_pages()
  - adopted some Kees' comments for the patch description
---
 .../admin-guide/kernel-parameters.txt         |  8 +++
 drivers/infiniband/core/uverbs_ioctl.c        |  2 +-
 include/linux/mm.h                            | 22 +++++++
 kernel/kexec_core.c                           |  2 +-
 mm/dmapool.c                                  |  2 +-
 mm/page_alloc.c                               | 63 ++++++++++++++++---
 mm/slab.c                                     | 16 ++++-
 mm/slab.h                                     | 16 +++++
 mm/slob.c                                     | 22 ++++++-
 mm/slub.c                                     | 27 ++++++--
 net/core/sock.c                               |  2 +-
 security/Kconfig.hardening                    | 14 +++++
 12 files changed, 175 insertions(+), 21 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 52e6fbb042cc..68fb6fa41cc1 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1673,6 +1673,14 @@
 
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
index 829b0c6944d8..61758201d9b2 100644
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
index 0e8834ac32b7..7733a341c0c4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2685,6 +2685,28 @@ static inline void kernel_poison_pages(struct page *page, int numpages,
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
 extern bool _debug_pagealloc_enabled;
 
 static inline bool debug_pagealloc_enabled(void)
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index fd5c95ff9251..2f75dd0d0d81 100644
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
index 3b13d3914176..14ded6620aa0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -135,6 +135,48 @@ unsigned long totalcma_pages __read_mostly;
 
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
@@ -1089,6 +1131,14 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 	return ret;
 }
 
+static void kernel_init_free_pages(struct page *page, int numpages)
+{
+	int i;
+
+	for (i = 0; i < numpages; i++)
+		clear_highpage(page + i);
+}
+
 static __always_inline bool free_pages_prepare(struct page *page,
 					unsigned int order, bool check_free)
 {
@@ -1141,6 +1191,8 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	}
 	arch_free_page(page, order);
 	kernel_poison_pages(page, 1 << order, 0);
+	if (want_init_on_free())
+		kernel_init_free_pages(page, 1 << order);
 	if (debug_pagealloc_enabled())
 		kernel_map_pages(page, 1 << order, 0);
 
@@ -2019,8 +2071,8 @@ static inline int check_new_page(struct page *page)
 
 static inline bool free_pages_prezeroed(void)
 {
-	return IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) &&
-		page_poisoning_enabled();
+	return (IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) &&
+		page_poisoning_enabled()) || want_init_on_free();
 }
 
 #ifdef CONFIG_DEBUG_VM
@@ -2074,13 +2126,10 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 							unsigned int alloc_flags)
 {
-	int i;
-
 	post_alloc_hook(page, order, gfp_flags);
 
-	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
-		for (i = 0; i < (1 << order); i++)
-			clear_highpage(page + i);
+	if (!free_pages_prezeroed() && want_init_on_alloc(gfp_flags))
+		kernel_init_free_pages(page, 1 << order);
 
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
diff --git a/mm/slab.c b/mm/slab.c
index 2915d912e89a..d42eb11f8f50 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1853,6 +1853,14 @@ static bool set_objfreelist_slab_cache(struct kmem_cache *cachep,
 
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
 
@@ -3293,7 +3301,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
 
-	if (unlikely(flags & __GFP_ZERO) && ptr)
+	if (unlikely(slab_want_init_on_alloc(flags, cachep)) && ptr)
 		memset(ptr, 0, cachep->object_size);
 
 	slab_post_alloc_hook(cachep, flags, 1, &ptr);
@@ -3350,7 +3358,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	prefetchw(objp);
 
-	if (unlikely(flags & __GFP_ZERO) && objp)
+	if (unlikely(slab_want_init_on_alloc(flags, cachep)) && objp)
 		memset(objp, 0, cachep->object_size);
 
 	slab_post_alloc_hook(cachep, flags, 1, &objp);
@@ -3471,6 +3479,8 @@ void ___cache_free(struct kmem_cache *cachep, void *objp,
 	struct array_cache *ac = cpu_cache_get(cachep);
 
 	check_irq_off();
+	if (unlikely(slab_want_init_on_free(cachep)))
+		memset(objp, 0, cachep->object_size);
 	kmemleak_free_recursive(objp, cachep->flags);
 	objp = cache_free_debugcheck(cachep, objp, caller);
 
@@ -3558,7 +3568,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
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
index 84aefd9b91ee..1b565ee7f479 100644
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
  * slob_page_alloc() - Allocate a slob block within a given slob_page sp.
  * @sp: Page to look in.
@@ -353,8 +366,6 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		BUG_ON(!b);
 		spin_unlock_irqrestore(&slob_lock, flags);
 	}
-	if (unlikely(gfp & __GFP_ZERO))
-		memset(b, 0, size);
 	return b;
 }
 
@@ -389,6 +400,9 @@ static void slob_free(void *block, int size)
 		return;
 	}
 
+	if (unlikely(want_init_on_free()))
+		memset(block, 0, size);
+
 	if (!slob_page_free(sp)) {
 		/* This slob page is about to become partially free. Easy! */
 		sp->units = units;
@@ -484,6 +498,8 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 	}
 
 	kmemleak_alloc(ret, size, 1, gfp);
+	if (unlikely(slob_want_init_on_alloc(gfp, 0)))
+		memset(ret, 0, size);
 	return ret;
 }
 
@@ -582,6 +598,8 @@ static void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 		WARN_ON_ONCE(flags & __GFP_ZERO);
 		c->ctor(b);
 	}
+	if (unlikely(slob_want_init_on_alloc(flags, c)))
+		memset(b, 0, c->size);
 
 	kmemleak_alloc_recursive(b, c->size, 1, c->flags, flags);
 	return b;
diff --git a/mm/slub.c b/mm/slub.c
index cd04dbd2b5d0..5fcb3f71cf84 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1424,6 +1424,19 @@ static __always_inline bool slab_free_hook(struct kmem_cache *s, void *x)
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
@@ -1433,9 +1446,7 @@ static inline bool slab_free_freelist_hook(struct kmem_cache *s,
 	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
 	defined(CONFIG_KASAN)
 
-	void *object;
-	void *next = *head;
-	void *old_tail = *tail ? *tail : *head;
+	next = *head;
 
 	/* Head and tail of the reconstructed freelist */
 	*head = NULL;
@@ -2741,8 +2752,14 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
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
@@ -3163,7 +3180,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	local_irq_enable();
 
 	/* Clear memory outside IRQ disabled fastpath loop */
-	if (unlikely(flags & __GFP_ZERO)) {
+	if (unlikely(slab_want_init_on_alloc(flags, s))) {
 		int j;
 
 		for (j = 0; j < i; j++)
diff --git a/net/core/sock.c b/net/core/sock.c
index 75b1c950b49f..9ceb90c875bc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1602,7 +1602,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		sk = kmem_cache_alloc(slab, priority & ~__GFP_ZERO);
 		if (!sk)
 			return sk;
-		if (priority & __GFP_ZERO)
+		if (want_init_on_alloc(priority))
 			sk_prot_clear_nulls(sk, prot->obj_size);
 	} else
 		sk = kmalloc(prot->obj_size, priority);
diff --git a/security/Kconfig.hardening b/security/Kconfig.hardening
index 0a1d4ca314f4..87883e3e3c2a 100644
--- a/security/Kconfig.hardening
+++ b/security/Kconfig.hardening
@@ -159,6 +159,20 @@ config STACKLEAK_RUNTIME_DISABLE
 	  runtime to control kernel stack erasing for kernels built with
 	  CONFIG_GCC_PLUGIN_STACKLEAK.
 
+config INIT_ON_ALLOC_DEFAULT_ON
+	bool "Set init_on_alloc=1 by default"
+	help
+	  Enable init_on_alloc=1 by default, making the kernel initialize every
+	  page and heap allocation with zeroes.
+	  init_on_alloc can be overridden via command line.
+
+config INIT_ON_FREE_DEFAULT_ON
+	bool "Set init_on_free=1 by default"
+	help
+	  Enable init_on_free=1 by default, making the kernel initialize freed
+	  pages and slab memory with zeroes.
+	  init_on_free can be overridden via command line.
+
 endmenu
 
 endmenu
-- 
2.21.0.1020.gf2820cf01a-goog

