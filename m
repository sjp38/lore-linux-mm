Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7E43C6B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 15:47:13 -0500 (EST)
Received: by wmnn186 with SMTP id n186so125744991wmn.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 12:47:13 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id vm2si20499319wjc.213.2015.11.09.12.47.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 12:47:12 -0800 (PST)
Received: by wmec201 with SMTP id c201so87394482wme.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 12:47:12 -0800 (PST)
Date: Mon, 9 Nov 2015 22:47:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 RESEND 4/11] x86/asm: Fix pud/pmd interfaces to handle
 large PAT bit
Message-ID: <20151109204710.GB5443@node.shutemov.name>
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
 <1442514264-12475-5-git-send-email-toshi.kani@hpe.com>
 <5640E08F.5020206@oracle.com>
 <1447096601.21443.15.camel@hpe.com>
 <5640F673.8070400@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5640F673.8070400@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Toshi Kani <toshi.kani@hpe.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com

On Mon, Nov 09, 2015 at 02:39:31PM -0500, Boris Ostrovsky wrote:
> On 11/09/2015 02:16 PM, Toshi Kani wrote:
> >On Mon, 2015-11-09 at 13:06 -0500, Boris Ostrovsky wrote:
> >>On 09/17/2015 02:24 PM, Toshi Kani wrote:
> >>>Now that we have pud/pmd mask interfaces, which handle pfn & flags
> >>>mask properly for the large PAT bit.
> >>>
> >>>Fix pud/pmd pfn & flags interfaces by replacing PTE_PFN_MASK and
> >>>PTE_FLAGS_MASK with the pud/pmd mask interfaces.
> >>>
> >>>Suggested-by: Juergen Gross <jgross@suse.com>
> >>>Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> >>>Cc: Juergen Gross <jgross@suse.com>
> >>>Cc: Konrad Wilk <konrad.wilk@oracle.com>
> >>>Cc: Thomas Gleixner <tglx@linutronix.de>
> >>>Cc: H. Peter Anvin <hpa@zytor.com>
> >>>Cc: Ingo Molnar <mingo@redhat.com>
> >>>Cc: Borislav Petkov <bp@alien8.de>
> >>>---
> >>>   arch/x86/include/asm/pgtable.h       |   14 ++++++++------
> >>>   arch/x86/include/asm/pgtable_types.h |    4 ++--
> >>>   2 files changed, 10 insertions(+), 8 deletions(-)
> >>>
> >>
> >>Looks like this commit is causing this splat for 32-bit kernels. I am
> >>attaching my config file, just in case.
> >Thanks for the report!  I'd like to reproduce the issue since I am not sure how
> >this change caused it...
> >
> >I tried to build a kernel with the attached config file, and got the following
> >error.  Not sure what I am missing.
> >
> >----
> >$ make -j24 ARCH=i386
> >    :
> >   LD      drivers/built-in.o
> >   LINK    vmlinux
> >./.config: line 44: $'\r': command not found
> 
> I wonder whether my email client added ^Ms to the file that I send. It
> shouldn't have.
> 
> >Makefile:929: recipe for target 'vmlinux' failed
> >make: *** [vmlinux] Error 127
> >----
> >
> >Do you have steps to reproduce the issue?  Or do you see it during boot-time?
> 
> This always happens just after system has booted, it may still be going over
> init scripts. I am booting with ramdisk, don't know whether it has anything
> to do with this problem.
> 
> FWIW, it looks like pmd_pfn_mask() inline is causing this. Reverting it
> alone makes this crash go away.

Could you check the patch below?

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index dd5b0aa9dd2f..c1e797266ce9 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -279,17 +279,14 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 static inline pudval_t pud_pfn_mask(pud_t pud)
 {
 	if (native_pud_val(pud) & _PAGE_PSE)
-		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+		return ~((1ULL << PUD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
 	else
 		return PTE_PFN_MASK;
 }
 
 static inline pudval_t pud_flags_mask(pud_t pud)
 {
-	if (native_pud_val(pud) & _PAGE_PSE)
-		return ~(PUD_PAGE_MASK & (pudval_t)PHYSICAL_PAGE_MASK);
-	else
-		return ~PTE_PFN_MASK;
+	return ~pud_pfn_mask(pud);
 }
 
 static inline pudval_t pud_flags(pud_t pud)
@@ -300,17 +297,14 @@ static inline pudval_t pud_flags(pud_t pud)
 static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
 {
 	if (native_pmd_val(pmd) & _PAGE_PSE)
-		return PMD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+		return ~((1ULL << PMD_SHIFT) - 1) & PHYSICAL_PAGE_MASK;
 	else
 		return PTE_PFN_MASK;
 }
 
 static inline pmdval_t pmd_flags_mask(pmd_t pmd)
 {
-	if (native_pmd_val(pmd) & _PAGE_PSE)
-		return ~(PMD_PAGE_MASK & (pmdval_t)PHYSICAL_PAGE_MASK);
-	else
-		return ~PTE_PFN_MASK;
+	return ~pmd_pfn_mask(pmd);
 }
 
 static inline pmdval_t pmd_flags(pmd_t pmd)
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
