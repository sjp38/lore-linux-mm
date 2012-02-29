Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D86C16B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 21:36:36 -0500 (EST)
Date: Wed, 29 Feb 2012 10:31:27 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-ID: <20120229023127.GB11583@localhost>
References: <20120228140022.614718843@intel.com>
 <20120228144747.198713792@intel.com>
 <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 28, 2012 at 04:04:03PM -0800, Andrew Morton wrote:
> On Tue, 28 Feb 2012 22:00:27 +0800
> Fengguang Wu <fengguang.wu@intel.com> wrote:
> 
> > This relays file pageout IOs to the flusher threads.
> > 
> > It's much more important now that page reclaim generally does not
> > writeout filesystem-backed pages.
> 
> It doesn't?  We still do writeback in direct reclaim.  This claim
> should be fleshed out rather a lot, please.

That claim is actually from Mel in his review comments :)

Current upstream kernel avoids writeback in direct reclaim totally
with commit ee72886d8ed5d ("mm: vmscan: do not writeback filesystem
pages in direct reclaim").

Now with this patch, as long as the pageout works are queued
successfully, the pageout() calls from kswapd() will also be
eliminated.

> > The ultimate target is to gracefully handle the LRU lists pressured by
> > dirty/writeback pages. In particular, problems (1-2) are addressed here.
> > 
> > 1) I/O efficiency
> > 
> > The flusher will piggy back the nearby ~10ms worth of dirty pages for I/O.
> > 
> > This takes advantage of the time/spacial locality in most workloads: the
> > nearby pages of one file are typically populated into the LRU at the same
> > time, hence will likely be close to each other in the LRU list. Writing
> > them in one shot helps clean more pages effectively for page reclaim.
> 
> Yes, this is often true.  But when adjacent pages from the same file
> are clustered together on the LRU, direct reclaim's LRU-based walk will
> also provide good I/O patterns.

I'm afraid the I/O elevator is not so smart (and technically possible)
at merging the pageout() bios. The file pages are typically
interleaved between DMA32 and NORMAL zones or even among NUMA nodes.
Page reclaim also walks the nodes/zones interleavely, but in some
different manner.  So pageout() might at best generate I/O for [1,
30], [150, 168], [90, 99], ...

IOW, the holes and disorderness are effectively killing large I/O. Not
to mention it hurts interactive performance to block in get_request_wait()
if we ever submit I/O inside page reclaim.

> > For the common dd style sequential writes that have excellent locality,
> > up to ~80ms data will be wrote around by the pageout work, which helps
> > make I/O performance very close to that of the background writeback.
> > 
> > 2) writeback work coordinations
> > 
> > To avoid memory allocations at page reclaim, a mempool for struct
> > wb_writeback_work is created.
> > 
> > wakeup_flusher_threads() is removed because it can easily delay the
> > more oriented pageout works and even exhaust the mempool reservations.
> > It's also found to not I/O efficient by frequently submitting writeback
> > works with small ->nr_pages.
> 
> The last sentence here needs help.

wakeup_flusher_threads() is called with total_scanned. Which could be
(LRU_size / 4096). Given 1GB LRU_size, the write chunk would be 256KB.
This is much smaller than the old 4MB and the now preferred write
chunk size (write_bandwidth/2).

                writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
==>             if (total_scanned > writeback_threshold) {
                        wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
                                                WB_REASON_TRY_TO_FREE_PAGES);
                        sc->may_writepage = 1;
                }

Actually I see much more wakeup_flusher_threads() calls than expected.
The above test condition may be too permissive.

For direct reclaim, sc->nr_to_reclaim=32 and total_scanned starts with
(LRU_size / 4096), which *always* exceeds writeback_threshold in boxes
with more than 1GB memory. So the flusher end up constantly be fed with
small writeout requests.

The test is not really reflecting "dirty pages pressure". And it's
easy to trigger direct reclaim by starting some concurrent page
allocators or by using memcg. Which has nothing to do with dirty
pressure.

> > Background/periodic works will quit automatically, so as to clean the
> > pages under reclaim ASAP.
> 
> I don't know what this means.  How does a work "quit automatically" and
> why does that initiate I/O?

Typically the flusher will be working on the background/periodic works
when there are heavy dirtier tasks. And wb_writeback() has this

                /*
                 * Background writeout and kupdate-style writeback may
                 * run forever. Stop them if there is other work to do
                 * so that e.g. sync can proceed. They'll be restarted
                 * after the other works are all done.
                 */
                if ((work->for_background || work->for_kupdate) &&
                    !list_empty(&wb->bdi->work_list))
                        break;

to quit the background/periodic work when pageout or other works are
queued. So the pageout works can typically be pick up and executed
quickly by the flusher: the background/periodic works are the dominant
ones and there are rarely other type of works in the way.

> > However for now the sync work can still block
> > us for long time.
> 
> Please define the term "sync work".

That's the works submitted by

        __sync_filesystem()
          ==> writeback_inodes_sb() for the WB_SYNC_NONE pass
          ==> sync_inodes_sb()      for the WB_SYNC_ALL pass

with reason WB_REASON_SYNC.

Thanks,
Fengguang

// break time..

> > Jan Kara: limit the search scope; remove works and unpin inodes on umount.
> > 
> > TODO: the pageout works may be starved by the sync work and maybe others.
> > Need a proper way to guarantee fairness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
