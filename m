Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E62536B0087
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 19:31:32 -0400 (EDT)
Received: by gxk25 with SMTP id 25so76386gxk.14
        for <linux-mm@kvack.org>; Wed, 20 Oct 2010 16:31:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTim1qeexFiDEEXiub+zQHjiM8YhMo5FiJcKD72aT@mail.gmail.com>
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
	<AANLkTim1qeexFiDEEXiub+zQHjiM8YhMo5FiJcKD72aT@mail.gmail.com>
Date: Thu, 21 Oct 2010 08:31:29 +0900
Message-ID: <AANLkTi=KK0VtvCKRa5JVhKcKEMbCB86EYxX+9U6vVJaz@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>, Jens Axboe <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 12:35 AM, Torsten Kaiser
<just.for.lkml@googlemail.com> wrote:
> On Wed, Oct 20, 2010 at 4:23 PM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:

< SNIP>

>> What is your problem?(Sorry if you explained it several time).
>
> The original problem was that using too many gcc's caused a swapstorm
> that completely hung my system.
> I first blame it one the workqueue changes in 2.6.36-rc1 and/or its
> interaction with XFS (because in -rc5 a workqueue related problem in
> XFS got fixed), but Tejun Heo found out that a) it were exhausted
> mempools and not the workqueues and that the problems itself existed
> at least in 2.6.35 already. In
> http://marc.info/?l=3Dlinux-raid&m=3D128699402805191&w=3D2 I have describ=
e a
> simpler testcase that I found after looking more closely into the
> mempools.
>
> Short story: swaping over RAID1 (drivers/md/raid1.c) can cause a
> system hang, because it is using too much of the fs_bio_set mempool
> from fs/bio.c.
>
>> I read the thread.
>> It seems Wu's patch solved deadlock problem by FS lock holding and too_m=
any_isolated.
>> What is the problem remained in your case? unusable system by swapstorm?
>> If it is, I think it's expected behavior. Please see the below comment.
>> (If I don't catch your point, Please explain your problem.)
>
> I do not have a problem, if the system becomes unusable *during* a
> swapstorm, but it should recover. That is not the case in my system.
> With Wu's too_many_isolated-patch and Neil's patch agains raid1.c the
> system does no longer seem to be completely stuck (a swapoutrate of
> ~80kb every 20 seconds still happens), but I would still expect a
> better recovery time. (At that rate the recovery would probably take a
> few days...)


I got understand your problem.
BTW, Wu's too_many_isolated patch should merge regardless of this problem.
It's another story.

>
>>> [ =A0437.481365] SysRq : Show Memory
>>> [ =A0437.490003] Mem-Info:
>>> [ =A0437.491357] Node 0 DMA per-cpu:
>>> [ =A0437.500032] CPU =A0 =A00: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>>> [ =A0437.500032] CPU =A0 =A01: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>>> [ =A0437.500032] CPU =A0 =A02: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>>> [ =A0437.500032] CPU =A0 =A03: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>>> [ =A0437.500032] Node 0 DMA32 per-cpu:
>>> [ =A0437.500032] CPU =A0 =A00: hi: =A0186, btch: =A031 usd: 138
>>> [ =A0437.500032] CPU =A0 =A01: hi: =A0186, btch: =A031 usd: =A030
>>> [ =A0437.500032] CPU =A0 =A02: hi: =A0186, btch: =A031 usd: =A0 0
>>> [ =A0437.500032] CPU =A0 =A03: hi: =A0186, btch: =A031 usd: =A0 0
>>> [ =A0437.500032] Node 1 DMA32 per-cpu:
>>> [ =A0437.500032] CPU =A0 =A00: hi: =A0186, btch: =A031 usd: =A0 0
>>> [ =A0437.500032] CPU =A0 =A01: hi: =A0186, btch: =A031 usd: =A0 0
>>> [ =A0437.500032] CPU =A0 =A02: hi: =A0186, btch: =A031 usd: =A0 0
>>> [ =A0437.500032] CPU =A0 =A03: hi: =A0186, btch: =A031 usd: =A0 0
>>> [ =A0437.500032] Node 1 Normal per-cpu:
>>> [ =A0437.500032] CPU =A0 =A00: hi: =A0186, btch: =A031 usd: =A0 0
>>> [ =A0437.500032] CPU =A0 =A01: hi: =A0186, btch: =A031 usd: =A0 0
>>> [ =A0437.500032] CPU =A0 =A02: hi: =A0186, btch: =A031 usd: =A025
>>> [ =A0437.500032] CPU =A0 =A03: hi: =A0186, btch: =A031 usd: =A030
>>> [ =A0437.500032] active_anon:2039 inactive_anon:985233 isolated_anon:68=
2
>>> [ =A0437.500032] =A0active_file:1667 inactive_file:1723 isolated_file:0
>>> [ =A0437.500032] =A0unevictable:0 dirty:0 writeback:25387 unstable:0
>>> [ =A0437.500032] =A0free:3471 slab_reclaimable:2840 slab_unreclaimable:=
6337
>>> [ =A0437.500032] =A0mapped:1284 shmem:960501 pagetables:523 bounce:0
>>> [ =A0437.500032] Node 0 DMA free:8008kB min:28kB low:32kB high:40kB
>>> active_anon:0kB inact
>>> ive_anon:7596kB active_file:12kB inactive_file:0kB unevictable:0kB
>>> isolated(anon):0kB i
>>> solated(file):0kB present:15768kB mlocked:0kB dirty:0kB
>>> writeback:404kB mapped:0kB shme
>>> m:7192kB slab_reclaimable:32kB slab_unreclaimable:304kB
>>> kernel_stack:0kB pagetables:0kB
>>> =A0unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:118
>>> all_unreclaimable? no
>>> [ =A0437.500032] lowmem_reserve[]: 0 2004 2004 2004
>>
>> Node 0 DMA : free 8008K but lowmem_reserve 8012K(2004 pages)
>> So page allocator can't allocate the page unless preferred zone is DMA
>>
>>> [ =A0437.500032] Node 0 DMA32 free:2980kB min:4036kB low:5044kB
>>> high:6052kB active_anon:2
>>> 844kB inactive_anon:1918424kB active_file:3428kB inactive_file:3780kB
>>> unevictable:0kB isolated(anon):1232kB isolated(file):0kB
>>> present:2052320kB mlocked:0kB dirty:0kB writeback:72016kB
>>> mapped:2232kB shmem:1847640kB slab_reclaimable:5444kB
>>> slab_unreclaimable:13508kB kernel_stack:744kB pagetables:864kB
>>> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
>>> all_unreclaimable? no
>>> [ =A0437.500032] lowmem_reserve[]: 0 0 0 0
>>
>> Node 0 DMA32 : free 2980K but min 4036K.
>> Few file LRU compare to anon LRU
>
> In the testcase I fill a tmpfs as fast as I can with data from
> /dev/zero. So nearly everything gets swapped out and only the last
> written data from the tmpfs fills all RAM. (I have 4GB RAM, the tmpfs
> is limited to 6GB, 16 dd's are writing into it)
>
>> Normally, it could fail to allocate the page.
>> 'Normal' means caller doesn't request alloc_pages with __GFP_HIGH or !__=
GFP_WAIT
>> Generally many call sites don't pass gfp_flag with __GFP_HIGH|!__GFP_WAI=
T.
>>
>>> [ =A0437.500032] Node 1 DMA32 free:2188kB min:3036kB low:3792kB
>>> high:4552kB active_anon:0kB inactive_anon:1555368kB active_file:0kB
>>> inactive_file:28kB unevictable:0kB isolated(anon):768kB
>>> isolated(file):0kB present:1544000kB mlocked:0kB dirty:0kB
>>> writeback:21160kB mapped:0kB shmem:1534960kB slab_reclaimable:3728kB
>>> slab_unreclaimable:7076kB kernel_stack:8kB pagetables:0kB unstable:0kB
>>> bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
>>> [ =A0437.500032] lowmem_reserve[]: 0 0 505 505
>>
>> Node 1 DMA32 free : 2188K min 3036K
>> It's a same situation with Node 0 DMA32.
>> Normally, it could fail to allocate the page.
>> Few file LRU compare to anon LRU
>>
>>
>>> [ =A0437.500032] Node 1 Normal free:708kB min:1016kB low:1268kB
>>> high:1524kB active_anon:5312kB inactive_anon:459544kB
>>> active_file:3228kB inactive_file:3084kB unevictable:0kB
>>> isolated(anon):728kB isolated(file):0kB present:517120kB mlocked:0kB
>>> dirty:0kB writeback:7968kB mapped:2904kB shmem:452212kB
>>> slab_reclaimable:2156kB slab_unreclaimable:4460kB kernel_stack:200kB
>>> pagetables:1228kB unstable:0kB bounce:0kB writeback_tmp:0kB
>>> pages_scanned:9678 all_unreclaimable? no
>>> [ =A0437.500032] lowmem_reserve[]: 0 0 0 0
>>
>> Node 1 Normal : free 708K min 1016K
>> Normally, it could fail to allocate the page.
>> Few file LRU compare to anon LRU
>>
>>> [ =A0437.500032] Node 0 DMA: 2*4kB 2*8kB 1*16kB 3*32kB 3*64kB 4*128kB
>>> 4*256kB 2*512kB 1*1024kB 2*2048kB 0*4096kB =3D 8008kB
>>> [ =A0437.500032] Node 0 DMA32: 27*4kB 15*8kB 8*16kB 8*32kB 7*64kB
>>> 1*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB =3D 2980kB
>>> [ =A0437.500032] Node 1 DMA32: 1*4kB 6*8kB 3*16kB 1*32kB 0*64kB 1*128kB
>>> 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB =3D 2308kB
>>> [ =A0437.500032] Node 1 Normal: 39*4kB 13*8kB 10*16kB 3*32kB 1*64kB
>>> 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 708kB
>>> [ =A0437.500032] 989289 total pagecache pages
>>> [ =A0437.500032] 25398 pages in swap cache
>>> [ =A0437.500032] Swap cache stats: add 859204, delete 833806, find 28/3=
9
>>> [ =A0437.500032] Free swap =A0=3D 9865628kB
>>> [ =A0437.500032] Total swap =3D 10000316kB
>>> [ =A0437.500032] 1048575 pages RAM
>>> [ =A0437.500032] 33809 pages reserved
>>> [ =A0437.500032] 7996 pages shared
>>> [ =A0437.500032] 1008521 pages non-shared
>>>
>> All zones don't have enough pages and don't have enough file lru pages.
>> So swapout is expected behavior, I think.
>> It means your workload exceeds your system available DRAM size.
>
> Yes, as intended. I wanted to create many writes to a RAID1 device
> under memory pressure to show/verify that the current use of mempools
> in raid1.c is buggered.
>
> That is not really any sane workload, that literally is just there to
> create a swapstorm and then see if the system survives it.
>
> The problem is, that the system is not surviving it: bio allocations
> fail in raid1.c and it falls back to the fs_bio_set mempool. But that
> mempool is only 2 entries big, because you should ever only use one of
> its entries at a time. But the current mainline code from raid1.c
> allocates one bio per drive before submitting it -> That bug is fixed
> my Neil's patch and I would have expected that to fix my hang. But it
> seems that there is an additional problem so that mempool still get
> emptied. And that means that no writeback happens any longer and so
> the kernel can't swapout and gets stuck.

That's what I missed that why there are lots of writeback pages in log.
Thanks for kind explanation.

>
> I think the last mail from Jens Axboe is the correct answer, not
> increasing the fs_bio_set mempool size via BIO_POOL_SIZE.
>
> But should that go even further: Forbid any use of bio_alloc() and
> bio_clone() in any device drivers? Or at the very least in all device
> drivers that could be used for swapspace?

But like Jens pointed out, "So md and friends should really have a
pool per device, so that stacking will always work properly."
Shouldn't raid1.c have a pool for bio_set and use own bio_set like
setup_clone in dm.c?
Maybe I am wrong since I don't have a knowledge about RAID.

>
> Torsten
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
