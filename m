Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5D1766B00A9
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:18:20 -0500 (EST)
Received: by ywh3 with SMTP id 3so697452ywh.22
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 07:18:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091126141738.GE13095@csn.ul.ie>
References: <20091126121945.GB13095@csn.ul.ie>
	 <4e5e476b0911260547r33424098v456ed23203a61dd@mail.gmail.com>
	 <20091126141738.GE13095@csn.ul.ie>
Date: Thu, 26 Nov 2009 16:18:18 +0100
Message-ID: <4e5e476b0911260718h35fab3b1hc63587b23c02d43f@mail.gmail.com>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
From: Corrado Zoccolo <czoccolo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 26, 2009 at 3:17 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Thu, Nov 26, 2009 at 02:47:10PM +0100, Corrado Zoccolo wrote:
>> On Thu, Nov 26, 2009 at 1:19 PM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > (cc'ing the people from the page allocator failure thread as this migh=
t be
>> > relevant to some of their problems)
>> >
>> > I know this is very last minute but I believe we should consider disab=
ling
>> > the "low_latency" tunable for block devices by default for 2.6.32. =C2=
=A0There was
>> > evidence that low_latency was a problem last week for page allocation =
failure
>> > reports but the reproduction-case was unusual and involved high-order =
atomic
>> > allocations in low-memory conditions. It took another few days to accu=
rately
>> > show the problem for more normal workloads and it's a bit more wide-sp=
read
>> > than just allocation failures.
>> >
>> > Basically, low_latency looks great as long as you have plenty of memor=
y
>> > but in low memory situations, it appears to cause problems that manife=
st
>> > as reduced performance, desktop stalls and in some cases, page allocat=
ion
>> > failures. I think most kernel developers are not seeing the problem as=
 they
>> > tend to test on beefier machines and without hitting swap or low-memor=
y
>> > situations for the most part. When they are hitting low-memory situati=
ons,
>> > it tends to be for stress tests where stalls and low performance are e=
xpected.
>>
>> The low latency tunable controls various policies inside cfq.
>> The one that could affect memory reclaim is:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Async queues must wait a bit before =
being allowed dispatch.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* We also ramp up the dispatch depth g=
radually for async IO,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* based on the last sync IO we service=
d
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latenc=
y) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long la=
st_sync =3D jiffies - cfqd->last_end_sync_rq;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int dep=
th;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 depth =3D last_s=
ync / cfqd->cfq_slice[1];
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!depth && !c=
fqq->dispatched)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 depth =3D 1;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (depth < max_=
dispatch)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 max_dispatch =3D depth;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> here the async queues max depth is limited to 1 for up to 200 ms after
>> a sync I/O is completed.
>> Note: dirty page writeback goes through an async queue, so it is
>> penalized by this.
>>
>> This can affect both low and high end hardware. My non-NCQ sata disk
>> can handle a depth of 2 when writing. NCQ sata disks can handle a
>> depth up to 31, so limiting depth to 1 can cause write performance
>> drop, and this in turn will slow down dirty page reclaim, and cause
>> allocation failures.
>>
>> It would be good to re-test the OOM conditions with that code commented =
out.
>>
>
> All of it or just the cfq_latency part?
The whole if, that is enabled only with cfq_latency.

>
> As it turns out the test machine does report for the disk NCQ (depth 31/3=
2)
> and it's the same on the laptop so slowing down dirty page cleaning
> could be impacting reclaim.
Yes, I think so.

>
>> >
>> > To show the problem, I used an x86-64 machine booting booted with 512M=
B of
>> > memory. This is a small amount of RAM but the bug reports related to p=
age
>> > allocation failures were on smallish machines and the disks in the sys=
tem
>> > are not very high-performance.
>> >
>> > I used three tests. The first was sysbench on postgres running an IO-h=
eavy
>> > test against a large database with 10,000,000 rows. The second was IOZ=
one
>> > running most of the automatic tests with a record length of 4KB and th=
e
>> > last was a simulated launching of gitk with a music player running in =
the
>> > background to act as a desktop-like scenario. The final test was simil=
ar
>> > to the test described here http://lwn.net/Articles/362184/ except that
>> > dm-crypt was not used as it has its own problems.
>>
>> low_latency was tested on other scenarios:
>> http://lkml.indiana.edu/hypermail/linux/kernel/0910.0/01410.html
>> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-11/msg04855.html
>> where it improved actual and perceived performance, so disabling it
>> completely may not be good.
>>
>
> It may not indeed.
>
> In case you mean a partial disabling of cfq_latency, I'm try the
> following patch. The intention is to disable the low_latency logic if
> kswapd is at work and presumably needs clean pages. Alternative
> suggestions welcome.
Yes, I meant exactly to disable that part, and doing it when kswapd is
active is probably a good choice.
I have a different idea for 2.6.33, though.
If you have a reliable reproducer of the issue, can you test it on
git://git.kernel.dk/linux-2.6-block.git branch for-2.6.33?
It may already be unaffected, since we had various performance
improvements there, but I think a better way to boost writeback is
possible.

Thanks,
Corrado

>
> =3D=3D=3D=3D=3D=3D
> cfq: Do not limit the async queue depth while kswapd is awake
>
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index aa1e953..dcab74e 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -1308,7 +1308,7 @@ static bool cfq_may_dispatch(struct cfq_data *cfqd,=
 struct cfq_queue *cfqq)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * We also ramp up the dispatch depth graduall=
y for async IO,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * based on the last sync IO we serviced
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency) {
> + =C2=A0 =C2=A0 =C2=A0 if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency && !=
kswapd_awake()) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long last=
_sync =3D jiffies - cfqd->last_end_sync_rq;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int depth=
;
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 6f75617..b593aff 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -655,6 +655,7 @@ typedef struct pglist_data {
> =C2=A0void get_zone_counts(unsigned long *active, unsigned long *inactive=
,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0unsigned long *free);
> =C2=A0void build_all_zonelists(void);
> +int kswapd_awake(void);
> =C2=A0void wakeup_kswapd(struct zone *zone, int order);
> =C2=A0int zone_watermark_ok(struct zone *z, int order, unsigned long mark=
,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int classzone_idx,=
 int alloc_flags);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 777af57..75cdd9a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2201,6 +2201,15 @@ static int kswapd(void *p)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> +int kswapd_awake(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 pg_data_t *pgdat;
> + =C2=A0 =C2=A0 =C2=A0 for_each_online_pgdat(pgdat)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!waitqueue_active(=
&pgdat->kswapd_wait))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return 1;
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> =C2=A0/*
> =C2=A0* A zone is low on free memory, so wake its kswapd task to service =
it.
> =C2=A0*/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
