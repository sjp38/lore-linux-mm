Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 881AC6B0022
	for <linux-mm@kvack.org>; Wed, 18 May 2011 18:42:32 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1527361qwa.14
        for <linux-mm@kvack.org>; Wed, 18 May 2011 15:42:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110518094718.GP5279@suse.de>
References: <1305558417-24354-1-git-send-email-mgorman@suse.de>
	<1305558417-24354-3-git-send-email-mgorman@suse.de>
	<20110516141654.2728f05a.akpm@linux-foundation.org>
	<1305614225.6008.19.camel@mulgrave.site>
	<20110517162226.96974d89.akpm@linux-foundation.org>
	<20110518094718.GP5279@suse.de>
Date: Thu, 19 May 2011 07:42:29 +0900
Message-ID: <BANLkTimtHL15Dc9xg8omQOW8wR0q-RQdww@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>

On Wed, May 18, 2011 at 6:47 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, May 17, 2011 at 04:22:26PM -0700, Andrew Morton wrote:
>> On Tue, 17 May 2011 10:37:04 +0400
>> James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
>>
>> > On Mon, 2011-05-16 at 14:16 -0700, Andrew Morton wrote:
>> > > On Mon, 16 May 2011 16:06:57 +0100
>> > > Mel Gorman <mgorman@suse.de> wrote:
>> > >
>> > > > Under constant allocation pressure, kswapd can be in the situation=
 where
>> > > > sleeping_prematurely() will always return true even if kswapd has =
been
>> > > > running a long time. Check if kswapd needs to be scheduled.
>> > > >
>> > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
>> > > > Acked-by: Rik van Riel <riel@redhat.com>
>> > > > ---
>> > > > =C2=A0mm/vmscan.c | =C2=A0 =C2=A04 ++++
>> > > > =C2=A01 files changed, 4 insertions(+), 0 deletions(-)
>> > > >
>> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > > > index af24d1e..4d24828 100644
>> > > > --- a/mm/vmscan.c
>> > > > +++ b/mm/vmscan.c
>> > > > @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t =
*pgdat, int order, long remaining,
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long balanced =3D 0;
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool all_zones_ok =3D true;
>> > > >
>> > > > + =C2=A0 =C2=A0 =C2=A0 /* If kswapd has been running too long, jus=
t sleep */
>> > > > + =C2=A0 =C2=A0 =C2=A0 if (need_resched())
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>> > > > +
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* If a direct reclaimer woke kswapd w=
ithin HZ/10, it's premature */
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (remaining)
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return tru=
e;
>> > >
>> > > I'm a bit worried by this one.
>> > >
>> > > Do we really fully understand why kswapd is continuously running lik=
e
>> > > this? =C2=A0The changelog makes me think "no" ;)
>> > >
>> > > Given that the page-allocating process is madly reclaiming pages in
>> > > direct reclaim (yes?) and that kswapd is madly reclaiming pages on a
>> > > different CPU, we should pretty promptly get into a situation where
>> > > kswapd can suspend itself. =C2=A0But that obviously isn't happening.=
 =C2=A0So
>> > > what *is* going on?
>> >
>> > The triggering workload is a massive untar using a file on the same
>> > filesystem, so that's a continuous stream of pages read into the cache
>> > for the input and a stream of dirty pages out for the writes. =C2=A0We
>> > thought it might have been out of control shrinkers, so we already
>> > debugged that and found it wasn't. =C2=A0It just seems to be an imbala=
nce in
>> > the zones that the shrinkers can't fix which causes
>> > sleeping_prematurely() to return true almost indefinitely.
>>
>> Is the untar disk-bound? =C2=A0The untar has presumably hit the writebac=
k
>> dirty_ratio? =C2=A0So its rate of page allocation is approximately equal=
 to
>> the write speed of the disks?
>>
>
> A reasonable assumption but it gets messy.
>
>> If so, the VM is consuming 100% of a CPU to reclaim pages at a mere
>> tens-of-megabytes-per-second. =C2=A0If so, there's something seriously w=
rong
>> here - under favorable conditions one would expect reclaim to free up
>> 100,000 pages/sec, maybe more.
>>
>> If the untar is not disk-bound and the required page reclaim rate is
>> equal to the rate at which a CPU can read, decompress and write to
>> pagecache then, err, maybe possible. =C2=A0But it still smells of
>> inefficient reclaim.
>>
>
> I think it's higher than just the rate of data but couldn't guess by
> how much exactly. Reproducing this locally would have been nice but
> the following conditions are likely happening on the problem machine.
>
> =C2=A0 SLUB is using high-orders for its slabs, kswapd and reclaimers are
> =C2=A0 reclaiming at a faster rate than required for just the data. SLUB
> =C2=A0 is using order-2 allocs for inodes so every 18 files created by
> =C2=A0 untar, we need an order-2 page. For ext4_io_end, we need order-3
> =C2=A0 allocs and we are allocating these due to delayed block allocation=
.
>
> =C2=A0 So for example: 50 files, each less than 1 page in size needs 50
> =C2=A0 order-0 pages, 3 order-2 page and 2 order-3 pages
>
> =C2=A0 To satisfy the high order pages, we are reclaiming at least 28
> =C2=A0 pages. For compaction, we are migrating these so we are allocating
> =C2=A0 a further 28 pages and then copying putting further pressure on
> =C2=A0 the system. We may do this multiple times as order-0 allocations
> =C2=A0 could be breaking up the pages again. Without compaction, we are
> =C2=A0 only reclaiming but can get stalled for significant periods of
> =C2=A0 time if dirty or writeback pages are encountered in the contiguous
> =C2=A0 blocks and can reclaim too many pages quite easily.
>
> So the rate of allocation required to write out data is higher than
> just the data rate. The reclaim rate could be just fine but the number
> of pages we need to reclaim to allocate slab objects can be screwy.
>
>> > > Secondly, taking an up-to-100ms sleep in response to a need_resched(=
)
>> > > seems pretty savage and I suspect it risks undesirable side-effects.=
 =C2=A0A
>> > > plain old cond_resched() would be more cautious. =C2=A0But presumabl=
y
>> > > kswapd() is already running cond_resched() pretty frequently, so why
>> > > didn't that work?
>> >
>> > So the specific problem with cond_resched() is that kswapd is still
>> > runnable, so even if there's other work the system can be getting on
>> > with, it quickly comes back to looping madly in kswapd. =C2=A0If we re=
turn
>> > false from sleeping_prematurely(), we stop kswapd until its woken up t=
o
>> > do more work. =C2=A0This manifests, even on non sandybridge systems th=
at
>> > don't hang as a lot of time burned in kswapd.
>> >
>> > I think the sandybridge bug I see on the laptop is that cond_resched()
>> > is somehow ineffective: =C2=A0kswapd is usually hogging one CPU and th=
ere are
>> > runnable processes but they seem to cluster on other CPUs, leaving
>> > kswapd to spin at close to 100% system time.
>> >
>> > When the problem was first described, we tried sprinkling more
>> > cond_rescheds() in the shrinker loop and it didn't work.
>>
>> Seems to me that kswapd for some reason is doing too much work. =C2=A0Or=
,
>> more specifically is doing its work very inefficiently. =C2=A0Making ksw=
apd
>> take arbitrary naps when it's misbehaving didn't fix that misbehaviour!
>>
>
> It is likely to be doing work inefficiently in one of two ways
>
> =C2=A01. We are reclaiming far more pages than required by the data
> =C2=A0 =C2=A0 for slab objects
>
> =C2=A02. The rate we are reclaiming is fast enough that dirty pages are
> =C2=A0 =C2=A0 reaching the end of the LRU quickly
>
> The latter part is also important. I doubt we are getting stalled in
> writepage as this is new data being written to disk to blocks aren't
> allocated yet but kswapd is encountering the dirty_ratio of pages
> on the LRU and churning them through the LRU and reclaims the clean
> pages in between.
>
> In effect, this "sorts" the LRU lists so the dirty pages get grouped
> together. At worst on a 2G system such as James', we have 104857
> (20% of memory in pages) pages together on the LRU, all dirty and
> all being skipped over by kswapd and direct reclaimers. This is at
> least 3276 takings of the zone LRU lock assuming we isolate pages in
> groups of SWAP_CLUSTER_MAX which a lot of list walking and CPU usage
> for no pages reclaimed.
>
> In this case, kswapd might as well take a brief nap as it can't clean
> the pages so the flusher threads can get some work done.
>
>> It would be interesting to watch kswapd's page reclaim inefficiency
>> when this is happening: /proc/vmstat:pgscan_kswapd_* versus
>> /proc/vmstat:kswapd_steal. =C2=A0If that ration is high then kswapd is
>> scanning many pages and not reclaiming them.
>>
>> But given the prominence of shrink_slab in the traces, perhaps that
>> isn't happening.
>>
>
> As we are aggressively shrinking slab, we can reach the stage where
> we scan the requested number of objects and reclaim none of them
> potentially setting zone->all_unreclaimable to 1 if a lot of scanning
> has also taken place recently without pages being freed. Once this
> happens, kswapd isn't even trying to reclaim pages and is instead stuck
> in shrink_slab until a page is freed clearing zone->all_unreclaimable
> and zone->pages-scanned.

Why does it stuck in shrink_slab?
If the zone is trouble to reclaim(ie, all_unreclaimable is set),
kswapd will poll the zone only in case of DEF_PRIORITY(ie, small
window) for when the problem goes away. In high priority (0..11), the
zone will be skipped and we can't get a chance to call
shrink_[zone|slab].


>
> The ratio during that window would not change but slabs_scanned would
> continue to increase.
>
> --
> Mel Gorman
> SUSE Labs
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
