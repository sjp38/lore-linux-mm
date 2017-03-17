Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C21926B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 13:27:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g2so150551917pge.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 10:27:20 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c2si9253639plb.50.2017.03.17.10.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 10:27:19 -0700 (PDT)
Date: Fri, 17 Mar 2017 20:27:12 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 5/7] mm/gup: Implement dev_pagemap logic in generic
 get_user_pages_fast()
Message-ID: <20170317172711.kx4oed6jbe5knbgs@black.fi.intel.com>
References: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
 <20170316152655.37789-6-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170316152655.37789-6-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>

On Thu, Mar 16, 2017 at 06:26:53PM +0300, Kirill A. Shutemov wrote:
> +static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
> +		unsigned long end, struct page **pages, int *nr)
> +{
> +	unsigned long fault_pfn;
> +
> +	fault_pfn = pmd_pfn(pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
> +}
> +
> +static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
> +		unsigned long end, struct page **pages, int *nr)
> +{
> +	unsigned long fault_pfn;
> +
> +	fault_pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> +	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
> +}
> +

PowerPC doesn't [always] provide pmd_pfn() and pud_pfn().

Fixup:

diff --git a/mm/gup.c b/mm/gup.c
index 5cc489d98562..6f36cbc294cf 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1287,6 +1287,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 }
 #endif /* __HAVE_ARCH_PTE_SPECIAL */
 
+#ifdef __HAVE_ARCH_PTE_DEVMAP
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
@@ -1328,6 +1329,21 @@ static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
 	fault_pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
 }
+#else
+static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
+		unsigned long end, struct page **pages, int *nr)
+{
+	BUILD_BUG();
+	return 0;
+}
+
+static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
+		unsigned long end, struct page **pages, int *nr)
+{
+	BUILD_BUG();
+	return 0;
+}
+#endif
 
 static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
@@ -1338,7 +1354,6 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	if (!pmd_access_permitted(orig, write))
 		return 0;
 
-	VM_BUG_ON(!pfn_valid(pmd_pfn(orig)));
 	if (pmd_devmap(orig))
 		return __gup_device_huge_pmd(orig, addr, end, pages, nr);
 
@@ -1378,7 +1393,6 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 	if (!pud_access_permitted(orig, write))
 		return 0;
 
-	VM_BUG_ON(!pfn_valid(pud_pfn(orig)));
 	if (pud_devmap(orig))
 		return __gup_device_huge_pud(orig, addr, end, pages, nr);
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
