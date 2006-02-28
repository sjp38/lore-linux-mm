Date: Mon, 27 Feb 2006 21:54:16 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: vDSO vs. mm : problems with ppc vdso
Message-Id: <20060227215416.2bfc1e18.akpm@osdl.org>
In-Reply-To: <1141105154.3767.27.camel@localhost.localdomain>
References: <1141105154.3767.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, hugh@veritas.com, paulus@samba.org, nickpiggin@yahoo.com.au, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
>
> (Andrew: I think it's important to assess at least how bad the problem
> is for 2.6.16 and see if we want to do something about it).
> 
> I have discovered some issues with my vDSO implementation that went
> unnoticed so far but might cause problems with the VM.
> 
> The problems are related to the way the powerpc vDSO is implemented in
> order to support COW (for breakpoints) and randomisation. It's not
> implemented as a gate_area() hack. Instead, I create a vma at process
> exec (see arch_setup_additional_pages() in arch/powerpc/kernel/vdso.c,
> which is called from binfmt_elf.c).
> 
> This vma has custom vm_ops with a nopage() function that maps in pages
> from the vdso on demand. Those pages are kernel pages shared by all
> processes at first, though if a COW happens, they will be replaced by
> normal anonymous pages by the normal COW code.
> 
> A first problem happens here (though it's not my main concern right now.
> It's a bug I need to fix but at least I have a good handle on it). The
> nopage function decides wether to map the pages from the 32 or the 64
> bits vdso based on test_thread_flag(). This is broken if those pages end
> up being faulted in as the result of a get_user_pages() done by another
> process. Typically, that means that a 64 bits gdb tracing a 32 bits
> program will fault the wrong pages in. So I need a way to "know" what
> vdso to fault it based on the vma ... that will require me to either
> hack something in the vma (stuff a flag somewhere ?) or find a way to
> identify a 32 bits vma from a 64 bits vma...

As mentioned on IRC, we keep on getting bugs because we don't have a clear
separation between 64-bit tasks (a task_struct thing) and 64-bit mm's (an
mm_struct thing).  I'd propose added mm_struct.task_size and testing that
in the appropriate places.

> The second problem is more subtle and that's where I really need a VM
> guru to help me assess how bad the situation is and what should be done
> to fix it.
> 
> Since when not-COWed, those vDSO pages are actually kernel pages mapped
> into every process, they aren't per-se anonymous pages, nor file
> pages... in fact, they don't quite fit in anything rmap knows about.
> However, I can't mark the VMA as VM_RESERVED or anything like that since
> that would prevent COW from working.
> 
> Thus we hit some "interesting" code path in rmap of that sort:

rmap won't touch this page unless your ->nopage handler put it onto the
page LRU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
