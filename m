Date: Mon, 27 Aug 2007 15:45:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] alloc_pages(): permit get_zeroed_page(GFP_ATOMIC)
 from interrupt context
Message-Id: <20070827154558.1c04e77f.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708271512390.8783@schroedinger.engr.sgi.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, thomas.jarosch@intra2net.com
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007 15:12:58 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 27 Aug 2007, Andrew Morton wrote:
> 
> > > Nesting (at least allocate a 
> > > regular page while highmem page is being mapped) needs to work in order to 
> > > be able to allocate a page from an interrupt contexts.
> > 
> > yup, but interrupt-level code should use the reserved-for-interrupt kmap
> > slots (KM_IRQ0, etc).
> 
> We are not using any kmap slot since we are allocating a non highmem page!

Right.  So a get_zeroed_page() from IRQ context happens to be not buggy,
even though it goes BUG.

So what do we do?

a) don't call clear_highpage() for non-highmem pages (my fix)

b) don't do the is-the-pte-zero check in kmap_atomic_prot() if the page
   isn't highmem

   This is bad because it'll disable the check completely if the machine
   doesn't physically have highmem, or if the page happened to be a lowmem
   one.

c) don't do the is-the-pte-zero check if __GFP_HIGHMEM wasn't set.

   OK, but we don't pass the gfp_t into kmap_atomic.  So we need to do
   this at the caller site.  That's what a) does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
