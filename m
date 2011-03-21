Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 557BE8D003A
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 05:59:13 -0400 (EDT)
Date: Mon, 21 Mar 2011 09:59:07 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: compaction beware writeback
Message-ID: <20110321095907.GI707@csn.ul.ie>
References: <alpine.LSU.2.00.1103192318100.1877@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1103192318100.1877@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, Mar 19, 2011 at 11:27:38PM -0700, Hugh Dickins wrote:
> I notice there's a Bug 31142 "Large write to USB stick freezes"
> discussion happening (which I've not digested), for which Andrea
> is proposing a patch which reminds me of this one.  Thought I'd
> better throw this into the mix for consideration.
> 
> I'd not sent it in yet, because I only see the problem on one machine,
> and then only with a shmem patch I'm working up; but can't see how
> that patch would actually be necessary to create the problem.
> 
> It happens in my extfs-on-loop-on-tmpfs swapping tests, when copying
> in the kernel tree.  I believe the relevant traces are these three:
> I notice sync_supers there every time it hangs, but I guess it comes
> along after, and gets stuck on the same page which cp is waiting for.
> 
> D  sync_supers:
> schedule +0x670
> io_schedule +0x50
> sync_buffer +0x68
> __wait_on_bit +0x90
> out_of_line_wait_on_bit +0x98
> __wait_on_buffer +0x30
> __sync_dirty_buffer +0xc0
> ext4_commit_super +0x2c4
> ext4_write_super +0x28
> sync_supers +0xdc
> bdi_sync_supers +0x40
> kthread +0xac
> kernel_thread +0x54
> 
> D  loop0:
> schedule +0x670
> io_schedule +0x50
> sync_page +0x84
> __wait_on_bit +0x90
> wait_on_page_bit +0xa4
> unmap_and_move +0x180
> migrate_pages +0xbc
> compact_zone +0xbc
> compact_zone_order +0xc8
> try_to_compact_pages +0x104
> __alloc_pages_direct_compact +0xc0
> __alloc_pages_nodemask +0x68c
> allocate_slab +0x84
> new_slab +0x58
> __slab_alloc +0x1ec
> kmem_cache_alloc +0x7c
> radix_tree_preload +0x94
> add_to_page_cache_locked +0x78
> shmem_getpage +0x208
> pagecache_write_begin +0x2c
> do_lo_send_aops +0xc0
> do_bio_filebacked +0x11c
> loop_thread +0x204
> kthread +0xac
> kernel_thread +0x54
> 
> D  cp:
> schedule +0x670
> io_schedule +0x50
> sync_buffer +0x68
> __wait_on_bit +0x90
> out_of_line_wait_on_bit +0x98
> __wait_on_buffer +0x30
> ext4_find_entry +0x230
> ext4_lookup +0x44
> d_alloc_and_lookup +0x74
> do_last +0xe0
> do_filp_open +0x2b8
> do_sys_open +0x8c
> compat_sys_open +0x24
> syscall_exit +0x0
> 
> I believe (but haven't verified for sure) that what happens is that
> compaction (when trying to allocate a radix_tree node - SLUB asks
> for order 2 - in the loop0 daemon trace) chooses the cp page under
> writeback which is waiting for loop0 to write it.
> 
> So I've extended your earlier PF_MEMALLOC patch to prevent waiting for
> writeback as well as waiting for pagelock.  And I've never seen the
> hang again since putting this patch in.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Yes, it is the case that waiting on page writeback can also cause
badness and I think this should also be considered for -stable.

Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
