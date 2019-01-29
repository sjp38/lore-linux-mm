Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D37CC282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B73821841
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B73821841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA0168E000E; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D45648E0012; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A88AF8E0011; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 463238E0009
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id p9so15440437pfj.3
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Yncdr+ZUNpa2Uv2D6DxE8u2f4VXkTONRNt4fbXj4dXE=;
        b=tUYV7V6euKCofYFdFpkXbbRP1l6qpUHdW/VJ4pusvTBhQcSmMafquL7FSUIaHYgnyo
         +5gduKz+prQMA83bY2y55UkVCfDJtOuXKgUkUrePooaRrAHgW72uTMtMAO9fADsdpJMa
         wGgR8q0+jbB88hEhylZSph69sz9sID4dx6XeLnQ8gP8K9MFZ2idOh+A8ypTB2FQOkqVa
         b6gpAKLeSQcTEP7WJT+XHJMA8+e4C5uqnkD+MvibFkVsI0Rh18tioXSXVZZL66wToZr3
         tD9wGHQXVBWYBdzrW58wBJCSkxrpXGUJHvVgXi4MWZTVW7K6fD3DfpCQ2fkCbXvymG5D
         aumg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfXQP+RZCvpfqn/34E2jXqTu97rYbHLV1Ygxii5yyMUPH4EXHoN
	68HQ54rXaUYLvuBrLEApGW7qEvg+mQ7np8ySNNsWKly1yBPyP/yGzkC7gXkzOSYxyJiBc3/bAaN
	eNoOuz0uw07f7dzM0QWSFvQYp3maWaU1LSJzMlK4vZixY3hkshcBPrR/b7pbf7F1M6w==
X-Received: by 2002:a63:4e41:: with SMTP id o1mr22288089pgl.282.1548722354914;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6ffbGCGAXsR7TwLxUOYY4bVKEWl+2olHuNXdgnkLMv2ln8/1zCOJn/ZOBMFG3SeT/52LiY
X-Received: by 2002:a63:4e41:: with SMTP id o1mr22288054pgl.282.1548722354139;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722354; cv=none;
        d=google.com; s=arc-20160816;
        b=On4b4Pubelru3gz7XftceKtmR2qn7bP4TZ1uuAPnBWsnQ5pAMJT99VnaWfD5shdAZ5
         4V95B1AbU8ThmOjZplAVCBwBQE2nhO0aUX/3dGLPN8MEx2W5vClukeatWAK+ew0dagjN
         VMEwSVHvXmU6dGpaLNXiql/Vu8sqLG0cpUJdmmNVMqZLbkce3ZvXjTeTDBjx7TOV00MK
         DBMf+cMUDARVh+xFKJcfyCW+B5Qk6bYeAVhwJncA49TtbyVx9oFY97RRlmOjjoZd6183
         xoOPv+PO8H9vyX+RbIFSOgjFDC8U4O1BTQP46REsqLnBneZb6WWYkiD8da51YBkGIWTp
         vdkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Yncdr+ZUNpa2Uv2D6DxE8u2f4VXkTONRNt4fbXj4dXE=;
        b=aH6nckAEizc3aI4gpnrikSLRw6k1s91bpEMAem9i4N/OTU9dAICxW86DXJbsj+j8r8
         jvWRgiNgbp5BzkAgqL66KmOYAVz8Xo0fk10KqdPFjzgh+T9AfGPJtjHCGH+jisyjaw5+
         NdOjWuaXfA6xUqQyVWrIX8BPcIGlSkfNDVvG0kpznnd9cNRLl1SwacqqIulUWGz9MxRW
         1kTy5w6BMUCvzP3g8roqV7jDIN66DMcYu8cE71PCF4wpxh8u1Ks9x6hgCdbSIHPa8uGq
         gMA+s+ICBgjwnDH0LdIYiYJuP0fenLaHB8FmFue1UAHHMADKPi8XQB23ignb1hNwT0Iw
         h9mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s17si4514712pgi.513.2019.01.28.16.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921926"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:12 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
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
Subject: [PATCH v2 14/20] mm: Make hibernate handle unmapped pages
Date: Mon, 28 Jan 2019 16:34:16 -0800
Message-Id: <20190129003422.9328-15-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For architectures with CONFIG_ARCH_HAS_SET_ALIAS, pages can be unmapped
briefly on the directmap, even when CONFIG_DEBUG_PAGEALLOC is not
configured. So this changes kernel_map_pages and kernel_page_present to be
defined when CONFIG_ARCH_HAS_SET_ALIAS is defined as well. It also changes
places (page_alloc.c) where those functions are assumed to only be
implemented when CONFIG_DEBUG_PAGEALLOC is defined.

So now when CONFIG_ARCH_HAS_SET_ALIAS=y, hibernate will handle not present
page when saving. Previously this was already done when
CONFIG_DEBUG_PAGEALLOC was configured. It does not appear to have a big
hibernating performance impact.

Before:
[    4.670938] PM: Wrote 171996 kbytes in 0.21 seconds (819.02 MB/s)

After:
[    4.504714] PM: Wrote 178932 kbytes in 0.22 seconds (813.32 MB/s)

Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Pavel Machek <pavel@ucw.cz>
Acked-by: Pavel Machek <pavel@ucw.cz>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/mm/pageattr.c |  4 ----
 include/linux/mm.h     | 18 ++++++------------
 mm/page_alloc.c        |  7 +++++--
 3 files changed, 11 insertions(+), 18 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 3a51915a1410..717bdc188aab 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -2257,7 +2257,6 @@ int set_alias_default_noflush(struct page *page)
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
index 80bb6408fe73..b362a280a919 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2642,37 +2642,31 @@ static inline void kernel_poison_pages(struct page *page, int numpages,
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
 
+#if defined(CONFIG_DEBUG_PAGEALLOC) || defined(CONFIG_ARCH_HAS_SET_ALIAS)
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
+#else	/* CONFIG_DEBUG_PAGEALLOC || CONFIG_ARCH_HAS_SET_ALIAS */
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
+#endif	/* CONFIG_DEBUG_PAGEALLOC || CONFIG_ARCH_HAS_SET_ALIAS */
 
 #ifdef __HAVE_ARCH_GATE_AREA
 extern struct vm_area_struct *get_gate_vma(struct mm_struct *mm);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d295c9bc01a8..92d0a0934274 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1074,7 +1074,9 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	}
 	arch_free_page(page, order);
 	kernel_poison_pages(page, 1 << order, 0);
-	kernel_map_pages(page, 1 << order, 0);
+	if (debug_pagealloc_enabled())
+		kernel_map_pages(page, 1 << order, 0);
+
 	kasan_free_nondeferred_pages(page, order);
 
 	return true;
@@ -1944,7 +1946,8 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	set_page_refcounted(page);
 
 	arch_alloc_page(page, order);
-	kernel_map_pages(page, 1 << order, 1);
+	if (debug_pagealloc_enabled())
+		kernel_map_pages(page, 1 << order, 1);
 	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
 	set_page_owner(page, order, gfp_flags);
-- 
2.17.1

