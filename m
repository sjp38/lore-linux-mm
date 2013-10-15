Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 07F366B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 06:27:19 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so8702732pde.9
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 03:27:19 -0700 (PDT)
Date: Tue, 15 Oct 2013 12:27:12 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
Message-ID: <20131015102712.GA12428@quack.suse.cz>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
 <20131011003930.GC4446@dastard>
 <20131014214250.GG856@cmpxchg.org>
 <20131015014123.GQ4446@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131015014123.GQ4446@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 15-10-13 12:41:23, Dave Chinner wrote:
> Then you have a serious design flaw if you are relying on a shrinker
> to control memory consumed by page cache radix trees as a result of
> page cache reclaim inserting exceptional entries into the radix
> tree and then forgetting about them.
> 
> To work around this, you keep a global count of exceptional entries
> and a global list of inodes with such exceptional radix tree
> entries. The count doesn't really tell you how much memory is used
> by the radix trees - the same count can mean an order of
> magnitude difference in actual memory consumption (one shadow entry
> per radix tree node vs 64) so it's not a very good measure to base
> memory reclaim behaviour on but it is an inferred (rather than
> actual) object count.
> 
> And even if you do free some entries, there is no guarantee that any
> memory will be freed because only empty radix tree nodes will get
> freed, and then memory will only get freed when the entire slab of
> radix tree nodes are freed.
> 
> This reclaim behaviour has potential to cause internal
> fragmentation of the radix tree node slab, which means that we'll
> simply spend time scanning and freeing entries but not free any
> memory.
> 
> You walk the inode list by a shrinker and scan radix trees for
> shadow entries that can be removed. It's expensive to scan radix
> trees, especially for inodes with large amounts of cached data, so
> this could do a lot of work to find very little in way of entries to
> free.
> 
> The shrinker doesn't rotate inodes on the list, so it will always
> scan the same inodes on the list in the same order and so if memory
> reclaim removes a few pages from an inode with a large amount of
> cached pages between each shrinker call, then those radix trees will
> be repeatedly scanned in it's entirety on each call to the shrinker.
> 
> Also, the shrinker only decrements nr_to_scan when it finds an entry
> to reclaim. nr_to_scan is the number of objects to scan for reclaim,
> not the number of objects to reclaim. hence the shrinker will be
> doing a lot of scanning if there's inodes at the head of the list
> with large radix trees....
> 
> Do I need to go on pointing out how unscalable this approach is?
  Just to add some real world experience to what Dave points out - ext4 has
a thing called extent cache. It essentially caches logical->physical
mapping of blocks together with some state flags together with inode. And
currently the cache is maintained similarly as you do it with shadow
entries - we have LRU list of inodes and we have a shrinker to scan extents
in an inode to find extents to free (we cannot reclaim arbitrary cached
extent because some state cannot be simply lost). And it is a pain. We burn
lots of CPU when scanning for extents to free under some loads, sometimes we
get RCU lockups and similar stuff. So we will have to rewrite the code to
use something more clever sooner rather than later. I don't think you
should repeat our mistake ;)

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
