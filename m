Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ADE856B004A
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 02:12:15 -0400 (EDT)
Date: Fri, 24 Sep 2010 14:58:58 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 04/10] hugetlb: hugepage migration core
Message-ID: <20100924055858.GB27176@spritzera.linux.bs1.fc.nec.co.jp>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1283908781-13810-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1009231131040.32567@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009231131040.32567@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Thank you for your review.

On Thu, Sep 23, 2010 at 11:52:26AM -0500, Christoph Lameter wrote:
> On Wed, 8 Sep 2010, Naoya Horiguchi wrote:
> 
> 
> > +static int hugetlbfs_migrate_page(struct address_space *mapping,
> > +				struct page *newpage, struct page *page)
> > +{
> > +	int rc;
> > +
> > +	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
> > +	if (rc)
> > +		return rc;
> > +	migrate_page_copy(newpage, page);
> > +
> > +	return 0;
> > +}
> > +
> >  static int hugetlbfs_statfs(struct dentry *dentry, struct kstatfs *buf)
> >  {
> >  	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(dentry->d_sb);
> > @@ -659,6 +673,7 @@ static const struct address_space_operations hugetlbfs_aops = {
> >  	.write_begin	= hugetlbfs_write_begin,
> >  	.write_end	= hugetlbfs_write_end,
> >  	.set_page_dirty	= hugetlbfs_set_page_dirty,
> > +	.migratepage    = hugetlbfs_migrate_page,
> >  };
> 
> Very straightforward conversion of innermost piece to huge pages. Good.
> 
> If migrate_page_move_mapping would do huge pages like it seems
> migrate_page_copy() does (a bit surprising) then we could save ourselves
> the function?

Yes, that sounds nice.
I'll do it in the next version.

> > index 351f8d1..55f3e2d 100644
> > --- v2.6.36-rc2/mm/hugetlb.c
> > +++ v2.6.36-rc2/mm/hugetlb.c
> > @@ -2217,6 +2217,19 @@ nomem:
> >  	return -ENOMEM;
> >  }
> >
> > +static int is_hugetlb_entry_migration(pte_t pte)
> > +{
> > +	swp_entry_t swp;
> > +
> > +	if (huge_pte_none(pte) || pte_present(pte))
> > +		return 0;
> > +	swp = pte_to_swp_entry(pte);
> > +	if (non_swap_entry(swp) && is_migration_entry(swp)) {
> > +		return 1;
> > +	} else
> > +		return 0;
> > +}
> 
> Ok that implies that to some extend swap must be supported for this case
> in the core vm?

Yes.
Currently hugepage does not support swapping in/out,
but does support migration entry and hwpoison entry
(both of them have swap entry format.)

> > @@ -2651,7 +2664,10 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	ptep = huge_pte_offset(mm, address);
> >  	if (ptep) {
> >  		entry = huge_ptep_get(ptep);
> > -		if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
> > +		if (unlikely(is_hugetlb_entry_migration(entry))) {
> > +			migration_entry_wait(mm, (pmd_t *)ptep, address);
> > +			return 0;
> > +		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
> >  			return VM_FAULT_HWPOISON;
> 
> No we have here in hugetlb_fault() a copy of  the migration wait logic
> from do_swap_page(). Hope the rest of the VM cannot inadvertantly
> encounter such a migration entry elsewhere?

No, because is_hugetlb_entry_migration() and is_hugetlb_entry_hwpoisoned()
can return true only when (!huge_pte_none(pte) && !pte_present(pte)) is true,
which means the entry is a swap entry.
Currently hugepage swap entry can only be created in page migration context
and in memory failure context, without any exceptions.

If hugepage swapping becomes available, we can insert an additional if()
to branch to like hugetlb_swap_page().


> 
> > diff --git v2.6.36-rc2/mm/migrate.c v2.6.36-rc2/mm/migrate.c
> 
> > @@ -130,10 +139,17 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
> >  	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
> >  	if (is_write_migration_entry(entry))
> >  		pte = pte_mkwrite(pte);
> > +	if (PageHuge(new))
> > +		pte = pte_mkhuge(pte);
> >  	flush_cache_page(vma, addr, pte_pfn(pte));
> >  	set_pte_at(mm, addr, ptep, pte);
> >
> > -	if (PageAnon(new))
> > +	if (PageHuge(new)) {
> > +		if (PageAnon(new))
> > +			hugepage_add_anon_rmap(new, vma, addr);
> > +		else
> > +			page_dup_rmap(new);
> 
> dup_rmap? What are non anon huge pages use for? That is not a file backed
> huge page right?

Yes, it's for file backed huge page.

This page_dup_rmap() is a hugepage variant of page_add_file_rmap().
Currently we don't account hugepage for zone_page_state nor for memory cgroup,
so only atomic_add() is needed and page_dup_rmap() does it.
I think it's OK because try_to_unmap_one() calls page_remove_rmap() both for
file mapped page and for anonymous page ("rmap" is a common term for both.)


> > @@ -276,11 +292,59 @@ static int migrate_page_move_mapping(struct address_space *mapping,
> >  }
> >
> >  /*
> > + * The expected number of remaining references is the same as that
> > + * of migrate_page_move_mapping().
> > + */
> > +int migrate_huge_page_move_mapping(struct address_space *mapping,
> > +				   struct page *newpage, struct page *page)
> > +{
> > +	int expected_count;
> > +	void **pslot;
> > +
> > +	if (!mapping) {
> > +		if (page_count(page) != 1)
> > +			return -EAGAIN;
> > +		return 0;
> > +	}
> > +
> > +	spin_lock_irq(&mapping->tree_lock);
> > +
> > +	pslot = radix_tree_lookup_slot(&mapping->page_tree,
> > +					page_index(page));
> > +
> > +	expected_count = 2 + page_has_private(page);
> > +	if (page_count(page) != expected_count ||
> > +	    (struct page *)radix_tree_deref_slot(pslot) != page) {
> > +		spin_unlock_irq(&mapping->tree_lock);
> > +		return -EAGAIN;
> > +	}
> > +
> > +	if (!page_freeze_refs(page, expected_count)) {
> > +		spin_unlock_irq(&mapping->tree_lock);
> > +		return -EAGAIN;
> > +	}
> > +
> > +	get_page(newpage);
> > +
> > +	radix_tree_replace_slot(pslot, newpage);
> > +
> > +	page_unfreeze_refs(page, expected_count);
> > +
> > +	__put_page(page);
> > +
> > +	spin_unlock_irq(&mapping->tree_lock);
> > +	return 0;
> > +}
> 
> Thats a pretty accurate copy of move_mapping(). Why are the counter
> updates missing at the end? This also suggests that the two functions
> could be merged into one.

Because hugepage are not counted as zone page statistics elsewhere.
But surely it looks better to merge these two functions with adding
if () around counter updates.


> > @@ -724,6 +788,92 @@ move_newpage:
> >  }
> >
> >  /*
> > + * Counterpart of unmap_and_move_page() for hugepage migration.
> > + *
> > + * This function doesn't wait the completion of hugepage I/O
> > + * because there is no race between I/O and migration for hugepage.
> > + * Note that currently hugepage I/O occurs only in direct I/O
> > + * where no lock is held and PG_writeback is irrelevant,
> > + * and writeback status of all subpages are counted in the reference
> > + * count of the head page (i.e. if all subpages of a 2MB hugepage are
> > + * under direct I/O, the reference of the head page is 512 and a bit more.)
> > + * This means that when we try to migrate hugepage whose subpages are
> > + * doing direct I/O, some references remain after try_to_unmap() and
> > + * hugepage migration fails without data corruption.
> > + *
> > + * There is also no race when direct I/O is issued on the page under migration,
> > + * because then pte is replaced with migration swap entry and direct I/O code
> > + * will wait in the page fault for migration to complete.
> > + */
> > +static int unmap_and_move_huge_page(new_page_t get_new_page,
> > +				unsigned long private, struct page *hpage,
> > +				int force, int offlining)
> > +{
> > +	int rc = 0;
> > +	int *result = NULL;
> > +	struct page *new_hpage = get_new_page(hpage, private, &result);
> > +	int rcu_locked = 0;
> > +	struct anon_vma *anon_vma = NULL;
> > +
> > +	if (!new_hpage)
> > +		return -ENOMEM;
> > +
> > +	rc = -EAGAIN;
> > +
> > +	if (!trylock_page(hpage)) {
> > +		if (!force)
> > +			goto out;
> > +		lock_page(hpage);
> > +	}
> > +
> > +	if (PageAnon(hpage)) {
> > +		rcu_read_lock();
> > +		rcu_locked = 1;
> > +
> > +		if (page_mapped(hpage)) {
> > +			anon_vma = page_anon_vma(hpage);
> > +			atomic_inc(&anon_vma->external_refcount);
> > +		}
> > +	}
> > +
> > +	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> > +
> > +	if (!page_mapped(hpage))
> > +		rc = move_to_new_page(new_hpage, hpage, 1);
> > +
> > +	if (rc)
> > +		remove_migration_ptes(hpage, hpage);
> > +
> > +	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount,
> > +					    &anon_vma->lock)) {
> > +		int empty = list_empty(&anon_vma->head);
> > +		spin_unlock(&anon_vma->lock);
> > +		if (empty)
> > +			anon_vma_free(anon_vma);
> 
> Hmmm.. The anon_vma dropping looks different? Why cant we use
> drop_anon_mva like in unmap_and_move? Also we do not take the root lock
> like drop_anon_vma does.

Oh, I failed to follow the latest code in rebasing.
Recently anon_vma code is frequently updated.
I'll fix it.


> > @@ -788,6 +938,52 @@ out:
> >  	return nr_failed + retry;
> >  }
> >
> > +int migrate_huge_pages(struct list_head *from,
> > +		new_page_t get_new_page, unsigned long private, int offlining)
> > +{
> > +	int retry = 1;
> > +	int nr_failed = 0;
> > +	int pass = 0;
> > +	struct page *page;
> > +	struct page *page2;
> > +	int rc;
> > +
> > +	for (pass = 0; pass < 10 && retry; pass++) {
> > +		retry = 0;
> > +
> > +		list_for_each_entry_safe(page, page2, from, lru) {
> > +			cond_resched();
> > +
> > +			rc = unmap_and_move_huge_page(get_new_page,
> > +					private, page, pass > 2, offlining);
> > +
> > +			switch(rc) {
> > +			case -ENOMEM:
> > +				goto out;
> > +			case -EAGAIN:
> > +				retry++;
> > +				break;
> > +			case 0:
> > +				break;
> > +			default:
> > +				/* Permanent failure */
> > +				nr_failed++;
> > +				break;
> > +			}
> > +		}
> > +	}
> > +	rc = 0;
> > +out:
> > +
> > +	list_for_each_entry_safe(page, page2, from, lru)
> > +		put_page(page);
> > +
> > +	if (rc)
> > +		return rc;
> > +
> > +	return nr_failed + retry;
> > +}
> 
> Copy of migrate_pages(). putback_lru_pages() omitted as also proposed for
> upstream in a recent discussion.

Sure.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
