Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABBDB6B0314
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 12:38:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e3so30725543pfc.4
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:38:40 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h129si1543229pgc.92.2017.06.27.09.38.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 09:38:39 -0700 (PDT)
Date: Tue, 27 Jun 2017 19:37:34 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: linux-next: BUG: Bad page state in process ip6tables-save
 pfn:1499f4
Message-ID: <20170627163734.6js4jkwkwlz6xwir@black.fi.intel.com>
References: <CANaxB-zPGB8Yy9480pTFmj9HECGs3quq9Ak18aBUbx9TsNSsaw@mail.gmail.com>
 <20170624001738.GB7946@gmail.com>
 <20170624150824.GA19708@gmail.com>
 <bff14c53-815a-0874-5ed9-43d3f4c54ffd@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bff14c53-815a-0874-5ed9-43d3f4c54ffd@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Punit Agrawal <punit.agrawal@arm.com>, Steve Capper <steve.capper@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrei Vagin <avagin@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Cyrill Gorcunov <gorcunov@openvz.org>

On Tue, Jun 27, 2017 at 09:18:15AM +0200, Vlastimil Babka wrote:
> On 06/24/2017 05:08 PM, Andrei Vagin wrote:
> > On Fri, Jun 23, 2017 at 05:17:44PM -0700, Andrei Vagin wrote:
> >> On Thu, Jun 22, 2017 at 11:21:03PM -0700, Andrei Vagin wrote:
> >>> Hello,
> >>>
> >>> We run CRIU tests for linux-next and today they triggered a kernel
> >>> bug. I want to mention that this kernel is built with kasan. This bug
> >>> was triggered in travis-ci. I can't reproduce it on my host. Without
> >>> kasan, kernel crashed but it is impossible to get a kernel log for
> >>> this case.
> >>
> >> We use this tree
> >> https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/
> >>
> >> This issue isn't reproduced on the akpm-base branch and
> >> it is reproduced each time on the akpm branch. I didn't
> >> have time today to bisect it, will do on Monday.
> > 
> > c3aab7b2d4e8434d53bc81770442c14ccf0794a8 is the first bad commit
> > 
> > commit c3aab7b2d4e8434d53bc81770442c14ccf0794a8
> > Merge: 849c34f 93a7379
> > Author: Stephen Rothwell
> > Date:   Fri Jun 23 16:40:07 2017 +1000
> > 
> >     Merge branch 'akpm-current/current'
> 
> Hm is it really the merge of mmotm itself and not one of the patches in
> mmotm?
> Anyway smells like THP, adding Kirill.

Okay, it took a while to figure it out.

The bug is in patch "mm, gup: ensure real head page is ref-counted when
using hugepages". We should look for a head *before* the loop. Otherwise
'page' may point to the first page beyond the compound page.

The patch below should help.

If no objections, Andrew, could you fold it into the problematic patch?

diff --git a/mm/gup.c b/mm/gup.c
index d8db6e5016a8..6f9ca86b3d03 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1424,6 +1424,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 
 	refs = 0;
 	page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+	head = compound_head(page);
 	do {
 		pages[*nr] = page;
 		(*nr)++;
@@ -1431,7 +1432,6 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
-	head = compound_head(page);
 	if (!page_cache_add_speculative(head, refs)) {
 		*nr -= refs;
 		return 0;
@@ -1462,6 +1462,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 
 	refs = 0;
 	page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+	head = compound_head(page);
 	do {
 		pages[*nr] = page;
 		(*nr)++;
@@ -1469,7 +1470,6 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
-	head = compound_head(page);
 	if (!page_cache_add_speculative(head, refs)) {
 		*nr -= refs;
 		return 0;
@@ -1499,6 +1499,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 	BUILD_BUG_ON(pgd_devmap(orig));
 	refs = 0;
 	page = pgd_page(orig) + ((addr & ~PGDIR_MASK) >> PAGE_SHIFT);
+	head = compound_head(page);
 	do {
 		pages[*nr] = page;
 		(*nr)++;
@@ -1506,7 +1507,6 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
-	head = compound_head(page);
 	if (!page_cache_add_speculative(head, refs)) {
 		*nr -= refs;
 		return 0;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
