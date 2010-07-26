Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DC9576B024D
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 03:18:08 -0400 (EDT)
Date: Mon, 26 Jul 2010 15:18:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/6] [RFC] writeback: try to write older pages first
Message-ID: <20100726071803.GA13076@localhost>
References: <20100722050928.653312535@intel.com>
 <20100723102400.GD5300@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723102400.GD5300@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Thu, Jul 22, 2010 at 01:09:28PM +0800, Wu Fengguang wrote:
> > 
> > The basic way of avoiding pageout() is to make the flusher sync inodes in the
> > right order. Oldest dirty inodes contains oldest pages. The smaller inode it
> > is, the more correlation between inode dirty time and its pages' dirty time.
> > So for small dirty inodes, syncing in the order of inode dirty time is able to
> > avoid pageout(). If pageout() is still triggered frequently in this case, the
> > 30s dirty expire time may be too long and could be shrinked adaptively; or it
> > may be a stressed memcg list whose dirty inodes/pages are more hard to track.
> > 
> 
> Have you confirmed this theory with the trace points? It makes perfect
> sense and is very rational but proof is a plus.

The proof would be simple.

On average, it takes longer time to dirty a large file than a small file.

For example, when uploading files to a file server with 1MB/s
throughput, it will take 10s for a 10MB file and 30s for a 30MB file.
This is the common case.

Another case is some fast dirtier. It may take 10ms to dirty a 100MB
file and 10s to dirty a 1G file -- the latter is dirty throttled to
the much lower IO throughput due to too many dirty pages. The opposite
may happen, however this is more likely in possibility. If both are
throttled, it degenerates to the above file server case.

So large files tend to contain dirty pages of more varied age.

> I'm guessing you have
> some decent writeback-related tests that might be of use. Mine have a
> big mix of anon and file writeback so it's not as clear-cut.

A neat trick is to run your test with `swapoff -a` :)

Seriously I have no scripts to monitor pageout() calls.
I'll explore ways to test it.

> Monitoring it isn't hard. Mount debugfs, enable the vmscan tracepoints
> and read the tracing_pipe. To reduce interference, I always pipe it
> through gzip and do post-processing afterwards offline with the script
> included in Documentation/

Thanks for the tip!

> Here is what I got from sysbench on x86-64 (other machines hours away)
> 
> 
> SYSBENCH FTrace Reclaim Statistics
>                     traceonly-v5r6         nodirect-v5r7      flusholdest-v5r7     flushforward-v5r7
> Direct reclaims                                683        785        670        938 
> Direct reclaim pages scanned                199776     161195     200400     166639 
> Direct reclaim write file async I/O          64802          0          0          0 
> Direct reclaim write anon async I/O           1009        419       1184      11390 
> Direct reclaim write file sync I/O              18          0          0          0 
> Direct reclaim write anon sync I/O               0          0          0          0 
> Wake kswapd requests                        685360     697255     691009     864602 
> Kswapd wakeups                                1596       1517       1517       1545 
> Kswapd pages scanned                      17527865   16817554   16816510   15032525 
> Kswapd reclaim write file async I/O         888082     618123     649167     147903 
> Kswapd reclaim write anon async I/O         229724     229123     233639     243561 
> Kswapd reclaim write file sync I/O               0          0          0          0 
> Kswapd reclaim write anon sync I/O               0          0          0          0 

> Time stalled direct reclaim (ms)             32.79      22.47      19.75       6.34 
> Time kswapd awake (ms)                     2192.03    2165.17    2112.73    2055.90 

I noticed that $total_direct_latency is divided by 1000 before
printing the above lines, so the unit should be seconds?

> User/Sys Time Running Test (seconds)         663.3    656.37    664.14    654.63
> Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.00%     0.00%
> Total Elapsed Time (seconds)               6703.22   6468.78   6472.69   6479.62
> Percentage Time kswapd Awake                 0.03%     0.00%     0.00%     0.00%

I don't see the code for generating the "Percentage" lines. And the
numbers seem too small to be true.

> Flush oldest actually increased the number of pages written back by
> kswapd but the anon writeback is also high as swap is involved. Kicking
> flusher threads also helps a lot. It helps less than previous released
> because I noticed I was kicking flusher threads for both anon and file
> dirty pages which is cheating. It's now only waking the threads for
> file. It's still a reduction of 84% overall so nothing to sneeze at.
> 
> What the patch did do was reduce time stalled in direct reclaim and time
> kswapd spent awake so it still might be going the right direction. I
> don't have a feeling for how much the writeback figures change between
> runs because they take so long to run.
> 
> STRESS-HIGHALLOC FTrace Reclaim Statistics
>                   stress-highalloc      stress-highalloc      stress-highalloc      stress-highalloc
>                     traceonly-v5r6         nodirect-v5r7      flusholdest-v5r7     flushforward-v5r7
> Direct reclaims                               1221       1284       1127       1252 
> Direct reclaim pages scanned                146220     186156     142075     140617 
> Direct reclaim write file async I/O           3433          0          0          0 
> Direct reclaim write anon async I/O          25238      28758      23940      23247 
> Direct reclaim write file sync I/O            3095          0          0          0 
> Direct reclaim write anon sync I/O           10911     305579     281824     246251 
> Wake kswapd requests                          1193       1196       1088       1209 
> Kswapd wakeups                                 805        824        758        804 
> Kswapd pages scanned                      30953364   52621368   42722498   30945547 
> Kswapd reclaim write file async I/O         898087     241135     570467      54319 
> Kswapd reclaim write anon async I/O        2278607    2201894    1885741    1949170 
> Kswapd reclaim write file sync I/O               0          0          0          0 
> Kswapd reclaim write anon sync I/O               0          0          0          0 
> Time stalled direct reclaim (ms)           8567.29    6628.83    6520.39    6947.23 
> Time kswapd awake (ms)                     5847.60    3589.43    3900.74   15837.59 
> 
> User/Sys Time Running Test (seconds)       2824.76   2833.05   2833.26   2830.46
> Percentage Time Spent Direct Reclaim         0.25%     0.00%     0.00%     0.00%
> Total Elapsed Time (seconds)              10920.14   9021.17   8872.06   9301.86
> Percentage Time kswapd Awake                 0.15%     0.00%     0.00%     0.00%
> 
> Same here, the number of pages written back by kswapd increased but
> again anon writeback was a big factor. Kicking threads when dirty pages
> are encountered still helps a lot with a 94% reduction of pages written
> back overall..

That is impressive! So it definitely helps to reduce total number of
dirty pages under memory pressure.

> Also, your patch really helped the time spent stalled by direct reclaim
> and kswapd was awake a lot less less with tests completing far faster.

Thanks. So it does improve the dirty page layout in the LRU lists.

> Overally, I still think your series if a big help (although I don't know if
> the patches in linux-next are also making a difference) but it's not actually
> reducing the pages encountered by direct reclaim. Maybe that is because
> the tests were making more forward progress and so scanning faster. The
> sysbench performance results are too varied to draw conclusions from but it
> did slightly improve the success rate of high-order allocations.
> 
> The flush-forward patches would appear to be a requirement. Christoph
> first described them as a band-aid but he didn't chuck rocks at me when
> the patch was actually released. Right now, I'm leaning towards pushing
> it and judge by the Swear Meter how good/bad others think it is. So far
> it's, me pro, Rik pro, Christoph maybe.

Sorry for the delay, I'll help review it.

> > For a large dirty inode, it may flush lots of newly dirtied pages _after_
> > syncing the expired pages. This is the normal case for a single-stream
> > sequential dirtier, where older pages are in lower offsets.  In this case we
> > shall not insist on syncing the whole large dirty inode before considering the
> > other small dirty inodes. This risks wasting time syncing 1GB freshly dirtied
> > pages before syncing the other N*1MB expired dirty pages who are approaching
> > the end of the LRU list and hence pageout().
> > 
> 
> Intuitively, this makes a lot of sense.
> 
> > For a large dirty inode, it may also flush lots of newly dirtied pages _before_
> > hitting the desired old ones, in which case it helps for pageout() to do some
> > clustered writeback, and/or set mapping->writeback_index to help the flusher
> > focus on old pages.
> > 
> 
> Will put this idea on the maybe pile.
> 
> > For a large dirty inode, it may also have intermixed old and new dirty pages.
> > In this case we need to make sure the inode is queued for IO before some of
> > its pages hit pageout(). Adaptive dirty expire time helps here.
> > 
> > OK, end of the vapour ideas. As for this patchset, it fixes the current
> > kupdate/background writeback priority:
> > 
> > - the kupdate/background writeback shall include newly expired inodes at each
> >   queue_io() time, as the large inodes left over from previous writeback rounds
> >   are likely to have less density of old pages.
> > 
> > - the background writeback shall consider expired inodes first, just like the
> >   kupdate writeback
> > 
> 
> I haven't actually reviewed these. I got testing kicked off first
> because it didn't require brains :)

Thanks all the same!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
