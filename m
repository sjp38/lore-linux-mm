Subject: vDSO vs. mm : problems with ppc vdso
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Tue, 28 Feb 2006 16:39:14 +1100
Message-Id: <1141105154.3767.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Paul Mackerras <paulus@samba.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

is for 2.6.16 and see if we want to do something about it).

I have discovered some issues with my vDSO implementation that went
unnoticed so far but might cause problems with the VM.

The problems are related to the way the powerpc vDSO is implemented in
order to support COW (for breakpoints) and randomisation. It's not
implemented as a gate_area() hack. Instead, I create a vma at process
exec (see arch_setup_additional_pages() in arch/powerpc/kernel/vdso.c,
which is called from binfmt_elf.c).

This vma has custom vm_ops with a nopage() function that maps in pages
from the vdso on demand. Those pages are kernel pages shared by all
processes at first, though if a COW happens, they will be replaced by
normal anonymous pages by the normal COW code.

A first problem happens here (though it's not my main concern right now.
It's a bug I need to fix but at least I have a good handle on it). The
nopage function decides wether to map the pages from the 32 or the 64
bits vdso based on test_thread_flag(). This is broken if those pages end
up being faulted in as the result of a get_user_pages() done by another
process. Typically, that means that a 64 bits gdb tracing a 32 bits
program will fault the wrong pages in. So I need a way to "know" what
vdso to fault it based on the vma ... that will require me to either
hack something in the vma (stuff a flag somewhere ?) or find a way to
identify a 32 bits vma from a 64 bits vma...

The second problem is more subtle and that's where I really need a VM
guru to help me assess how bad the situation is and what should be done
to fix it.

Since when not-COWed, those vDSO pages are actually kernel pages mapped
into every process, they aren't per-se anonymous pages, nor file
pages... in fact, they don't quite fit in anything rmap knows about.
However, I can't mark the VMA as VM_RESERVED or anything like that since
that would prevent COW from working.

Thus we hit some "interesting" code path in rmap of that sort:

 - page_address_in_vma() will always fail for those pages afaik. Not
sure of the consequences at this point. (Neither PageAnon() nor
page->mapping)

 - page_referenced() will not get into any of the code path under "if
(page_mapped(page) && page->mapping) {" thanks to page->mapping being
NULL afaik. I think that's a good thing in this case. We rely solely on
the PTE information for these pages

 - try_to_unmap() gets more funny... It will call try_to_unmap_file().
Maybe we shouldn't ... maybe I should set the kernel pages of the vdso's
PageLocked(), though I would have to dig through the possible side
effects of that (notably vs. COW). If that works though, it may be a
good workaround to avoid nasty code path in the VM.

 - If we hit try_to_unmap_one(), we'll probably do dec_mm_counter(mm,
file_rss). But file_rss has never been incremented when the page was
faulted in in the first place, was it ? Those shared kernel pages
shouldn't be accounted there anyway

 - There may be other problematic code path outside of rmap.c that I
missed.

I'd really like to assess the situation and maybe get a few band aids in
2.6.16 if proper fixes are too complicated... 

Thanks !

Ben.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
