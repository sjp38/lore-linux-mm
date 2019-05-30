Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D38C0C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 04:50:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92A1F25D0B
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 04:50:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="CUCf1ofe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92A1F25D0B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E5C46B0273; Thu, 30 May 2019 00:50:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56F256B0275; Thu, 30 May 2019 00:50:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 411296B0274; Thu, 30 May 2019 00:50:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id F389E6B0272
	for <linux-mm@kvack.org>; Thu, 30 May 2019 00:50:27 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d22so3162179plr.0
        for <linux-mm@kvack.org>; Wed, 29 May 2019 21:50:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=0d2DjLTtSzc/j4GazSC/oBA3i3Oos8BMeCC9qu8DWTQ=;
        b=H3/Xyjlv30emWeHjzHjklwjlNuMi0BZlM1lxp8tYNT3KKJEbzI3RsyQiwJl94NZa0S
         TajAmEX6h870bl3ujX9O9OOAowo33tqA/ITO0f1VLps1fqTaZi6wSj87hlDCAdSc2GQZ
         scuL7/BePSAB3O2X6f0LpDkENY0gkb8VVZTf6CI7oBeFhhT0M6YXs8DwlcQJp9H+zeFh
         rwYJET2o2wQXkzHvbU0Jrngt2aOkhs9aC0P68t7G1Ex/GtfVM+inc+B5oCqkM63Rx5Jn
         rIDijYFNX4Hhj0PcGWpLRKqgvPU456tRuOGRZcRBLY6cUVOH9i5QZcpGrioNlkUn2bT3
         Q29g==
X-Gm-Message-State: APjAAAWb3YpOE7dlx6SfxzYj7oT2GlsnHfoVCSrtqb05fV2BWLNbu7hY
	XyAJ3mVCRdQUYiUXE3gHYVB7ASwoXKiMO+KC0rjzWWHOMsApvCMhtg0qhxwE/esVtfMelJyBKds
	2+KEhgphgVl6oOYN64KM1C8bmcf78GYtAaG9uBUIM4XYeUMyuLKwPZHxDGGSJAfVyyQ==
X-Received: by 2002:a63:c50c:: with SMTP id f12mr1961031pgd.71.1559191827572;
        Wed, 29 May 2019 21:50:27 -0700 (PDT)
X-Received: by 2002:a63:c50c:: with SMTP id f12mr1961001pgd.71.1559191826660;
        Wed, 29 May 2019 21:50:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559191826; cv=none;
        d=google.com; s=arc-20160816;
        b=lgqIZQB69gqNcF07vkaR70AyKtizzUg0lVgxrOtLRrNYKBRFvomzfDuNJYE4kasWdQ
         hvHsKnJuXQEXEokEWwkOZ+Vlwh1ldb/ldlazLwFw0QsmUfAYSsGw8BkuiDeNoX6n4jp/
         NTHchtmz+Z+aANg5DSf6jdtaLeUZ24JoKqnHhfIC+gXEu+uFSrhUFN4/wghXM7LSTZga
         bvOZzK9q7EBFipdLVxn3tJNvV8j7kA4NWlp6T2gGmm35tFFMI+0wuWaySwqUkmBm+hGc
         5juZnoFyt4Ds+hzZ7c/HpVHl2lCl7QAwf3RKNpdqvjgrKQWFbu2wC8IHIIwW/J2mZn1o
         IPRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=0d2DjLTtSzc/j4GazSC/oBA3i3Oos8BMeCC9qu8DWTQ=;
        b=W7/CGyZ8r55JhpZRNIC9RYzZyKTWrSoXoc4A6P9Ytl5G3ymXtQPPQlKWtnmio07gQM
         bHldk1XxbCp+C2v5ajGDtkjmKw6xb+1ITADkfH9NL5OPWq9sitrFAqwRlwqyHDZDFzEy
         aMHcWnYfmu822e5INuqZIjUrEHZM8tXSH1suSYp3AVDxvupEEZNNiVsNqP0MP2kL9Wx4
         UNBZ55oFuWDGzt011M1toQge7QHjyUqyI6RInmojmmmw+zPxT1m0w7pQvkkx5g1DndG0
         9VNCAziras4eNsa4TWnmOYID6o/hia1kX3SyGKN/cu6nHnopkJ7qbOPMBT1pOMWa4Js5
         YP5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=CUCf1ofe;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e23sor1774536pgb.69.2019.05.29.21.50.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 21:50:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=CUCf1ofe;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=0d2DjLTtSzc/j4GazSC/oBA3i3Oos8BMeCC9qu8DWTQ=;
        b=CUCf1ofeWouCM5OzBk/IBw9EmIyAjfi5VZFZ/WBrN8Vklom9TEX+memXlAOdgMfFti
         ff8V2Y4FMs2V8ynl6NLjipV5OJsO3EvUHiIYYn7sDVlaFqUrrqojm8TL8uyFTCeFEY2l
         yJbNftijtrl4QLGvYLNSt1A/1l0b8F0qQ0ud8=
X-Google-Smtp-Source: APXvYqwDsRz4qk6MfIpcfvDtSrrTWKmVd2sbAjLdyUwrbya7Z0brqCXAdyW7W1bnwSiib5kYONjLMg==
X-Received: by 2002:a63:cc4b:: with SMTP id q11mr1994193pgi.43.1559191826365;
        Wed, 29 May 2019 21:50:26 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id f28sm1339930pfk.104.2019.05.29.21.50.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 21:50:24 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>,
	Matthew Wilcox <willy@infradead.org>,
	Alexander Popov <alex.popov@linux.com>,
	Alexander Potapenko <glider@google.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH 3/3] lkdtm/heap: Add tests for freelist hardening
Date: Wed, 29 May 2019 21:50:17 -0700
Message-Id: <20190530045017.15252-4-keescook@chromium.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190530045017.15252-1-keescook@chromium.org>
References: <20190530045017.15252-1-keescook@chromium.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This adds tests for double free and cross-cache freeing, which should
both be caught by CONFIG_SLAB_FREELIST_HARDENED.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/misc/lkdtm/core.c  |  5 +++
 drivers/misc/lkdtm/heap.c  | 72 ++++++++++++++++++++++++++++++++++++++
 drivers/misc/lkdtm/lkdtm.h |  5 +++
 3 files changed, 82 insertions(+)

diff --git a/drivers/misc/lkdtm/core.c b/drivers/misc/lkdtm/core.c
index 4f3a6e1cd331..b78df5a09217 100644
--- a/drivers/misc/lkdtm/core.c
+++ b/drivers/misc/lkdtm/core.c
@@ -133,6 +133,9 @@ static const struct crashtype crashtypes[] = {
 	CRASHTYPE(READ_AFTER_FREE),
 	CRASHTYPE(WRITE_BUDDY_AFTER_FREE),
 	CRASHTYPE(READ_BUDDY_AFTER_FREE),
+	CRASHTYPE(SLAB_FREE_DOUBLE),
+	CRASHTYPE(SLAB_FREE_CROSS),
+	CRASHTYPE(SLAB_FREE_PAGE),
 	CRASHTYPE(SOFTLOCKUP),
 	CRASHTYPE(HARDLOCKUP),
 	CRASHTYPE(SPINLOCKUP),
@@ -439,6 +442,7 @@ static int __init lkdtm_module_init(void)
 	lkdtm_bugs_init(&recur_count);
 	lkdtm_perms_init();
 	lkdtm_usercopy_init();
+	lkdtm_heap_init();
 
 	/* Register debugfs interface */
 	lkdtm_debugfs_root = debugfs_create_dir("provoke-crash", NULL);
@@ -485,6 +489,7 @@ static void __exit lkdtm_module_exit(void)
 	debugfs_remove_recursive(lkdtm_debugfs_root);
 
 	/* Handle test-specific clean-up. */
+	lkdtm_heap_exit();
 	lkdtm_usercopy_exit();
 
 	if (lkdtm_kprobe != NULL)
diff --git a/drivers/misc/lkdtm/heap.c b/drivers/misc/lkdtm/heap.c
index 65026d7de130..3c5cec85edce 100644
--- a/drivers/misc/lkdtm/heap.c
+++ b/drivers/misc/lkdtm/heap.c
@@ -7,6 +7,10 @@
 #include <linux/slab.h>
 #include <linux/sched.h>
 
+static struct kmem_cache *double_free_cache;
+static struct kmem_cache *a_cache;
+static struct kmem_cache *b_cache;
+
 /*
  * This tries to stay within the next largest power-of-2 kmalloc cache
  * to avoid actually overwriting anything important if it's not detected
@@ -146,3 +150,71 @@ void lkdtm_READ_BUDDY_AFTER_FREE(void)
 
 	kfree(val);
 }
+
+void lkdtm_SLAB_FREE_DOUBLE(void)
+{
+	int *val;
+
+	val = kmem_cache_alloc(double_free_cache, GFP_KERNEL);
+	if (!val) {
+		pr_info("Unable to allocate double_free_cache memory.\n");
+		return;
+	}
+
+	/* Just make sure we got real memory. */
+	*val = 0x12345678;
+	pr_info("Attempting double slab free ...\n");
+	kmem_cache_free(double_free_cache, val);
+	kmem_cache_free(double_free_cache, val);
+}
+
+void lkdtm_SLAB_FREE_CROSS(void)
+{
+	int *val;
+
+	val = kmem_cache_alloc(a_cache, GFP_KERNEL);
+	if (!val) {
+		pr_info("Unable to allocate a_cache memory.\n");
+		return;
+	}
+
+	/* Just make sure we got real memory. */
+	*val = 0x12345679;
+	pr_info("Attempting cross-cache slab free ...\n");
+	kmem_cache_free(b_cache, val);
+}
+
+void lkdtm_SLAB_FREE_PAGE(void)
+{
+	unsigned long p = __get_free_page(GFP_KERNEL);
+
+	pr_info("Attempting non-Slab slab free ...\n");
+	kmem_cache_free(NULL, (void *)p);
+	free_page(p);
+}
+
+/*
+ * We have constructors to keep the caches distinctly separated without
+ * needing to boot with "slab_nomerge".
+ */
+static void ctor_double_free(void *region)
+{ }
+static void ctor_a(void *region)
+{ }
+static void ctor_b(void *region)
+{ }
+
+void __init lkdtm_heap_init(void)
+{
+	double_free_cache = kmem_cache_create("lkdtm-heap-double_free",
+					      64, 0, 0, ctor_double_free);
+	a_cache = kmem_cache_create("lkdtm-heap-a", 64, 0, 0, ctor_a);
+	b_cache = kmem_cache_create("lkdtm-heap-b", 64, 0, 0, ctor_b);
+}
+
+void __exit lkdtm_heap_exit(void)
+{
+	kmem_cache_destroy(double_free_cache);
+	kmem_cache_destroy(a_cache);
+	kmem_cache_destroy(b_cache);
+}
diff --git a/drivers/misc/lkdtm/lkdtm.h b/drivers/misc/lkdtm/lkdtm.h
index 23dc565b4307..c5ae0b37587d 100644
--- a/drivers/misc/lkdtm/lkdtm.h
+++ b/drivers/misc/lkdtm/lkdtm.h
@@ -28,11 +28,16 @@ void lkdtm_STACK_GUARD_PAGE_LEADING(void);
 void lkdtm_STACK_GUARD_PAGE_TRAILING(void);
 
 /* lkdtm_heap.c */
+void __init lkdtm_heap_init(void);
+void __exit lkdtm_heap_exit(void);
 void lkdtm_OVERWRITE_ALLOCATION(void);
 void lkdtm_WRITE_AFTER_FREE(void);
 void lkdtm_READ_AFTER_FREE(void);
 void lkdtm_WRITE_BUDDY_AFTER_FREE(void);
 void lkdtm_READ_BUDDY_AFTER_FREE(void);
+void lkdtm_SLAB_FREE_DOUBLE(void);
+void lkdtm_SLAB_FREE_CROSS(void);
+void lkdtm_SLAB_FREE_PAGE(void);
 
 /* lkdtm_perms.c */
 void __init lkdtm_perms_init(void);
-- 
2.17.1

