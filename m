Date: Mon, 27 Aug 2007 16:40:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] alloc_pages(): permit get_zeroed_page(GFP_ATOMIC)
 from interrupt context
Message-Id: <20070827164050.64af7153.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708271550550.9100@schroedinger.engr.sgi.com>
References: <200708232107.l7NL7XDt026979@imap1.linux-foundation.org>
	<Pine.LNX.4.64.0708271308380.5457@schroedinger.engr.sgi.com>
	<20070827133347.424f83a6.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271357220.6435@schroedinger.engr.sgi.com>
	<20070827140440.d2109ea5.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271411200.6566@schroedinger.engr.sgi.com>
	<20070827143459.82bdeddd.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271441530.8293@schroedinger.engr.sgi.com>
	<20070827151107.31f18742.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271512390.8783@schroedinger.engr.sgi.com>
	<20070827154558.1c04e77f.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271550550.9100@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, thomas.jarosch@intra2net.com
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007 16:01:28 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 27 Aug 2007, Andrew Morton wrote:
> 
> > So what do we do?
> > 
> > a) don't call clear_highpage() for non-highmem pages (my fix)
> 
> Then we need to be sure that this is the only case where we call 
> clear_highpage() from an interrupt. This solves an i386 arch problem in 
> core code. Other arches are not broken like that. See f.e. sparc:
> 
> void *kmap_atomic(struct page *page, enum km_type type)
> {
>         unsigned long idx;
>         unsigned long vaddr;
> 
>         /* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
>         pagefault_disable();
>         if (!PageHighMem(page))
>                 return page_address(page);
> 
>         idx = type + KM_TYPE_NR*smp_processor_id();
>         vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
> 
> 
> > b) don't do the is-the-pte-zero check in kmap_atomic_prot() if the page
> >    isn't highmem
> > 
> >    This is bad because it'll disable the check completely if the machine
> >    doesn't physically have highmem, or if the page happened to be a lowmem
> >    one.
> 
> The check is meaningless if we do not have highmem.

umm, yeah, it'll never trigger on a non-highmem machine.

> kmap_atomic is a 
> function to be used in atomic context. I.e. interrupts. Nested by 
> definition. It is broken as is since it BUG()s on a legitimate nested 
> call.

Is it broken?  Dunno.  It's a bit silly to run kmap_atomic() against a page
which the caller *knows* cannot be a highmem page.

The only situation where this is likely to occur is where the caller
received a gfp_t from higher up, like this case.

> > c) don't do the is-the-pte-zero check if __GFP_HIGHMEM wasn't set.
> > 
> >    OK, but we don't pass the gfp_t into kmap_atomic.  So we need to do
> >    this at the caller site.  That's what a) does.
> 
> Would that not mean leaving kmap_atomic broken on i386? Before Ingo's 
> commit things were fine. Revert the commit and there is no need 
> to change core code.

If we revert the commit we lose a bit of debug support.

We could move the assert to after we've checked for PageHighmem, but then
we'd fail to detect a bug if the nested caller happened to get a lowmem
page for a __GFP_HIGHMEM allocation.

> What exactly is the point of checking that a kmap_atomic of a non highmem 
> page cannot occur during the kmap_atomic of a highmem page? AFAICT this is 
> fine.

Just that the non-highmem page _might_ have been a highmem page, only the
caller got lucky.

I dunno, it's all a bit marginal, and tricky.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
