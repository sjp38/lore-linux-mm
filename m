Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 386B1C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:42:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB422217FA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:42:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NqP7PthO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB422217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C0186B000D; Thu, 18 Apr 2019 11:42:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 870D16B000E; Thu, 18 Apr 2019 11:42:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75FC36B0010; Thu, 18 Apr 2019 11:42:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56BAD6B000D
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:42:41 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g48so2352082qtk.19
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:42:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=7Vx5LHPJZXF/Q6+oqstdvL483bzBYrhBlKRq8Wbm+ds=;
        b=NqcBov29sOHx5BL/E6UqsbmRNEy7OyuTOM14phLVwudN+OJ4H5qFkdFEqtKSq0BV8v
         efrYfR+NLHYCihgrrgZIDG+XsnhHEC6XzGNRiq3tt1YhobC6Cb1R18hZ1UwT6bSHHTQ9
         BgU35TxRTRshsA4Z1EFPGlvL3QzK3ykrF3dQ7j9Gb8R6YeM5+7+zpTMZH/3ghNOitVD6
         ir6rQO2/HV69x71XaY1cWGbcmhfKjG3dCf7Y4ADI/atolBb7PBJPCqs1UJHn1vdDl/YI
         AzGBoc0KOQlQ6ArA5L+BKJ9iIsHlRz8w6P33ksXk5/jCF0JbdNvWHXBTEVHuC8P2xak9
         DXqA==
X-Gm-Message-State: APjAAAWCxFVcTBF/oyuXrxFWDg14ooSg3/c05vW43x9zhjCmuC98tnwa
	X3s1UDzN8F5McnVMGYBzgO8grLZG6ofPNTWJ9ThlyAgfRMyCtH4ZSgeMA69y9DlwWi0AvkLMFpE
	ayPiMoEwwk1Cg935XAC07WuuXYzpJ4Wd9pNdDXUgRwX4t3qjPtNA1d/vxdCwIdeJ4bg==
X-Received: by 2002:a0c:ba8b:: with SMTP id x11mr75442749qvf.196.1555602161044;
        Thu, 18 Apr 2019 08:42:41 -0700 (PDT)
X-Received: by 2002:a0c:ba8b:: with SMTP id x11mr75442690qvf.196.1555602160109;
        Thu, 18 Apr 2019 08:42:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602160; cv=none;
        d=google.com; s=arc-20160816;
        b=Z9/4vohf2urum3CHJQZ1aEqy6zdPWkvrmP0Z/+aLG3ofpUqreXLiatROLu3jfUrXnP
         efQGnjnrUCO0iNJsssFLhM1+RObwyMkqTNqOM1Y1TQyuv55MhU2Y1etn3Xdg6A2enW6X
         xpEvEy03vDvSO5DFinFUBBMJt6cE74DQjle2WL/OPZ8sJBSDgYFlzToAJR7mOZPd7oDN
         JHkgpGznaAi8JAqBIP/iG9EPYgwUTWbUJmfBhy5j5HZA+7zS9rFaT5XFX/nJD6NfItds
         h+MGersh8rK4D+3Szs39gVYHavl1RhWIJqlDrcYcC5b4dP4K9qSIthBhVYE7L5hst7E1
         vm1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=7Vx5LHPJZXF/Q6+oqstdvL483bzBYrhBlKRq8Wbm+ds=;
        b=xbPBufdc1KeBKCKt1PL9iyXeiAyD94V+ca4AGvPUrLlwqcbj98B54ibYzaPO98S4tI
         6xZjrFjLJX0dzUZo7usRIPBTWrjlBoJB9isLOZzti+mKbmKfmVLiPX1FjbXYyDkUcEtP
         yyDkCT3epuTxZM+16dmeI5dy1UnwNOa+h1sSI7fZuChwHMJOsdSdEqt6WVpZE0K/Cw95
         +gLhI6WktBE5thjXnG1QL8Tp3VAO4PUA4SDEcVpahmuLq59L0s/ndjkhI+PYItHzGuQG
         SeyTEMEIBptWO5RNzHoDPFcMyUniVFXCGqv+MNoEektsk3BmEOP5oMDEBVQx/EW7RMr/
         UPNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NqP7PthO;
       spf=pass (google.com: domain of 375q4xaykcpiafcxylaiiafy.wigfchor-ggepuwe.ila@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=375q4XAYKCPIafcXYlaiiafY.Wigfchor-ggepUWe.ila@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id o56sor2019047qvc.71.2019.04.18.08.42.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 08:42:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of 375q4xaykcpiafcxylaiiafy.wigfchor-ggepuwe.ila@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NqP7PthO;
       spf=pass (google.com: domain of 375q4xaykcpiafcxylaiiafy.wigfchor-ggepuwe.ila@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=375q4XAYKCPIafcXYlaiiafY.Wigfchor-ggepUWe.ila@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=7Vx5LHPJZXF/Q6+oqstdvL483bzBYrhBlKRq8Wbm+ds=;
        b=NqP7PthO/bEtcFc0pQvk/uBBzKLAYIGtocI1hT+DM8hIo72UfBZBIBVnXu+fFrk+tM
         KJ5KSZENmiDl1qNVhGgd64Eo7q5BYkLRtCEvVEFt4zKeuw5kXUTYR365Z82Cj3qMWVPD
         aqiFQ4UW07z2n8WK/QUrgcOurRafhQKaNjCdOzCokzVPCi0ptMEt9C1aXeU8dsh2JgaO
         PjTCt3Tw23L24+A2yOTiggHdld5+GG1vDUoSHz/QUtCxldjzEm0xbBNwT/2ThgQM/Khl
         l7+MeWTxQUAFNK3s4krDJTyxJdmPZmwDQ+Ap3CxsPF4oW4lMViQzuaQ/Nsi6OPNYZ2do
         fQAQ==
X-Google-Smtp-Source: APXvYqwjGLSVcle0eamytkf9ScG/iJnIkVEcX89YhKur0TC0GeJgj8QXWXF+lQeOH0HrDzay5Lgtdu1MljE=
X-Received: by 2002:a0c:a8e7:: with SMTP id h39mr75555057qvc.34.1555602159823;
 Thu, 18 Apr 2019 08:42:39 -0700 (PDT)
Date: Thu, 18 Apr 2019 17:42:07 +0200
In-Reply-To: <20190418154208.131118-1-glider@google.com>
Message-Id: <20190418154208.131118-3-glider@google.com>
Mime-Version: 1.0
References: <20190418154208.131118-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [PATCH 2/3] gfp: mm: introduce __GFP_NOINIT
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

When passed to an allocator (either pagealloc or SL[AOU]B), __GFP_NOINIT
tells it to not initialize the requested memory if the init_allocations
boot option is enabled. This can be useful in the cases the newly
allocated memory is going to be initialized by the caller right away.

__GFP_NOINIT basically defeats the hardening against information leaks
provided by the init_allocations feature, so one should use it with
caution.

This patch also adds __GFP_NOINIT to alloc_pages() calls in SL[AOU]B.

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
Cc: Qian Cai <cai@lca.pw>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com
---
 include/linux/gfp.h | 6 +++++-
 include/linux/mm.h  | 2 +-
 kernel/kexec_core.c | 2 +-
 mm/slab.c           | 2 +-
 mm/slob.c           | 1 +
 mm/slub.c           | 1 +
 6 files changed, 10 insertions(+), 4 deletions(-)

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
index b38b71a5efaa..8f03334a9033 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2601,7 +2601,7 @@ DECLARE_STATIC_KEY_FALSE(init_allocations);
 static inline bool want_init_memory(gfp_t flags)
 {
 	if (static_branch_unlikely(&init_allocations))
-		return true;
+		return !(flags & __GFP_NOINIT);
 	return flags & __GFP_ZERO;
 }
 
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index be84f5f95c97..f9d1f1236cd0 100644
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
index dcc5b73cf767..762cb0e7bcc1 100644
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
index 18981a71e962..867d2d68a693 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -192,6 +192,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 {
 	void *page;
 
+	gfp |= __GFP_NOINIT;
 #ifdef CONFIG_NUMA
 	if (node != NUMA_NO_NODE)
 		page = __alloc_pages_node(node, gfp, order);
diff --git a/mm/slub.c b/mm/slub.c
index e4efb6575510..a79b4cb768a2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1493,6 +1493,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	struct page *page;
 	unsigned int order = oo_order(oo);
 
+	flags |= __GFP_NOINIT;
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
 	else
-- 
2.21.0.392.gf8f6787159e-goog

