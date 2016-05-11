Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C333E6B025F
	for <linux-mm@kvack.org>; Wed, 11 May 2016 15:26:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 4so103347528pfw.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 12:26:34 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id o8si11433460pfi.251.2016.05.11.12.26.33
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 12:26:33 -0700 (PDT)
Date: Wed, 11 May 2016 13:26:32 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 16/18] dax: New fault locking
Message-ID: <20160511192632.GA8841@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-17-git-send-email-jack@suse.cz>
 <20160506041350.GA29628@linux.intel.com>
 <20160510122715.GK11897@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160510122715.GK11897@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Tue, May 10, 2016 at 02:27:15PM +0200, Jan Kara wrote:
> On Thu 05-05-16 22:13:50, Ross Zwisler wrote:
> > On Mon, Apr 18, 2016 at 11:35:39PM +0200, Jan Kara wrote:
> > > +/*
> > > + * Find radix tree entry at given index. If it points to a page, return with
> > > + * the page locked. If it points to the exceptional entry, return with the
> > > + * radix tree entry locked. If the radix tree doesn't contain given index,
> > > + * create empty exceptional entry for the index and return with it locked.
> > > + *
> > > + * Note: Unlike filemap_fault() we don't honor FAULT_FLAG_RETRY flags. For
> > > + * persistent memory the benefit is doubtful. We can add that later if we can
> > > + * show it helps.
> > > + */
> > > +static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index)
> > > +{
> > > +	void *ret, **slot;
> > > +
> > > +restart:
> > > +	spin_lock_irq(&mapping->tree_lock);
> > > +	ret = get_unlocked_mapping_entry(mapping, index, &slot);
> > > +	/* No entry for given index? Make sure radix tree is big enough. */
> > > +	if (!ret) {
> > > +		int err;
> > > +
> > > +		spin_unlock_irq(&mapping->tree_lock);
> > > +		err = radix_tree_preload(
> > > +				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
> > 
> > In the conversation about v2 of this series you said:
> > 
> > > Note that we take the hit for dropping the lock only if we really need to
> > > allocate new radix tree node so about once per 64 new entries. So it is not
> > > too bad.
> > 
> > I think this is incorrect.  We get here whenever we get a NULL return from
> > __radix_tree_lookup().  I believe that this happens if we don't have a node,
> > in which case we need an allocation, but I think it also happens in the case
> > where we do have a node and we just have a NULL slot in that node.
> > 
> > For the behavior you're looking for (only preload if you need to do an
> > allocation), you probably need to check the 'slot' we get back from
> > get_unlocked_mapping_entry(), yea?
> 
> You are correct. However currently __radix_tree_lookup() doesn't return a
> slot pointer if entry was not found so it is not easy to fix. So I'd leave
> the code as is for now and we can later optimize the case where we don't
> need to grow the radix tree...

Ah, you're right.  Sure, that plan sounds good.

> > > +/*
> > > + * Delete exceptional DAX entry at @index from @mapping. Wait for radix tree
> > > + * entry to get unlocked before deleting it.
> > > + */
> > > +int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
> > > +{
> > > +	void *entry;
> > > +
> > > +	spin_lock_irq(&mapping->tree_lock);
> > > +	entry = get_unlocked_mapping_entry(mapping, index, NULL);
> > > +	/*
> > > +	 * Caller should make sure radix tree modifications don't race and
> > > +	 * we have seen exceptional entry here before.
> > > +	 */
> > > +	if (WARN_ON_ONCE(!entry || !radix_tree_exceptional_entry(entry))) {
> > 
> > dax_delete_mapping_entry() is only called from clear_exceptional_entry().
> > With this new code we've changed the behavior of that call path a little.
> > 
> > In the various places where clear_exceptional_entry() is called, the code
> > batches up a bunch of entries in a pvec via pagevec_lookup_entries().  We
> > don't hold the mapping->tree_lock between the time this lookup happens and the
> > time that the entry is passed to clear_exceptional_entry(). This is why the
> > old code did a verification that the entry passed in matched what was still
> > currently present in the radix tree.  This was done in the DAX case via
> > radix_tree_delete_item(), and it was open coded in clear_exceptional_entry()
> > for the page cache case.  In both cases if the entry didn't match what was
> > currently in the tree, we bailed without doing anything.
> > 
> > This new code doesn't verify against the 'entry' passed to
> > clear_exceptional_entry(), but instead makes sure it is an exceptional entry
> > before removing, and if not it does a WARN_ON_ONCE().
> > 
> > This changes things because:
> > 
> > a) If the exceptional entry changed, say from a plain lock entry to an actual
> > DAX entry, we wouldn't notice, and we would just clear the latter out.  My
> > guess is that this is fine, I just wanted to call it out.
> > 
> > b) If we have a non-exceptional entry here now, say because our lock entry has
> > been swapped out for a zero page, we will WARN_ON_ONCE() and return without a
> > removal.  I think we may want to silence the WARN_ON_ONCE(), as I believe this
> > could happen during normal operation and we don't want to scare anyone. :)
> 
> So your concerns are exactly why I have added a comment to
> dax_delete_mapping_entry() that:
> 
> 	/*
> 	 * Caller should make sure radix tree modifications don't race and
> 	 * we have seen exceptional entry here before.
> 	 */
> 
> The thing is dax_delete_mapping_entry() is called only from truncate /
> punch hole path. Those should hold i_mmap_sem for writing and thus there
> should be no modifications of the radix tree. If anything changes, between
> what truncate_inode_pages() (or similar functions) finds and what
> dax_delete_mapping_entry() sees, we have a locking bug and I want to know
> about it :). Any suggestion how I should expand the comment so that this is
> clearer?

Ah, I didn't understand all that.  :)  Given a bit more context the comment
seems fine - if anything it could be a bit more specific, and include the
text: "dax_delete_mapping_entry() is called only from truncate / punch hole
path. Those should hold i_mmap_sem for writing and thus there should be no
modifications of the radix tree."  Either way - thanks for explaining.

> > > +/*
> > >   * The user has performed a load from a hole in the file.  Allocating
> > >   * a new page in the file would cause excessive storage usage for
> > >   * workloads with sparse files.  We allocate a page cache page instead.
> > > @@ -307,15 +584,24 @@ EXPORT_SYMBOL_GPL(dax_do_io);
> > >   * otherwise it will simply fall out of the page cache under memory
> > >   * pressure without ever having been dirtied.
> > >   */
> > > -static int dax_load_hole(struct address_space *mapping, struct page *page,
> > > -							struct vm_fault *vmf)
> > > +static int dax_load_hole(struct address_space *mapping, void *entry,
> > > +			 struct vm_fault *vmf)
> > >  {
> > > -	if (!page)
> > > -		page = find_or_create_page(mapping, vmf->pgoff,
> > > -						GFP_KERNEL | __GFP_ZERO);
> > > -	if (!page)
> > > -		return VM_FAULT_OOM;
> > > +	struct page *page;
> > > +
> > > +	/* Hole page already exists? Return it...  */
> > > +	if (!radix_tree_exceptional_entry(entry)) {
> > > +		vmf->page = entry;
> > > +		return VM_FAULT_LOCKED;
> > > +	}
> > >  
> > > +	/* This will replace locked radix tree entry with a hole page */
> > > +	page = find_or_create_page(mapping, vmf->pgoff,
> > > +				   vmf->gfp_mask | __GFP_ZERO);
> > 
> > This replacement happens via page_cache_tree_insert(), correct?  In this case,
> > who wakes up anyone waiting on the old lock entry that we just killed?  In the
> > non-hole case we would traverse through put_locked_mapping_entry(), but I
> > don't see that in the hole case.
> 
> Ha, good catch. We miss the wakeup. Fixed.
> 
> Attached is the diff resulting from your review of this patch. I still have
> to hunt down that strange interaction with workingset code you've reported...

At the end of this mail I've attached one small fixup for the incremental diff
you sent.  Aside from that, I think that you've addressed all my review
feedback, thanks!

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

I'm going to try and get more info on the working set test failure.

---

diff --git a/fs/dax.c b/fs/dax.c
index f496854..c4cb69b 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -406,7 +406,7 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 
        init_wait(&ewait.wait);
        ewait.wait.func = wake_exceptional_entry_func;
-       ewait.key.root = &mapping->page_tree;
+       ewait.key.mapping = mapping;
        ewait.key.index = index;
 
        for (;;) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
