Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7013A6B00A0
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:35:31 -0400 (EDT)
Received: by gyd10 with SMTP id 10so2303096gyd.14
        for <linux-mm@kvack.org>; Wed, 20 Oct 2010 08:35:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101020142326.GA5243@barrios-desktop>
References: <20100915122334.3fa7b35f@notabene>
	<20100915082843.GA17252@localhost>
	<20100915184434.18e2d933@notabene>
	<20101018151459.2b443221@notabene>
	<AANLkTimv_zXHdFDGa9ecgXyWmQynOKTDRPC59PZA9mvL@mail.gmail.com>
	<20101019101151.57c6dd56@notabene>
	<AANLkTin3wXWwA-HXhjx6wvzznp3p57Pg6fee8YNkZB79@mail.gmail.com>
	<AANLkTimVu+5gTDs8przJVP2EbWC=FX-zWW7aH08BtrHC@mail.gmail.com>
	<20101020055717.GA12752@localhost>
	<AANLkTinC=xcgfwgXw8Tr-Q_cnxZakjj_W=HwQRV+5vkd@mail.gmail.com>
	<20101020142326.GA5243@barrios-desktop>
Date: Wed, 20 Oct 2010 17:35:27 +0200
Message-ID: <AANLkTim1qeexFiDEEXiub+zQHjiM8YhMo5FiJcKD72aT@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Torsten Kaiser <just.for.lkml@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>, Jens Axboe <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 20, 2010 at 4:23 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Hello
>
> On Wed, Oct 20, 2010 at 09:25:49AM +0200, Torsten Kaiser wrote:
>> On Wed, Oct 20, 2010 at 7:57 AM, Wu Fengguang <fengguang.wu@intel.com> w=
rote:
>> > On Tue, Oct 19, 2010 at 06:06:21PM +0800, Torsten Kaiser wrote:
>> >> swap_writepage() uses get_swap_bio() which uses bio_alloc() to get on=
e
>> >> bio. That bio is the submitted, but the submit path seems to get into
>> >> make_request from raid1.c and that allocates a second bio from
>> >> bio_alloc() via bio_clone().
>> >>
>> >> I am seeing this pattern (swap_writepage calling
>> >> md_make_request/make_request and then getting stuck in mempool_alloc)
>> >> more than 5 times in the SysRq+T output...
>> >
>> > I bet the root cause is the failure of pool->alloc(__GFP_NORETRY)
>> > inside mempool_alloc(), which can be fixed by this patch.
>>
>> No. I tested the patch (ontop of Neils fix and your patch regarding
>> too_many_isolated()), but the system got stuck the same way on the
>> first try to fill the tmpfs.
>> I think the basic problem is, that the mempool that should guarantee
>> progress is exhausted because the raid1 device is stacked between the
>> pageout code and the disks and so the "use only 1 bio"-rule gets
>> violated.
>>
>> > Thanks,
>> > Fengguang
>> > ---
>> >
>> > concurrent direct page reclaim problem
>> >
>> > ?__GFP_NORETRY page allocations may fail when there are many concurren=
t page
>> > ?allocating tasks, but not necessary in real short of memory. The root=
 cause
>> > ?is, tasks will first run direct page reclaim to free some pages from =
the LRU
>> > ?lists and put them to the per-cpu page lists and the buddy system, an=
d then
>> > ?try to get a free page from there. ?However the free pages reclaimed =
by this
>> > ?task may be consumed by other tasks when the direct reclaim task is a=
ble to
>> > ?get the free page for itself.
>>
>> I believe the facts disagree with that assumtion. My bad for not
>> posting this before, but I also used SysRq+M to see whats going on,
>> but each time there still was some free memory.
>> Here is the SysRq+M output from the run with only Neils patch applied,
>> but on each other run the same ~14Mb stayed free
>
>
> What is your problem?(Sorry if you explained it several time).

The original problem was that using too many gcc's caused a swapstorm
that completely hung my system.
I first blame it one the workqueue changes in 2.6.36-rc1 and/or its
interaction with XFS (because in -rc5 a workqueue related problem in
XFS got fixed), but Tejun Heo found out that a) it were exhausted
mempools and not the workqueues and that the problems itself existed
at least in 2.6.35 already. In
http://marc.info/?l=3Dlinux-raid&m=3D128699402805191&w=3D2 I have describe =
a
simpler testcase that I found after looking more closely into the
mempools.

Short story: swaping over RAID1 (drivers/md/raid1.c) can cause a
system hang, because it is using too much of the fs_bio_set mempool
from fs/bio.c.

> I read the thread.
> It seems Wu's patch solved deadlock problem by FS lock holding and too_ma=
ny_isolated.
> What is the problem remained in your case? unusable system by swapstorm?
> If it is, I think it's expected behavior. Please see the below comment.
> (If I don't catch your point, Please explain your problem.)

I do not have a problem, if the system becomes unusable *during* a
swapstorm, but it should recover. That is not the case in my system.
With Wu's too_many_isolated-patch and Neil's patch agains raid1.c the
system does no longer seem to be completely stuck (a swapoutrate of
~80kb every 20 seconds still happens), but I would still expect a
better recovery time. (At that rate the recovery would probably take a
few days...)

>> [ =A0437.481365] SysRq : Show Memory
>> [ =A0437.490003] Mem-Info:
>> [ =A0437.491357] Node 0 DMA per-cpu:
>> [ =A0437.500032] CPU =A0 =A00: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>> [ =A0437.500032] CPU =A0 =A01: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>> [ =A0437.500032] CPU =A0 =A02: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>> [ =A0437.500032] CPU =A0 =A03: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>> [ =A0437.500032] Node 0 DMA32 per-cpu:
>> [ =A0437.500032] CPU =A0 =A00: hi: =A0186, btch: =A031 usd: 138
>> [ =A0437.500032] CPU =A0 =A01: hi: =A0186, btch: =A031 usd: =A030
>> [ =A0437.500032] CPU =A0 =A02: hi: =A0186, btch: =A031 usd: =A0 0
>> [ =A0437.500032] CPU =A0 =A03: hi: =A0186, btch: =A031 usd: =A0 0
>> [ =A0437.500032] Node 1 DMA32 per-cpu:
>> [ =A0437.500032] CPU =A0 =A00: hi: =A0186, btch: =A031 usd: =A0 0
>> [ =A0437.500032] CPU =A0 =A01: hi: =A0186, btch: =A031 usd: =A0 0
>> [ =A0437.500032] CPU =A0 =A02: hi: =A0186, btch: =A031 usd: =A0 0
>> [ =A0437.500032] CPU =A0 =A03: hi: =A0186, btch: =A031 usd: =A0 0
>> [ =A0437.500032] Node 1 Normal per-cpu:
>> [ =A0437.500032] CPU =A0 =A00: hi: =A0186, btch: =A031 usd: =A0 0
>> [ =A0437.500032] CPU =A0 =A01: hi: =A0186, btch: =A031 usd: =A0 0
>> [ =A0437.500032] CPU =A0 =A02: hi: =A0186, btch: =A031 usd: =A025
>> [ =A0437.500032] CPU =A0 =A03: hi: =A0186, btch: =A031 usd: =A030
>> [ =A0437.500032] active_anon:2039 inactive_anon:985233 isolated_anon:682
>> [ =A0437.500032] =A0active_file:1667 inactive_file:1723 isolated_file:0
>> [ =A0437.500032] =A0unevictable:0 dirty:0 writeback:25387 unstable:0
>> [ =A0437.500032] =A0free:3471 slab_reclaimable:2840 slab_unreclaimable:6=
337
>> [ =A0437.500032] =A0mapped:1284 shmem:960501 pagetables:523 bounce:0
>> [ =A0437.500032] Node 0 DMA free:8008kB min:28kB low:32kB high:40kB
>> active_anon:0kB inact
>> ive_anon:7596kB active_file:12kB inactive_file:0kB unevictable:0kB
>> isolated(anon):0kB i
>> solated(file):0kB present:15768kB mlocked:0kB dirty:0kB
>> writeback:404kB mapped:0kB shme
>> m:7192kB slab_reclaimable:32kB slab_unreclaimable:304kB
>> kernel_stack:0kB pagetables:0kB
>> =A0unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:118
>> all_unreclaimable? no
>> [ =A0437.500032] lowmem_reserve[]: 0 2004 2004 2004
>
> Node 0 DMA : free 8008K but lowmem_reserve 8012K(2004 pages)
> So page allocator can't allocate the page unless preferred zone is DMA
>
>> [ =A0437.500032] Node 0 DMA32 free:2980kB min:4036kB low:5044kB
>> high:6052kB active_anon:2
>> 844kB inactive_anon:1918424kB active_file:3428kB inactive_file:3780kB
>> unevictable:0kB isolated(anon):1232kB isolated(file):0kB
>> present:2052320kB mlocked:0kB dirty:0kB writeback:72016kB
>> mapped:2232kB shmem:1847640kB slab_reclaimable:5444kB
>> slab_unreclaimable:13508kB kernel_stack:744kB pagetables:864kB
>> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
>> all_unreclaimable? no
>> [ =A0437.500032] lowmem_reserve[]: 0 0 0 0
>
> Node 0 DMA32 : free 2980K but min 4036K.
> Few file LRU compare to anon LRU

In the testcase I fill a tmpfs as fast as I can with data from
/dev/zero. So nearly everything gets swapped out and only the last
written data from the tmpfs fills all RAM. (I have 4GB RAM, the tmpfs
is limited to 6GB, 16 dd's are writing into it)

> Normally, it could fail to allocate the page.
> 'Normal' means caller doesn't request alloc_pages with __GFP_HIGH or !__G=
FP_WAIT
> Generally many call sites don't pass gfp_flag with __GFP_HIGH|!__GFP_WAIT=
