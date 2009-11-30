Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 54F7C600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 07:54:08 -0500 (EST)
Received: by ywh3 with SMTP id 3so3128500ywh.22
        for <linux-mm@kvack.org>; Mon, 30 Nov 2009 04:54:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091130120428.GA23491@csn.ul.ie>
References: <20091126121945.GB13095@csn.ul.ie>
	 <4e5e476b0911271014k1d507a02o60c11723948dcfa@mail.gmail.com>
	 <20091127185234.GQ13095@csn.ul.ie>
	 <200911291611.16434.czoccolo@gmail.com>
	 <20091130120428.GA23491@csn.ul.ie>
Date: Mon, 30 Nov 2009 13:54:04 +0100
Message-ID: <4e5e476b0911300454x74c46852od4c35132f0d4c104@mail.gmail.com>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
From: Corrado Zoccolo <czoccolo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 30, 2009 at 1:04 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Sun, Nov 29, 2009 at 04:11:15PM +0100, Corrado Zoccolo wrote:
>> On Fri, Nov 27, 2009 19:52:34, Mel Gorman wrote:
>> : > On Fri, Nov 27, 2009 at 07:14:41PM +0100, Corrado Zoccolo wrote:
>> > > On Fri, Nov 27, 2009 at 4:58 PM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > > > On Fri, Nov 27, 2009 at 01:03:29PM +0100, Corrado Zoccolo wrote:
>> > > >> On Fri, Nov 27, 2009 at 12:44 PM, Mel Gorman <mel@csn.ul.ie> wrot=
e:
>> > > >
>> > > > How would one go about selecting the proper ratio at which to disa=
ble
>> > > > the low_latency logic?
>> > >
>> > > Can we measure the dirty ratio when the allocation failures start to
>> > > happen?
>> >
>> > Would the number of dirty pages in the page allocation failure message=
 to
>> > kern.log be enough? You won't get them all because of printk suppress =
but
>> > it's something. Alternatively, tell me exactly what stats from /proc y=
ou
>> > want and I'll stick a monitor on there. Assuming you want nr_dirty vs =
total
>> > number of pages though, the monitor tends to execute too late to be us=
eful.
>> >
>> Since I wanted to go deeper in the understanding, but my system is healt=
y,
>> I devised a measure of fragmentation, and wanted to chart it to understa=
nd
>> what was going wrong. A perl script that produces gnuplot compatible out=
put is provided:
>>
>> use strict;
>> select(STDOUT);
>> $|=3D1;
>> do {
>> open (my $bf, "< /proc/buddyinfo") or die;
>> open (my $up, "< /proc/uptime") or die;
>> my $now =3D <$up>;
>> chomp $now;
>> print $now;
>> while(<$bf>) {
>> =C2=A0 =C2=A0 next unless /Node (\d+), zone\s+([a-zA-Z]+)\s+(.+)$/;
>> =C2=A0 =C2=A0 my ($frag, $tot, $val) =3D (0,0,1);
>> =C2=A0 =C2=A0 map { $frag +=3D $_; $tot +=3D $val * $_; $val <<=3D 1;} (=
$3 =3D~ /\d+/g);
>> =C2=A0 =C2=A0 print "\t", $frag/$tot;
>> }
>> print "\n";
>> sleep 1;
>> } while(1);
>>
>> My definition of fragmentation is just the number of fragments / the num=
ber of pages:
>> * It is 1 only when all pages are of order 0
>> * it is 2/3 on a random marking of used pages (each page has probability=
 0.5 of being used)
>> * to be sure that a order k allocation succeeds, the fragmentation shoul=
d be <=3D 2^-k
>>
>
> In practice, the ordering of page allocations and frees are not random
> but it's ok for the purposes here.
>
> Also when considering fragmentation, I'd take into account the order of t=
he
> desired allocation as fragmentations at or over that size are not contrib=
uting
> to fragmentation in a negative way. I'd usually express it in terms of fr=
ee
> pages instead of total pages as well to avoid large fluctuations when rec=
laim
> is working. We can work with this measure for the moment though to avoid
> getting side-tracked on what fragmentation is.
>
>> I observed the mainline kernel during normal usage, and found that:
>> * the fragmentation is very low after boot (< 1%).
>> * it tends to increase when memory is freed, and to decrease when memory=
 is allocated (since the kernel usually performs order 0 allocations).
>> * high memory fragmentation increases first, and only when all high memo=
ry is used, normal memory starts to fragment.
>
> All three of these observations are expected.
>
>> * when the page cache is big enough (so memory pressure is high for the =
allocator), the fragmentation starts to fluctuate a lot, sometimes exceedin=
g 2/3 (up to 0.8).
>
> Again, this is expected. Page cache pages stay resident until
> reclaimed. If they are clean, they are not really contributing to
> fragmentation in any way that matters as they should be quickly found
> and discarded in most cases. In the networking case, it's depending on
> kswapd to find and reclaim the pages fast enough.

If you need an order 5 page, how would kswapd work?
Will it free randomly some order 0 pages until a merge magically happens?
Unless the dirty ratio is really high, there should already be plenty
of contiguous non-dirty pages in the page cache that could be freed,
but if you use an LRU policy to evict, you can go through a lot of
freeing before a merge will happen.

>> * the only way to make the fragmentation return to sane values after it =
enters fluctuation is to do a sync & drop caches. Even in this case, it wil=
l go around 14%, that is still quite high.
>> >
>> > Two major differences. 1, the previous non-high-order tests had also
>> > run sysbench and iozone so the starting conditions are different. I ha=
d
>> > disabled those tests to get some of the high-order figures before I we=
nt
>> > offline. However, the starting conditions are probably not as importan=
t as
>> > the fact that kswapd is working to free order-2 pages and staying awak=
e
>> > until watermarks are reached. kswapd working harder is probably making=
 a
>> > big difference.
>> >
>>
>> From my observation, having run a program that fills page cache before a=
 test has a lot of impact to the fragmentation.
>
> While this is true, during the course of the test, the old page cache
> should be discarded quickly. It's not as abrupt as dropping the page
> cache but the end result should be similar in the majority of cases -
> the exception being when atomic allocations are a major factor.

For my I/O scheduler tests I use an external disk, to be able to
monitor exactly what is happening.
If I don't do a sync & drop cache before starting a test, I usually
see writeback happening on the main disk, even if the only activity on
the machine is writing a sequential file to my external disk. If that
writeback is done in the context of my test process, this will alter
the result.
And with high order allocations, depending on how do you free page
cache, it can be even worse than that.

>
>> On the other hand, I saw that the problems with high order allocations s=
tarted
>> around 2.6.31, where we didn't have any low_latency patch.
>
> While this is true, there appear to be many sources of the high order
> allocation failures. While low_latency is not the original source, it
> does not appear to have helped either. Even without high-order
> allocations being involved, disabling low_latency performs much better
> in low-memory situations.
Can you try reproducing:
http://lkml.indiana.edu/hypermail/linux/kernel/0911.1/01848.html
in a low memory scenario, to substantiate your claim?

>> After a 1day study of the VM, I found an other way to improve the fragme=
ntation.
>> With the patch below, the fragmentation stays below 2/3 even when memory=
 pressure is high,
>> and decreases overtime, if the system is lightly used, even without drop=
ping caches.
>> Moreover, the precious zones (Normal, DMA) are kept at a lower fragmenta=
tion, since high order
>> allocations are usually serviced by the other zones (more likely than wi=
th mainline allocator).
>>
>> The idea is to have 2 freelists for each zone.
>> The free_list_0 has the pages that are less likely to cause an higher-or=
der merge, since the buddy of their compound is not free.
>> The free_list_1 contains the other ones.
>> When expanding, we put pages into free_list_1.When freeing, we put them =
in the proper one by checking the buddy of the compound.
>> And when extracting, we always extract from free_list_0 first,
>
> This is subtle, but as well as increased overhead in the page allocator, =
I'd
> expect this to break the page-ordering when a caller is allocation many n=
umbers
> of order-0 pages. Some IO controllers get a boost by the pages coming bac=
k
> in physically contiguous order which happens if a high-order page is bein=
g
> split towards the beginning of the stream of requests. Previous attempts =
at
> altering how coalescing and splitting to reduce fragmentation with method=
s
> similar to yours have fallen foul of this.
I took extreme care in not disrupting the page ordering. In fact, I
thought, too, to a single list solution, but it could cause page
reordering (since I would have used add_tail to add to the other
list).

>
>> and fall back on the other if the first is empty.
>> In this way, we keep free longer the pages that are more likely to cause=
 a big merge.
>> Consequently we tend to aggregate the long-living allocations on a subse=
t of the compounds, reducing the fragmentation.
>>
>> It can, though, slow down allocation and reclaim, so someone more knowle=
dgeable than me should have a look.
>>
>> Signed-off-by: Corrado Zoccolo <czoccolo@gmail.com>
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 6f75617..6427361 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -55,7 +55,8 @@ static inline int get_pageblock_migratetype(struct pag=
e *page)
>> =C2=A0}
>>
>> =C2=A0struct free_area {
>> - =C2=A0 =C2=A0 struct list_head =C2=A0 =C2=A0 =C2=A0 =C2=A0free_list[MI=
GRATE_TYPES];
>> + =C2=A0 =C2=A0 struct list_head =C2=A0 =C2=A0 =C2=A0 =C2=A0free_list_0[=
MIGRATE_TYPES];
>> + =C2=A0 =C2=A0 struct list_head =C2=A0 =C2=A0 =C2=A0 =C2=A0free_list_1[=
MIGRATE_TYPES];
>> =C2=A0 =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr=
_free;
>> =C2=A0};
>>
>> diff --git a/kernel/kexec.c b/kernel/kexec.c
>> index f336e21..aee5ef5 100644
>> --- a/kernel/kexec.c
>> +++ b/kernel/kexec.c
>> @@ -1404,13 +1404,15 @@ static int __init crash_save_vmcoreinfo_init(voi=
d)
>> =C2=A0 =C2=A0 =C2=A0 VMCOREINFO_OFFSET(zone, free_area);
>> =C2=A0 =C2=A0 =C2=A0 VMCOREINFO_OFFSET(zone, vm_stat);
>> =C2=A0 =C2=A0 =C2=A0 VMCOREINFO_OFFSET(zone, spanned_pages);
>> - =C2=A0 =C2=A0 VMCOREINFO_OFFSET(free_area, free_list);
>> + =C2=A0 =C2=A0 VMCOREINFO_OFFSET(free_area, free_list_0);
>> + =C2=A0 =C2=A0 VMCOREINFO_OFFSET(free_area, free_list_1);
>> =C2=A0 =C2=A0 =C2=A0 VMCOREINFO_OFFSET(list_head, next);
>> =C2=A0 =C2=A0 =C2=A0 VMCOREINFO_OFFSET(list_head, prev);
>> =C2=A0 =C2=A0 =C2=A0 VMCOREINFO_OFFSET(vm_struct, addr);
>> =C2=A0 =C2=A0 =C2=A0 VMCOREINFO_LENGTH(zone.free_area, MAX_ORDER);
>> =C2=A0 =C2=A0 =C2=A0 log_buf_kexec_setup();
>> - =C2=A0 =C2=A0 VMCOREINFO_LENGTH(free_area.free_list, MIGRATE_TYPES);
>> + =C2=A0 =C2=A0 VMCOREINFO_LENGTH(free_area.free_list_0, MIGRATE_TYPES);
>> + =C2=A0 =C2=A0 VMCOREINFO_LENGTH(free_area.free_list_1, MIGRATE_TYPES);
>> =C2=A0 =C2=A0 =C2=A0 VMCOREINFO_NUMBER(NR_FREE_PAGES);
>> =C2=A0 =C2=A0 =C2=A0 VMCOREINFO_NUMBER(PG_lru);
>> =C2=A0 =C2=A0 =C2=A0 VMCOREINFO_NUMBER(PG_private);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index cdcedf6..5f488d8 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -451,6 +451,8 @@ static inline void __free_one_page(struct page *page=
,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int migratetype)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 unsigned long page_idx;
>> + =C2=A0 =C2=A0 unsigned long combined_idx;
>> + =C2=A0 =C2=A0 bool high_order_free =3D false;
>>
>> =C2=A0 =C2=A0 =C2=A0 if (unlikely(PageCompound(page)))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(destroy_co=
mpound_page(page, order)))
>> @@ -464,7 +466,6 @@ static inline void __free_one_page(struct page *page=
,
>> =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(bad_range(zone, page));
>>
>> =C2=A0 =C2=A0 =C2=A0 while (order < MAX_ORDER-1) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long combined_idx;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *buddy;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 buddy =3D __page_find_b=
uddy(page, page_idx, order);
>> @@ -481,8 +482,21 @@ static inline void __free_one_page(struct page *pag=
e,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 order++;
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 set_page_order(page, order);
>> - =C2=A0 =C2=A0 list_add(&page->lru,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &zone->free_area[order].free=
_list[migratetype]);
>> +
>> + =C2=A0 =C2=A0 if (order < MAX_ORDER-1) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *parent_page, *p=
page_buddy;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 combined_idx =3D __find_comb=
ined_index(page_idx, order);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 parent_page =3D page + combi=
ned_idx - page_idx;
>
> parent_page is a bad name here. It's not the parent of anything. What I
> think you're looking for is the lowest page of the pair of buddies that
> was last considered for merging.
Right, this should be the combined page, to keep naming consistent
with combined_idx.

>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ppage_buddy =3D __page_find_=
buddy(parent_page, combined_idx, order + 1);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 high_order_free =3D page_is_=
buddy(parent_page, ppage_buddy, order + 1);
>> + =C2=A0 =C2=A0 }
>
> And you are checking if when one buddy of this pair frees, will it then
> be merged with the next-highest order. If so, you want to delay reusing
> that page for allocation.
Exactly.
If you have two streams of allocations, with different average
lifetime (and with the long lifetime allocations having a slower
rate), this will make very probable that the long lifetime allocations
span a smaller set of compounds.
>
>> +
>> + =C2=A0 =C2=A0 if (high_order_free)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add(&page->lru,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
&zone->free_area[order].free_list_1[migratetype]);
>> + =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add(&page->lru,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
&zone->free_area[order].free_list_0[migratetype]);
>
> You could have avoided the extra list to some extent by altering whether
> it was the head or tail of the list the page was added to. It would have
> had a similar effect of the page not being used for longer with slightly
> less overhead.
Right, but the order of insertions at the tail would be reversed.

>> =C2=A0 =C2=A0 =C2=A0 zone->free_area[order].nr_free++;
>> =C2=A0}
>>
>> @@ -663,7 +677,7 @@ static inline void expand(struct zone *zone, struct =
page *page,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 high--;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size >>=3D 1;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(bad_range(zon=
e, &page[size]));
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add(&page[size].lru, &a=
rea->free_list[migratetype]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add(&page[size].lru, &a=
rea->free_list_1[migratetype]);
>
> I think this here will damage the contiguous ordering of pages being
> returned to callers.
This shouldn't damage the order. In fact, expand always inserts in the
free_list_1, in the same order as the original code inserted in the
free_list. And if we hit expand, then the free_list_0 is empty, so all
allocations will be serviced from free_list_1 in the same order as the
original code.

>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 area->nr_free++;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 set_page_order(&page[si=
ze], high);
>> =C2=A0 =C2=A0 =C2=A0 }
>> @@ -723,12 +737,19 @@ struct page *__rmqueue_smallest(struct zone *zone,=
 unsigned int order,
>>
>> =C2=A0 =C2=A0 =C2=A0 /* Find a page of the appropriate size in the prefe=
rred list */
>> =C2=A0 =C2=A0 =C2=A0 for (current_order =3D order; current_order < MAX_O=
RDER; ++current_order) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool fl0, fl1;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 area =3D &(zone->free_a=
rea[current_order]);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (list_empty(&area->free_l=
ist[migratetype]))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fl0 =3D list_empty(&area->fr=
ee_list_0[migratetype]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fl1 =3D list_empty(&area->fr=
ee_list_1[migratetype]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (fl0 && fl1)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
>>
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D list_entry(area->fr=
ee_list[migratetype].next,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page, lru);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (fl0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
page =3D list_entry(area->free_list_1[migratetype].next,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page,=
 lru);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
page =3D list_entry(area->free_list_0[migratetype].next,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page,=
 lru);
>
> By altering whether it's the head or tail free pages are added to, you
> can achieve a similar effect.
>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rmv_page_order(page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 area->nr_free--;
>> @@ -792,7 +813,7 @@ static int move_freepages(struct zone *zone,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 order =3D page_order(pa=
ge);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add(&page->lru,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
&zone->free_area[order].free_list[migratetype]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
&zone->free_area[order].free_list_0[migratetype]);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page +=3D 1 << order;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages_moved +=3D 1 << o=
rder;
>> =C2=A0 =C2=A0 =C2=A0 }
>> @@ -845,6 +866,7 @@ __rmqueue_fallback(struct zone *zone, int order, int=
 start_migratetype)
>> =C2=A0 =C2=A0 =C2=A0 for (current_order =3D MAX_ORDER-1; current_order >=
=3D order;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 --current_order) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < MIGRA=
TE_TYPES - 1; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
bool fl0, fl1;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 migratetype =3D fallbacks[start_migratetype][i];
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* MIGRATE_RESERVE handled later if necessary */
>> @@ -852,11 +874,20 @@ __rmqueue_fallback(struct zone *zone, int order, i=
nt start_migratetype)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 area =3D &(zone->free_area[current_order]);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (list_empty(&area->free_list[migratetype]))
>> +
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
fl0 =3D list_empty(&area->free_list_0[migratetype]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
fl1 =3D list_empty(&area->free_list_1[migratetype]);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (fl0 && fl1)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
>>
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
page =3D list_entry(area->free_list[migratetype].next,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page, lru);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (fl0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D list_entry(area->free_list_1[migratety=
pe].next,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 struct page, lru);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D list_entry(area->free_list_0[migratety=
pe].next,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 struct page, lru);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 area->nr_free--;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
>> @@ -1061,7 +1092,14 @@ void mark_free_pages(struct zone *zone)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 for_each_migratetype_order(order, t) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_for_each(curr, &zone->f=
ree_area[order].free_list[t]) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_for_each(curr, &zone->f=
ree_area[order].free_list_0[t]) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
unsigned long i;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
pfn =3D page_to_pfn(list_entry(curr, struct page, lru));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
for (i =3D 0; i < (1UL << order); i++)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 swsusp_set_page_free(pfn_to_page(pfn + i));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_for_each(curr, &zone->f=
ree_area[order].free_list_1[t]) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 unsigned long i;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pfn =3D page_to_pfn(list_entry(curr, struct page, lru));
>> @@ -2993,7 +3031,8 @@ static void __meminit zone_init_free_lists(struct =
zone *zone)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 int order, t;
>> =C2=A0 =C2=A0 =C2=A0 for_each_migratetype_order(order, t) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&zone->free_a=
rea[order].free_list[t]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&zone->free_a=
rea[order].free_list_0[t]);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&zone->free_a=
rea[order].free_list_1[t]);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->free_area[order].=
nr_free =3D 0;
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0}
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index c81321f..613ef1e 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -468,7 +468,9 @@ static void pagetypeinfo_showfree_print(struct seq_f=
ile *m,
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 area =3D &(zone->free_area[order]);
>>
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
list_for_each(curr, &area->free_list[mtype])
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
list_for_each(curr, &area->free_list_0[mtype])
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 freecount++;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
list_for_each(curr, &area->free_list_1[mtype])
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 freecount++;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 seq_printf(m, "%6lu ", freecount);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>
> No more than the low_latency switch, I think this will help some
> workloads in terms of fragmentation but hurt others that depend on the
> ordering of pages being returned.
Hopefully not, if my considerations above are correct.
> There is a fair amount of overhead
> introduced here as well with branches and a lot of extra lists although
> I believe that could be mitigated.
>
> What are the results if you just alter whether it's the head or tail of
> the list that is used in __free_one_page()?
In that case, it would alter the ordering, but not the one of the
pages returned by expand.
In fact, only the order of the pages returned by free will be
affected, and in that case maybe it is already quite disordered.
If that order is not needed to be kept, I can prepare a new version
with a single list.

BTW, if we only guarantee that pages returned by expand are well
ordered, this patch will increase the ordered-ness of the stream of
allocated pages, since it will increase the probability that
allocations go into expand (since frees will more likely create high
order combined pages). So it will also improve the workloads that
prefer ordered allocations.

>
> --
> Mel Gorman
> Part-time Phd Student =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linux Technology Center
> University of Limerick =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IBM Dublin Software Lab
>

--=20
__________________________________________________________________________

dott. Corrado Zoccolo                          mailto:czoccolo@gmail.com
PhD - Department of Computer Science - University of Pisa, Italy
--------------------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
