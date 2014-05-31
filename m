Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1D18E6B0035
	for <linux-mm@kvack.org>; Sat, 31 May 2014 00:46:05 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so1608896pdi.41
        for <linux-mm@kvack.org>; Fri, 30 May 2014 21:46:04 -0700 (PDT)
Received: from mail-pb0-x229.google.com (mail-pb0-x229.google.com [2607:f8b0:400e:c01::229])
        by mx.google.com with ESMTPS id ae4si8146239pbc.257.2014.05.30.21.46.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 21:46:04 -0700 (PDT)
Received: by mail-pb0-f41.google.com with SMTP id uo5so2413192pbc.28
        for <linux-mm@kvack.org>; Fri, 30 May 2014 21:46:03 -0700 (PDT)
Date: Fri, 30 May 2014 21:44:45 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 0/3] File Sealing & memfd_create()
In-Reply-To: <CANq1E4TDDzG+HtBz261_nid3kVRG_jwcWHizzkdZCZZE3BaLgQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1405301956570.1037@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com> <alpine.LSU.2.11.1405132118330.4401@eggly.anvils> <537396A2.9090609@cybernetics.com> <alpine.LSU.2.11.1405141456420.2268@eggly.anvils> <CANq1E4QgSbD9G70H7W4QeXbZ77_Kn1wV7edwzN4k4NjQJS=36A@mail.gmail.com>
 <20140519160942.GD3427@quack.suse.cz> <alpine.LSU.2.11.1405191403280.969@eggly.anvils> <CANq1E4TDDzG+HtBz261_nid3kVRG_jwcWHizzkdZCZZE3BaLgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Tony Battersby <tonyb@cybernetics.com>, Al Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mgorman@suse.de>

On Mon, 26 May 2014, David Herrmann wrote:
> 
> (CC migrate.c committers)
> 
> On Tue, May 20, 2014 at 12:11 AM, Hugh Dickins <hughd@google.com> wrote:
> > On Mon, 19 May 2014, Jan Kara wrote:
> >> On Mon 19-05-14 13:44:25, David Herrmann wrote:
> >> > On Thu, May 15, 2014 at 12:35 AM, Hugh Dickins <hughd@google.com> wrote:
> >> > > The aspect which really worries me is this: the maintenance burden.
> >> > > This approach would add some peculiar new code, introducing a rare
> >> > > special case: which we might get right today, but will very easily
> >> > > forget tomorrow when making some other changes to mm.  If we compile
> >> > > a list of danger areas in mm, this would surely belong on that list.
> >> >
> >> > I tried doing the page-replacement in the last 4 days, but honestly,
> >> > it's far more complex than I thought. So if no-one more experienced
> >
> > To be honest, I'm quite glad to hear that: it is still a solution worth
> > considering, but I'd rather continue the search for a better solution.
> 
> What if we set VM_IO for memory-mappings if a file supports sealing?
> That might be a hack and quite restrictive, but we could also add a
> VM_DONTPIN flag that just prevents any page-pinning like GUP (which is
> also a side-effect of VM_IO). This is basically what we do to protect
> PCI BARs from that race during hotplug (well, VM_PFNMAP ist what
> protects those, but the code is the same). If we mention in the
> man-page that memfd-objects don't support direct-IO, we'd be fine, I
> think. Not sure if that hack is better than the page-replacement,
> though. It'd be definitely much simpler.

I admire your resourcefulness, but three things put me off using
VM_IO.

One is just a great distaste for using VM_IO in mm, when it's about
device and memory regions unknown to mm.  You can indeed get around
that objection by making a new VM_DONTPIN with similar restrictions.

Two is that I'm afraid of those restrictions which you foresee.
Soon after putting this in, we shall have people saying "I can't
do such-and-such on my memfd-object, can you please enable it"
and then we shall have to find another solution.

But three, more importantly, that gives no protection against
get_user_pages_fast() callers: as mentioned before, GUP-fast works
on page tables, not examining vmas at all, so it is blind to VM_IO.

get_user_pages_fast() does check pte access, and pte_special bit,
falling back to get_user_pages() if unsuitable: IIRC, pte_special
support is important for an architecture to support GUP-fast.
But I definitely don't want any shmem to be !vm_normal_page().

> 
> Regarding page-replacement, I tried using migrate_page(), however,
> this obviously fails in page_freeze_refs() due to the elevated
> ref-count and we cannot account for those, as they might vanish
> asynchronously. Now I wonder whether we could just add a new mode
> MIGRATE_PHASE_OUT that avoids freezing the page and forces the copy.
> Existing refs would still operate on the old page, but any new access
> gets the new page. This way, we could collect pages with elevated
> ref-counts in shmem similar to do_move_page_to_node_array() and then
> call migrate_pages(). Now migrate_pages() takes good care to prevent
> any new refs during migration. try_to_unmap(TTU_MIGRATION) marks PTEs
> as 'in-migration', so accesses are delayed. Page-faults wait on the
> page-lock and retry due to mapping==NULL. lru is disabled beforehand.
> Therefore, there cannot be any racing page-lookups as they all stall
> on the migration. Moreover, page_freeze_refs() fails only if the page
> is pinned by independent users (usually some form of I/O).
> Question is what those additional ref-counts might be. Given that
> shmem 'owns' its pages, none of these external references should pass
> those refs around. All they use it for is I/O. Therefore, we shouldn't
> even need an additional try_to_unmap() _after_ MIGRATE_PHASE_OUT as we
> expect those external refs to never pass page-refs around. If that's a
> valid assumption (and I haven't found any offenders so far), we should
> be good with migrate_pages(MIGRATE_PHASE_OUT) as I described.
> 
> Comments?

I have not given these details all the attention that they deserve.
It's Tony's copy-on-seal suggestion, fleshed out to use the migration
infrastructure; but I still feel the same way about it as I did before.

It's complexity (and complexity outside of mm/shmem.c) that I would
prefer to avoid; and I find it hard to predict the consequence of
this copy-on-write-in-reverse, where existing users are left holding
something that used to be part of the object and now is not.  Perhaps
the existing sudden-truncation codepaths would handle it appropriately,
perhaps they would not.

(I wonder if Daniel Phillips's Tux3 "page fork"ing is relevant here?
But don't want to explore that right now.  "Revoke" also comes to mind.)

I do think it may turn out to be a good future way forward, if what
we do now turns out to be too restrictive; but we don't want to turn
mm (slightly) upside down just to get sealing in.

> 
> While skimming over migrate.c I noticed two odd behaviors:
> 1) migration_entry_wait() is used to wait on a migration to finish,
> before accessing PTE entries. However, we call get_page() there, which
> increases the ref-count of the old page and causes page_freeze_refs()
> to fail. There's no way we can know how many tasks wait on a migration
> entry when calling page_freeze_refs(). I have no idea how that's
> supposed to work? Why don't we store the new page in the migration-swp
> entry so any lookups stall on the new page? We don't care for
> ref-counts on that page and if the migration fails, new->mapping is
> set to NULL and any lookup is retried. remove_migration_pte() can
> restore the old page correctly.

Good point.  IIRC one reason for using the old page in the migration
pte, is that the migration may fail and the new page be discarded before
the old ptes have been restored.  Perhaps some rearrangement could handle
that.  As to how it works at present, I think it simply relies on the
unlikelihood that any migration_entry_wait() will raise the page count
before the "expected_count" is checked.  And there's a fair bit of
-EAGAIN retrying too.

But again, I've only just caught up with you here, and haven't thought
about it much yet.  I don't remember considering migration_entry_wait()
as counter-productive in the way you indicate: worth more thought.

> 2) remove_migration_pte() calls get_page(new) before writing the PTE.
> But who releases the ref of the old page?

putback_lru_page()?  You may want a longer answer, or you may have
worked it out for yourself meanwhile - I'm confident that we do not
actually have a common leak there, that would have been noticed by now.


After all that negativity, below is a function for you.  Basically,
it's for your original idea of checking page references at sealing
time.  I was put off by the thought of endless attempts to get every
page of a large file accountable at the same time, but didn't think
of radix_tree tags until a couple of nights ago: they make it much
more palatable.

This is not wonderful (possibility of -EBUSY after 150ms - even if
pages are pinned for read only); but I think it's good enough, to
start with anyway.  You may disagree - and please don't jump at it, 
just because you're keen to get the sealing in.

I imagine you calling this near the i_mmap_writable check, and only
bothering to call it when the object has at some time been mapped
VM_SHARED (note VM_SHARED in shmem_inode_info->flags).  Precisely
the locking needed, we can see when you have i_mmap_writable right.

I still have your replies on 1-3/3 to respond to: not tonight.
Oh, before I forget, linux-api@vger.kernel.org - that's a mailing
list that we've only recently become conscious of, good for Cc'ing
patches such as yours to.

Hugh

/*
 * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
 * so reuse a tag which we firmly believe is never set or cleared on shmem.
 */
#define SHMEM_TAG_PINNED	PAGECACHE_TAG_TOWRITE
#define LAST_SCAN		4	/* about 150ms max */

static int shmem_wait_for_pins(struct address_space *mapping)
{
	struct radix_tree_iter iter;
	void **slot;
	pgoff_t start;
	struct page *page;
	int scan;
	int error;

	start = 0;
	rcu_read_lock();
restart1:
	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
		page = radix_tree_deref_slot(slot);
		if (!page || radix_tree_exception(page)) {
			if (radix_tree_deref_retry(page))
				goto restart1;
			goto continue1;
		}

		if (page_count(page) - page_mapcount(page) == 1)
			goto continue1;

		spin_lock_irq(&mapping->tree_lock);
		radix_tree_tag_set(&mapping->page_tree, iter.index,
						SHMEM_TAG_PINNED);
		spin_unlock_irq(&mapping->tree_lock);
continue1:
		if (need_resched()) {
			cond_resched_rcu();
			start = iter.index + 1;
			goto restart1;
		}
	}
	rcu_read_unlock();

	error = 0;
	for (scan = 0; scan <= LAST_SCAN; scan++) {
		if (!radix_tree_tagged(&mapping->page_tree, SHMEM_TAG_PINNED))
			break;

		if (!scan)
			lru_add_drain_all();
		else if (schedule_timeout_killable((HZ << scan) / 200))
			scan = LAST_SCAN;

		start = 0;
		rcu_read_lock();
restart2:
		radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter,
						start, SHMEM_TAG_PINNED) {
			page = radix_tree_deref_slot(slot);
			if (radix_tree_exception(page)) {
				if (radix_tree_deref_retry(page))
					goto restart2;
				page = NULL;
			}

			if (page &&
			    page_count(page) - page_mapcount(page) != 1) {
				if (scan < LAST_SCAN)
					goto continue2;
				/*
				 * On the last scan, we should probably clean
				 * up all those tags we inserted; but make a
				 * note that we still found pages pinned.
				 */
				error = -EBUSY;
			}

			spin_lock_irq(&mapping->tree_lock);
			radix_tree_tag_clear(&mapping->page_tree,
						iter.index, SHMEM_TAG_PINNED);
			spin_unlock_irq(&mapping->tree_lock);
continue2:
			if (need_resched()) {
				cond_resched_rcu();
				start = iter.index + 1;
				goto restart2;
			}
		}
		rcu_read_unlock();
	}

	return error;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
