In-reply-to: <Pine.LNX.4.64.0703291412240.24494@blonde.wat.veritas.com>
	(message from Hugh Dickins on Thu, 29 Mar 2007 14:39:29 +0100 (BST))
Subject: Re: [PATCH 1/4] holepunch: fix shmem_truncate_range punching too
 far
References: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
 <E1HWsJq-0000vz-00@dorka.pomaz.szeredi.hu> <Pine.LNX.4.64.0703291212080.19050@blonde.wat.veritas.com>
 <E1HWtTi-00013Z-00@dorka.pomaz.szeredi.hu> <Pine.LNX.4.64.0703291412240.24494@blonde.wat.veritas.com>
Message-Id: <E1HWvjA-0001Eo-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 29 Mar 2007 16:35:48 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com
Cc: akpm@linux-foundation.org, mszeredi@suse.cz, pbadari@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 29 Mar 2007, Miklos Szeredi wrote:
> > 
> > I think we should at least have a
> > 
> >   BUG_ON((end + 1) % PAGE_CACHE_SIZE);
> > 
> > or something, to remind us about this wart.
> 
> truncate_inode_pages_range does indeed have
> 	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
> but you're right that falls short of covering all the places we might
> make such a mistake.
> 
> And in future I'd expect them to be extended to allow non-page-sized
> holes, zeroing the partial areas at each end of the hole: whereupon
> no such BUG_ON will be possible.
> 
> I'd much prefer to change the interface to vmtruncate_range,
> truncate_inode_pages_range, shmem_truncate_range,
> i_op->truncate_range, to take the expected end offset.

I agree 100%

> There are other interface changes needed to eradicate
> (rather than paper over) the races we've mentioned in private mail.
> shmem_truncate_range, and I believe any other implementation of an
> i_op->truncate_range, needs to know when the holepunch is beginning
> (if the prior unmap_mapping_range and truncate_inode_pages_range
> aren't just to be a waste of time that has to be repeated).
> Easiest is just to move those calls into each i_op->truncate_range.
> 
> But are we free to make such interface changes now?
> Might third parties have observed MADV_REMOVE and ->truncate_range,
> and be implementing them in their own filesystems?

I think that's very unlikly.  Considering that there were two bugs
(the infinite loop and the ABBA deadlock) in the generic MADV_REMOVE
code, and nobody noticed until now.

The sooner that change is done, the better.

> And another change I'd like to suggest: at present holepunching
> is using unmap_mapping_range(,,,1) which discards privately COWed
> pages from vmas.  It's certainly easier to implement unracily if
> we change it only to unmap the shared file pages: and I argue that
> it's more correct that way, that the madvise(,,MADV_REMOVE) caller
> should not be discarding private data from others' address spaces.

Yes, that makes sense too.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
