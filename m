Date: Tue, 21 Feb 2006 13:09:26 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: remap_file_pages - Bug with _PAGE_PROTNONE - is it used in
 current kernels?
In-Reply-To: <200602202354.48851.blaisorblade@yahoo.it>
Message-ID: <Pine.LNX.4.61.0602211257360.8644@goblin.wat.veritas.com>
References: <200602202354.48851.blaisorblade@yahoo.it>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Feb 2006, Blaisorblade wrote:

> I've been hitting a bug on a patch I'm working on and have considered (and 
> more or less tested with good results) doing this change:
> 
> -#define pte_present(x)  ((x).pte_low & (_PAGE_PRESENT | _PAGE_PROTNONE))
> +#define pte_present(x)  ((x).pte_low & (_PAGE_PRESENT))
> 
> (and the corresponding thing on other architecture).
> 
> In general, the question is whether __P000 and __S000 in protection_map are 
> ever used except for MAP_POPULATE, and even then if they work well.
> 
> I'm seeking for objections to this change and/or anything I'm missing.

Objection, your honor.

> This bug showed up while porting remap_file_pages protection support to 
> 2.6.16-rc3. It always existed but couldn't trigger before the PageReserved 
> changes.
> 
> Consider a _PAGE_PROTNONE pte, which has then pte_pfn(pte) == 0 (with 
> remap_file_pages you need them to exist). Obviously pte_pfn(pte) on such a PTE 
> doesn't make sense, but since pte_present(pte) gives true the code doesn't 
> know that.

I didn't fully understand you there, but I think you've got it the wrong
way round: _PAGE_PROTNONE is included in the pte_present() test precisely
because there is a valid page there, pfn is set (it might be pfn 0, yes,
but much more likely to be pfn non-0).

I've never used PROT_NONE myself (beyond testing), but I think the
traditional way it's used is this: mmap(,,PROT_READ|PROT_WRITE,,,),
initialize the pages of that mapping, then mprotect(,,PROT_NONE) -
which retains all those pages but make them generate SIGSEGVs - so
the app can detect accesses and decide if it wants to do something
special with them, other than the obvious mprotect(,,PROT_READ) or
whatever.

PROT_NONE gives you a way of holding the page present (unlike munmap),
yet failing access.  And since those pages remain present, they do
need to be freed later when you get to zap_pte_range.  They are
normal pages, but user access to them has been restricted.

Hugh

> Consider a call to munmap on this range. We get to zap_pte_range() which (in 
> condensed source code):
> 
> zap_pte_range() 
> ...
>                 if (pte_present(ptent)) {
> //This test is passed
>                         struct page *page = vm_normal_page(vma, addr, ptent);
> //Now page points to page 0 - which is wrong, page should be NULL
>                         page_remove_rmap(page);
> //Which doesn't make any sense.
> //If mem_map[0] wasn't mapped we hit a BUG now, if it was we'll hit it later - 
> //i.e. negative page_mapcount().
> 
> Now, since this code doesn't work in this situation, I wonder whether PROTNONE 
> is indeed used anywhere in the code *at the moment*, since faults on pages 
> mapped as such are handled with SIGSEGV.
> 
> The only possible application, which is only possible in 2.6 and not in 2.4 
> where _PAGE_PROTNONE still exists, is mmap(MAP_POPULATE) with prot == 
> PROT_NONE.
> 
> Instead I need to make use of PROTNONE, so the handling of it may need 
> changes. In particular, I wonder about why:
> 
> #define pte_present(x)  ((x).pte_low & (_PAGE_PRESENT | _PAGE_PROTNONE))
> 
> I see why that _PAGE_PROTNONE can make sense, but in the above code it 
> doesn't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
