Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 54BAF6B03B0
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 12:54:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m188so32642624pgm.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:54:04 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 2si2203579pfk.47.2017.06.27.09.54.02
        for <linux-mm@kvack.org>;
        Tue, 27 Jun 2017 09:54:03 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: linux-next: BUG: Bad page state in process ip6tables-save pfn:1499f4
References: <CANaxB-zPGB8Yy9480pTFmj9HECGs3quq9Ak18aBUbx9TsNSsaw@mail.gmail.com>
	<20170624001738.GB7946@gmail.com> <20170624150824.GA19708@gmail.com>
	<bff14c53-815a-0874-5ed9-43d3f4c54ffd@suse.cz>
	<20170627163734.6js4jkwkwlz6xwir@black.fi.intel.com>
Date: Tue, 27 Jun 2017 17:53:59 +0100
In-Reply-To: <20170627163734.6js4jkwkwlz6xwir@black.fi.intel.com> (Kirill
	A. Shutemov's message of "Tue, 27 Jun 2017 19:37:34 +0300")
Message-ID: <87lgodl6c8.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Steve Capper <steve.capper@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrei Vagin <avagin@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Cyrill Gorcunov <gorcunov@openvz.org>

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> On Tue, Jun 27, 2017 at 09:18:15AM +0200, Vlastimil Babka wrote:
>> On 06/24/2017 05:08 PM, Andrei Vagin wrote:
>> > On Fri, Jun 23, 2017 at 05:17:44PM -0700, Andrei Vagin wrote:
>> >> On Thu, Jun 22, 2017 at 11:21:03PM -0700, Andrei Vagin wrote:
>> >>> Hello,
>> >>>
>> >>> We run CRIU tests for linux-next and today they triggered a kernel
>> >>> bug. I want to mention that this kernel is built with kasan. This bug
>> >>> was triggered in travis-ci. I can't reproduce it on my host. Without
>> >>> kasan, kernel crashed but it is impossible to get a kernel log for
>> >>> this case.
>> >>
>> >> We use this tree
>> >> https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/
>> >>
>> >> This issue isn't reproduced on the akpm-base branch and
>> >> it is reproduced each time on the akpm branch. I didn't
>> >> have time today to bisect it, will do on Monday.
>> > 
>> > c3aab7b2d4e8434d53bc81770442c14ccf0794a8 is the first bad commit
>> > 
>> > commit c3aab7b2d4e8434d53bc81770442c14ccf0794a8
>> > Merge: 849c34f 93a7379
>> > Author: Stephen Rothwell
>> > Date:   Fri Jun 23 16:40:07 2017 +1000
>> > 
>> >     Merge branch 'akpm-current/current'
>> 
>> Hm is it really the merge of mmotm itself and not one of the patches in
>> mmotm?
>> Anyway smells like THP, adding Kirill.
>
> Okay, it took a while to figure it out.

I'm sorry you had to go chasing for this one again.

I'd found the same issue while investigating an ltp failure on arm64[0] and
sent a fix[1]. The fix is effectively the same as your patch below.

Andrew picked up the patch from v5 posting and I can see it in today's
next[2].


[0] http://lists.infradead.org/pipermail/linux-arm-kernel/2017-June/510318.html
[1] https://patchwork.kernel.org/patch/9766193/
[2] https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/mm/gup.c?h=next-20170627&id=d31945b5d4ab4490fb5f961dd5b066cc9f560eb3

>
> The bug is in patch "mm, gup: ensure real head page is ref-counted when
> using hugepages". We should look for a head *before* the loop. Otherwise
> 'page' may point to the first page beyond the compound page.
>
> The patch below should help.
>
> If no objections, Andrew, could you fold it into the problematic patch?
>
> diff --git a/mm/gup.c b/mm/gup.c
> index d8db6e5016a8..6f9ca86b3d03 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1424,6 +1424,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>  
>  	refs = 0;
>  	page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +	head = compound_head(page);
>  	do {
>  		pages[*nr] = page;
>  		(*nr)++;
> @@ -1431,7 +1432,6 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>  		refs++;
>  	} while (addr += PAGE_SIZE, addr != end);
>  
> -	head = compound_head(page);
>  	if (!page_cache_add_speculative(head, refs)) {
>  		*nr -= refs;
>  		return 0;
> @@ -1462,6 +1462,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
>  
>  	refs = 0;
>  	page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> +	head = compound_head(page);
>  	do {
>  		pages[*nr] = page;
>  		(*nr)++;
> @@ -1469,7 +1470,6 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
>  		refs++;
>  	} while (addr += PAGE_SIZE, addr != end);
>  
> -	head = compound_head(page);
>  	if (!page_cache_add_speculative(head, refs)) {
>  		*nr -= refs;
>  		return 0;
> @@ -1499,6 +1499,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
>  	BUILD_BUG_ON(pgd_devmap(orig));
>  	refs = 0;
>  	page = pgd_page(orig) + ((addr & ~PGDIR_MASK) >> PAGE_SHIFT);
> +	head = compound_head(page);
>  	do {
>  		pages[*nr] = page;
>  		(*nr)++;
> @@ -1506,7 +1507,6 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
>  		refs++;
>  	} while (addr += PAGE_SIZE, addr != end);
>  
> -	head = compound_head(page);
>  	if (!page_cache_add_speculative(head, refs)) {
>  		*nr -= refs;
>  		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
