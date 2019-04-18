Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F6FAC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:42:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B69612183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:42:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ruHCFZTf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B69612183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69E3A6B000A; Thu, 18 Apr 2019 11:42:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 658326B000C; Thu, 18 Apr 2019 11:42:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53DB26B000D; Thu, 18 Apr 2019 11:42:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D41D6B000A
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:42:37 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e31so2402342qtb.0
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:42:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=M9VDOWzYn6nXrWz02ZAfm+oG12axOPQ9eunlREvBT5g=;
        b=iR206QDmkWrr/3v+EyRsHSpZ/QdiTNZZsBbcvgnXuufa6TTm/kjQHBpNPs8RfyF7KP
         hr7Gh3YNJCiyptHMMbGufgkE2Z/xQxb85zRz6G0YBD/vRHDERMZgoSKmO6fLd1mcpBby
         LKqn4xZSVoEekXZLdt6K3typDLiLI2DJzuTrmtRqwDWac0H2BDj5dRc9FFFkHvaWZn5U
         J7xJVcOV/+DriVimKWHoycMSg2WqxdJNMpRF0/c7azJwpEwD5pSwGuhNAAWrMIqfvPIR
         KScofKNMB3XXZ4GN7xnKvSKQLTreIpCpPoShQEchwtXjIb9X+aqT9W4Ts1GPXIg2gPlK
         f3Mg==
X-Gm-Message-State: APjAAAWlpscWnDTiDQV1oA2ZHeLEdzlGTxCkAdCuKbIDwm3hJ4qgsetC
	QaBNZwF6R2J1YAOCOmX9kgr6iCbUsAKxB/nZyLfFxUwQ8lXvMBFNgkfirSzvoMzwvAKoQvCE3Uh
	U7Ky1pzijbATwatRr3a8F34JpDetKIk9F+aLce6BqwyOTUVnzS2fgRes2Tz3VsWM7uQ==
X-Received: by 2002:ac8:3821:: with SMTP id q30mr73063096qtb.73.1555602156856;
        Thu, 18 Apr 2019 08:42:36 -0700 (PDT)
X-Received: by 2002:ac8:3821:: with SMTP id q30mr73063030qtb.73.1555602155944;
        Thu, 18 Apr 2019 08:42:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602155; cv=none;
        d=google.com; s=arc-20160816;
        b=a467k0rLUqRrPehAHg6HQKMQcfMyB5g1yaPY+gBWDUGkOCAkwsUGtvTZQ/pSpFq2mw
         hiZP7Xu/4Gucjk5Tl3go9Mpof0dVDmy/V9a0qIRcayf91wa0Kc3fKEkfRtv9AXYoToBJ
         MPDb8/s/oGHXgSMqjW/lFecXqIrcSSZjLj7rvPffc31H5maqzv6bxlajxgXSsvRIcGPG
         xxqDfvh3hTsFLQ0TqrtG1+rSWG+yp/2wnIzmSMgB/IvdjiAS/GANLwvHPKybDgPTWW5A
         r25H8X3BCxWwPxLnUnpFggSwfefwoIIxGBDy07fXjgukN19Osuqqo+aqGUixO7kQEBCE
         /tgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=M9VDOWzYn6nXrWz02ZAfm+oG12axOPQ9eunlREvBT5g=;
        b=DarS4W7R03/vU35Aj+unJUtLdb5dM2dVMNHObx8v8iqz42zmhUajaZT3prEG0cPbYx
         YhPjSwYuExkhg1T/8BW6kYNoSZAY5edov/nio1PTzq2KbYxuOKkhJxHVxQToEDX827Fv
         aBPYexmDHDqB1Ci1tsXpzRLF8dfCr6jssR78E+VOmjF+ObmI+ph91oNOZeIEr7a/oTZA
         +2yxgpTBBoxSqTu8x4HAwjSorTdIlhV9Ww2p2HmJ509Ac0wYzZhjq2DFG0YBhqT25QHM
         nZ8EVzIeujh+vLBLeeKa12tLkVoMWML65VLLA+vhYbRieRhRo51nM0M06/RW+JLbOHA3
         X9wA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ruHCFZTf;
       spf=pass (google.com: domain of 365q4xaykco4wbytuhweewbu.secbydkn-ccalqsa.ehw@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=365q4XAYKCO4WbYTUhWeeWbU.SecbYdkn-ccalQSa.ehW@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g15sor2085907qve.22.2019.04.18.08.42.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 08:42:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of 365q4xaykco4wbytuhweewbu.secbydkn-ccalqsa.ehw@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ruHCFZTf;
       spf=pass (google.com: domain of 365q4xaykco4wbytuhweewbu.secbydkn-ccalqsa.ehw@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=365q4XAYKCO4WbYTUhWeeWbU.SecbYdkn-ccalQSa.ehW@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=M9VDOWzYn6nXrWz02ZAfm+oG12axOPQ9eunlREvBT5g=;
        b=ruHCFZTfTPR7oJ0Q5gBHGMu4QYXz2jROHunlJBX6a9drH/Sem3dfobkW5bOPT8FC91
         PbePih1PzsH47kTmoKLiWVDPuTWQ5hxHdYb1v+NA81Jh3zIjR0ryxKrPaxxZxoybQSMF
         6evD1/aGfv3F1rkDrjl+6HIJe9mEfvCypDjpC4108XA1+/IP5R8WGDrFhCn7O3PhsMFK
         emWsI1sxTUKuUZyHA49ncvdSuwwFsxZ+Eq/eu3pqRs1MSYmE6dLTS/LYiTK+Hz/FO+9w
         WrfOa4C14q1ZratFGNrl8gBCbYzB0EPrGDIuGdvdk5tm6jyJ0BvqzhCy3mS8ifOQeNo3
         KvEQ==
X-Google-Smtp-Source: APXvYqxCR/g/qmygXOlG5JedEBKs3Cvl/p3zxixLLIJ6SAf3CKB+orRGA7efImjMaMxC2TICPuF3/VUlaYc=
X-Received: by 2002:a0c:86cd:: with SMTP id 13mr76282193qvg.146.1555602155603;
 Thu, 18 Apr 2019 08:42:35 -0700 (PDT)
Date: Thu, 18 Apr 2019 17:42:06 +0200
In-Reply-To: <20190418154208.131118-1-glider@google.com>
Message-Id: <20190418154208.131118-2-glider@google.com>
Mime-Version: 1.0
References: <20190418154208.131118-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [PATCH 1/3] mm: security: introduce the init_allocations=1 boot option
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, dvyukov@google.com, 
	keescook@chromium.org, labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org, 
	kernel-hardening@lists.openwall.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This option adds the possibility to initialize newly allocated pages and
heap objects with zeroes. This is needed to prevent possible information
leaks and make the control-flow bugs that depend on uninitialized values
more deterministic.

Initialization is done at allocation time at the places where checks for
__GFP_ZERO are performed. We don't initialize slab caches with
constructors to preserve their semantics. To reduce runtime costs of
checking cachep->ctor we replace a call to memset with a call to
cachep->poison_fn, which is only executed if the memory block needs to
be initialized.

For kernel testing purposes filling allocations with a nonzero pattern
would be more suitable, but may require platform-specific code. To have
a simple baseline we've decided to start with zero-initialization.

No performance optimizations are done at the moment to reduce double
initialization of memory regions.

Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
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
Cc: Qian Cai <cai@lca.pw>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com
---
 drivers/infiniband/core/uverbs_ioctl.c |  2 +-
 include/linux/mm.h                     |  8 ++++++++
 include/linux/slab_def.h               |  1 +
 include/linux/slub_def.h               |  1 +
 kernel/kexec_core.c                    |  2 +-
 mm/dmapool.c                           |  2 +-
 mm/page_alloc.c                        | 18 +++++++++++++++++-
 mm/slab.c                              | 12 ++++++------
 mm/slab.h                              |  1 +
 mm/slab_common.c                       | 15 +++++++++++++++
 mm/slob.c                              |  2 +-
 mm/slub.c                              |  8 ++++----
 net/core/sock.c                        |  2 +-
 13 files changed, 58 insertions(+), 16 deletions(-)

diff --git a/drivers/infiniband/core/uverbs_ioctl.c b/drivers/infiniband/core/uverbs_ioctl.c
index e1379949e663..f31234906be2 100644
--- a/drivers/infiniband/core/uverbs_ioctl.c
+++ b/drivers/infiniband/core/uverbs_ioctl.c
@@ -127,7 +127,7 @@ __malloc void *_uverbs_alloc(struct uverbs_attr_bundle *bundle, size_t size,
 	res = (void *)pbundle->internal_buffer + pbundle->internal_used;
 	pbundle->internal_used =
 		ALIGN(new_used, sizeof(*pbundle->internal_buffer));
-	if (flags & __GFP_ZERO)
+	if (want_init_memory(flags))
 		memset(res, 0, size);
 	return res;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76769749b5a5..b38b71a5efaa 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2597,6 +2597,14 @@ static inline void kernel_poison_pages(struct page *page, int numpages,
 					int enable) { }
 #endif
 
+DECLARE_STATIC_KEY_FALSE(init_allocations);
+static inline bool want_init_memory(gfp_t flags)
+{
+	if (static_branch_unlikely(&init_allocations))
+		return true;
+	return flags & __GFP_ZERO;
+}
+
 #ifdef CONFIG_DEBUG_PAGEALLOC
 extern bool _debug_pagealloc_enabled;
 extern void __kernel_map_pages(struct page *page, int numpages, int enable);
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 9a5eafb7145b..9dfe9eb639d7 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -37,6 +37,7 @@ struct kmem_cache {
 
 	/* constructor func */
 	void (*ctor)(void *obj);
+	void (*poison_fn)(struct kmem_cache *c, void *object);
 
 /* 4) cache creation/removal */
 	const char *name;
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d2153789bd9f..afb928cb7c20 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -99,6 +99,7 @@ struct kmem_cache {
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
+	void (*poison_fn)(struct kmem_cache *c, void *object);
 	unsigned int inuse;		/* Offset to metadata */
 	unsigned int align;		/* Alignment */
 	unsigned int red_left_pad;	/* Left redzone padding size */
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index d7140447be75..be84f5f95c97 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -315,7 +315,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
 		arch_kexec_post_alloc_pages(page_address(pages), count,
 					    gfp_mask);
 
-		if (gfp_mask & __GFP_ZERO)
+		if (want_init_memory(gfp_mask))
 			for (i = 0; i < count; i++)
 				clear_highpage(pages + i);
 	}
diff --git a/mm/dmapool.c b/mm/dmapool.c
index 76a160083506..796e38160d39 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -381,7 +381,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
 #endif
 	spin_unlock_irqrestore(&pool->lock, flags);
 
-	if (mem_flags & __GFP_ZERO)
+	if (want_init_memory(mem_flags))
 		memset(retval, 0, pool->size);
 
 	return retval;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d96ca5bc555b..e2a21d866ac9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -133,6 +133,22 @@ unsigned long totalcma_pages __read_mostly;
 
 int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
+bool want_init_allocations __read_mostly;
+EXPORT_SYMBOL(want_init_allocations);
+DEFINE_STATIC_KEY_FALSE(init_allocations);
+
+static int __init early_init_allocations(char *buf)
+{
+	int ret;
+
+	if (!buf)
+		return -EINVAL;
+	ret = kstrtobool(buf, &want_init_allocations);
+	if (want_init_allocations)
+		static_branch_enable(&init_allocations);
+	return ret;
+}
+early_param("init_allocations", early_init_allocations);
 
 /*
  * A cached value of the page's pageblock's migratetype, used when the page is
@@ -2014,7 +2030,7 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
 
 	post_alloc_hook(page, order, gfp_flags);
 
-	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
+	if (!free_pages_prezeroed() && want_init_memory(gfp_flags))
 		for (i = 0; i < (1 << order); i++)
 			clear_highpage(page + i);
 
diff --git a/mm/slab.c b/mm/slab.c
index 47a380a486ee..dcc5b73cf767 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3331,8 +3331,8 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
 
-	if (unlikely(flags & __GFP_ZERO) && ptr)
-		memset(ptr, 0, cachep->object_size);
+	if (unlikely(want_init_memory(flags)) && ptr)
+		cachep->poison_fn(cachep, ptr);
 
 	slab_post_alloc_hook(cachep, flags, 1, &ptr);
 	return ptr;
@@ -3388,8 +3388,8 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	prefetchw(objp);
 
-	if (unlikely(flags & __GFP_ZERO) && objp)
-		memset(objp, 0, cachep->object_size);
+	if (unlikely(want_init_memory(flags)) && objp)
+		cachep->poison_fn(cachep, objp);
 
 	slab_post_alloc_hook(cachep, flags, 1, &objp);
 	return objp;
@@ -3596,9 +3596,9 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	cache_alloc_debugcheck_after_bulk(s, flags, size, p, _RET_IP_);
 
 	/* Clear memory outside IRQ disabled section */
-	if (unlikely(flags & __GFP_ZERO))
+	if (unlikely(want_init_memory(flags)))
 		for (i = 0; i < size; i++)
-			memset(p[i], 0, s->object_size);
+			s->poison_fn(s, p[i]);
 
 	slab_post_alloc_hook(s, flags, size, p);
 	/* FIXME: Trace call missing. Christoph would like a bulk variant */
diff --git a/mm/slab.h b/mm/slab.h
index 43ac818b8592..3b541e8970ee 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -27,6 +27,7 @@ struct kmem_cache {
 	const char *name;	/* Slab name for sysfs */
 	int refcount;		/* Use counter */
 	void (*ctor)(void *);	/* Called on object slot creation */
+	void (*poison_fn)(struct kmem_cache *c, void *object);
 	struct list_head list;	/* List of all slab caches on the system */
 };
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..37810114b2ea 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -360,6 +360,16 @@ struct kmem_cache *find_mergeable(unsigned int size, unsigned int align,
 	return NULL;
 }
 
+static void poison_zero(struct kmem_cache *c, void *object)
+{
+	memset(object, 0, c->object_size);
+}
+
+static void poison_dont(struct kmem_cache *c, void *object)
+{
+	/* Do nothing. Use for caches with constructors. */
+}
+
 static struct kmem_cache *create_cache(const char *name,
 		unsigned int object_size, unsigned int align,
 		slab_flags_t flags, unsigned int useroffset,
@@ -381,6 +391,10 @@ static struct kmem_cache *create_cache(const char *name,
 	s->size = s->object_size = object_size;
 	s->align = align;
 	s->ctor = ctor;
+	if (ctor)
+		s->poison_fn = poison_dont;
+	else
+		s->poison_fn = poison_zero;
 	s->useroffset = useroffset;
 	s->usersize = usersize;
 
@@ -974,6 +988,7 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name,
 	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
 	s->useroffset = useroffset;
 	s->usersize = usersize;
+	s->poison_fn = poison_zero;
 
 	slab_init_memcg_params(s);
 
diff --git a/mm/slob.c b/mm/slob.c
index 307c2c9feb44..18981a71e962 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -330,7 +330,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		BUG_ON(!b);
 		spin_unlock_irqrestore(&slob_lock, flags);
 	}
-	if (unlikely(gfp & __GFP_ZERO))
+	if (unlikely(want_init_memory(gfp)))
 		memset(b, 0, size);
 	return b;
 }
diff --git a/mm/slub.c b/mm/slub.c
index d30ede89f4a6..e4efb6575510 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2750,8 +2750,8 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 		stat(s, ALLOC_FASTPATH);
 	}
 
-	if (unlikely(gfpflags & __GFP_ZERO) && object)
-		memset(object, 0, s->object_size);
+	if (unlikely(want_init_memory(gfpflags)) && object)
+		s->poison_fn(s, object);
 
 	slab_post_alloc_hook(s, gfpflags, 1, &object);
 
@@ -3172,11 +3172,11 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	local_irq_enable();
 
 	/* Clear memory outside IRQ disabled fastpath loop */
-	if (unlikely(flags & __GFP_ZERO)) {
+	if (unlikely(want_init_memory(flags))) {
 		int j;
 
 		for (j = 0; j < i; j++)
-			memset(p[j], 0, s->object_size);
+			s->poison_fn(s, p[j]);
 	}
 
 	/* memcg and kmem_cache debug support */
diff --git a/net/core/sock.c b/net/core/sock.c
index 782343bb925b..99b288a19b39 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1601,7 +1601,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		sk = kmem_cache_alloc(slab, priority & ~__GFP_ZERO);
 		if (!sk)
 			return sk;
-		if (priority & __GFP_ZERO)
+		if (want_init_memory(priority))
 			sk_prot_clear_nulls(sk, prot->obj_size);
 	} else
 		sk = kmalloc(prot->obj_size, priority);
-- 
2.21.0.392.gf8f6787159e-goog

