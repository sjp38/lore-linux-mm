Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 721CF6B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 11:38:41 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 132-v6so3111285pga.18
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 08:38:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h9-v6si4322190pfh.240.2018.07.27.08.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 27 Jul 2018 08:38:40 -0700 (PDT)
Date: Fri, 27 Jul 2018 08:38:35 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH resend] powerpc/64s: fix page table fragment refcount
 race vs speculative references
Message-ID: <20180727153834.GC13348@bombadil.infradead.org>
References: <20180727114817.27190-1-npiggin@gmail.com>
 <20180727134156.GA13348@bombadil.infradead.org>
 <20180728002906.531d0211@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180728002906.531d0211@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org

On Sat, Jul 28, 2018 at 12:29:06AM +1000, Nicholas Piggin wrote:
> On Fri, 27 Jul 2018 06:41:56 -0700
> Matthew Wilcox <willy@infradead.org> wrote:
> 
> > On Fri, Jul 27, 2018 at 09:48:17PM +1000, Nicholas Piggin wrote:
> > > The page table fragment allocator uses the main page refcount racily
> > > with respect to speculative references. A customer observed a BUG due
> > > to page table page refcount underflow in the fragment allocator. This
> > > can be caused by the fragment allocator set_page_count stomping on a
> > > speculative reference, and then the speculative failure handler
> > > decrements the new reference, and the underflow eventually pops when
> > > the page tables are freed.  
> > 
> > Oof.  Can't you fix this instead by using page_ref_add() instead of
> > set_page_count()?
> 
> It's ugly doing it that way. The problem is we have a page table
> destructor and that would be missed if the spec ref was the last
> put. In practice with RCU page table freeing maybe you can say
> there will be no spec ref there (unless something changes), but
> still it just seems much simpler doing this and avoiding any
> complexity or relying on other synchronization.

I don't want to rely on the speculative reference not happening by the
time the page table is torn down; that's way too black-magic for me.
Another possibility would be to use, say, the top 16 bits of the
atomic for your counter and call the dtor once the atomic is below 64k.
I'm also thinking about overhauling the dtor system so it's not tied to
compound pages; anyone with a bit in page_type would be able to use it.
That way you'd always get your dtor called, even if the speculative
reference was the last one.

> > > Any objection to the struct page change to grab the arch specific
> > > page table page word for powerpc to use? If not, then this should
> > > go via powerpc tree because it's inconsequential for core mm.  
> > 
> > I want (eventually) to get to the point where every struct page carries
> > a pointer to the struct mm that it belongs to.  It's good for debugging
> > as well as handling memory errors in page tables.
> 
> That doesn't seem like it should be a problem, there's some spare
> words there for arch independent users.

Could you take one of the spare words instead then?  My intent was to
just take the 'x86 pgds only' comment off that member.  _pt_pad_2 looks
ideal because it'll be initialised to 0 and you'll return it to 0 by
the time you're done.
