Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 18C8C6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 02:27:08 -0400 (EDT)
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 31 Jul 2013 07:20:48 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id E348A219005E
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 07:31:19 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6V6QpWc60620816
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 06:26:51 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6V6R20n028442
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 00:27:02 -0600
Date: Wed, 31 Jul 2013 08:26:59 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 1/2] mm: add support for discard of unused ptes
Message-ID: <20130731082659.1b5a5377@mschwide>
In-Reply-To: <20130730134422.98c0977eada81d3ac41a08bb@linux-foundation.org>
References: <1374742461-29160-1-git-send-email-schwidefsky@de.ibm.com>
	<1374742461-29160-2-git-send-email-schwidefsky@de.ibm.com>
	<20130730134422.98c0977eada81d3ac41a08bb@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Weitz <konstantin.weitz@gmail.com>

On Tue, 30 Jul 2013 13:44:22 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 25 Jul 2013 10:54:20 +0200 Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
> 
> > From: Konstantin Weitz <konstantin.weitz@gmail.com>
> > 
> > In a virtualized environment and given an appropriate interface the guest
> > can mark pages as unused while they are free (for the s390 implementation
> > see git commit 45e576b1c3d00206 "guest page hinting light"). For the host
> > the unused state is a property of the pte.
> > 
> > This patch adds the primitive 'pte_unused' and code to the host swap out
> > handler so that pages marked as unused by all mappers are not swapped out
> > but discarded instead, thus saving one IO for swap out and potentially
> > another one for swap in.
> > 
> > ...
> >
> > --- a/include/asm-generic/pgtable.h
> > +++ b/include/asm-generic/pgtable.h
> > @@ -193,6 +193,19 @@ static inline int pte_same(pte_t pte_a, pte_t pte_b)
> >  }
> >  #endif
> >  
> > +#ifndef __HAVE_ARCH_PTE_UNUSED
> > +/*
> > + * Some architectures provide facilities to virtualization guests
> > + * so that they can flag allocated pages as unused. This allows the
> > + * host to transparently reclaim unused pages. This function returns
> > + * whether the pte's page is unused.
> > + */
> > +static inline int pte_unused(pte_t pte)
> > +{
> > +	return 0;
> > +}
> > +#endif
> > +
> >  #ifndef __HAVE_ARCH_PMD_SAME
> >  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >  static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index cd356df..2291f25 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1234,6 +1234,16 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  		}
> >  		set_pte_at(mm, address, pte,
> >  			   swp_entry_to_pte(make_hwpoison_entry(page)));
> > +	} else if (pte_unused(pteval)) {
> > +		/*
> > +		 * The guest indicated that the page content is of no
> > +		 * interest anymore. Simply discard the pte, vmscan
> > +		 * will take care of the rest.
> > +		 */
> > +		if (PageAnon(page))
> > +			dec_mm_counter(mm, MM_ANONPAGES);
> > +		else
> > +			dec_mm_counter(mm, MM_FILEPAGES);
> >  	} else if (PageAnon(page)) {
> >  		swp_entry_t entry = { .val = page_private(page) };
> 
> Obviously harmless.  Please include this in whatever tree carries
> "[PATCH 2/2] s390/kvm: support collaborative memory management".
 
Cool, thanks. This will go out via the KVM tree then.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
