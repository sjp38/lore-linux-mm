Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 67DEF9000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 02:47:05 -0400 (EDT)
Received: by qyk32 with SMTP id 32so2284884qyk.14
        for <linux-mm@kvack.org>; Tue, 05 Jul 2011 23:47:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110706045301.GA11604@localhost>
References: <20110629140109.003209430@bombadil.infradead.org>
	<20110629140336.950805096@bombadil.infradead.org>
	<20110701022248.GM561@dastard>
	<20110701041851.GN561@dastard>
	<20110701093305.GA28531@infradead.org>
	<20110701154136.GA17881@localhost>
	<20110704032534.GD1026@dastard>
	<20110706045301.GA11604@localhost>
Date: Wed, 6 Jul 2011 15:47:02 +0900
Message-ID: <CAEwNFnCjqxBGmffeDV4_U=gxz6nz6BHyocb5T=QdCP4fT2knPA@mail.gmail.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback clustering
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Jul 6, 2011 at 1:53 PM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> On Mon, Jul 04, 2011 at 11:25:34AM +0800, Dave Chinner wrote:
>> On Fri, Jul 01, 2011 at 11:41:36PM +0800, Wu Fengguang wrote:
>> > Christoph,
>> >
>> > On Fri, Jul 01, 2011 at 05:33:05PM +0800, Christoph Hellwig wrote:
>> > > Johannes, Mel, Wu,
>> > >
>> > > Dave has been stressing some XFS patches of mine that remove the XFS
>> > > internal writeback clustering in favour of using write_cache_pages.
>> > >
>> > > As part of investigating the behaviour he found out that we're still
>> > > doing lots of I/O from the end of the LRU in kswapd. =C2=A0Not only =
is that
>> > > pretty bad behaviour in general, but it also means we really can't
>> > > just remove the writeback clustering in writepage given how much
>> > > I/O is still done through that.
>> > >
>> > > Any chance we could the writeback vs kswap behaviour sorted out a bi=
t
>> > > better finally?
>> >
>> > I once tried this approach:
>> >
>> > http://www.spinics.net/lists/linux-mm/msg09202.html
>> >
>> > It used a list structure that is not linearly scalable, however that
>> > part should be independently improvable when necessary.
>>
>> I don't think that handing random writeback to the flusher thread is
>> much better than doing random writeback directly. =C2=A0Yes, you added
>> some clustering, but I'm still don't think writing specific pages is
>> the best solution.
>
> I agree that the VM should avoid writing specific pages as much as
> possible. Mostly often, it's indeed OK to just skip sporadically
> encountered dirty page and reclaim the clean pages presumably not
> far away in the LRU list. So your 2-liner patch is all good if
> constraining it to low scan pressure, which will look like
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (priority =3D=3D DEF_PRIORITY)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tag PG_reclaim on =
encountered dirty pages and
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skip writing it
>
> However the VM in general does need the ability to write specific
> pages, such as when reclaiming from specific zone/memcg. So I'll still
> propose to do bdi_start_inode_writeback().
>
> Below is the patch rebased to linux-next. It's good enough for testing
> purpose, and I guess even with the ->nr_pages work issue, it's
> complete enough to get roughly the same performance as your 2-liner
> patch.
>
>> > The real problem was, it seem to not very effective in my test runs.
>> > I found many ->nr_pages works queued before the ->inode works, which
>> > effectively makes the flusher working on more dispersed pages rather
>> > than focusing on the dirty pages encountered in LRU reclaim.
>>
>> But that's really just an implementation issue related to how you
>> tried to solve the problem. That could be addressed.
>>
>> However, what I'm questioning is whether we should even care what
>> page memory reclaim wants to write - it seems to make fundamentally
>> bad decisions from an IO persepctive.
>>
>> We have to remember that memory reclaim is doing LRU reclaim and the
>> flusher threads are doing "oldest first" writeback. IOWs, both are tryin=
g
>> to operate in the same direction (oldest to youngest) for the same
>> purpose. =C2=A0The fundamental problem that occurs when memory reclaim
>> starts writing pages back from the LRU is this:
>>
>> =C2=A0 =C2=A0 =C2=A0 - memory reclaim has run ahead of IO writeback -
>>
>> The LRU usually looks like this:
>>
>> =C2=A0 =C2=A0 =C2=A0 oldest =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0youngest
>> =C2=A0 =C2=A0 =C2=A0 +---------------+---------------+--------------+
>> =C2=A0 =C2=A0 =C2=A0 clean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 writeback =
=C2=A0 =C2=A0 =C2=A0 dirty
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ^ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ^
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Where flusher wil=
l next work from
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Where kswapd is w=
orking from
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 |
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 IO submitted by flusher, waiting on completion
>>
>>
>> If memory reclaim is hitting dirty pages on the LRU, it means it has
>> got ahead of writeback without being throttled - it's passed over
>> all the pages currently under writeback and is trying to write back
>> pages that are *newer* than what writeback is working on. IOWs, it
>> starts trying to do the job of the flusher threads, and it does that
>> very badly.
>>
>> The $100 question is =E2=88=97why is it getting ahead of writeback*?
>
> The most important case is: faster reader + relatively slow writer.
>
> Assume for every 10 pages read, 1 page is dirtied, and the dirty speed
> is fast enough to trigger the 20% dirty ratio and hence dirty balancing.
>
> That pattern is able to evenly distribute dirty pages all over the LRU
> list and hence trigger lots of pageout()s. The "skip reclaim writes on
> low pressure" approach can fix this case.
>
> Thanks,
> Fengguang
> ---
> Subject: writeback: introduce bdi_start_inode_writeback()
> Date: Thu Jul 29 14:41:19 CST 2010
>
> This relays ASYNC file writeback IOs to the flusher threads.
>
> pageout() will continue to serve the SYNC file page writes for necessary
> throttling for preventing OOM, which may happen if the LRU list is small
> and/or the storage is slow, so that the flusher cannot clean enough
> pages before the LRU is full scanned.
>
> Only ASYNC pageout() is relayed to the flusher threads, the less
> frequent SYNC pageout()s will work as before as a last resort.
> This helps to avoid OOM when the LRU list is small and/or the storage is
> slow, and the flusher cannot clean enough pages before the LRU is
> full scanned.
>
> The flusher will piggy back more dirty pages for IO
> - it's more IO efficient
> - it helps clean more pages, a good number of them may sit in the same
> =C2=A0LRU list that is being scanned.
>
> To avoid memory allocations at page reclaim, a mempool is created.
>
> Background/periodic works will quit automatically (as done in another
> patch), so as to clean the pages under reclaim ASAP. However for now the
> sync work can still block us for long time.
>
> Jan Kara: limit the search scope.
>
> CC: Jan Kara <jack@suse.cz>
> CC: Rik van Riel <riel@redhat.com>
> CC: Mel Gorman <mel@linux.vnet.ibm.com>
> CC: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

It seems to be enhanced version of old Mel's done.
I support this approach :) but I have some questions.

> ---
> =C2=A0fs/fs-writeback.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| =C2=A0156 ++++++++++++++++++++++++++++-
> =C2=A0include/linux/backing-dev.h =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01
> =C2=A0include/trace/events/writeback.h | =C2=A0 15 ++
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A08 +
> =C2=A04 files changed, 174 insertions(+), 6 deletions(-)
>
> --- linux-next.orig/mm/vmscan.c 2011-06-29 20:43:10.000000000 -0700
> +++ linux-next/mm/vmscan.c =C2=A0 =C2=A0 =C2=A02011-07-05 18:30:19.000000=
000 -0700
> @@ -825,6 +825,14 @@ static unsigned long shrink_page_list(st
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageDirty(page=
)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0nr_dirty++;
>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (page_is_file_cache(page) && mapping &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 sc->reclaim_mode !=3D RECLAIM_MODE_SYNC) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (flush_inode_page(page, mapping) >=3D=
 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SetPageRecla=
im(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto keep_lo=
cked;

keep_locked changes old behavior.
Normally, in case of async mode, we does keep_lumpy(ie, we didn't
reset reclaim_mode) but now you are always resetting reclaim_mode. so
sync call of shrink_page_list never happen if flush_inode_page is
successful.
Is it your intention?


> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
> +

If flush_inode_page fails(ie, the page isn't nearby of current work's
writeback range), we still do pageout although it's async mode. Is it
your intention?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
