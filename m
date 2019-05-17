Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 649D5C04E84
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 00:50:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12C122082E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 00:50:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="CSOy8X4i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12C122082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98F846B0005; Thu, 16 May 2019 20:50:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 940306B0006; Thu, 16 May 2019 20:50:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 808FE6B0007; Thu, 16 May 2019 20:50:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 463546B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 20:50:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d21so3372732pfr.3
        for <linux-mm@kvack.org>; Thu, 16 May 2019 17:50:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:in-reply-to;
        bh=NL+2xCgkdZjiZqCBPfjZBo7z+6ErcBZumRMPeJ0EeFQ=;
        b=cmIRDCzZKFQaFiqz5qUcMSQFJY4erGhQUq1ui+W8AD3mQema5BU3THaMmW2dmXJAhl
         bm8Ze3+RZFWyiXkz+3HR8+S5aNP+uB3iWQnc3wmpxwzBkFQ3kSoKj17xwm1uBVjQBPrj
         sVFYEXjjw2fr6UGzqLbTCs8THgaHY0Kk0Lc6aad1odhLFaE+q3IZk6euiI0Qmtd4Fc76
         JYEzJm7XlWQn/eYi4dzyddaxODQzaPeUIp3lYipHuw5756uXY7Bq+cXA8NkULZNL5vu3
         oF0094qdau3eWd1KQTZYBQhEofdXVpwlBkPqMFaRANXfvVSIhGDzAjF2nxOQMhp9x9A+
         dQ/g==
X-Gm-Message-State: APjAAAU2WxyNRT9qFtTbkcJ5jjWLMRJ19bx9aoD8TYyx96Puorbcj6+G
	dwwe6kwq6Bq+9CSrZ8Gx0DYqgZHThYuYGIpPhK7l/rHTy64wtLpi5yXr57woT4MfAgYM0hqV490
	hyz5w44yPmXa15GAT+sI4IaOCkWeZt7Vi+9N0y83HtOqRXvlhRyYVQrQ4+fCdRIvpzA==
X-Received: by 2002:a62:2643:: with SMTP id m64mr11190585pfm.46.1558054225768;
        Thu, 16 May 2019 17:50:25 -0700 (PDT)
X-Received: by 2002:a62:2643:: with SMTP id m64mr11190517pfm.46.1558054224827;
        Thu, 16 May 2019 17:50:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558054224; cv=none;
        d=google.com; s=arc-20160816;
        b=k6WfSIRfOzANEaqQLiD0IhjsERsX1dBxPz9UUWTlPbZCJLstZoeT3h89dKPxJ3uudH
         maaGRX0MzKmTz0/aYKeQBCPkmgG+eQKx/MNxZzIL991RhSdh61wt051aZleynSEZ70x7
         m7Z7ZIyYhJQ03MjRgw+gmWVNUNXLhO8RHqBzVG7fSWWNgWQ4Wy18J8a1YPTwZu5HiuxV
         FdczhV6frtXEQglZFM2CxkZDfVLxaZSB08hah12lhRPRNF8PaKX3duatISjGNlGlhaFt
         zVF+5XKJsaSP89MNF+qmG3Ai5GFUPOmfkSWO2YCJM62x3bOs7n1YfOLnDVjPA2ZhoI1t
         iqhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=NL+2xCgkdZjiZqCBPfjZBo7z+6ErcBZumRMPeJ0EeFQ=;
        b=TPosrXNMpXLdyBh7pC7KsTg8wG4cA0iQzKILX20+BB7Mj2axuz1/YFGsEMW0b47Lm/
         P53+ckQxVejQKSntjmBvreAQ1f/9aB89NSjSSYGGwmMqUGUQW1+KM+xPU1nQ/zX8Osgk
         7sQLWEcWiwhD24EzpYw7iKUtymdqMO7X+nspYWliYqVEpd6qiRUiPRyB2RWuq5t8damf
         RLBug2OgLZzkZvpFDkrW09IgZaSTM7QLUxphoJKIKV30TK57s75HN5hi87eqdpMIualF
         VuGBNBR/Pv6IqUpZEDugfFUPLeMx5wKhbA1LbjL6UeMfjyPzEAUT3NHWE/qo2vVZ/1gs
         ds1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=CSOy8X4i;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u23sor7771502pfh.51.2019.05.16.17.50.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 17:50:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=CSOy8X4i;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :in-reply-to;
        bh=NL+2xCgkdZjiZqCBPfjZBo7z+6ErcBZumRMPeJ0EeFQ=;
        b=CSOy8X4is2wKO5Rx00RuxmgXP2xZ/JC0zjufsNKTddwrxwO2WKPgOuXTHfERCHP17t
         /NQWFMlmPsBYSh7Egh8kIVJpTxtTFcLIzeZM2jDOqcOiXqopm11/OjGDq01Su5EXxkTb
         1ghHfV+1HedbTD3CkcfjioeNBQtpo4hTUV65U=
X-Google-Smtp-Source: APXvYqybqaQ0dXdhVwgFoK8fD+r7lJjBN2v7ErsEC2WUSyLWan6WZ1LYFWJpqOYM54Zi1kkADEi3gw==
X-Received: by 2002:a63:fb02:: with SMTP id o2mr52230505pgh.357.1558054224431;
        Thu, 16 May 2019 17:50:24 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id s32sm6108209pgm.19.2019.05.16.17.50.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 17:50:23 -0700 (PDT)
Date: Thu, 16 May 2019 17:50:22 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: akpm@linux-foundation.org, cl@linux.com,
	kernel-hardening@lists.openwall.com,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org
Subject: [PATCH 5/4] mm: Introduce SLAB_NO_FREE_INIT and mark excluded caches
Message-ID: <201905161746.16E885F@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514143537.10435-5-glider@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order to improve the init_on_free performance, some frequently
freed caches with less sensitive contents can be excluded from the
init_on_free behavior.

This patch is modified from Brad Spengler/PaX Team's code in the
last public patch of grsecurity/PaX based on my understanding of the
code. Changes or omissions from the original code are mine and don't
reflect the original grsecurity/PaX code.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/buffer.c          | 2 +-
 fs/dcache.c          | 3 ++-
 include/linux/slab.h | 3 +++
 kernel/fork.c        | 6 ++++--
 mm/rmap.c            | 5 +++--
 mm/slab.h            | 5 +++--
 net/core/skbuff.c    | 6 ++++--
 7 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 0faa41fb4c88..04a85bd4cf2e 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3457,7 +3457,7 @@ void __init buffer_init(void)
 	bh_cachep = kmem_cache_create("buffer_head",
 			sizeof(struct buffer_head), 0,
 				(SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
-				SLAB_MEM_SPREAD),
+				SLAB_MEM_SPREAD|SLAB_NO_FREE_INIT),
 				NULL);
 
 	/*
diff --git a/fs/dcache.c b/fs/dcache.c
index 8136bda27a1f..323b039accba 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3139,7 +3139,8 @@ void __init vfs_caches_init_early(void)
 void __init vfs_caches_init(void)
 {
 	names_cachep = kmem_cache_create_usercopy("names_cache", PATH_MAX, 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, 0, PATH_MAX, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NO_FREE_INIT, 0,
+			PATH_MAX, NULL);
 
 	dcache_init();
 	inode_init();
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9449b19c5f10..7eba9ad8830d 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -92,6 +92,9 @@
 /* Avoid kmemleak tracing */
 #define SLAB_NOLEAKTRACE	((slab_flags_t __force)0x00800000U)
 
+/* Exclude slab from zero-on-free when init_on_free is enabled */
+#define SLAB_NO_FREE_INIT	((slab_flags_t __force)0x01000000U)
+
 /* Fault injection mark */
 #ifdef CONFIG_FAILSLAB
 # define SLAB_FAILSLAB		((slab_flags_t __force)0x02000000U)
diff --git a/kernel/fork.c b/kernel/fork.c
index b4cba953040a..9868585f5520 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2550,11 +2550,13 @@ void __init proc_caches_init(void)
 
 	mm_cachep = kmem_cache_create_usercopy("mm_struct",
 			mm_size, ARCH_MIN_MMSTRUCT_ALIGN,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT,
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT|
+			SLAB_NO_FREE_INIT,
 			offsetof(struct mm_struct, saved_auxv),
 			sizeof_field(struct mm_struct, saved_auxv),
 			NULL);
-	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT);
+	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT|
+						    SLAB_NO_FREE_INIT);
 	mmap_init();
 	nsproxy_cache_init();
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..b7b8013eeb0a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -432,10 +432,11 @@ static void anon_vma_ctor(void *data)
 void __init anon_vma_init(void)
 {
 	anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
-			0, SLAB_TYPESAFE_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT,
+			0, SLAB_TYPESAFE_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT|
+			SLAB_NO_FREE_INIT,
 			anon_vma_ctor);
 	anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain,
-			SLAB_PANIC|SLAB_ACCOUNT);
+			SLAB_PANIC|SLAB_ACCOUNT|SLAB_NO_FREE_INIT);
 }
 
 /*
diff --git a/mm/slab.h b/mm/slab.h
index 24ae887359b8..f95b4f03c57b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -129,7 +129,8 @@ static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
 /* Legal flag mask for kmem_cache_create(), for various configurations */
 #define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | \
 			 SLAB_CACHE_DMA32 | SLAB_PANIC | \
-			 SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS )
+			 SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS | \
+			 SLAB_NO_FREE_INIT)
 
 #if defined(CONFIG_DEBUG_SLAB)
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
@@ -535,7 +536,7 @@ static inline bool slab_want_init_on_alloc(gfp_t flags, struct kmem_cache *c)
 static inline bool slab_want_init_on_free(struct kmem_cache *c)
 {
 	if (static_branch_unlikely(&init_on_free))
-		return !(c->ctor);
+		return !(c->ctor) && ((c->flags & SLAB_NO_FREE_INIT) == 0);
 	else
 		return false;
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e89be6282693..b65902d2c042 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3981,14 +3981,16 @@ void __init skb_init(void)
 	skbuff_head_cache = kmem_cache_create_usercopy("skbuff_head_cache",
 					      sizeof(struct sk_buff),
 					      0,
-					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					      SLAB_HWCACHE_ALIGN|SLAB_PANIC|
+					      SLAB_NO_FREE_INIT,
 					      offsetof(struct sk_buff, cb),
 					      sizeof_field(struct sk_buff, cb),
 					      NULL);
 	skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
 						sizeof(struct sk_buff_fclones),
 						0,
-						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+						SLAB_HWCACHE_ALIGN|SLAB_PANIC|
+						SLAB_NO_FREE_INIT,
 						NULL);
 	skb_extensions_init();
 }
-- 
2.17.1


-- 
Kees Cook

