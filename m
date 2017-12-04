Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0C046B0253
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 12:50:37 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e69so11976660pgc.15
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 09:50:37 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m184si10597956pfb.373.2017.12.04.09.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 09:50:36 -0800 (PST)
Date: Mon, 4 Dec 2017 20:50:02 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] x86/mm: Rewrite sme_populate_pgd() in a more sensible way
Message-ID: <20171204175002.ohf6u4fenut2puzb@black.fi.intel.com>
References: <20171204112323.47019-1-kirill.shutemov@linux.intel.com>
 <d177df77-cdc7-1507-08f8-fcdb3b443709@amd.com>
 <20171204145755.6xu2w6a6og56rq5v@node.shutemov.name>
 <d9701b1c-1abf-5fc1-80b0-47ab4e517681@amd.com>
 <20171204163445.qt5dqcrrkilnhowz@black.fi.intel.com>
 <20171204173931.pjnmfdutys7cnesx@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171204173931.pjnmfdutys7cnesx@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 04, 2017 at 05:39:31PM +0000, Kirill A. Shutemov wrote:
> On Mon, Dec 04, 2017 at 04:34:45PM +0000, Kirill A. Shutemov wrote:
> > On Mon, Dec 04, 2017 at 04:00:26PM +0000, Tom Lendacky wrote:
> > > On 12/4/2017 8:57 AM, Kirill A. Shutemov wrote:
> > > > On Mon, Dec 04, 2017 at 08:19:11AM -0600, Tom Lendacky wrote:
> > > > > On 12/4/2017 5:23 AM, Kirill A. Shutemov wrote:
> > > > > > sme_populate_pgd() open-codes a lot of things that are not needed to be
> > > > > > open-coded.
> > > > > > 
> > > > > > Let's rewrite it in a more stream-lined way.
> > > > > > 
> > > > > > This would also buy us boot-time switching between support between
> > > > > > paging modes, when rest of the pieces will be upstream.
> > > > > 
> > > > > Hi Kirill,
> > > > > 
> > > > > Unfortunately, some of these can't be changed.  The use of p4d_offset(),
> > > > > pud_offset(), etc., use non-identity mapped virtual addresses which cause
> > > > > failures at this point of the boot process.
> > > > 
> > > > Wat? Virtual address is virtual address. p?d_offset() doesn't care about
> > > > what mapping you're using.
> > > 
> > > Yes it does.  For example, pmd_offset() issues a pud_page_addr() call,
> > > which does a __va() returning a non-identity mapped address (0xffff88...).
> > > Only identity mapped virtual addresses have been setup at this point, so
> > > the use of that virtual address panics the kernel.
> > 
> > Stupid me. You are right.
> > 
> > What about something like this:
> 
> sme_pgtable_calc() also looks unnecessary complex.
> 
> Any objections on this:

Oops. Screwed up whitespaces.

diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 65e0d68f863f..f7b6c7972884 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -548,8 +548,7 @@ static void __init *sme_populate_pgd(pgd_t *pgd_base, void *pgtable_area,
 
 static unsigned long __init sme_pgtable_calc(unsigned long len)
 {
-	unsigned long p4d_size, pud_size, pmd_size;
-	unsigned long total;
+	unsigned long entries, tables;
 
 	/*
 	 * Perform a relatively simplistic calculation of the pagetable
@@ -559,41 +558,25 @@ static unsigned long __init sme_pgtable_calc(unsigned long len)
 	 * mappings. Incrementing the count for each covers the case where
 	 * the addresses cross entries.
 	 */
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-		p4d_size = (ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE) + 1;
-		p4d_size *= sizeof(p4d_t) * PTRS_PER_P4D;
-		pud_size = (ALIGN(len, P4D_SIZE) / P4D_SIZE) + 1;
-		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
-	} else {
-		p4d_size = 0;
-		pud_size = (ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE) + 1;
-		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
-	}
-	pmd_size = (ALIGN(len, PUD_SIZE) / PUD_SIZE) + 1;
-	pmd_size *= sizeof(pmd_t) * PTRS_PER_PMD;
 
-	total = p4d_size + pud_size + pmd_size;
+	entries = (DIV_ROUND_UP(len, PGDIR_SIZE) + 1) * PAGE_SIZE;
+	if (PTRS_PER_P4D > 1)
+		entries += (DIV_ROUND_UP(len, P4D_SIZE) + 1) * PAGE_SIZE;
+	entries += (DIV_ROUND_UP(len, PUD_SIZE) + 1) * PAGE_SIZE;
+	entries += (DIV_ROUND_UP(len, PMD_SIZE) + 1) * PAGE_SIZE;
 
 	/*
 	 * Now calculate the added pagetable structures needed to populate
 	 * the new pagetables.
 	 */
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-		p4d_size = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
-		p4d_size *= sizeof(p4d_t) * PTRS_PER_P4D;
-		pud_size = ALIGN(total, P4D_SIZE) / P4D_SIZE;
-		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
-	} else {
-		p4d_size = 0;
-		pud_size = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
-		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
-	}
-	pmd_size = ALIGN(total, PUD_SIZE) / PUD_SIZE;
-	pmd_size *= sizeof(pmd_t) * PTRS_PER_PMD;
 
-	total += p4d_size + pud_size + pmd_size;
+	tables = DIV_ROUND_UP(entries, PGDIR_SIZE) * PAGE_SIZE;
+	if (PTRS_PER_P4D > 1)
+		tables += DIV_ROUND_UP(entries, P4D_SIZE) * PAGE_SIZE;
+	tables += DIV_ROUND_UP(entries, PUD_SIZE) * PAGE_SIZE;
+	tables += DIV_ROUND_UP(entries, PMD_SIZE) * PAGE_SIZE;
 
-	return total;
+	return entries + tables;
 }
 
 void __init sme_encrypt_kernel(void)
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
