Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38C9BC10F14
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 12:45:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D13112084D
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 12:45:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sgPD7ga0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D13112084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AD226B0010; Fri, 12 Apr 2019 08:45:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45CD96B026A; Fri, 12 Apr 2019 08:45:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 372A96B026B; Fri, 12 Apr 2019 08:45:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0A76B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:45:09 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id w69so1930261vsc.9
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 05:45:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=83wHpmEoWmTPnFwY0l59Y0OXpUaa/f0svyU4uSEFOdQ=;
        b=Nmnn404+K2Ca62rRlMaQNn8Ra6YD9GaqEBv8AKU3USSXywvbCUlloioNfZ5iF7pzEc
         4fITXtsywyNm/wzrrxClW3N9zK3e2E68RKnAacOqz954Nud9BeEXPVGKJ06MLFyvgLPr
         xeo1Un3DzMWsrmp8gxgtLXI8Xfx662O8OJmtrcEZ9a7TDuC0YoW53bqbM/cZD4fd9X/l
         uu4XgRQV3YHHWcqXjQe5CvKqibObjboRAaZ/aWEIDTkwHtIutG55KhtOydILdteTHKI9
         jSEDFTq41yewyg2etdWh1IyJskwAaU3f5SKGpo45BGI1fEXKtUQ+m8A9FlTWp/rn9x4Z
         gZEg==
X-Gm-Message-State: APjAAAV4/toeEg4pC4kWmsqF/eMZPpY/G+jAhVMjS/1zWPvX2A4amQ2W
	EffGhRoimfw7ChMYodSHtoi3aM7vV+PRpisfsNo3l4cdUMTW13ukW/Ur1SxhAazZAL0wZpjo9Zk
	2LRJkJa3lw0VrK4a2n7SJSU7WDFFwhM0VDpCunzDOSRP2KuC7STtLt5MV8HlQlANKwQ==
X-Received: by 2002:a05:6102:d9:: with SMTP id u25mr31819209vsp.162.1555073108605;
        Fri, 12 Apr 2019 05:45:08 -0700 (PDT)
X-Received: by 2002:a05:6102:d9:: with SMTP id u25mr31819167vsp.162.1555073107390;
        Fri, 12 Apr 2019 05:45:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555073107; cv=none;
        d=google.com; s=arc-20160816;
        b=PMSn5q/VxqsshvRPcscT0r20WukqyIPQaeDJNLs7P5hXKucpqpHMsO87Bq5E6Aa2Hf
         8HXaH+ZsYLiGaJpADNdl7/zFFqsi15TH+MnIRHxtqAwaq2AOsoYqk1xThlUIWMt2i8gB
         NAyG7vX+PDI/McmLUZ86b+/7K+Ul3XXddlfvYespnT4a+A01vjQ45hy3DITbl+LMjQEU
         uKlNUS7OHYVcGLEwY0wVHsD0ZDQY79ZZJbKhZ0ZhM0oWeW/H8J8X1l2fJYkiMlFAM2rs
         RE53nUf+1XNyrsCcECJYHNGPHZ/0uoV4tsYS4vMalfoPROKvOVgHLZ3++Ixh9Ij2GhKK
         Jlow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=83wHpmEoWmTPnFwY0l59Y0OXpUaa/f0svyU4uSEFOdQ=;
        b=ZUIkeL2g2yszlwhDPtHhgyPgkQqjQXC47PPfQSAbIa0ixVCouaxbGQb4nyAfaHUezK
         Fz5B1L6Z6lcPrJtX6dK2bQZhPjeHHh2X0MCPgsiQAGuV48IoLi56nb3cdbXElf4ZdPDQ
         qB3ndLHxVbEqM+9T8KGrNQY1ZZAt73i8HHv5dpdcZYos8qzaSCo5f4XRnBK2DS3CQr0B
         vXi6uoJMNL0UNjAeNyiSCT1QEPXJGoXP1znN3MA7uuzqiy1fbkvCx8W2ekNEVWbnSNq1
         fDfBy3HQGhqr8YC2RW5FJpZF2xFTXgvbcXFPKzNppcE8ECOKRuMHevbpbYGEXTS0wMmo
         whpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sgPD7ga0;
       spf=pass (google.com: domain of 3uoiwxaykcbex2zuv8x55x2v.t532z4be-331crt1.58x@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3UoiwXAYKCBEx2zuv8x55x2v.t532z4BE-331Crt1.58x@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w21sor25483555vse.34.2019.04.12.05.45.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 05:45:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3uoiwxaykcbex2zuv8x55x2v.t532z4be-331crt1.58x@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sgPD7ga0;
       spf=pass (google.com: domain of 3uoiwxaykcbex2zuv8x55x2v.t532z4be-331crt1.58x@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3UoiwXAYKCBEx2zuv8x55x2v.t532z4BE-331Crt1.58x@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=83wHpmEoWmTPnFwY0l59Y0OXpUaa/f0svyU4uSEFOdQ=;
        b=sgPD7ga0/28KiS/8Rq6wWxAEcHkcRJ+G0I7U0LiWpYOjovshcYh4pPEh9LALIVANns
         jjDkAGka9UDbyxtNlW7U5BawFs/G+hP9eB00oHAzfDKTDPN+7vMLf94WN4L4OYC3jN06
         Mpi5yAlNu3Gb8kvMilZBgL+P4632zyJqMDSv+XdSOpnFMwWlKaHQx/4/sdanybS+E5l0
         oibiJgdX/NLQCM8wmXshVlLiWNu3QGfvqddUC2owrn8eZ5tcKXyEqDecml+nlHlc7Dlj
         l13faHoaFXUVHen3AGiCFhTAV3MjMY3FEn7BCu2KlQIodUHJfA53Fr27ZG+dscjJI3SG
         JmQA==
X-Google-Smtp-Source: APXvYqwd8NXWmS7nTqXo/l4ZCq9qsGa703/O8iSSu0SZwOGOevq4EFMZR9NzupdZfMeKeu5JNDAXXVuS0yk=
X-Received: by 2002:a67:e295:: with SMTP id g21mr6550492vsf.24.1555073106933;
 Fri, 12 Apr 2019 05:45:06 -0700 (PDT)
Date: Fri, 12 Apr 2019 14:45:01 +0200
Message-Id: <20190412124501.132678-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, 
	ndesaulniers@google.com, kcc@google.com, dvyukov@google.com, 
	keescook@chromium.org, sspatil@android.com, labbott@redhat.com, 
	kernel-hardening@lists.openwall.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This config option adds the possibility to initialize newly allocated
pages and heap objects with zeroes. This is needed to prevent possible
information leaks and make the control-flow bugs that depend on
uninitialized values more deterministic.

Initialization is done at allocation time at the places where checks for
__GFP_ZERO are performed. We don't initialize slab caches with
constructors or SLAB_TYPESAFE_BY_RCU to preserve their semantics.

For kernel testing purposes filling allocations with a nonzero pattern
would be more suitable, but may require platform-specific code. To have
a simple baseline we've decided to start with zero-initialization.

No performance optimizations are done at the moment to reduce double
initialization of memory regions.

Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
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
This patch applies on top of the "Refactor memory initialization
hardening" patch series by Kees Cook: https://lkml.org/lkml/2019/4/10/748
---
 drivers/infiniband/core/uverbs_ioctl.c |  2 +-
 include/linux/gfp.h                    |  8 ++++++++
 kernel/kexec_core.c                    |  2 +-
 mm/dmapool.c                           |  2 +-
 mm/page_alloc.c                        |  2 +-
 mm/slab.c                              |  6 +++---
 mm/slab.h                              | 10 ++++++++++
 mm/slob.c                              |  2 +-
 mm/slub.c                              |  4 ++--
 net/core/sock.c                        |  2 +-
 security/Kconfig.hardening             | 10 ++++++++++
 11 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/core/uverbs_ioctl.c b/drivers/infiniband/core/uverbs_ioctl.c
index e1379949e663..34937cecac62 100644
--- a/drivers/infiniband/core/uverbs_ioctl.c
+++ b/drivers/infiniband/core/uverbs_ioctl.c
@@ -127,7 +127,7 @@ __malloc void *_uverbs_alloc(struct uverbs_attr_bundle *bundle, size_t size,
 	res = (void *)pbundle->internal_buffer + pbundle->internal_used;
 	pbundle->internal_used =
 		ALIGN(new_used, sizeof(*pbundle->internal_buffer));
-	if (flags & __GFP_ZERO)
+	if (GFP_WANT_INIT(flags))
 		memset(res, 0, size);
 	return res;
 }
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fdab7de7490d..4f49a6a13f6f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -213,6 +213,14 @@ struct vm_area_struct;
 #define __GFP_COMP	((__force gfp_t)___GFP_COMP)
 #define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)
 
+#ifdef CONFIG_INIT_HEAP_ALL
+#define GFP_WANT_INIT(flags) (1)
+#define GFP_INIT_ALWAYS_ON (1)
+#else
+#define GFP_WANT_INIT(flags) (unlikely((flags) & __GFP_ZERO))
+#define GFP_INIT_ALWAYS_ON (0)
+#endif
+
 /* Disable lockdep for GFP context tracking */
 #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
 
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index d7140447be75..1ad0097695a1 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -315,7 +315,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
 		arch_kexec_post_alloc_pages(page_address(pages), count,
 					    gfp_mask);
 
-		if (gfp_mask & __GFP_ZERO)
+		if (GFP_WANT_INIT(gfp_mask))
 			for (i = 0; i < count; i++)
 				clear_highpage(pages + i);
 	}
diff --git a/mm/dmapool.c b/mm/dmapool.c
index 76a160083506..d40d62145ca3 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -381,7 +381,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
 #endif
 	spin_unlock_irqrestore(&pool->lock, flags);
 
-	if (mem_flags & __GFP_ZERO)
+	if (GFP_WANT_INIT(mem_flags))
 		memset(retval, 0, pool->size);
 
 	return retval;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d96ca5bc555b..ceddc4eeaff4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2014,7 +2014,7 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
 
 	post_alloc_hook(page, order, gfp_flags);
 
-	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
+	if (!free_pages_prezeroed() && GFP_WANT_INIT(gfp_flags))
 		for (i = 0; i < (1 << order); i++)
 			clear_highpage(page + i);
 
diff --git a/mm/slab.c b/mm/slab.c
index 47a380a486ee..848e47658667 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3331,7 +3331,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
 
-	if (unlikely(flags & __GFP_ZERO) && ptr)
+	if (SLAB_WANT_INIT(cachep, flags) && ptr)
 		memset(ptr, 0, cachep->object_size);
 
 	slab_post_alloc_hook(cachep, flags, 1, &ptr);
@@ -3388,7 +3388,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	prefetchw(objp);
 
-	if (unlikely(flags & __GFP_ZERO) && objp)
+	if (SLAB_WANT_INIT(cachep, flags) && objp)
 		memset(objp, 0, cachep->object_size);
 
 	slab_post_alloc_hook(cachep, flags, 1, &objp);
@@ -3596,7 +3596,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	cache_alloc_debugcheck_after_bulk(s, flags, size, p, _RET_IP_);
 
 	/* Clear memory outside IRQ disabled section */
-	if (unlikely(flags & __GFP_ZERO))
+	if (SLAB_WANT_INIT(s, flags))
 		for (i = 0; i < size; i++)
 			memset(p[i], 0, s->object_size);
 
diff --git a/mm/slab.h b/mm/slab.h
index 43ac818b8592..4bb10af0031b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -167,6 +167,16 @@ static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
 			      SLAB_TEMPORARY | \
 			      SLAB_ACCOUNT)
 
+/*
+ * Do we need to initialize this allocation?
+ * Always true for __GFP_ZERO, CONFIG_INIT_HEAP_ALL enforces initialization
+ * of caches without constructors and RCU.
+ */
+#define SLAB_WANT_INIT(cache, gfp_flags) \
+	((GFP_INIT_ALWAYS_ON && !(cache)->ctor && \
+	  !((cache)->flags & SLAB_TYPESAFE_BY_RCU)) || \
+	 (gfp_flags & __GFP_ZERO))
+
 bool __kmem_cache_empty(struct kmem_cache *);
 int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
diff --git a/mm/slob.c b/mm/slob.c
index 307c2c9feb44..0c402e819cf7 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -330,7 +330,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		BUG_ON(!b);
 		spin_unlock_irqrestore(&slob_lock, flags);
 	}
-	if (unlikely(gfp & __GFP_ZERO))
+	if (GFP_WANT_INIT(gfp))
 		memset(b, 0, size);
 	return b;
 }
diff --git a/mm/slub.c b/mm/slub.c
index d30ede89f4a6..686ab9d49ced 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2750,7 +2750,7 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 		stat(s, ALLOC_FASTPATH);
 	}
 
-	if (unlikely(gfpflags & __GFP_ZERO) && object)
+	if (SLAB_WANT_INIT(s, gfpflags) && object)
 		memset(object, 0, s->object_size);
 
 	slab_post_alloc_hook(s, gfpflags, 1, &object);
@@ -3172,7 +3172,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	local_irq_enable();
 
 	/* Clear memory outside IRQ disabled fastpath loop */
-	if (unlikely(flags & __GFP_ZERO)) {
+	if (SLAB_WANT_INIT(s, flags)) {
 		int j;
 
 		for (j = 0; j < i; j++)
diff --git a/net/core/sock.c b/net/core/sock.c
index 782343bb925b..51b13d7fd82f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1601,7 +1601,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		sk = kmem_cache_alloc(slab, priority & ~__GFP_ZERO);
 		if (!sk)
 			return sk;
-		if (priority & __GFP_ZERO)
+		if (GFP_WANT_INIT(priority))
 			sk_prot_clear_nulls(sk, prot->obj_size);
 	} else
 		sk = kmalloc(prot->obj_size, priority);
diff --git a/security/Kconfig.hardening b/security/Kconfig.hardening
index d744e20140b4..cb7d7dfb506f 100644
--- a/security/Kconfig.hardening
+++ b/security/Kconfig.hardening
@@ -93,6 +93,16 @@ choice
 
 endchoice
 
+config INIT_HEAP_ALL
+	bool "Initialize kernel heap allocations"
+	default n
+	help
+	  Enforce initialization of pages allocated from page allocator
+	  and objects returned by kmalloc and friends.
+	  Allocated memory is initialized with zeroes, preventing possible
+	  information leaks and making the control-flow bugs that depend
+	  on uninitialized values more deterministic.
+
 config GCC_PLUGIN_STRUCTLEAK_VERBOSE
 	bool "Report forcefully initialized variables"
 	depends on GCC_PLUGIN_STRUCTLEAK
-- 
2.21.0.392.gf8f6787159e-goog

