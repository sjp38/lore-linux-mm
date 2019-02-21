Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04015C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B14B720818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B14B720818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2BA78E00D2; Thu, 21 Feb 2019 18:51:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F01498E00CD; Thu, 21 Feb 2019 18:51:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF4668E00D2; Thu, 21 Feb 2019 18:51:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DAD18E00CD
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:08 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 11so309882pgd.19
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=iG1R2RBktKeFpHfZ1a/wtU6qsgc12QlvnPW3fBUPBtk=;
        b=E5Lbzr2GVkdbP8yTpxBxMXx3sSQRav1+z/a08dAiMRCxxOnDAVUg9j+qlMfVQ3WQ4Y
         Ch02hl+dRJ3MqEv9cFrRfXQPO7jL+lASWPY67Z3Jmt58TOd9I4AZPEpSqMVJBMmMacxs
         RxT0t/BHUHVDNgCMamsNVbsNZj0mPgD+66tfMQNTie4Ty2+UmAKQV3PKaRjrje60iwkL
         pfQb++Ia/6JpI1jQQntx1Aqiff9jWGJRGKYW2dJogpvjsj5qAQ3aTjRCo+/7VPbew/2D
         AW6tCP4LiyDCADQ/v9JEtu1cBDJQxXY7KsIsAdeIm9Zw2FEBubGrPt4DQYCR/lpsWhuZ
         1jvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ0ywv1AVPOzFf6I8ooNCu443OXsrIeTzeFmTxXJ8m6PQwge9B1
	xRRtArZ5yXsKp9L2L58LVDxshUuDXfnGAvG/G0lKLYoRyH6Y8eMI/OagKw8PLru82+4NSYorOam
	3nlAbVbg4W3LV4MmV4+XH6NnxgAMOgmhxvU52FPYqw8P99P7FlczGSqtbQqG3OegdNw==
X-Received: by 2002:a63:534c:: with SMTP id t12mr1040688pgl.205.1550793068235;
        Thu, 21 Feb 2019 15:51:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IayCtXafJgp3eUkVgHgR8aM6TrKnDz0Ocpu8/t1tLeTYrOWKywk6owwaq+/XiA+EPFGb/LX
X-Received: by 2002:a63:534c:: with SMTP id t12mr1040634pgl.205.1550793067310;
        Thu, 21 Feb 2019 15:51:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793067; cv=none;
        d=google.com; s=arc-20160816;
        b=PjBsjKGLiwrzfQ8eBuFYaDUruI/p12YBPQvez/9+vQeeG7UNvq13DKn9qkQhHRCpBR
         dDMGccm3Uqz8byhqHEwBFWH9J2Had+nDuRhwnumgLWxS5cQCEeEKIASMNHyvNqXNGrEb
         0TxPzMr82JW76KyoWIJDhUVFQPq+znRl1LGAfZc78D1Tt0kDj8XOUtNM6qfYg17aJhwN
         IcGgqZccFrR9Io5IP+yoHNNIAwWL8AML1scRkRe8OKWT3UzYxigYU74fOB8/SVv89G+9
         XDvW+dstdOXYmZ6rw/9yCg3QAYZU9SAM/rw5PzBwmehrEENlnLSh5cX4VxGMgPhV5jEe
         QKog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=iG1R2RBktKeFpHfZ1a/wtU6qsgc12QlvnPW3fBUPBtk=;
        b=ZEZ10NEbafMtlYbiNROT0iU592aVRM+G3J4X3434LaNbGRwi1GzDlA9xb1iqItmXTZ
         gfwzBSpV83bHizYL9dlTQMReZK4rzyicL07Iof2noctMQRwpOHNxLHAqPqbtpiJJ0tC4
         MG4mQhLW7Gq0M6l3irsS82N6+kY9x3SpJALW/d+6fpGV33e9BO/EjDneKUUhwTI9ClYE
         TIBLteiqwB4nuRCI9q6lPbt8QLtAJGc83fmJRBPFaf0HR04uvhc83ImgjFuaK0bsdhqm
         x3o2LWnNH8KBShl7kf0Q0pAYUmCilOaMSe7izr6BAb4tdu3PgO/lW3+rqOZBad6S54QH
         HcjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:07 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:06 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394932"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:05 -0800
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
Subject: [PATCH v3 14/20] mm: Make hibernate handle unmapped pages
Date: Thu, 21 Feb 2019 15:44:45 -0800
Message-Id: <20190221234451.17632-15-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
index fff9c91ad177..1cffee05f987 100644
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
index 80bb6408fe73..5748e9ce133e 100644
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
index 640b2034edd6..f69b2920d4f4 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1334,8 +1334,9 @@ static inline void do_copy_page(long *dst, long *src)
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

