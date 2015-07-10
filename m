Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDD36B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 17:16:23 -0400 (EDT)
Received: by oiyy130 with SMTP id y130so219763369oiy.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 14:16:23 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id b5si7676767oej.10.2015.07.10.14.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 14:16:22 -0700 (PDT)
Message-ID: <1436562922.3214.124.camel@hp.com>
Subject: Re: [PATCH 1/2] x86: Fix pXd_flags() to handle _PAGE_PAT_LARGE
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 10 Jul 2015 15:15:22 -0600
In-Reply-To: <559F4293.1090801@suse.com>
References: <1436461431-27305-1-git-send-email-toshi.kani@hp.com>
	 <1436461431-27305-2-git-send-email-toshi.kani@hp.com>
	 <559F4293.1090801@suse.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, konrad.wilk@oracle.com, elliott@hp.com

On Fri, 2015-07-10 at 05:57 +0200, Juergen Gross wrote:
> On 07/09/2015 07:03 PM, Toshi Kani wrote:
> > The PAT bit gets relocated to bit 12 when PUD and PMD mappings are
> > used.  This bit 12, however, is not covered by PTE_FLAGS_MASK, 
> > which
> > is corrently used for masking the flag bits for all cases.
> > 
> > Fix pud_flags() and pmd_flags() to cover the PAT bit, 
> > _PAGE_PAT_LARGE,
> > when they are used to map a large page with _PAGE_PSE set.
  :
> Hmm, I think this covers only half of the problem. pud_pfn() and
> pmd_pfn() will return wrong results for large pages with PAT bit
> set as well.
> 
> I'd rather use something like:
> 
> static inline unsigned long pmd_pfn_mask(pmd_t pmd)
> {
> 	if (pmd_large(pmd))
> 		return PMD_PAGE_MASK & PHYSICAL_PAGE_MASK;
> 	else
> 		return PTE_PFN_MASK;
> }
> 
> static inline unsigned long pmd_flags_mask(pmd_t pmd)
> {
> 	if (pmd_large(pmd))
> 		return ~(PMD_PAGE_MASK & PHYSICAL_PAGE_MASK);
> 	else
> 		return ~PTE_PFN_MASK;
> }
> 
> static inline unsigned long pmd_pfn(pmd_t pmd)
> {
>          return (pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT;
> }
> 
> static inline pmdval_t pmd_flags(pmd_t pmd)
> {
> 	return native_pmd_val(pmd) & ~pmd_flags_mask(pmd);
> }

Thanks for the suggestion!  I agree that it is cleaner in this way.  I
am updating the patches and found the following changes are needed as
well:

 - Define PGTABLE_LEVELS to 2 in
"arch/x86/entry/vdso/vdso32/vclock_gettime.c".  This file redefines to
X86_32.  Setting to 2 levels (since X86_PAE is not set) allows <asm
-generic/pgtable-nopmd.h> be included to define PMD_SHIFT.

 - Move PUD_PAGE_SIZE & PUD_PAGE_MASK from <asm/page_64_types.h> to
<asm/page_types.h>.  This allows X86_32 to refer the PUD macros.

 - Nit: pmd_large() cannot be used in pmd_xxx_mask() since it calls
pmd_flags().  Use (native_pud_val(pud) & _PAGE_PSE), instead.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
