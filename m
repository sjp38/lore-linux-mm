Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25B99C606BD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:09:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8A4E2173E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:09:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="keIyX3CN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8A4E2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75A328E0025; Mon,  8 Jul 2019 13:09:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70B3B8E0002; Mon,  8 Jul 2019 13:09:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FA088E0025; Mon,  8 Jul 2019 13:09:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 280EE8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:09:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id u10so9081506plq.21
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:09:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=3eGEWBsY8dqF2V6DSZ5u38cqY6eLJM9O9Aa4+MoaYxw=;
        b=QZnOkRdYQf8mUWhv/8goxyW49dQK1f6TH7q+YuHq6zOFBBhHr0GY3ksUcCvRpLbHcb
         QBOYrdeiOBuAG8d0ksyAzgZWJUdF3KWccVabr/CjaKCfhiGiD0rAL9nJ24Z5NzvTDE3Y
         nyvXFMrauG/AD9Gz96IZF19zMsjQW/YaSLkAECJa12vn121ro3UgEXCA1mXxHgTunnVh
         VVbYzA5XAYppCDPAs14QapNjN+sc4EOrV1tOMOq1/onwOIulFTf3hJbzqFNyhXEgQWD8
         xHVXapVIVI5cwB932SlVARyaga0qjKyBupDbZ5zlC8JHHED9mCzli35BfNQBo0eWK6Fi
         TKTA==
X-Gm-Message-State: APjAAAVSyRISt4M7dDCgzc7+GhFPlf8HrXVq4XxISkv8XPkg/Fy+T9Oo
	ncvaqo9zLCmwe8/UvvqR9cGOknvu2qU1qURjgpLkJ/EkW7CMJXiByxIbG7mY5mglw8lgIE+BuYH
	PLavObaSNk64tfjnItqbBuMbDFa9E4LvkJ6Pa36t+gJP0WqzJns6blioXuR1GG/h4bQ==
X-Received: by 2002:a65:6454:: with SMTP id s20mr25192664pgv.15.1562605748702;
        Mon, 08 Jul 2019 10:09:08 -0700 (PDT)
X-Received: by 2002:a65:6454:: with SMTP id s20mr25192601pgv.15.1562605747954;
        Mon, 08 Jul 2019 10:09:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562605747; cv=none;
        d=google.com; s=arc-20160816;
        b=0b3lslYHFruBhsgNf9KvSHxQOkSUaHAXX9t7jy9LPr+HwhYWAyikvV5ejYcfmdKWCE
         30kw0J5cSja3CzuG2KwnaTAffHj25ZedWB/pBAR77swVnLOdBOP9zRIK+RijHmgmTuqR
         swMvqWxeGJfiXcNki8O47rEI7hskZYFwvs9Pi6gqgBcTSC9yl/X9DXI3Tpl9f+pdyh5n
         vsl3SK5NbmOJyMjlcoPDTLmW4vuZcqPnD/9mRoNcGKQvLVa77JY2vzOcBSG48t1fJ+W/
         7fFYwlNuktd9CeTEOIrPZYUUERZax5H98+fonNH10y3I0s4wNaThSd+Cbh1jnPwzpUGD
         wFbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=3eGEWBsY8dqF2V6DSZ5u38cqY6eLJM9O9Aa4+MoaYxw=;
        b=daOPUqYgvqPGu/6uP1EszIRnvfV04M0FeIpYiVUWRrYEWELyHJXxBEDC03NxzTAknV
         x8XQn/KDOImeAm4gWqSmBNp0Whh5ltVSwGer7hFJoGY8+KKukj8MKI5A03p4pg/dPXrN
         pbcvtKYPdMBDXizH0oJX72a+ZDDv9JyGmrHvvbbvX5t2ZZpQcggIH4Fd2pjLLt2lS7g4
         FcK+g1Gosi6HPzgMCZHqb31cvAN0kq1nUeiMTXHrpzdCe6EdPVj9dDrY2MqZzF3qpgIz
         mw3JNgUsanJCLgTd90UtBxNnqqsULSVo98xzYMT0pni0tYMwUIsjFTIXXgPURhSri4jR
         Jobw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=keIyX3CN;
       spf=pass (google.com: domain of 3s3gjxqukccicjtcpemmejc.amkjglsv-kkit8ai.mpe@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3s3gjXQUKCCICJTCPEMMEJC.AMKJGLSV-KKIT8AI.MPE@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t29sor9507499pgm.5.2019.07.08.10.09.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:09:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3s3gjxqukccicjtcpemmejc.amkjglsv-kkit8ai.mpe@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=keIyX3CN;
       spf=pass (google.com: domain of 3s3gjxqukccicjtcpemmejc.amkjglsv-kkit8ai.mpe@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3s3gjXQUKCCICJTCPEMMEJC.AMKJGLSV-KKIT8AI.MPE@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=3eGEWBsY8dqF2V6DSZ5u38cqY6eLJM9O9Aa4+MoaYxw=;
        b=keIyX3CNl5DDG92vrsREjVSX3La62v+TlU4jy29++vEjNAOxL156RFN76FY/S9OuA1
         OJ9exP5qjcKi3SlFhKHjuoXtrqwxEHS8Uh6+D1eWxeC7htGTZw4dEuJhIKRLQosTcuoG
         Qvu2q0Klh44hoXqdiXhZZJCBSL6MLnEin4YgW/6DGR9CnQjOvvh2Pu/gcQqenAnMG5AW
         3hLrmpY401qXabYeDGwIGYs4nTXkWrzcI5w3Pt1D/l8nlMcYMomItJP0aC6fsYX7ckqk
         1CUgnYMJLNcb62DvNeuh1evMOM4jAvl8LNFfS039wNK3Ol764X60jOB8PX5aqcR4Xuxm
         o/aw==
X-Google-Smtp-Source: APXvYqxNoDRGx+nApVWU9QeJBNTPDlCB953CYwbgWqfrgJL3iN+co1Qsz4hLpAn3aevd4wZ0T3x8crL6GA==
X-Received: by 2002:a63:2a8d:: with SMTP id q135mr25079867pgq.46.1562605747189;
 Mon, 08 Jul 2019 10:09:07 -0700 (PDT)
Date: Mon,  8 Jul 2019 19:07:06 +0200
In-Reply-To: <20190708170706.174189-1-elver@google.com>
Message-Id: <20190708170706.174189-5-elver@google.com>
Mime-Version: 1.0
References: <20190708170706.174189-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v5 4/5] mm/slab: Refactor common ksize KASAN logic into slab_common.c
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, 
	kasan-dev@googlegroups.com, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This refactors common code of ksize() between the various allocators
into slab_common.c: __ksize() is the allocator-specific implementation
without instrumentation, whereas ksize() includes the required KASAN
logic.

Signed-off-by: Marco Elver <elver@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: kasan-dev@googlegroups.com
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/slab.h |  1 +
 mm/slab.c            | 28 ++++++----------------------
 mm/slab_common.c     | 26 ++++++++++++++++++++++++++
 mm/slob.c            |  4 ++--
 mm/slub.c            | 14 ++------------
 5 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9449b19c5f10..98c3d12b7275 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -184,6 +184,7 @@ void * __must_check __krealloc(const void *, size_t, gfp_t);
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
 void kzfree(const void *);
+size_t __ksize(const void *);
 size_t ksize(const void *);
 
 #ifdef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
diff --git a/mm/slab.c b/mm/slab.c
index f7117ad9b3a3..394e7c7a285e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4204,33 +4204,17 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 #endif /* CONFIG_HARDENED_USERCOPY */
 
 /**
- * ksize - get the actual amount of memory allocated for a given object
- * @objp: Pointer to the object
+ * __ksize -- Uninstrumented ksize.
  *
- * kmalloc may internally round up allocations and return more memory
- * than requested. ksize() can be used to determine the actual amount of
- * memory allocated. The caller may use this additional memory, even though
- * a smaller amount of memory was initially specified with the kmalloc call.
- * The caller must guarantee that objp points to a valid object previously
- * allocated with either kmalloc() or kmem_cache_alloc(). The object
- * must not be freed during the duration of the call.
- *
- * Return: size of the actual memory used by @objp in bytes
+ * Unlike ksize(), __ksize() is uninstrumented, and does not provide the same
+ * safety checks as ksize() with KASAN instrumentation enabled.
  */
-size_t ksize(const void *objp)
+size_t __ksize(const void *objp)
 {
-	size_t size;
-
 	BUG_ON(!objp);
 	if (unlikely(objp == ZERO_SIZE_PTR))
 		return 0;
 
-	size = virt_to_cache(objp)->object_size;
-	/* We assume that ksize callers could use the whole allocated area,
-	 * so we need to unpoison this area.
-	 */
-	kasan_unpoison_shadow(objp, size);
-
-	return size;
+	return virt_to_cache(objp)->object_size;
 }
-EXPORT_SYMBOL(ksize);
+EXPORT_SYMBOL(__ksize);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..b7c6a40e436a 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1597,6 +1597,32 @@ void kzfree(const void *p)
 }
 EXPORT_SYMBOL(kzfree);
 
+/**
+ * ksize - get the actual amount of memory allocated for a given object
+ * @objp: Pointer to the object
+ *
+ * kmalloc may internally round up allocations and return more memory
+ * than requested. ksize() can be used to determine the actual amount of
+ * memory allocated. The caller may use this additional memory, even though
+ * a smaller amount of memory was initially specified with the kmalloc call.
+ * The caller must guarantee that objp points to a valid object previously
+ * allocated with either kmalloc() or kmem_cache_alloc(). The object
+ * must not be freed during the duration of the call.
+ *
+ * Return: size of the actual memory used by @objp in bytes
+ */
+size_t ksize(const void *objp)
+{
+	size_t size = __ksize(objp);
+	/*
+	 * We assume that ksize callers could use whole allocated area,
+	 * so we need to unpoison this area.
+	 */
+	kasan_unpoison_shadow(objp, size);
+	return size;
+}
+EXPORT_SYMBOL(ksize);
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
diff --git a/mm/slob.c b/mm/slob.c
index 84aefd9b91ee..7f421d0ca9ab 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -527,7 +527,7 @@ void kfree(const void *block)
 EXPORT_SYMBOL(kfree);
 
 /* can't use ksize for kmem_cache_alloc memory, only kmalloc */
-size_t ksize(const void *block)
+size_t __ksize(const void *block)
 {
 	struct page *sp;
 	int align;
@@ -545,7 +545,7 @@ size_t ksize(const void *block)
 	m = (unsigned int *)(block - align);
 	return SLOB_UNITS(*m) * SLOB_UNIT;
 }
-EXPORT_SYMBOL(ksize);
+EXPORT_SYMBOL(__ksize);
 
 int __kmem_cache_create(struct kmem_cache *c, slab_flags_t flags)
 {
diff --git a/mm/slub.c b/mm/slub.c
index cd04dbd2b5d0..05a8d17dd9b2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3901,7 +3901,7 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
 
-static size_t __ksize(const void *object)
+size_t __ksize(const void *object)
 {
 	struct page *page;
 
@@ -3917,17 +3917,7 @@ static size_t __ksize(const void *object)
 
 	return slab_ksize(page->slab_cache);
 }
-
-size_t ksize(const void *object)
-{
-	size_t size = __ksize(object);
-	/* We assume that ksize callers could use whole allocated area,
-	 * so we need to unpoison this area.
-	 */
-	kasan_unpoison_shadow(object, size);
-	return size;
-}
-EXPORT_SYMBOL(ksize);
+EXPORT_SYMBOL(__ksize);
 
 void kfree(const void *x)
 {
-- 
2.22.0.410.gd8fdbe21b5-goog

