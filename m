Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E14B2C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:36:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C0142085A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:36:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HnfouE+v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C0142085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C72E6B0007; Tue, 14 May 2019 10:36:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 376DC6B0008; Tue, 14 May 2019 10:36:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28D326B000A; Tue, 14 May 2019 10:36:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 006A46B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:36:09 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id c64so6134186oia.22
        for <linux-mm@kvack.org>; Tue, 14 May 2019 07:36:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=lbdUPdHa+bdM+dxU1m+K2QEpeUH2T4hzEiJEzMD7K4o=;
        b=RzRxsobignDBenEYLYPzI2BQlwTR3fehbIOUQUXZJDakQQ+ju0412bu4DOQHH2wR+2
         0B998cF/7CTELUiXAVKJo35zqpWxV3JeXXBAAIiD+z8UJqhuOUuEPuxvLp8KvMGyKQuX
         hPjWuCWy9bTHrH7eBIba0Uleu9VCFrRQrokq839ujh+JEk2XAZO8AbB9Jy6xXeJhs1hE
         XCIM97KIP370dvz8dImsUAf0oGA3nedeKv6aw0qaTSelzw4Ej4aKa9qQ70c6a0j2G+ZQ
         vHIoXDz65GBTHo844tBweDW+6MHxEsUG3mcZymV8O+CjAdm++5wVuZz1Dk4vQjWBwBfr
         xH+g==
X-Gm-Message-State: APjAAAXdxOqz8jAnTLDHaX6zzLw8/IAN716c1ICNhusJokW+QFyQownS
	FOf0Wn4ivjDwgzZBwUnVTgDiOqefPFqsLEMeUCRFAStDZ6cnS7sDEwh2VWKFJJRlNewLkfzZ/4h
	WS5Y1too2hqxeEO/6/Js6AtwJ1Gc6svNhF4/+FVyzq7gQKSFLpzh5Jv1U+ewpZqJSLA==
X-Received: by 2002:a9d:4047:: with SMTP id o7mr8645530oti.231.1557844568469;
        Tue, 14 May 2019 07:36:08 -0700 (PDT)
X-Received: by 2002:a9d:4047:: with SMTP id o7mr8645474oti.231.1557844567635;
        Tue, 14 May 2019 07:36:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557844567; cv=none;
        d=google.com; s=arc-20160816;
        b=NxCjHxWTLXMAqan5J7lAU+9+o5P1c/jWFSURNdHbH7vYzUu4qTRZFODXw+urzKi0fA
         g6Qfj46e7XL6lMzYfn0VgfDsdJ5whAi5JwEY3wQTSeIX44S1WyJeiTizQhNYsY608AKU
         Lc5ea6z6YKiKwKZC/VYFDGpvftCSgCY7TOij5nN3LL241Rl8SJG/VSujK6bbzAsNHnTI
         JCGICLAx+YaJ8HZArGRGNftIfYP/h+dFrrDPEesI8zKNAnT0eyYhB6KZEg+AUgSN2Ulm
         0lFnzpJAEy5wJ+NXD5bkNBBJJRJeeEZRBb4NJ9YNaSRBTHwK/0tuniWmPaA+uJeAzKVJ
         Y4qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=lbdUPdHa+bdM+dxU1m+K2QEpeUH2T4hzEiJEzMD7K4o=;
        b=ipZvRmsyacmOEuCO/86MlEYzC47XlxwDC9qG4poctRcoDgBsczbvZzvLjarYhofI5i
         h+PDUrbMJ42ZB/gEMHQQNaL/t0R3QevLLxpoTyDEXVRpV6mADykSp5GbyjVnGDcjnRoz
         nnA+1/INYuEZzv2bJ3qK24oibSrzTnn2ooorT0AQi5LOs68s0P2et3eCocZvwX8DGzSi
         kyjBfzP7nGfpp54/XlqPKVsknSAJzshPYMiuAe4YHU9Ma8n/6ewwWplqGw0IdvVDFWOX
         MWCAvWlruuXzcPDS9kV6HtNitvkDA4DN/GPQ5YcVQ4xszVi5MoZqB7rp1t8oMdSE6RGK
         4sRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HnfouE+v;
       spf=pass (google.com: domain of 3v9laxaykcfq274z0d2aa270.ya8749gj-886hwy6.ad2@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3V9LaXAYKCFQ274z0D2AA270.yA8749GJ-886Hwy6.AD2@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p186sor2012276oig.128.2019.05.14.07.36.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 07:36:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3v9laxaykcfq274z0d2aa270.ya8749gj-886hwy6.ad2@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HnfouE+v;
       spf=pass (google.com: domain of 3v9laxaykcfq274z0d2aa270.ya8749gj-886hwy6.ad2@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3V9LaXAYKCFQ274z0D2AA270.yA8749GJ-886Hwy6.AD2@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=lbdUPdHa+bdM+dxU1m+K2QEpeUH2T4hzEiJEzMD7K4o=;
        b=HnfouE+vVHCSk/BQWNA2IoM8dz0DlJb1ySFeCJDuDts8JvsGv0c3ABDhxeZs5R1jQ5
         fL3ARiq3DAbXqQTqJfJuZH+qPM0Rlxs+eQXmzqAwtxAnJNYEaSrvHiNcxGnelj3HmfgX
         SSeCx+dAjpm4EnYIiFU/I55GSIaka0an9xHoe2esmSu0PB5SH7by0fAzZu2mm0Mixvs1
         WAgEPqulx2gTZH/2wtpBrBL+/yGwJvgPaaOhPEwkgOBXuSvFAk/GEC3w+P2hNj9dN06E
         3f5VELZcrJ00AMfyT4YjpAwlQDk+F+t0Pa9AiePOGat0x6TjdKPGnk4TKNYrnaALiQhA
         jI1g==
X-Google-Smtp-Source: APXvYqzwuuntM7HozbX9bxO0OlitRtQOtjK1eJ98Ru/9/M+wLdZyTT23D/aLqfOSqP4W7vywT6UYFvkqKIU=
X-Received: by 2002:aca:5f84:: with SMTP id t126mr3137888oib.18.1557844567217;
 Tue, 14 May 2019 07:36:07 -0700 (PDT)
Date: Tue, 14 May 2019 16:35:36 +0200
In-Reply-To: <20190514143537.10435-1-glider@google.com>
Message-Id: <20190514143537.10435-4-glider@google.com>
Mime-Version: 1.0
References: <20190514143537.10435-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v2 3/4] gfp: mm: introduce __GFP_NO_AUTOINIT
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org
Cc: kernel-hardening@lists.openwall.com, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When passed to an allocator (either pagealloc or SL[AOU]B),
__GFP_NO_AUTOINIT tells it to not initialize the requested memory if the
init_on_alloc boot option is enabled. This can be useful in the cases
newly allocated memory is going to be initialized by the caller right
away.

__GFP_NO_AUTOINIT doesn't affect init_on_free behavior, except for SLOB,
where init_on_free implies init_on_alloc.

__GFP_NO_AUTOINIT basically defeats the hardening against information
leaks provided by init_on_alloc, so one should use it with caution.

This patch also adds __GFP_NO_AUTOINIT to alloc_pages() calls in SL[AOU]B.
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
To: Andrew Morton <akpm@linux-foundation.org>
To: Kees Cook <keescook@chromium.org>
To: Christoph Lameter <cl@linux.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
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
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com
---
 v2:
  - renamed __GFP_NOINIT to __GFP_NO_AUTOINIT, updated patch
    name/description
---
 include/linux/gfp.h | 13 +++++++++----
 include/linux/mm.h  |  2 +-
 kernel/kexec_core.c |  3 ++-
 mm/slab.c           |  2 +-
 mm/slob.c           |  3 ++-
 mm/slub.c           |  1 +
 6 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fdab7de7490d..e1a83bd0ca67 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -44,6 +44,7 @@ struct vm_area_struct;
 #else
 #define ___GFP_NOLOCKDEP	0
 #endif
+#define ___GFP_NO_AUTOINIT	0x1000000u
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
@@ -208,16 +209,20 @@ struct vm_area_struct;
  * %__GFP_COMP address compound page metadata.
  *
  * %__GFP_ZERO returns a zeroed page on success.
+ *
+ * %__GFP_NO_AUTOINIT requests non-initialized memory from the underlying
+ * allocator.
  */
-#define __GFP_NOWARN	((__force gfp_t)___GFP_NOWARN)
-#define __GFP_COMP	((__force gfp_t)___GFP_COMP)
-#define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)
+#define __GFP_NOWARN		((__force gfp_t)___GFP_NOWARN)
+#define __GFP_COMP		((__force gfp_t)___GFP_COMP)
+#define __GFP_ZERO		((__force gfp_t)___GFP_ZERO)
+#define __GFP_NO_AUTOINIT	((__force gfp_t)___GFP_NO_AUTOINIT)
 
 /* Disable lockdep for GFP context tracking */
 #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
 
 /* Room for N __GFP_FOO bits */
-#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
+#define __GFP_BITS_SHIFT (25)
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /**
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 18d96f1d07c5..ce6c63396002 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2618,7 +2618,7 @@ DECLARE_STATIC_KEY_FALSE(init_on_alloc);
 static inline bool want_init_on_alloc(gfp_t flags)
 {
 	if (static_branch_unlikely(&init_on_alloc))
-		return true;
+		return !(flags & __GFP_NO_AUTOINIT);
 	return flags & __GFP_ZERO;
 }
 
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 2f75dd0d0d81..7fc37bacac79 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -302,7 +302,8 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
 {
 	struct page *pages;
 
-	pages = alloc_pages(gfp_mask & ~__GFP_ZERO, order);
+	pages = alloc_pages((gfp_mask & ~__GFP_ZERO) | __GFP_NO_AUTOINIT,
+			    order);
 	if (pages) {
 		unsigned int count, i;
 
diff --git a/mm/slab.c b/mm/slab.c
index d00e9de26a45..1089461fc22b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1393,7 +1393,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	struct page *page;
 	int nr_pages;
 
-	flags |= cachep->allocflags;
+	flags |= (cachep->allocflags | __GFP_NO_AUTOINIT);
 
 	page = __alloc_pages_node(nodeid, flags, cachep->gfporder);
 	if (!page) {
diff --git a/mm/slob.c b/mm/slob.c
index 351d3dfee000..d505f36aa398 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -192,6 +192,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 {
 	void *page;
 
+	gfp |= __GFP_NO_AUTOINIT;
 #ifdef CONFIG_NUMA
 	if (node != NUMA_NO_NODE)
 		page = __alloc_pages_node(node, gfp, order);
@@ -221,7 +222,7 @@ static inline bool slob_want_init_on_alloc(gfp_t flags, struct kmem_cache *c)
 {
 	if (static_branch_unlikely(&init_on_alloc) ||
 	    static_branch_unlikely(&init_on_free))
-		return c ? (!c->ctor) : true;
+		return c ? (!c->ctor) : !(flags & __GFP_NO_AUTOINIT);
 	return flags & __GFP_ZERO;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 01424e910800..0aa306f5769a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1495,6 +1495,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	struct page *page;
 	unsigned int order = oo_order(oo);
 
+	flags |= __GFP_NO_AUTOINIT;
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
 	else
-- 
2.21.0.1020.gf2820cf01a-goog

