Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE716B003D
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 09:55:55 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n2TDujSL027135
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 13:56:45 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2TDuicT3395804
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 15:56:44 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2TDuiRO009661
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 15:56:44 +0200
Date: Sun, 29 Mar 2009 15:56:40 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [patch 1/6] Guest page hinting: core + volatile page cache.
Message-ID: <20090329155640.31472c61@skybase>
In-Reply-To: <49CD59DB.3070906@redhat.com>
References: <20090327150905.819861420@de.ibm.com>
	<20090327151011.534224968@de.ibm.com>
	<49CD59DB.3070906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 27 Mar 2009 18:57:31 -0400
Rik van Riel <riel@redhat.com> wrote:

> Martin Schwidefsky wrote:
> 
> > The major obstacles that need to get addressed:
> > * Concurrent page state changes:
> >   To guard against concurrent page state updates some kind of lock
> >   is needed. If page_make_volatile() has already done the 11 checks it
> >   will issue the state change primitive. If in the meantime one of
> >   the conditions has changed the user that requires that page in
> >   stable state will have to wait in the page_make_stable() function
> >   until the make volatile operation has finished. It is up to the
> >   architecture to define how this is done with the three primitives
> >   page_test_set_state_change, page_clear_state_change and
> >   page_state_change.
> >   There are some alternatives how this can be done, e.g. a global
> >   lock, or lock per segment in the kernel page table, or the per page
> >   bit PG_arch_1 if it is still free.
> 
> Can this be taken care of by memory barriers and
> careful ordering of operations?

I don't see how this could be done with memory barries, the sequence is
1) check conditions
2) do state change to volatile

another cpus can do
i) change one of the conditions

The operation i) needs to be postponed while the first cpu has done 1)
but not done 2) yet. 1+2 needs to be atomic but consists of several
instructions. Ergo we need a lock, no ?

> If we consider the states unused -> volatile -> stable
> as progressively higher, "upgrades" can be done before
> any kernel operation that requires the page to be in
> that state (but after setting up the things that allow
> it to be found), while downgrades can be done after the
> kernel is done with needing the page at a higher level.
> 
> Since the downgrade checks for users that need the page
> in a higher state, no lock should be required.
> 
> In fact, it may be possible to manage the page state
> bitmap with compare-and-swap, without needing a call
> to the hypervisor.
> 
> > Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> Some comments and questions in line.
> 
> > @@ -601,6 +604,21 @@ copy_one_pte(struct mm_struct *dst_mm, s
> >  
> >  out_set_pte:
> >  	set_pte_at(dst_mm, addr, dst_pte, pte);
> > +	return;
> > +
> > +out_discard_pte:
> > +	/*
> > +	 * If the page referred by the pte has the PG_discarded bit set,
> > +	 * copy_one_pte is racing with page_discard. The pte may not be
> > +	 * copied or we can end up with a pte pointing to a page not
> > +	 * in the page cache anymore. Do what try_to_unmap_one would do
> > +	 * if the copy_one_pte had taken place before page_discard.
> > +	 */
> > +	if (page->index != linear_page_index(vma, addr))
> > +		/* If nonlinear, store the file page offset in the pte. */
> > +		set_pte_at(dst_mm, addr, dst_pte, pgoff_to_pte(page->index));
> > +	else
> > +		pte_clear(dst_mm, addr, dst_pte);
> >  }
> 
> It would be good to document that PG_discarded can only happen for
> file pages and NOT for eg. clean swap cache pages.

PG_discarded can happen for swap cache pages as well. If a clean swap
cache page gets remove and subsequently access again the discard fault
handler will set the bit (see __page_discard). The code necessary for
volatile swap cache is introduced with patch #2. So I would rather not
add a comment in patch #1 only to remove it again with patch #2 ..

> > @@ -1390,6 +1391,7 @@ int test_clear_page_writeback(struct pag
> >  			radix_tree_tag_clear(&mapping->page_tree,
> >  						page_index(page),
> >  						PAGECACHE_TAG_WRITEBACK);
> > +			page_make_volatile(page, 1);
> >  			if (bdi_cap_account_writeback(bdi)) {
> >  				__dec_bdi_stat(bdi, BDI_WRITEBACK);
> >  				__bdi_writeout_inc(bdi);
> 
> Does this mark the page volatile before the IO writing the
> dirty data back to disk has even started?  Is that OK?
 
Hmm, it could be that the page_make_volatile is just superflouos here.
The logic here is that whenever one of the conditions that prevent a
page from becoming volatile is cleared a try with page_make_volatile
is done. The condition in question here is PageWriteback(page). If we
can prove that one of the other conditions is true this particular call
is a waste of effort.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
