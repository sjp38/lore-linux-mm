Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5416B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 11:07:10 -0400 (EDT)
Date: Thu, 14 Jul 2011 11:07:00 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/5] mm: vmscan: Do not writeback filesystem pages in
 direct reclaim
Message-ID: <20110714150700.GC23587@infradead.org>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <1310567487-15367-2-git-send-email-mgorman@suse.de>
 <20110714103801.83e10fdb.kamezawa.hiroyu@jp.fujitsu.com>
 <20110714044643.GA3203@infradead.org>
 <20110714134634.4a7a15c8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110714134634.4a7a15c8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 14, 2011 at 01:46:34PM +0900, KAMEZAWA Hiroyuki wrote:
> > XFS and btrfs already disable writeback from memcg context, as does ext4
> > for the typical non-overwrite workloads, and none has fallen apart.
> > 
> > In fact there's no way we can enable them as the memcg calling contexts
> > tend to have massive stack usage.
> > 
> 
> Hmm, XFS/btrfs adds pages to radix-tree in deep stack ?

We're using a fairly deep stack in normal buffered read/write,
wich is almost 100% common code.  It's not just the long callchain
(see below), but also that we put the unneeded kiocb and a vector
of I/O vects on the stack:

vfs_writev
do_readv_writev
do_sync_write
generic_file_aio_write
__generic_file_aio_write
generic_file_buffered_write
generic_perform_write
block_write_begin
grab_cache_page_write_begin
add_to_page_cache_lru
add_to_page_cache
add_to_page_cache_locked
mem_cgroup_cache_charge

this might additionally come from in-kernel callers like nfsd,
which has even more stack space used.  And at this point we only
enter the memcg/reclaim code, which last time I had a stack trace
ate up another about 3k of stack space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
