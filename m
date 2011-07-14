Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 65DAC6B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 20:02:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B2D153EE0C1
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 09:02:31 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9824445DE54
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 09:02:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 793ED45DE59
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 09:02:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 689381DB8056
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 09:02:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 313941DB8052
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 09:02:31 +0900 (JST)
Date: Fri, 15 Jul 2011 08:55:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] mm: vmscan: Do not writeback filesystem pages in
 direct reclaim
Message-Id: <20110715085520.23feca2d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110714150700.GC23587@infradead.org>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
	<1310567487-15367-2-git-send-email-mgorman@suse.de>
	<20110714103801.83e10fdb.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714044643.GA3203@infradead.org>
	<20110714134634.4a7a15c8.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714150700.GC23587@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, 14 Jul 2011 11:07:00 -0400
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jul 14, 2011 at 01:46:34PM +0900, KAMEZAWA Hiroyuki wrote:
> > > XFS and btrfs already disable writeback from memcg context, as does ext4
> > > for the typical non-overwrite workloads, and none has fallen apart.
> > > 
> > > In fact there's no way we can enable them as the memcg calling contexts
> > > tend to have massive stack usage.
> > > 
> > 
> > Hmm, XFS/btrfs adds pages to radix-tree in deep stack ?
> 
> We're using a fairly deep stack in normal buffered read/write,
> wich is almost 100% common code.  It's not just the long callchain
> (see below), but also that we put the unneeded kiocb and a vector
> of I/O vects on the stack:
> 
> vfs_writev
> do_readv_writev
> do_sync_write
> generic_file_aio_write
> __generic_file_aio_write
> generic_file_buffered_write
> generic_perform_write
> block_write_begin
> grab_cache_page_write_begin
> add_to_page_cache_lru
> add_to_page_cache
> add_to_page_cache_locked
> mem_cgroup_cache_charge
> 
> this might additionally come from in-kernel callers like nfsd,
> which has even more stack space used.  And at this point we only
> enter the memcg/reclaim code, which last time I had a stack trace
> ate up another about 3k of stack space.
> 

Hmm. I'll prepare 2 functions for memcg 
  1. asynchronous memory reclaim as kswapd does.
  2. dirty_ratio

please remove ->writepage 1st. It may break memcg but it happens sometimes.
We'll do fix.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
