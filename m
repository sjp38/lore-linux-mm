Date: Fri, 27 Oct 2006 14:06:26 +1000
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [RFC] reduce hugetlb_instantiation_mutex usage
Message-ID: <20061027040626.GI11733@localhost.localdomain>
References: <000101c6f94c$8138c590$ff0da8c0@amr.corp.intel.com> <20061026154451.bfe110c6.akpm@osdl.org> <20061026233137.GA11733@localhost.localdomain> <20061026170415.ec0bb0b9.akpm@osdl.org> <20061027031156.GH11733@localhost.localdomain> <20061026203522.d8b3e248.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061026203522.d8b3e248.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 26, 2006 at 08:35:22PM -0700, Andrew Morton wrote:
> On Fri, 27 Oct 2006 13:11:56 +1000
> "'David Gibson'" <david@gibson.dropbear.id.au> wrote:
> 
> > On Thu, Oct 26, 2006 at 05:04:15PM -0700, Andrew Morton wrote:
> > > On Fri, 27 Oct 2006 09:31:37 +1000
> > > "'David Gibson'" <david@gibson.dropbear.id.au> wrote:
> > > 
> > > > On Thu, Oct 26, 2006 at 03:44:51PM -0700, Andrew Morton wrote:
> > > > > On Thu, 26 Oct 2006 15:17:20 -0700
> > > > > "Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
> > > > > 
> > > > > > First rev of patch to allow hugetlb page fault to scale.
> > > > > > 
> > > > > > hugetlb_instantiation_mutex was introduced to prevent spurious allocation
> > > > > > failure in a corner case: two threads race to instantiate same page with
> > > > > > only one free page left in the global pool.  However, this global
> > > > > > serialization hurts fault performance badly as noted by Christoph Lameter.
> > > > > > This patch attempt to cut back the use of mutex only when free page resource
> > > > > > is limited, thus allow fault to scale in most common cases.
> > > > > >
> > > > > 
> > > > > ug.
> > > > > 
> > > > > How about we kill that instantiation_mutex thing altogether and fix
> > > > > the original bug in a better fashion?  Like...
> > > > > 
> > > > > In hugetlb_no_page():
> > > > > 
> > > > > retry:
> > > > > 	page = find_lock_page(...)
> > > > > 	if (!page) {
> > > > > 		write_lock_irq(&mapping->tree_lock);
> > > > > 		if (radix_tree_lookup(...)) {
> > > > > 			write_unlock_irq(tree_lock);
> > > > > 			goto retry;
> > > > > 		}
> > > > > 		page = alloc_huge_page(...);
> > > > > 		if (!page)
> > > > > 			bail;
> > > > > 		radix_tree_insert(...);
> > > > > 		SetPageLocked(page);
> > > > > 		write_unlock_irq(tree_lock);
> > > > > 		clear_huge_page(...);
> > > > > 	}
> > > > > 
> > > > > 	<stick it in page tables>
> > > > > 
> > > > > 	unlock_page(page);
> > > > > 
> > > > > The key points:
> > > > > 
> > > > > - Use tree_lock to prevent the race
> > > > > 
> > > > > - allocate the hugepage inside tree_lock so we never get into this
> > > > >   two-threads-tried-to-allocate-the-final-page problem.
> > > > > 
> > > > > - The hugepage is zeroed without locks held, under lock_page()
> > > > > 
> > > > > - lock_page() is used to make the other thread(s) sleep while the winner
> > > > >   thread is zeroing out the page.
> > > > > 
> > > > > It means that rather a lot of add_to_page_cache() will need to be copied
> > > > > into hugetlb_no_page().
> > > > 
> > > > This handles the case of processes racing on a shared mapping, but not
> > > > the case of threads racing on a private mapping.  In the latter case
> > > > the race ends at the set_pte() rather than the add_to_page_cache()
> > > > (well, strictly with the whole page_table_lock atomic lump).  And we
> > > > can't move the clear after the set_pte() :(.
> > > > 
> > > 
> > > I expect we can do a similar thing, using page_table_lock to prevent the
> > > race.
> > > 
> > > The key is to be able to make racing threads still block on the page lock. 
> > > Perhaps install a temp pte which is !pte_present() and also !pte_none(). 
> > > So the racing thread can use that pte to locate and wait upon the
> > > presently-locked page while it is being COWed by another CPU.
> > 
> > Um.. yes, that might work.  Though I'd need to think hard about a more
> > specific scheme.  I've been through a lot of approaches lately that
> > looked ok at first glance, but weren't :-/
> > 
> > And obviously we'd need to make sure such "tentative" PTEs are
> > constructible won't confuse other code on each relevant architecture.
> 
> There's various cross-arch infrastructure for this which is used for
> encoding swap offsets within pte's which could perhaps be
> ab^W^Wreused.

Yes, but the encoding and assumptions about ptes aren't always exactly
the same for hugeptes as normal ptes.

> Alternatively, we could put the page into pagecache whether or not the
> mapping is MAP_SHARED.  Then pull it out again prior to unlocking it if
> it's MAP_PRIVATE.  So we're using pagecache just as a way for the
> concurrent faulter to locate the page.

Hrm.. interesting if we can make it work.  I'd be worried about cases
with concurrent PRIVATE and SHARED pages on the same file offset.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
