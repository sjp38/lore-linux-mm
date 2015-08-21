Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 04D7F6B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 08:10:33 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so18132173wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 05:10:32 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id d13si14513289wjs.119.2015.08.21.05.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 05:10:31 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so14314001wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 05:10:30 -0700 (PDT)
Date: Fri, 21 Aug 2015 15:10:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150821121028.GB12016@node.dhcp.inet.fi>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Thu, Aug 20, 2015 at 04:36:43PM -0700, Andrew Morton wrote:
> On Wed, 19 Aug 2015 12:21:45 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > Hugh has pointed that compound_head() call can be unsafe in some
> > context. There's one example:
> > 
> > 	CPU0					CPU1
> > 
> > isolate_migratepages_block()
> >   page_count()
> >     compound_head()
> >       !!PageTail() == true
> > 					put_page()
> > 					  tail->first_page = NULL
> >       head = tail->first_page
> > 					alloc_pages(__GFP_COMP)
> > 					   prep_compound_page()
> > 					     tail->first_page = head
> > 					     __SetPageTail(p);
> >       !!PageTail() == true
> >     <head == NULL dereferencing>
> > 
> > The race is pure theoretical. I don't it's possible to trigger it in
> > practice. But who knows.
> > 
> > We can fix the race by changing how encode PageTail() and compound_head()
> > within struct page to be able to update them in one shot.
> > 
> > The patch introduces page->compound_head into third double word block in
> > front of compound_dtor and compound_order. That means it shares storage
> > space with:
> > 
> >  - page->lru.next;
> >  - page->next;
> >  - page->rcu_head.next;
> >  - page->pmd_huge_pte;
> > 
> > That's too long list to be absolutely sure, but looks like nobody uses
> > bit 0 of the word. It can be used to encode PageTail(). And if the bit
> > set, rest of the word is pointer to head page.
> 
> So nothing else which participates in the union in the "Third double
> word block" is allowed to use bit zero of the first word.

Correct.

> Is this really true?  For example if it's a slab page, will that page
> ever be inspected by code which is looking for the PageTail bit?

+Christoph.

What we know for sure is that space is not used in tail pages, otherwise
it would collide with current compound_dtor.

For head/small pages it gets trickier. I convinced myself that it should
be safe this way:

All fields it shares space with are pointers (with possible exception of
pmd_huge_pte, see below) to objects with sizeof() > 1. I think it's
reasonable to expect that the bit 0 in such pointers would be clear due
alignment. We do the same for page->mapping.

On pmd_huge_pte: it's pgtable_t which on most architectures is typedef to
struct page *. That should not create any conflicts. On some architectures
it's pte_t *, which is fine too. On arc it's virtual address of the page
in form of unsigned long. It should work.

The worry I have about pmd_huge_pte is that some new architecture may
choose to implement pgtable_t as pfn and that will collide on bit 0. :-/

We can address this worry by shifting pmd_huge_pte to the second word in
the double word block. But I'm not sure if we should.

And of course there's chance that these field are used not according to
its type. I didn't find such cases, but I can't guarantee that they don't
exist.

I tested patched kernel with all three SLAB allocator and was not able to
crash it under trinity. More testing is required.

> Anyway, this is quite subtle and there's a risk that people will
> accidentally break it later on.  I don't think the patch puts
> sufficient documentation in place to prevent this.

I would appreciate for suggestion on place and form of documentation.

> And even documentation might not be enough to prevent accidents.

The only think I can propose is VM_BUG_ON() in PageTail() and
compound_head() which would ensure that page->compound_page points to
place within MAX_ORDER_NR_PAGES before the current page if bit 0 is set.

Do you consider this helpful?

> >
> > ...
> >
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -120,7 +120,12 @@ struct page {
> >  		};
> >  	};
> >  
> > -	/* Third double word block */
> > +	/*
> > +	 * Third double word block
> > +	 *
> > +	 * WARNING: bit 0 of the first word encode PageTail and *must* be 0
> > +	 * for non-tail pages.
> > +	 */
> >  	union {
> >  		struct list_head lru;	/* Pageout list, eg. active_list
> >  					 * protected by zone->lru_lock !
> > @@ -143,6 +148,7 @@ struct page {
> >  						 */
> >  		/* First tail page of compound page */
> >  		struct {
> > +			unsigned long compound_head; /* If bit zero is set */
> 
> I think the comments around here should have more details and should
> be louder!

I'm always bad when it comes to documentation. Is it enough?

	/*
	 * Third double word block
	 *
	 * WARNING: bit 0 of the first word encode PageTail(). That means
	 * the rest users of the storage space MUST NOT use the bit to
	 * avoid collision and false-positive PageTail().
	 */
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
