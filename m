Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2F3ED6B01CC
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 15:27:40 -0400 (EDT)
Date: Tue, 23 Mar 2010 14:27:08 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 11/11] Do not compact within a preferred zone after a
 compaction failure
In-Reply-To: <20100323183936.GF5870@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003231422290.10178@router.home>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-12-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1003231327580.10178@router.home> <20100323183936.GF5870@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010, Mel Gorman wrote:

> I was having some sort of fit when I wrote that obviously. Try this on
> for size
>
> The fragmentation index may indicate that a failure is due to external
> fragmentation but after a compaction run completes, it is still possible
> for an allocation to fail.

Ok.

> > > fail. There are two obvious reasons as to why
> > >
> > >   o Page migration cannot move all pages so fragmentation remains
> > >   o A suitable page may exist but watermarks are not met
> > >
> > > In the event of compaction and allocation failure, this patch prevents
> > > compaction happening for a short interval. It's only recorded on the
> >
> > compaction is "recorded"? deferred?
> >
>
> deferred makes more sense.
>
> What I was thinking at the time was that compact_resume was stored in struct
> zone - i.e. that is where it is recorded.

Ok adding a dozen or more words here may be useful.

> > > preferred zone but that should be enough coverage. This could have been
> > > implemented similar to the zonelist_cache but the increased size of the
> > > zonelist did not appear to be justified.
> >
> > > @@ -1787,6 +1787,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> > >  			 */
> > >  			count_vm_event(COMPACTFAIL);
> > >
> > > +			/* On failure, avoid compaction for a short time. */
> > > +			defer_compaction(preferred_zone, jiffies + HZ/50);
> > > +
> >
> > 20ms? How was that interval determined?
> >
>
> Matches the time the page allocator would defer to an event like
> congestion. The choice is somewhat arbitrary. Ideally, there would be
> some sort of event that would re-enable compaction but there wasn't an
> obvious candidate so I used time.

There are frequent uses of HZ/10 as well especially in vmscna.c. A longer
time may be better?  HZ/50 looks like an interval for writeout. But this
is related to reclaim?


 backing-dev.h    <global>                      283 long congestion_wait(int sync, long timeout);
1 backing-dev.c    <global>                      762 EXPORT_SYMBOL(congestion_wait);
2 usercopy_32.c    __copy_to_user_ll             754 congestion_wait(BLK_RW_ASYNC, HZ/50);
3 pktcdvd.c        pkt_make_request             2557 congestion_wait(BLK_RW_ASYNC, HZ);
4 dm-crypt.c       kcryptd_crypt_write_convert   834 congestion_wait(BLK_RW_ASYNC, HZ/100);
5 file.c           fat_file_release              137 congestion_wait(BLK_RW_ASYNC, HZ/10);
6 journal.c        reiserfs_async_progress_wait  990 congestion_wait(BLK_RW_ASYNC, HZ / 10);
7 kmem.c           kmem_alloc                     61 congestion_wait(BLK_RW_ASYNC, HZ/50);
8 kmem.c           kmem_zone_alloc               117 congestion_wait(BLK_RW_ASYNC, HZ/50);
9 xfs_buf.c        _xfs_buf_lookup_pages         343 congestion_wait(BLK_RW_ASYNC, HZ/50);
a backing-dev.c    congestion_wait               751 long congestion_wait(int sync, long timeout)
b memcontrol.c     mem_cgroup_force_empty       2858 congestion_wait(BLK_RW_ASYNC, HZ/10);
c page-writeback.c throttle_vm_writeout          674 congestion_wait(BLK_RW_ASYNC, HZ/10);
d page_alloc.c     __alloc_pages_high_priority  1753 congestion_wait(BLK_RW_ASYNC, HZ/50);
e page_alloc.c     __alloc_pages_slowpath       1924 congestion_wait(BLK_RW_ASYNC, HZ/50);
f vmscan.c         shrink_inactive_list         1136 congestion_wait(BLK_RW_ASYNC, HZ/10);
g vmscan.c         shrink_inactive_list         1220 congestion_wait(BLK_RW_ASYNC, HZ/10);
h vmscan.c         do_try_to_free_pages         1837 congestion_wait(BLK_RW_ASYNC, HZ/10);
i vmscan.c         balance_pgdat                2161 congestion_wait(BLK_RW_ASYNC, HZ/10);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
