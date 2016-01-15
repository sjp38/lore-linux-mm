Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8E32B828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 08:22:38 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l65so20106043wmf.1
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 05:22:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z129si4348432wmb.37.2016.01.15.05.22.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Jan 2016 05:22:37 -0800 (PST)
Date: Fri, 15 Jan 2016 14:22:49 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v8 4/9] dax: support dirty DAX entries in radix tree
Message-ID: <20160115132249.GL15950@quack.suse.cz>
References: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
 <1452230879-18117-5-git-send-email-ross.zwisler@linux.intel.com>
 <20160113094411.GA17057@quack.suse.cz>
 <20160113184832.GA5904@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160113184832.GA5904@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

On Wed 13-01-16 11:48:32, Ross Zwisler wrote:
> On Wed, Jan 13, 2016 at 10:44:11AM +0100, Jan Kara wrote:
> > On Thu 07-01-16 22:27:54, Ross Zwisler wrote:
> > > Add support for tracking dirty DAX entries in the struct address_space
> > > radix tree.  This tree is already used for dirty page writeback, and it
> > > already supports the use of exceptional (non struct page*) entries.
> > > 
> > > In order to properly track dirty DAX pages we will insert new exceptional
> > > entries into the radix tree that represent dirty DAX PTE or PMD pages.
> > > These exceptional entries will also contain the writeback sectors for the
> > > PTE or PMD faults that we can use at fsync/msync time.
> > > 
> > > There are currently two types of exceptional entries (shmem and shadow)
> > > that can be placed into the radix tree, and this adds a third.  We rely on
> > > the fact that only one type of exceptional entry can be found in a given
> > > radix tree based on its usage.  This happens for free with DAX vs shmem but
> > > we explicitly prevent shadow entries from being added to radix trees for
> > > DAX mappings.
> > > 
> > > The only shadow entries that would be generated for DAX radix trees would
> > > be to track zero page mappings that were created for holes.  These pages
> > > would receive minimal benefit from having shadow entries, and the choice
> > > to have only one type of exceptional entry in a given radix tree makes the
> > > logic simpler both in clear_exceptional_entry() and in the rest of DAX.
> > > 
> > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > Reviewed-by: Jan Kara <jack@suse.cz>
> > 
> > I have realized there's one issue with this code. See below:
> > 
> > > @@ -34,31 +35,39 @@ static void clear_exceptional_entry(struct address_space *mapping,
> > >  		return;
> > >  
> > >  	spin_lock_irq(&mapping->tree_lock);
> > > -	/*
> > > -	 * Regular page slots are stabilized by the page lock even
> > > -	 * without the tree itself locked.  These unlocked entries
> > > -	 * need verification under the tree lock.
> > > -	 */
> > > -	if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
> > > -		goto unlock;
> > > -	if (*slot != entry)
> > > -		goto unlock;
> > > -	radix_tree_replace_slot(slot, NULL);
> > > -	mapping->nrshadows--;
> > > -	if (!node)
> > > -		goto unlock;
> > > -	workingset_node_shadows_dec(node);
> > > -	/*
> > > -	 * Don't track node without shadow entries.
> > > -	 *
> > > -	 * Avoid acquiring the list_lru lock if already untracked.
> > > -	 * The list_empty() test is safe as node->private_list is
> > > -	 * protected by mapping->tree_lock.
> > > -	 */
> > > -	if (!workingset_node_shadows(node) &&
> > > -	    !list_empty(&node->private_list))
> > > -		list_lru_del(&workingset_shadow_nodes, &node->private_list);
> > > -	__radix_tree_delete_node(&mapping->page_tree, node);
> > > +
> > > +	if (dax_mapping(mapping)) {
> > > +		if (radix_tree_delete_item(&mapping->page_tree, index, entry))
> > > +			mapping->nrexceptional--;
> > 
> > So when you punch hole in a file, you can delete a PMD entry from a radix
> > tree which covers part of the file which still stays. So in this case you
> > have to split the PMD entry into PTE entries (probably that needs to happen
> > up in truncate_inode_pages_range()) or something similar...
> 
> I think (and will verify) that the DAX code just unmaps the entire PMD range
> when we receive a hole punch request inside of the PMD.  If this is true then
> I think the radix tree code should behave the same way and just remove the PMD
> entry in the radix tree.

But you cannot just remove it if it is dirty... You have to keep somewhere
information that part of the PMD range is still dirty (or write that range
out before removing the radix tree entry).

> This will cause new accesses that used to land in the PMD range to get new
> page faults.  These faults will call get_blocks(), where presumably the
> filesystem will tell us that we don't have a contiguous 2MiB range anymore, so
> we will fall back to PTE faults.  These PTEs will fill in both the radix tree
> and the page tables.
> 
> So, I think the work here is to verify the behavior of DAX wrt hole punches
> for PMD ranges, and make the radix tree code match that behavior.  Sound good?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
