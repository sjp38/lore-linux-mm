Date: Sat, 21 Jun 2008 11:36:41 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.26-rc: nfsd hangs for a few sec
In-Reply-To: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com>
Message-ID: <alpine.LFD.1.10.0806211128070.3167@woody.linux-foundation.org>
References: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Beregalov <a.beregalov@gmail.com>
Cc: kernel-testers@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sat, 21 Jun 2008, Alexander Beregalov wrote:
> >
> >  -> #1 (&(&ip->i_iolock)->mr_lock){----}:
> >        [<c0135416>] __lock_acquire+0xa0c/0xbc6
> >        [<c013563a>] lock_acquire+0x6a/0x86
> >        [<c012c4f2>] down_write_nested+0x33/0x6a
> >        [<c0211068>] xfs_ilock+0x7b/0xd6
> >        [<c02111e1>] xfs_ireclaim+0x1d/0x59
> >        [<c022f342>] xfs_finish_reclaim+0x173/0x195
> >        [<c0231496>] xfs_reclaim+0xb3/0x138
> >        [<c023ba0f>] xfs_fs_clear_inode+0x55/0x8e
> >        [<c016f830>] clear_inode+0x83/0xd2
> >        [<c016faaf>] dispose_list+0x3c/0xc1
> >        [<c016fca7>] shrink_icache_memory+0x173/0x19b
> >        [<c014a7fa>] shrink_slab+0xda/0x153
> >        [<c014aa53>] try_to_free_pages+0x1e0/0x2a1
> >        [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
> >        [<c0146c56>] __alloc_pages+0xa/0xc
> >        [<c015b8c2>] __slab_alloc+0x1c7/0x513
> >        [<c015beef>] kmem_cache_alloc+0x45/0xb3
> >        [<c01a5afe>] reiserfs_alloc_inode+0x12/0x23
> >        [<c016f308>] alloc_inode+0x14/0x1a9
> >        [<c016f5ed>] iget5_locked+0x47/0x133

Hmm. Both the trace above and the trace below:

> >  -> #0 (iprune_mutex){--..}:
> >        [<c0135333>] __lock_acquire+0x929/0xbc6
> >        [<c013563a>] lock_acquire+0x6a/0x86
> >        [<c037db3e>] mutex_lock_nested+0xba/0x232
> >        [<c016fb6c>] shrink_icache_memory+0x38/0x19b
> >        [<c014a7fa>] shrink_slab+0xda/0x153
> >        [<c014aa53>] try_to_free_pages+0x1e0/0x2a1
> >        [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
> >        [<c0146c56>] __alloc_pages+0xa/0xc
> >        [<c01484f2>] __do_page_cache_readahead+0xaa/0x16a
> >        [<c01487ac>] ondemand_readahead+0x119/0x127
> >        [<c014880c>] page_cache_async_readahead+0x52/0x5d
> >        [<c0179410>] generic_file_splice_read+0x290/0x4a8
> >        [<c023a46a>] xfs_splice_read+0x4b/0x78

are kind of scary, because they are both filesystem memory allocation 
paths that don't have GFP_NOFS, so they cause a callback back into the 
filesystem to free things.

Which in general isn't necessarily wrong: under inode pressure, it may 
well make sense to try to shrink the inode caches when allocating a new 
inode, or things may well blow up out of proportion, but it does make me a 
big nervous.

However, it's not clear why things apparently bisected down to the commit 
it did (54a6eb5c4765aa573a030ceeba2c14e3d2ea5706: "mm: use two zonelist 
that are filtered by GFP mask"). That part makes me worry that that commit 
screwed up the freeing pressure logic. 

Mel?

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
