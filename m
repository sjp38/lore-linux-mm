Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id B40C76B0036
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 12:09:11 -0500 (EST)
Received: by mail-bk0-f48.google.com with SMTP id v10so3314922bkz.21
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 09:09:10 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ke1si12531092bkb.241.2013.11.27.09.09.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 09:09:10 -0800 (PST)
Date: Wed, 27 Nov 2013 12:08:04 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 6/9] mm + fs: store shadow entries in page cache
Message-ID: <20131127170804.GD3556@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <1385336308-27121-7-git-send-email-hannes@cmpxchg.org>
 <20131125231716.GJ8803@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131125231716.GJ8803@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 26, 2013 at 10:17:16AM +1100, Dave Chinner wrote:
> On Sun, Nov 24, 2013 at 06:38:25PM -0500, Johannes Weiner wrote:
> > Reclaim will be leaving shadow entries in the page cache radix tree
> > upon evicting the real page.  As those pages are found from the LRU,
> > an iput() can lead to the inode being freed concurrently.  At this
> > point, reclaim must no longer install shadow pages because the inode
> > freeing code needs to ensure the page tree is really empty.
> > 
> > Add an address_space flag, AS_EXITING, that the inode freeing code
> > sets under the tree lock before doing the final truncate.  Reclaim
> > will check for this flag before installing shadow pages.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ....
> > @@ -545,10 +546,25 @@ static void evict(struct inode *inode)
> >  	 */
> >  	inode_wait_for_writeback(inode);
> >  
> > +	/*
> > +	 * Page reclaim can not do iput() and thus can race with the
> > +	 * inode teardown.  Tell it when the address space is exiting,
> > +	 * so that it does not install eviction information after the
> > +	 * final truncate has begun.
> > +	 *
> > +	 * As truncation uses a lockless tree lookup, acquire the
> > +	 * spinlock to make sure any ongoing tree modification that
> > +	 * does not see AS_EXITING is completed before starting the
> > +	 * final truncate.
> > +	 */
> > +	spin_lock_irq(&inode->i_data.tree_lock);
> > +	mapping_set_exiting(&inode->i_data);
> > +	spin_unlock_irq(&inode->i_data.tree_lock);
> > +
> >  	if (op->evict_inode) {
> >  		op->evict_inode(inode);
> >  	} else {
> > -		if (inode->i_data.nrpages)
> > +		if (inode->i_data.nrpages || inode->i_data.nrshadows)
> >  			truncate_inode_pages(&inode->i_data, 0);
> >  		clear_inode(inode);
> >  	}
> 
> Ok, so what I see here is that we need a wrapper function that
> handles setting the AS_EXITING flag and doing the "final"
> truncate_inode_pages() call, and the locking for the AS_EXITING flag
> moved into mapping_set_exiting()
> 
> That is, because this AS_EXITING flag and it's locking constraints
> are directly related to the upcoming truncate_inode_pages() call,
> I'd prefer to see a helper that captures that relationship used
> in all the filesystem code. e.g:
> 
> void truncate_inode_pages_final(struct address_space *mapping)
> {
> 	spin_lock_irq(&mapping->tree_lock);
> 	mapping_set_exiting(mapping);
> 	spin_unlock_irq(&mapping->tree_lock);
> 	if (inode->i_data.nrpages || inode->i_data.nrshadows)
> 		truncate_inode_pages_range(mapping, 0, (loff_t)-1);
> }
> 
> And document it in Documentation/filesystems/porting as a mandatory
> function to be called from ->evict_inode() implementations before
> calling clear_inode().  You can then replace all the direct calls to
> truncate_inode_pages() in the evict_inode() path with a call to
> truncate_inode_pages_final().

Ok, fair enough.  I'll add a BUG_ON(!mapping_exiting(&inode->i_data))
to the inode sanity checks on final teardown to make sure filesystems
don't miss the change to truncate_inode_pages_final().

> As it is, I'd really like to see that unconditional irq disable go
> away from this code - disabling and enabling interrupts for every
> single inode we reclaim is going to add significant overhead to this
> hot code path. And given that:
> 
> > +static inline void mapping_set_exiting(struct address_space *mapping)
> > +{
> > +	set_bit(AS_EXITING, &mapping->flags);
> > +}
> > +
> > +static inline int mapping_exiting(struct address_space *mapping)
> > +{
> > +	return test_bit(AS_EXITING, &mapping->flags);
> > +}
> 
> these atomic bit ops, why do we need to take the tree_lock and
> disable irqs in evict() to set this bit if there's nothing to
> truncate on the inode? i.e. something like this:
> 
> void truncate_inode_pages_final(struct address_space *mapping)
> {
> 	mapping_set_exiting(mapping);
> 	if (inode->i_data.nrpages || inode->i_data.nrshadows) {
> 		/*
> 		 * spinlock barrier to ensure all modifications are
> 		 * complete before we do the final truncate
> 		 */
> 		spin_lock_irq(&mapping->tree_lock);
> 		spin_unlock_irq(&mapping->tree_lock);
> 		truncate_inode_pages_range(mapping, 0, (loff_t)-1);
> }

That would almost work, but we need to enforce ordering of the counter
reads and updates or truncation might read 0 on both while racing with
reclaim.

Reclaim would have to do:

  spin_lock_irq(&mapping->tree_lock)
  if !mapping_exiting():
    swap shadow entry
    mapping->nrshadows++
    smp_wmb()
    mapping->nrpages--
  spin_unlock_irq(&mapping->tree_lock)

and the final truncate side would have to do

  mapping_set_exiting()
  nrpages = mapping->nrpages
  smp_rmb()
  nrshadows = mapping->nrshadows
  if (nrpages || nrshadows)
    spin_lock_irq(&mapping->tree_lock)
    spin_unlock_irq(&mapping->tree_lock)
    truncate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
