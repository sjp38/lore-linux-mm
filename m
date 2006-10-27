Date: Thu, 26 Oct 2006 17:04:15 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] reduce hugetlb_instantiation_mutex usage
Message-Id: <20061026170415.ec0bb0b9.akpm@osdl.org>
In-Reply-To: <20061026233137.GA11733@localhost.localdomain>
References: <000101c6f94c$8138c590$ff0da8c0@amr.corp.intel.com>
	<20061026154451.bfe110c6.akpm@osdl.org>
	<20061026233137.GA11733@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Oct 2006 09:31:37 +1000
"'David Gibson'" <david@gibson.dropbear.id.au> wrote:

> On Thu, Oct 26, 2006 at 03:44:51PM -0700, Andrew Morton wrote:
> > On Thu, 26 Oct 2006 15:17:20 -0700
> > "Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
> > 
> > > First rev of patch to allow hugetlb page fault to scale.
> > > 
> > > hugetlb_instantiation_mutex was introduced to prevent spurious allocation
> > > failure in a corner case: two threads race to instantiate same page with
> > > only one free page left in the global pool.  However, this global
> > > serialization hurts fault performance badly as noted by Christoph Lameter.
> > > This patch attempt to cut back the use of mutex only when free page resource
> > > is limited, thus allow fault to scale in most common cases.
> > >
> > 
> > ug.
> > 
> > How about we kill that instantiation_mutex thing altogether and fix
> > the original bug in a better fashion?  Like...
> > 
> > In hugetlb_no_page():
> > 
> > retry:
> > 	page = find_lock_page(...)
> > 	if (!page) {
> > 		write_lock_irq(&mapping->tree_lock);
> > 		if (radix_tree_lookup(...)) {
> > 			write_unlock_irq(tree_lock);
> > 			goto retry;
> > 		}
> > 		page = alloc_huge_page(...);
> > 		if (!page)
> > 			bail;
> > 		radix_tree_insert(...);
> > 		SetPageLocked(page);
> > 		write_unlock_irq(tree_lock);
> > 		clear_huge_page(...);
> > 	}
> > 
> > 	<stick it in page tables>
> > 
> > 	unlock_page(page);
> > 
> > The key points:
> > 
> > - Use tree_lock to prevent the race
> > 
> > - allocate the hugepage inside tree_lock so we never get into this
> >   two-threads-tried-to-allocate-the-final-page problem.
> > 
> > - The hugepage is zeroed without locks held, under lock_page()
> > 
> > - lock_page() is used to make the other thread(s) sleep while the winner
> >   thread is zeroing out the page.
> > 
> > It means that rather a lot of add_to_page_cache() will need to be copied
> > into hugetlb_no_page().
> 
> This handles the case of processes racing on a shared mapping, but not
> the case of threads racing on a private mapping.  In the latter case
> the race ends at the set_pte() rather than the add_to_page_cache()
> (well, strictly with the whole page_table_lock atomic lump).  And we
> can't move the clear after the set_pte() :(.
> 

I expect we can do a similar thing, using page_table_lock to prevent the
race.

The key is to be able to make racing threads still block on the page lock. 
Perhaps install a temp pte which is !pte_present() and also !pte_none(). 
So the racing thread can use that pte to locate and wait upon the
presently-locked page while it is being COWed by another CPU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
