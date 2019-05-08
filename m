Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72E7BC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:38:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 286FC21530
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:38:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vPEylMZX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 286FC21530
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A990B6B02C1; Wed,  8 May 2019 11:38:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4C786B02C2; Wed,  8 May 2019 11:38:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93B416B02C3; Wed,  8 May 2019 11:38:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75D966B02C1
	for <linux-mm@kvack.org>; Wed,  8 May 2019 11:38:23 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n39so23568703qtn.0
        for <linux-mm@kvack.org>; Wed, 08 May 2019 08:38:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=lo76tEV8/5tTBkkO8xlJz/8lajq8uCmmdOMOd2IZBb4=;
        b=tbftP7YalyeQGUxOu2hj2QZbKwd4NhJP25861rBgto+91ZujJVQHpQQTWxZRpX9KEc
         CxXLAbOMrfjgEG00+ANUjjotG638srzgE4Q4QweP0uyRcLjHWLyNFyiB/vrhScYISd1k
         s4iMWEnC4ndvLERz1q7VkLkJ3ZEViTekD/JvjKoujnTTFC/pZ3Fl7jR9tuxwJJ29ZCjS
         sxIAsaeQOe7vly5cEDkpSekPwyINL7/Hn2Zttcr9LTxgK0XfV4syQN3GSUybx85IaXMx
         ve3vNPSHTshtUQiwBskfFBzXLI0xgZwz1+Mb1mbxOe6yu6wDFaeOV9TC9HglkH3AX/eX
         4Pqg==
X-Gm-Message-State: APjAAAUZr5uDQfuAtfAhA5BhnVQnBj/yXb+tgqNEi22CL5sheWv0zcDA
	3dryDzaAkir+szpgWw6b6yvUT9GjjaD+Sqz9sm44SoTputi8PkVN5n1BJnFo47u6PxGKA7iMwcs
	Kc1WP8bd/WGU/hp2JmyRZFI17X4k/uxBJhU5wbZrHZ+Vab5zNHvavUbXDkjkaoo2dUw==
X-Received: by 2002:ae9:f203:: with SMTP id m3mr11373282qkg.317.1557329903235;
        Wed, 08 May 2019 08:38:23 -0700 (PDT)
X-Received: by 2002:ae9:f203:: with SMTP id m3mr11373240qkg.317.1557329902416;
        Wed, 08 May 2019 08:38:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557329902; cv=none;
        d=google.com; s=arc-20160816;
        b=bgCfsoe8AjZSuj4wA/HEHAkALdTATDMqUJ+gQmHPpyg9PovsP4RXuy+/s7oY04xKoR
         aGvw3l+9IAe8T7IyuxNC9P+iw5vmLSQKJT5lA+mxH3jO1nGLhCHPqggQItd0FgEV0Z82
         TFbn3tKMKm1TwFIIWHYa4YnGEIEtOoTblQ4ra4CrpqkUHxhycqmff0pJd27sYDnIckZM
         PpIWi7KOJg3UPSqJd+IfFOyzU28G4sNMdlJzNcVros6ikxAD9PsDDGUHpn72T6pGFIh9
         2nBoiazrKC8PI1qnsVDf/qDBw1Ftx/GeB8yWDX2jD/K/DzxJQlCDbQ73j4qrGA5Y5N3F
         6pZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=lo76tEV8/5tTBkkO8xlJz/8lajq8uCmmdOMOd2IZBb4=;
        b=vKgkcNZLabmgZSEP9G5bluoVzWtrqlIGKfm05DlRoXqp0yEVbzZiYa/Iu1d72sisXb
         2Q7BMiBdTMKwDBIp0hEc8ro7Ars+ZiUu4cssvVbaIL0wTBWOokPi9FmMdNHoX5S17yC2
         icKmMSd3/nDxUXlQmkFZMW5JSTIp3EPOQhiJBsGOV3dLYMYzoA2d5pUaVmESSUsM2Qux
         9ftCVZbtXXXDEhlIXCCJLFHDjIzvAsLLfQahMwGfDG5TLI2DmR3z8v2bnaVKnq79ZGDe
         Df9T6zLTXfl0M9zESbhz5CxcXGthlmsbRcrUsdS6RxQgFApSmrQjyiXHqdJVLbsx+L/N
         +sIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vPEylMZX;
       spf=pass (google.com: domain of 37vfsxaykcbc38501e3bb381.zb985ahk-997ixz7.be3@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=37vfSXAYKCBc38501E3BB381.zB985AHK-997Ixz7.BE3@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c3sor14254091qvt.9.2019.05.08.08.38.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 08:38:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of 37vfsxaykcbc38501e3bb381.zb985ahk-997ixz7.be3@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vPEylMZX;
       spf=pass (google.com: domain of 37vfsxaykcbc38501e3bb381.zb985ahk-997ixz7.be3@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=37vfSXAYKCBc38501E3BB381.zB985AHK-997Ixz7.BE3@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=lo76tEV8/5tTBkkO8xlJz/8lajq8uCmmdOMOd2IZBb4=;
        b=vPEylMZXayPSZVpEaDJqWP9qm/OESynGMJRRV2MuSsH86lVqB1H02b/PiTIS+flJKP
         t6u5nGh7WqlGTmmiuLu9CAqTVfSYiEM6CS7PMQr8LiNxQWqIygR1z3f1vzfHvunG8MfG
         Nl+u+93U4iGK/9xuTGGr+SHMh4RT1GIIASx9sNQyJpVm3j1i3Pg4YdJN9WEBHKx81UNM
         y0n9VztOlXCZo0Mo0bd5i8gmrFPjvvepY5C/rjxdAqKOJ8m1Iw72t3OCjEbfehy4tigT
         H8V9L5vu7Y47nOBAZQpVNjPcmDubUS/YkZvy3vwto5ROsdazyfci1dI+FRklG39i5/QI
         U8zQ==
X-Google-Smtp-Source: APXvYqwNgpwHjUPfZi1Dbb0SZ7eXYtog/czzOSLoWn+D6mOOwqHmlQYuA0cyyWtpdJ//wXF2GWIvL/IEdeo=
X-Received: by 2002:a0c:c3d0:: with SMTP id p16mr31293733qvi.229.1557329902083;
 Wed, 08 May 2019 08:38:22 -0700 (PDT)
Date: Wed,  8 May 2019 17:37:35 +0200
In-Reply-To: <20190508153736.256401-1-glider@google.com>
Message-Id: <20190508153736.256401-4-glider@google.com>
Mime-Version: 1.0
References: <20190508153736.256401-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH 3/4] gfp: mm: introduce __GFP_NOINIT
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

When passed to an allocator (either pagealloc or SL[AOU]B), __GFP_NOINIT
tells it to not initialize the requested memory if the init_on_alloc
boot option is enabled. This can be useful in the cases newly allocated
memory is going to be initialized by the caller right away.

__GFP_NOINIT doesn't affect init_on_free behavior, except for SLOB,
where init_on_free implies init_on_alloc.

__GFP_NOINIT basically defeats the hardening against information leaks
provided by init_on_alloc, so one should use it with caution.

This patch also adds __GFP_NOINIT to alloc_pages() calls in SL[AOU]B.
Doing so is safe, because the heap allocators initialize the pages they
receive before passing memory to the callers.

Slowdown for the initialization features compared to init_on_free=0,
init_on_alloc=0:

hackbench, init_on_free=1:  +6.84% sys time (st.err 0.74%)
hackbench, init_on_alloc=1: +7.25% sys time (st.err 0.72%)

Linux build with -j12, init_on_free=1:  +8.52% wall time (st.err 0.42%)
Linux build with -j12, init_on_free=1:  +24.31% sys time (st.err 0.47%)
Linux build with -j12, init_on_alloc=1: -0.16% wall time (st.err 0.40%)
Linux build with -j12, init_on_alloc=1: +1.24% sys time (st.err 0.39%)

The slowdown for init_on_free=0, init_on_alloc=0 compared to the
baseline is within the standard error.

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
 include/linux/gfp.h | 6 +++++-
 include/linux/mm.h  | 2 +-
 kernel/kexec_core.c | 2 +-
 mm/slab.c           | 2 +-
 mm/slob.c           | 3 ++-
 mm/slub.c           | 1 +
 6 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fdab7de7490d..66d7f5604fe2 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -44,6 +44,7 @@ struct vm_area_struct;
 #else
 #define ___GFP_NOLOCKDEP	0
 #endif
+#define ___GFP_NOINIT		0x1000000u
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
@@ -208,16 +209,19 @@ struct vm_area_struct;
  * %__GFP_COMP address compound page metadata.
  *
  * %__GFP_ZERO returns a zeroed page on success.
+ *
+ * %__GFP_NOINIT requests non-initialized memory from the underlying allocator.
  */
 #define __GFP_NOWARN	((__force gfp_t)___GFP_NOWARN)
 #define __GFP_COMP	((__force gfp_t)___GFP_COMP)
 #define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)
+#define __GFP_NOINIT	((__force gfp_t)___GFP_NOINIT)
 
 /* Disable lockdep for GFP context tracking */
 #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
 
 /* Room for N __GFP_FOO bits */
-#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
+#define __GFP_BITS_SHIFT (25)
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /**
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ee1a1092679c..8ab152750eb4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2618,7 +2618,7 @@ DECLARE_STATIC_KEY_FALSE(init_on_alloc);
 static inline bool want_init_on_alloc(gfp_t flags)
 {
 	if (static_branch_unlikely(&init_on_alloc))
-		return true;
+		return !(flags & __GFP_NOINIT);
 	return flags & __GFP_ZERO;
 }
 
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index f19d1a91190b..e8ed6e3c6702 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -302,7 +302,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
 {
 	struct page *pages;
 
-	pages = alloc_pages(gfp_mask & ~__GFP_ZERO, order);
+	pages = alloc_pages((gfp_mask & ~__GFP_ZERO) | __GFP_NOINIT, order);
 	if (pages) {
 		unsigned int count, i;
 
diff --git a/mm/slab.c b/mm/slab.c
index fc5b3b81db60..f18739559825 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1393,7 +1393,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	struct page *page;
 	int nr_pages;
 
-	flags |= cachep->allocflags;
+	flags |= (cachep->allocflags | __GFP_NOINIT);
 
 	page = __alloc_pages_node(nodeid, flags, cachep->gfporder);
 	if (!page) {
diff --git a/mm/slob.c b/mm/slob.c
index 351d3dfee000..5b3c40dbd3f2 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -192,6 +192,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 {
 	void *page;
 
+	gfp |= __GFP_NOINIT;
 #ifdef CONFIG_NUMA
 	if (node != NUMA_NO_NODE)
 		page = __alloc_pages_node(node, gfp, order);
@@ -221,7 +222,7 @@ static inline bool slob_want_init_on_alloc(gfp_t flags, struct kmem_cache *c)
 {
 	if (static_branch_unlikely(&init_on_alloc) ||
 	    static_branch_unlikely(&init_on_free))
-		return c ? (!c->ctor) : true;
+		return c ? (!c->ctor) : !(flags & __GFP_NOINIT);
 	return flags & __GFP_ZERO;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index cc091424c593..8b61d244fdb4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1504,6 +1504,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	struct page *page;
 	unsigned int order = oo_order(oo);
 
+	flags |= __GFP_NOINIT;
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
 	else
-- 
2.21.0.1020.gf2820cf01a-goog

