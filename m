Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8B1CC43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8980C208C2
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kQVzfXvt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8980C208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 644CC6B0270; Sat, 27 Apr 2019 02:43:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E0D66B0271; Sat, 27 Apr 2019 02:43:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30D0C6B0272; Sat, 27 Apr 2019 02:43:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFF1B6B0270
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:29 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z12so3498634pgs.4
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=QhBGq/JNavwlurWIVFo7GWw2xI+63VIDOiZrYQv9auY=;
        b=pienI7LaBzMaV5GLUlXgqOtQiWkv3Zo4UpuTta6yCLch5N0tKXiR6DOmuuNDXfM9eN
         7f1FPgAsAjDIMN6VoMI6gQuEhTMdyRwZG6tY5ZZZ9OZjH0rRK0tGnCYOFjPozhloEZvz
         TQfMG+E4jzbq6JvwzzAiw7uLg6n0RUfv3euBzUSwhP60v62jV66ZpqDrGtr24tUNYU0L
         H54nLpR+mcW+459YrmOt//btm50UrfjEg9oFsfXwrDlnvVZbthmXouiOZr+OEnWiBa1P
         SgusRytoiR7oqjwn6/dAl/etWiknLlYPyqcUPdwj8QORVKNCg55zprOK/YLlGADq4AZl
         CDzQ==
X-Gm-Message-State: APjAAAVtEy/fFbPM6J5CQLZkt/tnn+rgGFHH74ZRvBEkrcapoD50uIAp
	qlPGSkAD8fd6UjYP9KMnRg7SlBRWi4Zad3JcCzqw+H2YL+teDdsfiyV2Q5B/qEVzbmsDa3GOckw
	xmZTUJUz/5MKrckW15oOI5Pk/x7ATQSZMoknXfHUufQMRDgOLhde14TGUVlfj9viBWA==
X-Received: by 2002:a62:62c3:: with SMTP id w186mr50088083pfb.73.1556347409542;
        Fri, 26 Apr 2019 23:43:29 -0700 (PDT)
X-Received: by 2002:a62:62c3:: with SMTP id w186mr50088010pfb.73.1556347408302;
        Fri, 26 Apr 2019 23:43:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347408; cv=none;
        d=google.com; s=arc-20160816;
        b=CzP3FY1YgF3cdnK+e1oN74kRyYMHgMGZi+CIcvMS5g/GdFkFmC5DkTZGEw6qZwrrbA
         Z7YQYmEN9wMRILnW73u3q/HoNFmJ7QVonQHr+NDMKNl0qxqro5UwTBwzVdvg9l4JFGU9
         mWOM8QJztI43Ubf1/LEGvSJfK1QUrO3CnkloRgU9JXHS4vEbtMK09RmAaUX/+VHl1s7e
         VqQ2VvvCkuNlqAqF9MQr7GjfCYXKfKXRKj9zprrJ8BYXLUywsc/70tNSzPhitR9y5hLl
         dMnVfvwVz3u/rXxI5GCUEJIEIRX7kGBtEoVLbe2rUE1OS8eazwCRquHzwWNHOESxbPHU
         7LWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=QhBGq/JNavwlurWIVFo7GWw2xI+63VIDOiZrYQv9auY=;
        b=qkaITdu6k6H2O/d57sGhSRtUqqximCbAomhuAfEHXjzOjD92Ev2RTK3yziCb2OedN9
         jdm2WLcTWIv2I7Z/u+QeC99YIOLX4E8CCJqY4NBMqglzaQ7iCcB82L8uh80goHXLPJSE
         SiE19sHbP13DmjfDdbAoiaAuZot/dJPTvhgl+s4o7WZmrEXI7+KwrR3/zd6IE61AG7xs
         QN5+9MV0uAYrGzNQXhPUOtikmNrMTot3qBoctxSxblKIvBAlV+Fv2j1mDbggIgCDJgK7
         OVkYhK72vrgU5pcJQaK8r57B7e2e5r9N4PVolarR+EoLgdOqb5Zh2RRU3KXEgnXlIWBj
         p2ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kQVzfXvt;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor2804967pgh.79.2019.04.26.23.43.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kQVzfXvt;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=QhBGq/JNavwlurWIVFo7GWw2xI+63VIDOiZrYQv9auY=;
        b=kQVzfXvt7w7FyD24D6OW7cca/iq64cXIdYieWuyKwNk+RlpS1Vrvzmoacb3ff7XKNz
         uSrIDJVnl0StI02S4mDmT9/orsTdFCLqxairNBVJHpFQOlVF+P545I79O3XIMap7MmNx
         B+eyRkbN1Pn1P8cvmN/nIG6h/QsEeRGGk823Xen9FH/1q+TdS2le7wdgc7mk51khO50a
         FM2ov6bJpTRs8rPyT3sOey+TdqaV/ShHovsU9ChNEC3Nj8Fx8yLDbxMu7UkHtsd0HXsr
         xXsGi8x4xGLugp1QRQm3EmYH1Hg5T8pmM4cIqX1ra4UyE2ICcBAtQsttpAyF860DV5oa
         hYYA==
X-Google-Smtp-Source: APXvYqzGKQmON9BzHH89UmuJkvJzJbwysA6AfztkU3vJ+XbGjoeBhsjpEhkWgnx/yazqn7g52/ieFg==
X-Received: by 2002:a63:5466:: with SMTP id e38mr48658719pgm.340.1556347407789;
        Fri, 26 Apr 2019 23:43:27 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:27 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Pavel Machek <pavel@ucw.cz>
Subject: [PATCH v6 16/24] mm: Make hibernate handle unmapped pages
Date: Fri, 26 Apr 2019 16:22:55 -0700
Message-Id: <20190426232303.28381-17-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rick Edgecombe <rick.p.edgecombe@intel.com>

Make hibernate handle unmapped pages on the direct map when
CONFIG_ARCH_HAS_SET_ALIAS is set. These functions allow for setting pages
to invalid configurations, so now hibernate should check if the pages have
valid mappings and handle if they are unmapped when doing a hibernate
save operation.

Previously this checking was already done when CONFIG_DEBUG_PAGEALLOC
was configured. It does not appear to have a big hibernating performance
impact. The speed of the saving operation before this change was measured
as 819.02 MB/s, and after was measured at 813.32 MB/s.

Before:
[    4.670938] PM: Wrote 171996 kbytes in 0.21 seconds (819.02 MB/s)

After:
[    4.504714] PM: Wrote 178932 kbytes in 0.22 seconds (813.32 MB/s)

Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Borislav Petkov <bp@alien8.de>
Acked-by: Pavel Machek <pavel@ucw.cz>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/mm/pageattr.c  |  4 ----
 include/linux/mm.h      | 18 ++++++------------
 kernel/power/snapshot.c |  5 +++--
 mm/page_alloc.c         |  7 +++++--
 4 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 3574550192c6..daf4d645e537 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -2257,7 +2257,6 @@ int set_direct_map_default_noflush(struct page *page)
 	return __set_pages_p(page, 1);
 }
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
 void __kernel_map_pages(struct page *page, int numpages, int enable)
 {
 	if (PageHighMem(page))
@@ -2302,11 +2301,8 @@ bool kernel_page_present(struct page *page)
 	pte = lookup_address((unsigned long)page_address(page), &level);
 	return (pte_val(*pte) & _PAGE_PRESENT);
 }
-
 #endif /* CONFIG_HIBERNATION */
 
-#endif /* CONFIG_DEBUG_PAGEALLOC */
-
 int __init kernel_map_pages_in_pgd(pgd_t *pgd, u64 pfn, unsigned long address,
 				   unsigned numpages, unsigned long page_flags)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b10c21630f5..083d7b4863ed 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2610,37 +2610,31 @@ static inline void kernel_poison_pages(struct page *page, int numpages,
 					int enable) { }
 #endif
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
 extern bool _debug_pagealloc_enabled;
-extern void __kernel_map_pages(struct page *page, int numpages, int enable);
 
 static inline bool debug_pagealloc_enabled(void)
 {
-	return _debug_pagealloc_enabled;
+	return IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) && _debug_pagealloc_enabled;
 }
 
+#if defined(CONFIG_DEBUG_PAGEALLOC) || defined(CONFIG_ARCH_HAS_SET_DIRECT_MAP)
+extern void __kernel_map_pages(struct page *page, int numpages, int enable);
+
 static inline void
 kernel_map_pages(struct page *page, int numpages, int enable)
 {
-	if (!debug_pagealloc_enabled())
-		return;
-
 	__kernel_map_pages(page, numpages, enable);
 }
 #ifdef CONFIG_HIBERNATION
 extern bool kernel_page_present(struct page *page);
 #endif	/* CONFIG_HIBERNATION */
-#else	/* CONFIG_DEBUG_PAGEALLOC */
+#else	/* CONFIG_DEBUG_PAGEALLOC || CONFIG_ARCH_HAS_SET_DIRECT_MAP */
 static inline void
 kernel_map_pages(struct page *page, int numpages, int enable) {}
 #ifdef CONFIG_HIBERNATION
 static inline bool kernel_page_present(struct page *page) { return true; }
 #endif	/* CONFIG_HIBERNATION */
-static inline bool debug_pagealloc_enabled(void)
-{
-	return false;
-}
-#endif	/* CONFIG_DEBUG_PAGEALLOC */
+#endif	/* CONFIG_DEBUG_PAGEALLOC || CONFIG_ARCH_HAS_SET_DIRECT_MAP */
 
 #ifdef __HAVE_ARCH_GATE_AREA
 extern struct vm_area_struct *get_gate_vma(struct mm_struct *mm);
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index f08a1e4ee1d4..bc9558ab1e5b 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1342,8 +1342,9 @@ static inline void do_copy_page(long *dst, long *src)
  * safe_copy_page - Copy a page in a safe way.
  *
  * Check if the page we are going to copy is marked as present in the kernel
- * page tables (this always is the case if CONFIG_DEBUG_PAGEALLOC is not set
- * and in that case kernel_page_present() always returns 'true').
+ * page tables. This always is the case if CONFIG_DEBUG_PAGEALLOC or
+ * CONFIG_ARCH_HAS_SET_DIRECT_MAP is not set. In that case kernel_page_present()
+ * always returns 'true'.
  */
 static void safe_copy_page(void *dst, struct page *s_page)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d96ca5bc555b..34a70681a4af 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1131,7 +1131,9 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	}
 	arch_free_page(page, order);
 	kernel_poison_pages(page, 1 << order, 0);
-	kernel_map_pages(page, 1 << order, 0);
+	if (debug_pagealloc_enabled())
+		kernel_map_pages(page, 1 << order, 0);
+
 	kasan_free_nondeferred_pages(page, order);
 
 	return true;
@@ -2001,7 +2003,8 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	set_page_refcounted(page);
 
 	arch_alloc_page(page, order);
-	kernel_map_pages(page, 1 << order, 1);
+	if (debug_pagealloc_enabled())
+		kernel_map_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
 	kernel_poison_pages(page, 1 << order, 1);
 	set_page_owner(page, order, gfp_flags);
-- 
2.17.1

