Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 538E96B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 21:20:28 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 149AB3EE0B5
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 11:20:25 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EB85845DE5D
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 11:20:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C53FE45DE55
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 11:20:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B815E1DB8037
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 11:20:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 549D21DB803C
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 11:20:24 +0900 (JST)
Date: Tue, 11 Jan 2011 11:14:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm hangs on compaction lock_page
Message-Id: <20110111111420.111757ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com>
References: <alpine.LSU.2.00.1101061632020.9601@sister.anvils>
	<20110107145259.GK29257@csn.ul.ie>
	<20110107175705.GL29257@csn.ul.ie>
	<20110110172609.GA11932@csn.ul.ie>
	<alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Jan 2011 15:56:37 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> > On Mon, 10 Jan 2011, Mel Gorman wrote:
> > 
> > ==== CUT HERE ====
> > mm: compaction: Avoid potential deadlock for readahead pages and direct compaction
> > 
> > Hugh Dickins reported that two instances of cp were locking up when
> > running on ppc64 in a memory constrained environment. The deadlock
> > appears to apply to readahead pages. When reading ahead, the pages are
> > added locked to the LRU and queued for IO. The process is also inserting
> > pages into the page cache and so is calling radix_preload and entering
> > the page allocator. When SLUB is used, this can result in direct
> > compaction finding the page that was just added to the LRU but still
> > locked by the current process leading to deadlock.
> > 
> > This patch avoids locking pages for migration that might already be
> > locked by the current process. Ideally it would only apply for direct
> > compaction but compaction does not set PF_MEMALLOC so there is no way
> > currently of identifying a process in direct compaction. A process-flag
> > could be added but is likely to be overkill.
> > 
> > Reported-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> But whilst I'm hugely grateful to you for working this out,
> I'm sorry to say that I'm not keen on your patch!
> 
> PageMappedToDisk is an fs thing, not an mm thing (migrate.c copies it
> over but that's all), and I don't like to see you rely on it.  I expect
> it works well for ext234 and many others that use mpage_readpages,
> but what of btrfs_readpages?  I couldn't see any use of PageMappedToDisk
> there.  I suppose you could insist it use it too, but...
> 
> How about setting and clearing PF_MEMALLOC around the call to
> try_to_compact_pages() in __alloc_pages_direct_compact(), and
> skipping the lock_page when PF_MEMALLOC is set, whatever the
> page flags?  That would mimic __alloc_pages_direct_reclaim
> (hmm, reclaim_state??); and I've a suspicion that this readahead
> deadlock may not be the only one lurking.
> 
> Hugh

Hmm, in migrate_pages()
==
int migrate_pages(struct list_head *from,
                new_page_t get_new_page, unsigned long private, bool offlining,
                bool sync)
{

...
        for(pass = 0; pass < 10 && retry; pass++) {
                retry = 0;
...
	
                        rc = unmap_and_move(get_new_page, private,
                                                page, pass > 2, offlining,
                                                sync);

==

do force locking at pass > 2. Considering direct-compaction, pass > 2 is not
required I think because it can do compaction on other range of pages.

IOW, what it requires is a range of pages for specified order, but a range of
pages which is specfied by users. How about skipping pass > 2 when
it's called by direct compaction ? quick-scan of the next range may be helpful
rather than waiting on lock.

Thanks,
-Kame
	





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
