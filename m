Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13F8EC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:21:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0AAC2054F
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:21:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="k/JHoGQL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0AAC2054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DDB28E0006; Mon, 29 Jul 2019 10:21:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28EA48E0002; Mon, 29 Jul 2019 10:21:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A39B8E0006; Mon, 29 Jul 2019 10:21:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D3FDF8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:21:22 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u21so38579987pfn.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:21:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4K6A/BJDfCnYwl6IVii41tr2UtMMY6EbkGcfzGbxqy8=;
        b=NsvrPYDb2MSc5yfXrcQyRKAlYA9LnGwpVHyytA1X5c93snVb3FiC9YjxKCBVtVQ6JH
         Cd06tEDzHEQw7Mip0tz74rb9nTd4BRwkoOneGLrp2GqjROMuY/zHCLeWR/KL8j+pA3cr
         J8bKCx6UMmLF/QiTKCoHNgf6b2E22jNRIBo680eSyRIgCaU2hoGiDMO/S//ReCsn6dJl
         gl9vdPxGKeDpeBNfUJ+Bl4n00+Jr9qZ2tREUT2QGpY5aN1S2HAYigF6K31bYg1pJRrHX
         6QV9jmILwiq+KlAmd9F4RQESYtllo47PLcu7RFkREmFxBtQI6Rb2IGEibYMDc9RNEoTX
         SuPw==
X-Gm-Message-State: APjAAAXcd+ipcrMtTvLjqFgbUZYauZf/DZBgyU6C2XlBAnPOIT+nz8+p
	jbUvCePbQ2srmKmQ04pYjsI/MlIGjrjRwTyst0PG/UsjTRJIucwJsRWUeq6mPJD4kgAPNywMxqv
	XpdVG+ROQUt9dr9++H5x6bf0vmeo/06DNAqzY+6uW++Ax93z34YIdKzzIPnZS/QOeUw==
X-Received: by 2002:a63:c03:: with SMTP id b3mr40862058pgl.23.1564410082345;
        Mon, 29 Jul 2019 07:21:22 -0700 (PDT)
X-Received: by 2002:a63:c03:: with SMTP id b3mr40861960pgl.23.1564410081046;
        Mon, 29 Jul 2019 07:21:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410081; cv=none;
        d=google.com; s=arc-20160816;
        b=bu7Jrj7DMGDMjlmrUOPkvqCTI6tfNWN6k9UlWb7kpqOIW6Rv5UwRDpgBHqehwq/BcU
         DwJagKq2QtLG5Dh031qtk0gG/KnkD3DVtWf0zQbfkewFVBee/gQGvTT8OQ5qhYvOClpe
         SFAwdiQKQ21mTONtljS8pox/4lCZ1nms4ePIYNLSqkHyGLMnfUWXgoeV7LrsN+h9YvvJ
         Tdyy7Zz7CGR5T9SzaTeOzxWj+5Tw6K8xlfkMrTfsQWnjfof+JhEii2U+f0oMp4kO9Vgu
         WHiDxyBBvB26oybRluW48VcGaPMRf1AGLv+1UHV8UmnekE/1m3CF3IR/ivKGhh57aTQY
         uTzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4K6A/BJDfCnYwl6IVii41tr2UtMMY6EbkGcfzGbxqy8=;
        b=qk7sc4ebu6owK2Bzln65G+8f8otmGEBPQputPzBvWw3ROaZbcTEEn/1KQ94KJ77VUx
         U0Bm9nG7aSRtaIcudoq0/OE9fyWRQmCXEi+Q2TiW1/4g4HUkn9rD/BqQ8NeFIj0yxOv6
         5tAc7xJ1L3NgpwfW61xmSWR60ruu2Nr7KOkHLQQolRJG3hL1EVprJt3ytGEad2wMY1Mj
         b+5E+tPtM2H42ZXzHLGXQI4mwj4vwac4fgAZAhdRlwaRNz+KGK0sX2wls3l+sLbeaUeB
         Ns+dKiIbKPFqDkMm3rLlMXU2AUeMR/B712rKy4d6erVd4e1aRNpNEtej407V5XI8EsHh
         Mjvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b="k/JHoGQL";
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 11sor36155665pgh.67.2019.07.29.07.21.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 07:21:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b="k/JHoGQL";
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=4K6A/BJDfCnYwl6IVii41tr2UtMMY6EbkGcfzGbxqy8=;
        b=k/JHoGQL3OaWjfKuB6ioubmbYvLKnaDcEsQSlZ0kxcHmP5VGUrtqxNo24Jr1UGk7Pg
         mMC/pY3m20FNhsjPW1tVbcfI++WoT1CENSZoJWSdD6AAvSgsDmfj0tgLWDoIEwvJ8a++
         NwUxEPtnkRK5BNLFxvThjsSeZesfAEDgsvTuA=
X-Google-Smtp-Source: APXvYqxEBTVWIFfjuDm3vIEII09WI0/WS8SQcmJ44QaatzBLcmtekytmxZx95yK8Os69M/yJP8MEZQ==
X-Received: by 2002:a63:9e54:: with SMTP id r20mr70626655pgo.64.1564410080536;
        Mon, 29 Jul 2019 07:21:20 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id 85sm65677300pfv.130.2019.07.29.07.21.18
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:21:19 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	linux-kernel@vger.kernel.org,
	mark.rutland@arm.com,
	dvyukov@google.com
Cc: Daniel Axtens <dja@axtens.net>
Subject: [PATCH v2 1/3] kasan: support backing vmalloc space with real shadow memory
Date: Tue, 30 Jul 2019 00:21:06 +1000
Message-Id: <20190729142108.23343-2-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190729142108.23343-1-dja@axtens.net>
References: <20190729142108.23343-1-dja@axtens.net>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hook into vmalloc and vmap, and dynamically allocate real shadow
memory to back the mappings.

Most mappings in vmalloc space are small, requiring less than a full
page of shadow space. Allocating a full shadow page per mapping would
therefore be wasteful. Furthermore, to ensure that different mappings
use different shadow pages, mappings would have to be aligned to
KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE.

Instead, share backing space across multiple mappings. Allocate
a backing page the first time a mapping in vmalloc space uses a
particular page of the shadow region. Keep this page around
regardless of whether the mapping is later freed - in the mean time
the page could have become shared by another vmalloc mapping.

This can in theory lead to unbounded memory growth, but the vmalloc
allocator is pretty good at reusing addresses, so the practical memory
usage grows at first but then stays fairly stable.

This requires architecture support to actually use: arches must stop
mapping the read-only zero page over portion of the shadow region that
covers the vmalloc space and instead leave it unmapped.

This allows KASAN with VMAP_STACK, and will be needed for architectures
that do not have a separate module space (e.g. powerpc64, which I am
currently working on).

Link: https://bugzilla.kernel.org/show_bug.cgi?id=202009
Signed-off-by: Daniel Axtens <dja@axtens.net>

---

v2: let kasan_unpoison_shadow deal with ranges that do not use a
    full shadow byte.
---
 Documentation/dev-tools/kasan.rst | 60 +++++++++++++++++++++++++++++++
 include/linux/kasan.h             | 16 +++++++++
 lib/Kconfig.kasan                 | 16 +++++++++
 lib/test_kasan.c                  | 26 ++++++++++++++
 mm/kasan/common.c                 | 51 ++++++++++++++++++++++++++
 mm/kasan/generic_report.c         |  3 ++
 mm/kasan/kasan.h                  |  1 +
 mm/vmalloc.c                      | 15 +++++++-
 8 files changed, 187 insertions(+), 1 deletion(-)

diff --git a/Documentation/dev-tools/kasan.rst b/Documentation/dev-tools/kasan.rst
index b72d07d70239..35fda484a672 100644
--- a/Documentation/dev-tools/kasan.rst
+++ b/Documentation/dev-tools/kasan.rst
@@ -215,3 +215,63 @@ brk handler is used to print bug reports.
 A potential expansion of this mode is a hardware tag-based mode, which would
 use hardware memory tagging support instead of compiler instrumentation and
 manual shadow memory manipulation.
+
+What memory accesses are sanitised by KASAN?
+--------------------------------------------
+
+The kernel maps memory in a number of different parts of the address
+space. This poses something of a problem for KASAN, which requires
+that all addresses accessed by instrumented code have a valid shadow
+region.
+
+The range of kernel virtual addresses is large: there is not enough
+real memory to support a real shadow region for every address that
+could be accessed by the kernel.
+
+By default
+~~~~~~~~~~
+
+By default, architectures only map real memory over the shadow region
+for the linear mapping (and potentially other small areas). For all
+other areas - such as vmalloc and vmemmap space - a single read-only
+page is mapped over the shadow area. This read-only shadow page
+declares all memory accesses as permitted.
+
+This presents a problem for modules: they do not live in the linear
+mapping, but in a dedicated module space. By hooking in to the module
+allocator, KASAN can temporarily map real shadow memory to cover
+them. This allows detection of invalid accesses to module globals, for
+example.
+
+This also creates an incompatibility with ``VMAP_STACK``: if the stack
+lives in vmalloc space, it will be shadowed by the read-only page, and
+the kernel will fault when trying to set up the shadow data for stack
+variables.
+
+CONFIG_KASAN_VMALLOC
+~~~~~~~~~~~~~~~~~~~~
+
+With ``CONFIG_KASAN_VMALLOC``, KASAN can cover vmalloc space at the
+cost of greater memory usage. Currently this is only supported on x86.
+
+This works by hooking into vmalloc and vmap, and dynamically
+allocating real shadow memory to back the mappings.
+
+Most mappings in vmalloc space are small, requiring less than a full
+page of shadow space. Allocating a full shadow page per mapping would
+therefore be wasteful. Furthermore, to ensure that different mappings
+use different shadow pages, mappings would have to be aligned to
+``KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE``.
+
+Instead, we share backing space across multiple mappings. We allocate
+a backing page the first time a mapping in vmalloc space uses a
+particular page of the shadow region. We keep this page around
+regardless of whether the mapping is later freed - in the mean time
+this page could have become shared by another vmalloc mapping.
+
+This can in theory lead to unbounded memory growth, but the vmalloc
+allocator is pretty good at reusing addresses, so the practical memory
+usage grows at first but then stays fairly stable.
+
+This allows ``VMAP_STACK`` support on x86, and enables support of
+architectures that do not have a fixed module region.
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index cc8a03cc9674..fcabc5a03fca 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -70,8 +70,18 @@ struct kasan_cache {
 	int free_meta_offset;
 };
 
+/*
+ * These functions provide a special case to support backing module
+ * allocations with real shadow memory. With KASAN vmalloc, the special
+ * case is unnecessary, as the work is handled in the generic case.
+ */
+#ifndef CONFIG_KASAN_VMALLOC
 int kasan_module_alloc(void *addr, size_t size);
 void kasan_free_shadow(const struct vm_struct *vm);
+#else
+static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
+static inline void kasan_free_shadow(const struct vm_struct *vm) {}
+#endif
 
 int kasan_add_zero_shadow(void *start, unsigned long size);
 void kasan_remove_zero_shadow(void *start, unsigned long size);
@@ -194,4 +204,10 @@ static inline void *kasan_reset_tag(const void *addr)
 
 #endif /* CONFIG_KASAN_SW_TAGS */
 
+#ifdef CONFIG_KASAN_VMALLOC
+void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area);
+#else
+static inline void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area) {}
+#endif
+
 #endif /* LINUX_KASAN_H */
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 4fafba1a923b..a320dc2e9317 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -6,6 +6,9 @@ config HAVE_ARCH_KASAN
 config HAVE_ARCH_KASAN_SW_TAGS
 	bool
 
+config	HAVE_ARCH_KASAN_VMALLOC
+	bool
+
 config CC_HAS_KASAN_GENERIC
 	def_bool $(cc-option, -fsanitize=kernel-address)
 
@@ -135,6 +138,19 @@ config KASAN_S390_4_LEVEL_PAGING
 	  to 3TB of RAM with KASan enabled). This options allows to force
 	  4-level paging instead.
 
+config KASAN_VMALLOC
+	bool "Back mappings in vmalloc space with real shadow memory"
+	depends on KASAN && HAVE_ARCH_KASAN_VMALLOC
+	help
+	  By default, the shadow region for vmalloc space is the read-only
+	  zero page. This means that KASAN cannot detect errors involving
+	  vmalloc space.
+
+	  Enabling this option will hook in to vmap/vmalloc and back those
+	  mappings with real shadow memory allocated on demand. This allows
+	  for KASAN to detect more sorts of errors (and to support vmapped
+	  stacks), but at the cost of higher memory usage.
+
 config TEST_KASAN
 	tristate "Module for testing KASAN for bug detection"
 	depends on m && KASAN
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index b63b367a94e8..d375246f5f96 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -18,6 +18,7 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/uaccess.h>
+#include <linux/vmalloc.h>
 
 /*
  * Note: test functions are marked noinline so that their names appear in
@@ -709,6 +710,30 @@ static noinline void __init kmalloc_double_kzfree(void)
 	kzfree(ptr);
 }
 
+#ifdef CONFIG_KASAN_VMALLOC
+static noinline void __init vmalloc_oob(void)
+{
+	void *area;
+
+	pr_info("vmalloc out-of-bounds\n");
+
+	/*
+	 * We have to be careful not to hit the guard page.
+	 * The MMU will catch that and crash us.
+	 */
+	area = vmalloc(3000);
+	if (!area) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	((volatile char *)area)[3100];
+	vfree(area);
+}
+#else
+static void __init vmalloc_oob(void) {}
+#endif
+
 static int __init kmalloc_tests_init(void)
 {
 	/*
@@ -752,6 +777,7 @@ static int __init kmalloc_tests_init(void)
 	kasan_strings();
 	kasan_bitops();
 	kmalloc_double_kzfree();
+	vmalloc_oob();
 
 	kasan_restore_multi_shot(multishot);
 
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 2277b82902d8..15d8f4ad581b 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -568,6 +568,7 @@ void kasan_kfree_large(void *ptr, unsigned long ip)
 	/* The object will be poisoned by page_alloc. */
 }
 
+#ifndef CONFIG_KASAN_VMALLOC
 int kasan_module_alloc(void *addr, size_t size)
 {
 	void *ret;
@@ -603,6 +604,7 @@ void kasan_free_shadow(const struct vm_struct *vm)
 	if (vm->flags & VM_KASAN)
 		vfree(kasan_mem_to_shadow(vm->addr));
 }
+#endif
 
 extern void __kasan_report(unsigned long addr, size_t size, bool is_write, unsigned long ip);
 
@@ -722,3 +724,52 @@ static int __init kasan_memhotplug_init(void)
 
 core_initcall(kasan_memhotplug_init);
 #endif
+
+#ifdef CONFIG_KASAN_VMALLOC
+void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area)
+{
+	unsigned long shadow_alloc_start, shadow_alloc_end;
+	unsigned long addr;
+	unsigned long backing;
+	pgd_t *pgdp;
+	p4d_t *p4dp;
+	pud_t *pudp;
+	pmd_t *pmdp;
+	pte_t *ptep;
+	pte_t backing_pte;
+
+	shadow_alloc_start = ALIGN_DOWN(
+		(unsigned long)kasan_mem_to_shadow(area->addr),
+		PAGE_SIZE);
+	shadow_alloc_end = ALIGN(
+		(unsigned long)kasan_mem_to_shadow(area->addr + area->size),
+		PAGE_SIZE);
+
+	addr = shadow_alloc_start;
+	do {
+		pgdp = pgd_offset_k(addr);
+		p4dp = p4d_alloc(&init_mm, pgdp, addr);
+		pudp = pud_alloc(&init_mm, p4dp, addr);
+		pmdp = pmd_alloc(&init_mm, pudp, addr);
+		ptep = pte_alloc_kernel(pmdp, addr);
+
+		/*
+		 * we can validly get here if pte is not none: it means we
+		 * allocated this page earlier to use part of it for another
+		 * allocation
+		 */
+		if (pte_none(*ptep)) {
+			backing = __get_free_page(GFP_KERNEL);
+			backing_pte = pfn_pte(PFN_DOWN(__pa(backing)),
+					      PAGE_KERNEL);
+			set_pte_at(&init_mm, addr, ptep, backing_pte);
+		}
+	} while (addr += PAGE_SIZE, addr != shadow_alloc_end);
+
+	kasan_unpoison_shadow(area->addr, requested_size);
+	requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
+	kasan_poison_shadow(area->addr + requested_size,
+			    area->size - requested_size,
+			    KASAN_VMALLOC_INVALID);
+}
+#endif
diff --git a/mm/kasan/generic_report.c b/mm/kasan/generic_report.c
index 36c645939bc9..2d97efd4954f 100644
--- a/mm/kasan/generic_report.c
+++ b/mm/kasan/generic_report.c
@@ -86,6 +86,9 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
 	case KASAN_ALLOCA_RIGHT:
 		bug_type = "alloca-out-of-bounds";
 		break;
+	case KASAN_VMALLOC_INVALID:
+		bug_type = "vmalloc-out-of-bounds";
+		break;
 	}
 
 	return bug_type;
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 014f19e76247..8b1f2fbc780b 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -25,6 +25,7 @@
 #endif
 
 #define KASAN_GLOBAL_REDZONE    0xFA  /* redzone for global variable */
+#define KASAN_VMALLOC_INVALID   0xF9  /* unallocated space in vmapped page */
 
 /*
  * Stack redzone shadow values
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 4fa8d84599b0..8cbcb5056c9b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2012,6 +2012,15 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	va->vm = vm;
 	va->flags |= VM_VM_AREA;
 	spin_unlock(&vmap_area_lock);
+
+	/*
+	 * If we are in vmalloc space we need to cover the shadow area with
+	 * real memory. If we come here through VM_ALLOC, this is done
+	 * by a higher level function that has access to the true size,
+	 * which might not be a full page.
+	 */
+	if (is_vmalloc_addr(vm->addr) && !(vm->flags & VM_ALLOC))
+		kasan_cover_vmalloc(vm->size, vm);
 }
 
 static void clear_vm_uninitialized_flag(struct vm_struct *vm)
@@ -2483,6 +2492,8 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	if (!addr)
 		return NULL;
 
+	kasan_cover_vmalloc(real_size, area);
+
 	/*
 	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
 	 * flag. It means that vm_struct is not fully initialized.
@@ -3324,9 +3335,11 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 	spin_unlock(&vmap_area_lock);
 
 	/* insert all vm's */
-	for (area = 0; area < nr_vms; area++)
+	for (area = 0; area < nr_vms; area++) {
 		setup_vmalloc_vm(vms[area], vas[area], VM_ALLOC,
 				 pcpu_get_vm_areas);
+		kasan_cover_vmalloc(sizes[area], vms[area]);
+	}
 
 	kfree(vas);
 	return vms;
-- 
2.20.1

