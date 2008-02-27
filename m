Subject: Re: [PATCH 00/28] Swap over NFS -v16
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1204100059.6242.360.camel@lappy>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
	 <1204099113.6242.353.camel@lappy>
	 <84144f020802270005p3bfbd04ar9da2875218ef98c4@mail.gmail.com>
	 <1204100059.6242.360.camel@lappy>
Content-Type: text/plain
Date: Wed, 27 Feb 2008 09:33:58 +0100
Message-Id: <1204101239.6242.372.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 2008-02-27 at 09:14 +0100, Peter Zijlstra wrote:
> On Wed, 2008-02-27 at 10:05 +0200, Pekka Enberg wrote:
> > Hi Peter,
> > 
> > On Wed, Feb 27, 2008 at 9:58 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > >  > 1/ I note there is no way to tell if memory returned by kmalloc is
> > >  >   from the emergency reserve - which contrasts with alloc_page
> > >  >   which does make that information available through page->reserve.
> > >  >   This seems a slightly unfortunate aspect of the interface.
> > >
> > >  Yes, but alas there is no room to store such information in kmalloc().
> > >  That is, in a sane way. I think it was Daniel Phillips who suggested
> > >  encoding it in the return pointer by flipping the low bit - but that is
> > >  just too ugly and breaks all current kmalloc sites to boot.
> > 
> > Why can't you add a kmem_is_emergency() to SLUB that looks up the
> > cache/slab/page (whatever is the smallest unit of the emergency pool
> > here) for the object and use that?
> 
> There is an idea.. :-) It would mean preserving page->reserved, but SLUB
> has plenty of page flags to pick from. Or maybe I should move the thing
> to a page flag anyway. If we do that SLAB would allow something similar,
> just look up the page for whatever address you get and look at PG_emerg
> or something.
> 
> Having this would clean things up. I'll go work on this.

Humm, and here I sit staring at the screen. Perhaps I should go get my
morning juice, but...

  if (mem_reserve_kmalloc_charge(my_res, sizeof(*foo), 0)) {
    foo = kmalloc(sizeof(*foo), gfp|__GFP_MEMALLOC)
    if (!kmem_is_emergency(foo))
      mem_reserve_kmalloc_charge(my_res, -sizeof(*foo), 0)
  } else
    foo = kmalloc(sizeof(*foo), gfp);

Just doesn't look too pretty..

And needing to always account the allocation seems wrong.. but I'll take
poison and see if that wakes up my mind.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
