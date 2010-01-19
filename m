Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F20676B00A1
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 20:33:07 -0500 (EST)
Date: Tue, 19 Jan 2010 09:33:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/8] vmalloc: simplify vread()/vwrite()
Message-ID: <20100119013303.GA12513@localhost>
References: <20100113135305.013124116@intel.com> <20100113135957.833222772@intel.com> <20100114124526.GB7518@laptop> <20100118133512.GC721@localhost> <20100118142359.GA14472@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100118142359.GA14472@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 07:23:59AM -0700, Nick Piggin wrote:
> On Mon, Jan 18, 2010 at 09:35:12PM +0800, Wu Fengguang wrote:
> > On Thu, Jan 14, 2010 at 05:45:26AM -0700, Nick Piggin wrote:
> > > On Wed, Jan 13, 2010 at 09:53:10PM +0800, Wu Fengguang wrote:
> > > > vread()/vwrite() is only called from kcore/kmem to access one page at a time.
> > > > So the logic can be vastly simplified.
> > > > 
> > > > The changes are:
> > > > - remove the vmlist walk and rely solely on vmalloc_to_page()
> > > > - replace the VM_IOREMAP check with (page && page_is_ram(pfn))
> > > > - rename to vread_page()/vwrite_page()
> > > > 
> > > > The page_is_ram() check is necessary because kmap_atomic() is not
> > > > designed to work with non-RAM pages.
> > > 
> > > I don't know if you can really do this. Previously vmlist_lock would be
> > > taken, which will prevent these vm areas from being freed.
> > >  
> > > > Note that even for a RAM page, we don't own the page, and cannot assume
> > > > it's a _PAGE_CACHE_WB page.
> > > 
> > > So why is this not a problem for your patch? I don't see how you handle
> > > it.
> > 
> > Sorry I didn't handle it. Just hope to catch attentions from someone
> > (ie. you :).
> > 
> > It's not a problem for x86_64 at all. For others I wonder if any
> > driver will vmalloc HIGHMEM pages with !_PAGE_CACHE_WB attribute..
> > 
> > So I noted the possible problem and leave it alone.
> 
> Well it doesn't need to be vmalloc. Any kind of vmap like ioremap. And
> these can be accompanied by changing the caching attribute. Like agp
> code, for an example. But I don't know if that ever becomes a problem
> in practice.

Yes vmap in general can change caching attribute. However I only care
about vmap that maps RAM pages, since my patch treats non-RAM pages as
hole and won't access them.

> > > What's the problem with the current code, exactly? I would prefer that
> > 
> > - unnecessary complexity to handle multi-page case, since it's always
> >   called to access one single page;
> 
> Fair point there. It just wasn't clear what exactly is your rationale
> because this was in a set of other patches.
>  
> > - the kmap_atomic() cache consistency problem, which I expressed some
> >   concern (without further action)
> 
> Which kmap_atomic problem? Can you explain again? Virtual cache aliasing
> problem you mean? Or caching attribute conflicts?

kmap_atomic() assumes you own the page and always use _PAGE_CACHE_WB.
So there may be conflicts if the page was !_PAGE_CACHE_WB.

> The whole thing looks stupid though, apparently kmap is used to avoid "the
> lock". But the lock is already held. We should just use the vmap
> address.

Yes. I wonder why Kame introduced kmap_atomic() in d0107eb07 -- given
that he at the same time fixed the order of removing vm_struct and
vmap in dd32c279983b.

> > > you continue using the same vmlist locking and checking for validating
> > > addresses.
> > 
> > It's a reasonable suggestion. Kame, would you agree on killing the
> > kmap_atomic() and revert to the vmlist walk?
> 
> Yes, vmlist locking is always required to have a pin on the pages, and
> IMO it should be quite easy to check for IOREMAP, so we should leave
> that check there to avoid the possibility of regressions.

I have no problem if Kame could dismiss my question :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
