Subject: Re: PageReserved removal from swsusp
From: Nigel Cunningham <ncunningham@cyclades.com>
Reply-To: ncunningham@cyclades.com
In-Reply-To: <42E44294.5020408@yahoo.com.au>
References: <42E44294.5020408@yahoo.com.au>
Content-Type: text/plain
Message-Id: <1122265909.6144.106.camel@localhost>
Mime-Version: 1.0
Date: Mon, 25 Jul 2005 14:31:50 +1000
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, Pavel Machek <pavel@suse.cz>, Hugh Dickins <hugh@veritas.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi.

On Mon, 2005-07-25 at 11:38, Nick Piggin wrote:
> Hi,
> 
> kernel/power/swsusp.c is the last remaining real user of PageReserved
> with my current PageReserved removal patchset. This is actually not a
> problem for my purposes, and swsusp is quite able to continue using
> PageReserved... however that may be a bit ugly, and means swsusp will
> be the sole user of 3(!) page-flags.
> 
> The PageReserved test in save_highmem_zone() is the hard one. rvmalloc
> is no problem, but it seems to be important to prevent saving regions
> that aren't RAM.
> 
> I seem to be able to work around this on i386 by testing page_is_ram()
> instead of PageReserved, however that looks nonportable, and at least
> on i386 we rather want something like page_is_usable_ram() which is
> (page_is_ram && !(bad_ppro && page_kills_ppro))
> 
> Otherwise we could perhaps have a PageUsableRAM() which returns
> page->flags != 0xffffffff or some other unlikely combination of flags.
> 
> They're my two ideas. Anyone else?

I have a few differences in Suspend2 that let me only use one real
pageflag (Nosave).

The changes are:

1) Use a set of order zero allocations, tied together via a kmalloc'd
list of pointers as a means of dynamically creating and destroying
pseudo page-flags (such as are only needed while suspending). The
bitmaps don't support sparsemem yet, but this support could be added
pretty easily.

2) This bitmap could be used straight off for swsusp's PageNosave flag
since it is only used in kernel/power/swsusp.c (2.6.13-rc3 checked).

3) Set & Clear PageNosaveFree are also used in mm/page_alloc.c, in
mark_free_pages, which is only called from swsusp.c, so a dynamically
allocated bitmap could be used there too.

4) That leaves PageReserved. Pavel and I both rely on a page flag being
set in the arch specific code (based on e820 tables), so as to know what
pages are untouchable. As I look more closely though, I wonder if we
could do without that if we instead directly do the 

(page_is_ram(pfn) && !(bad_ppro && page_kills_ppro(pfn))

and

(addr < (void *)&__nosave_begin || addr >= (void *)&__nosave_end)

tests when preparing the image. Assuming, of course, that page_is_ram,
bad_ppro and page_kills_ppro can be made usable by us.

Regards,

Nigel
-- 
Evolution.
Enumerate the requirements.
Consider the interdependencies.
Calculate the probabilities.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
