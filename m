Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97C1C6B0069
	for <linux-mm@kvack.org>; Sun,  2 Oct 2016 10:17:28 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id l13so197194227itl.0
        for <linux-mm@kvack.org>; Sun, 02 Oct 2016 07:17:28 -0700 (PDT)
Received: from nm13-vm4.bullet.mail.ne1.yahoo.com (nm13-vm4.bullet.mail.ne1.yahoo.com. [98.138.91.173])
        by mx.google.com with ESMTPS id i34si30739696iod.116.2016.10.02.07.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Oct 2016 07:17:27 -0700 (PDT)
Date: Sun, 2 Oct 2016 14:17:00 +0000 (UTC)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Message-ID: <677858900.4154177.1475417820204@mail.yahoo.com>
In-Reply-To: <d173cb394eb044af8a6d008a4e6af16e@POCITMSXMB04.LntUniverse.com>
References: <CGME20160910115611epcas5p27310a0c2f05290b5c3642f82c045554e@epcas5p2.samsung.com> <9250e22a60af484cbede7a1ba34ada5e@POCITMSXMB04.LntUniverse.com> <003e01d20cb2$a0a007c0$e1e01740$@samsung.com> <004c01d20cbc$b429a9e0$1c7cfda0$@samsung.com> <d173cb394eb044af8a6d008a4e6af16e@POCITMSXMB04.LntUniverse.com>
Subject: Re: Memory fragmentation issue related suggestion request
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankur Tank <Ankur.Tank@LntTechservices.com>, PINTU KUMAR <pintu.k@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "artfri2@gmail.com" <artfri2@gmail.com>

Hi Ankur,

Please find some of my comments below.

>________________________________
> From: Ankur Tank <Ankur.Tank@LntTechservices.com>
>To: PINTU KUMAR <pintu.k@samsung.com>; "linux-kernel@vger.kernel.org" <lin=
ux-kernel@vger.kernel.org>; "linux-mm@kvack.org" <linux-mm@kvack.org>=20
>Cc: "artfri2@gmail.com" <artfri2@gmail.com>
>Sent: Wednesday, 21 September 2016 3:17 PM
>Subject: RE: Memory fragmentation issue related suggestion request
>=20
>
>Hello Pintu Kumar,
>
>I tried registering Linux memory management mailing list and somehow I am =
not able to get through it. :(
>Meanwhile I try doing it, Just wanted ask you some information,
>
>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>TL;DR
>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>Different analysis points that we have memory fragmentation

>
For memory fragmentation issue, you need to keep checking /proc/buddyinfo a=
nd meminfo.
If the amount of memory requested in greater than meminfo (free) and still =
the allocation is failing, then its due to fragmentation.

>I was again going through below presentation given by you at ELC-2015.
>http://events.linuxfoundation.org/sites/events/files/slides/%5BELC-2015%5D=
-System-wide-Memory-Defragmenter.pdf
>

>1. We found the use case where its every single time reproducible, However=
 if we drop_caches, can compact_memory and run use case we don't see issue.

If drop_caches & compact_memory is working for you then its obviously fragm=
entation issue.
But as I know, drop_caches is meant only for debugging purpose. It may degr=
ade system performance if we use continuously.

>     So looks like we have some kind of memory shrinker what you talked ab=
out we can handle this issue.
>2. Is your kernel module already released ?

>3. If It is not released, we are thinking of implementing such module and =
continuously measure fragmentation and once it reaches a limit, shrink the =
memory, so that we don't end up in such situation.

About memory_shrinker interface, I have released a patch last year, but it =
was rejected.
If you are still interested, you can find here:
http://www.kernelhub.org/?p=3D2&msg=3D785290
But, this is just an interface. A place needs to be decided where it can be=
 invoked.
If you have disk-swap enabled, it can degrade the performance. But it works=
 best with ZRAM.
It is similar to drop_caches but may give better results if used appropriat=
ely.
Note that, the system already try to do shrink_memory internally several ti=
mes in the form of direct_reclaim but at times, the amount of memory it rec=
laims during LIVE allocation may not be sufficient or it becomes too late.

>    Do you have any suggestion/pointers apart from what you have mentioned=
 in above presentation?

>
1) If drop_caches are working, then ideally this should also work with prop=
er tuning.
   Explore: /proc/sys/vm/dirty_background_ratio/bytes=20

   Try tuning it with various values. I already talked about it before.

2) As I saw, you have large around of CMA free areas ( > 15MB). That means =
this amount of memory cannot be used for allocation even if it shown in sys=
tem free memory.
   Thus, if possible, try to disable CMA or reduce it to the least possible=
 value.
3) Instead of rootfs, just try "dd" command on your system with 500MB block=
 size. You might be seeing the same issue.
   Thus, I think the root cause is, on a <256MB RAM system, you are trying =
to load 500MB of disk space which may obviously cause problems at least som=
e times if not always.
   If possible, try to squeeze your rootfs to few 100s mega bytes and check=
 if it helps.
   If its a read-only partition, you can even try to use SQUASH_FS which ca=
n compress the data.

>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>Detailed Mail
>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>We found the use case where we could reproduce the error every time.
>Use case:
>a.       Create big rootfs containing 4k size files. Approximately 81000.
>b.       Mount spare RFS partition of size 500MB.
>c.       Untar big rootf.tar.gz onto mounted spare partition.
>d.       With this use case we could reproduce issue every single time.
>e.       I have attached the log where =E2=80=9CDetected aborted journal=
=E2=80=9D error is reproduced and just before that meminfo shows that 16KB =
memory block is not available. ( in while loop we were running echo m > /pr=
oc/sysrq-trigger )
>2.       We have tried following solutions so far
>a.       If we disable journal we are not seeing the issue, However during=
 untar if there is a power disconnect there are many file-system errors obs=
erved. (so we are not inclined to use this).

>b.       Even if we change /proc/sys/vm/min_free_kbytes value to 8192, iss=
ue is reproducible, if not in one round of untar, process second round of u=
ntar its reproducible.

You can try to by reducing free CMA areas and including tuning for dirty_ba=
ckground_ratio/bytes.
It should help.

>c.       If we keep dropping caches couple of time while untar is underway=
 we don=E2=80=99t see issue being reproduced.
>we used following commands for dropping caches and trigger memory compacti=
on
>To free pagecache:
>        echo 1 > /proc/sys/vm/drop_caches
>To free reclaimable slab objects (includes dentries and inodes):
>        echo 2 > /proc/sys/vm/drop_caches
>To free slab objects and pagecache:
>        echo 3 > /proc/sys/vm/drop_caches
>To compact memory
>echo 1 > /proc/sys/vm/compact_memory

>

If drop_caches help because you have large amount of memory available in th=
e form of caches because of heavy disk operations. Thus dropping caches at =
some interval followed by "sync" operation may help in keeping RAM free.
But, this is with the cost of system performance.

>
>Regarding questions you had asked previously,
>
>In addition, you may need to provide the following information:
>RAM size ?
>cat /proc/meminfo  (before and after the operation) cat /proc/buddyinfo (b=
efore and after the operation) cat /proc/vmstat (before and after the opera=
tion)
>
>1.  We have AM3352(running at 600Mhz) based custom board with 256MB RAM, 4=
GB of eMMC.
>2.  Attached Logs_21_sep_2016.tar which contains buddyinfo, pagetypeinfo &=
 vmstat before and after issue occurred.
>
>I am not sure, but I think this is the crude way of taking the backup.
>This will certainly overload your system.
>FOTA upgrade experts can give more comments here.
>3. Do you suggest any forum/mailing list for the same? I am searching on t=
his.
>
>Did you tried enabling CONFIG_COMPACTION ?
>Try using ZRAM or ZSWAP (~30% of MemTotal).
>Try tuning : /proc/sys/vm/dirty_{background_ratio/bytes} and others.
>[Refer kernel/documentation for the same]
>4.  Yes COMPACTION is enabled, I tried that. I had used software swap, I h=
ad created a swap file and used that as swap, I haven't tried ZRAM and ZSWA=
P as yet.
>5. Swappiness value from /proc/sys/vm/swappiness    is  60
>
>Is it : /proc/sys/vm/shrink_memory
>6. Yes, /proc/sys/vm/shrink_memory , I don't see it in my kernel, is it yo=
ur kernel module exporting to proc ?

>

Yes, this is my new interface that I proposed, but unfortunately it was rej=
ected.
It is not available in the mainline kernel.

>7. The log which I had copied didn't have swap enabled, I had tested it be=
fore.
>
>You have huge amount of memory sitting in caches. These can be reclaimed i=
n back ground (with slight performance degradation).
>To experiment and debug you can try: echo 3 > /proc/sys/vm/drop_caches
>
>8.  Yes dropping caches helps but how do we do it automatically rather tha=
n doing by writing to /proc/sys/vm/drop_caches ? (kernel module? )

>
It it is for experimental purpose, you can try invoking it from user space =
it in background with certain conditions.
Says, free memory is below some threshold but large memory available in buf=
fers/cached.
Do not try to do this in kernel.

>Thank you,
>
>Regards,
>Ankur
>
>-----Original Message-----
>From: PINTU KUMAR [mailto:pintu.k@samsung.com]
>Sent: Monday, September 12, 2016 11:43 AM
>To: Ankur Tank <Ankur.Tank@LntTechservices.com>; linux-kernel@vger.kernel.=
org; linux-mm@kvack.org
>Cc: artfri2@gmail.com; pintu.k@samsung.com
>Subject: RE: Memory fragmentation issue related suggestion request
>
>Dear Ankur,
>
>I would suggest you register to linux-mm@kvack.org and explain your issues=
 in details.
>There are other experts here, who can guide you.
>
>Few comments are inline below.
>
>> From: Ankur Tank [mailto:Ankur.Tank@LntTechservices.com]
>> Sent: Saturday, September 10, 2016 5:26 PM
>> To: pintu.k@samsung.com
>> Cc: artfri2@gmail.com
>> Subject: Memory fragmentation issue related suggestion request
>>
>> Hello Pintukumar,
>>
>> TL;DR
>> We have an issue in our Linux box, what looks like memory
>> fragmentation issue, while searching on net I referred talk you gave in =
Embedded Linux Conf.
>I have several talks in ELC, not sure which one you are referring to. Plea=
se point out.
>
>> I am facing this issue for couple of weeks so thought to ask you for sug=
gestions.
>> Please forgive me If I offended you by writing mail to you, Ignore mail =
if you feel so.
>>
>> Details
>> We are facing one issue in our Embedded Linux board, Our board is
>> Beaglebone black based custom board, with 4GB eMMC as storage. We are
>> using Linux kernel 3.12.
>In addition, you may need to provide the following information:
>RAM size ?
>cat /proc/meminfo  (before and after the operation) cat /proc/buddyinfo (b=
efore and after the operation) cat /proc/vmstat (before and after the opera=
tion)
>
>> Our firmware upgrade strategy is using backgup partition for
>> Bootloader, Kernel, dtb, rootfs.
>> So,
>> During firmware upgrade with big rootfs and running dd to read the
>> partition in raw mode.
>> In short looks like those operations are overloading the system.
>>
>I am not sure, but I think this is the crude way of taking the backup.
>This will certainly overload your system.
>FOTA upgrade experts can give more comments here.
>
>> From below log looks like pages above 32KB size is not available and
>> may be because of that rootfs tar on the emmc is failing.
>> I have following queries in that regards,
>>
>> 1.       Do you think it is a memory fragmentation ?
>Yes, if all above 32KB (2^3 order) pages are not available, and pages are =
available in lower orders (2^0/1/2) then its certainly fragmentation proble=
m.
>However, as I said, you need to provide the following output to confirm:
>cat /proc/buddyinfo
>
>> May be silly to ask so but just to confirm, because I had added the
>> software swap however with that also we were seeing issue reproducible
>> and swap was not full at that time =E2=98=B9
>>
>Well, adding swap should help a bit but it may not solve the problem compl=
etely.
>How much swap did you actually allocated?
>What kind of swap you used ?
>Is it ZRAM/ZSWAP (with compression support) ?
>What is the swappiness ratio ? (/proc/sys/vm/swappiness)
>
>> 2.       If it is so how do we handle it ? is there a some way similar t=
o your shrinker
>> utility to reclaim the memory pages ?
>>
>Not sure which shrinker utility are you referring to ?
>Is it : /proc/sys/vm/shrink_memory ?
>
>> Any suggestion would help me move forward,
>>
>Did you tried enabling CONFIG_COMPACTION ?
>Try using ZRAM or ZSWAP (~30% of MemTotal).
>Try tuning : /proc/sys/vm/dirty_{background_ratio/bytes} and others.
>[Refer kernel/documentation for the same]
>
>From the logs, I observed the following:
>> [ 6676.674219] mmcqd/1: page allocation failure: order:1,
>> mode:0x200020
>Order-1 allocation is failing, so pages might be sitting in order-0.
>> [ 6676.674739]  free_cma:1982
>You have around ~7MB of CMA free pages, so this cannot be used for non-mov=
able allocation.
>> [ 6676.674885] 51661 total pagecache pages
>You have huge amount of memory sitting in caches. These can be reclaimed i=
n back ground (with slight performance degradation).
>To experiment and debug you can try: echo 3 > /proc/sys/vm/drop_caches
>> [ 6676.674925] Total swap =3D 0kB
>Swap is not enabled on your system.
>
>
>> Regards,
>> Ankur
>>
>> Error log
>> ----------------------------
>>
>> [ 6676.674219] mmcqd/1: page allocation failure: order:1, mode:0x200020
>>    [ 6676.674256] CPU: 0 PID: 612 Comm: mmcqd/1 Tainted: P           O 3=
.12.10-005-
>> ts-armv7l #2
>>     [ 6676.674321] [<c0012d24>] (unwind_backtrace+0x0/0xf4) from
>> [<c0011130>]
>> (show_stack+0x10/0x14)
>>     [ 6676.674355] [<c0011130>] (show_stack+0x10/0x14) from
>> [<c0087548>]
>> (warn_alloc_failed+0xe0/0x118)
>>     [ 6676.674383] [<c0087548>] (warn_alloc_failed+0xe0/0x118) from
>> [<c008a3ac>]
>> (__alloc_pages_nodemask+0x74c/0x8f8)
>>     [ 6676.674413] [<c008a3ac>] (__alloc_pages_nodemask+0x74c/0x8f8)
>> from [<c00b2e8c>] (cache_alloc_refill+0x328/0x620)
>>     [ 6676.674436] [<c00b2e8c>] (cache_alloc_refill+0x328/0x620) from
>> [<c00b3224>] (__kmalloc+0xa0/0xe8)
>>     [ 6676.674471] [<c00b3224>] (__kmalloc+0xa0/0xe8) from
>> [<c0212904>]
>> (edma_prep_slave_sg+0x84/0x388)
>>     [ 6676.674505] [<c0212904>] (edma_prep_slave_sg+0x84/0x388) from
>> [<c02ec0a0>] (omap_hsmmc_request+0x414/0x508)
>>     [ 6676.674544] [<c02ec0a0>] (omap_hsmmc_request+0x414/0x508) from
>> [<c02d6748>] (mmc_start_request+0xc4/0xe0)
>>     [ 6676.674568] [<c02d6748>] (mmc_start_request+0xc4/0xe0) from
>> [<c02d7530>] (mmc_start_req+0x2d8/0x38c)
>>     [ 6676.674589] [<c02d7530>] (mmc_start_req+0x2d8/0x38c) from
>> [<c02e4818>]
>> (mmc_blk_issue_rw_rq+0xb4/0x9d8)
>>     [ 6676.674611] [<c02e4818>] (mmc_blk_issue_rw_rq+0xb4/0x9d8) from
>> [<c02e52e0>] (mmc_blk_issue_rq+0x1a4/0x468)
>>     [ 6676.674631] [<c02e52e0>] (mmc_blk_issue_rq+0x1a4/0x468) from
>> [<c02e5c68>] (mmc_queue_thread+0x88/0x118)
>>     [ 6676.674657] [<c02e5c68>] (mmc_queue_thread+0x88/0x118) from
>> [<c004d8b8>] (kthread+0xb4/0xb8)
>>     [ 6676.674681] [<c004d8b8>] (kthread+0xb4/0xb8) from [<c000e298>]
>> (ret_from_fork+0x14/0x3c)
>>     [ 6676.674691] Mem-info:
>>     [ 6676.674700] Normal per-cpu:
>>     [ 6676.674711] CPU    0: hi:   90, btch:  15 usd:  79
>>     [ 6676.674739] active_anon:4889 inactive_anon:13 isolated_anon:0
>>     [ 6676.674739]  active_file:8082 inactive_file:43196 isolated_file:0
>>     [ 6676.674739]  unevictable:422 dirty:2 writeback:1152 unstable:0
>>     [ 6676.674739]  free:3286 slab_reclaimable:1090 slab_unreclaimable:9=
15
>>     [ 6676.674739]  mapped:1593 shmem:39 pagetables:181 bounce:0
>>     [ 6676.674739]  free_cma:1982
>>     [ 6676.674800] Normal free:13144kB min:2004kB low:2504kB
>> high:3004kB active_anon:19556kB inactive_anon:52kB active_file:32328kB
>> inactive_file:172784kB unevictable:o
>>     [ 6676.674813] lowmem_reserve[]: 0 0 0
>>     [ 6676.674831] Normal: 2584*4kB (UMC) 217*8kB (C) 57*16kB (C)
>> 5*32kB (C) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB
>> 0*8192kB =3D 13144kB
>>     [ 6676.674885] 51661 total pagecache pages
>>     [ 6676.674900] 0 pages in swap cache
>>     [ 6676.674910] Swap cache stats: add 0, delete 0, find 0/0
>>     [ 6676.674918] Free swap  =3D 0kB
>>     [ 6676.674925] Total swap =3D 0kB
>>     [ 6676.674938] SLAB: Unable to allocate memory on node 0 (gfp=3D0x20=
)
>>     [ 6676.674949]   cache: kmalloc-8192, object size: 8192, order: 1
>>     [ 6676.674962]   node 0: slabs: 3/3, objs: 3/3, free: 0
>>     [ 6676.674984] omap_hsmmc 481d8000.mmc: prep_slave_sg() failed
>>     [ 6676.674997] omap_hsmmc 481d8000.mmc: MMC start dma failure
>>     [ 6676.676181] mmcblk0: unknown error -1 sending read/write
>> command, card status 0x900
>>     [ 6676.676300] end_request: I/O error, dev mmcblk0, sector 27648
>>     [ 6676.676318] Buffer I/O error on device mmcblk0p9, logical block 8=
96
>>     [ 6676.676329] lost page write due to I/O error on mmcblk0p9
>>     [ 6676.676401] end_request: I/O error, dev mmcblk0, sector 27656
>>     [ 6676.676415] Buffer I/O error on device mmcblk0p9, logical block 8=
97
>>     [ 6676.676425] lost page write due to I/O error on mmcblk0p9
>>     [ 6676.676450] end_request: I/O error, dev mmcblk0, sector 27664
>>     [ 6676.676461] Buffer I/O error on device mmcblk0p9, logical block 8=
98
>>     [ 6676.676471] lost page write due to I/O error on mmcblk0p9
>>     [ 6676.676494] end_request: I/O error, dev mmcblk0, sector 27672
>>     [ 6676.676505] Buffer I/O error on device mmcblk0p9, logical block 8=
99
>>     [ 6676.676515] lost page write due to I/O error on mmcblk0p9
>>     [ 6676.676537] end_request: I/O error, dev mmcblk0, sector 27680
>>     [ 6676.676548] Buffer I/O error on device mmcblk0p9, logical block 9=
00
>>     [ 6676.676558] lost page write due to I/O error on mmcblk0p9
>>     [ 6676.676580] end_request: I/O error, dev mmcblk0, sector 27688
>>     [ 6676.676591] Buffer I/O error on device mmcblk0p9, logical block 9=
01
>>     [ 6676.676601] lost page write due to I/O error on mmcblk0p9
>>     [ 6676.676622] end_request: I/O error, dev mmcblk0, sector 27696
>>     [ 6676.676634] Buffer I/O error on device mmcblk0p9, logical block 9=
02
>>     [ 6676.676643] lost page write due to I/O error on mmcblk0p9
>>     [ 6676.676665] end_request: I/O error, dev mmcblk0, sector 27704
>>     [ 6676.676676] Buffer I/O error on device mmcblk0p9, logical block 9=
03
>>     [ 6676.676685] lost page write due to I/O error on mmcblk0p9
>>     [ 6676.676707] end_request: I/O error, dev mmcblk0, sector 27712
>>     [ 6676.676718] Buffer I/O error on device mmcblk0p9, logical block 9=
04
>>     [ 6676.676728] lost page write due to I/O error on mmcblk0p9
>>     [ 6676.676749] end_request: I/O error, dev mmcblk0, sector 27720
>>     [ 6676.678266] mmcqd/1: page allocation failure: order:1, mode:0x200=
020
>>     [ 6676.678285] CPU: 0 PID: 612 Comm: mmcqd/1 Tainted: P           O =
3.12.10-005-
>> ts-armv7l #2
>>     [ 6676.678330] [<c0012d24>] (unwind_backtrace+0x0/0xf4) from
>> [<c0011130>]
>> (show_stack+0x10/0x14)
>>     [ 6676.678358] [<c0011130>] (show_stack+0x10/0x14) from
>> [<c0087548>]
>> (warn_alloc_failed+0xe0/0x118)
>>     [ 6676.678385] [<c0087548>] (warn_alloc_failed+0xe0/0x118) from
>> [<c008a3ac>]
>> (__alloc_pages_nodemask+0x74c/0x8f8)
>>     [ 6676.678412] [<c008a3ac>] (__alloc_pages_nodemask+0x74c/0x8f8)
>> from [<c00b2e8c>] (cache_alloc_refill+0x328/0x620)
>>     [ 6676.678434] [<c00b2e8c>] (cache_alloc_refill+0x328/0x620) from
>> [<c00b3224>] (__kmalloc+0xa0/0xe8)
>>     [ 6676.678464] [<c00b3224>] (__kmalloc+0xa0/0xe8) from
>> [<c0212904>]
>> (edma_prep_slave_sg+0x84/0x388)
>>     [ 6676.678493] [<c0212904>] (edma_prep_slave_sg+0x84/0x388) from
>> [<c02ec0a0>] (omap_hsmmc_request+0x414/0x508)
>>     [ 6676.678524] [<c02ec0a0>] (omap_hsmmc_request+0x414/0x508) from
>> [<c02d6748>] (mmc_start_request+0xc4/0xe0)
>>     [ 6676.678547] [<c02d6748>] (mmc_start_request+0xc4/0xe0) from
>> [<c02d7530>] (mmc_start_req+0x2d8/0x38c)
>>     [ 6676.678568] [<c02d7530>] (mmc_start_req+0x2d8/0x38c) from
>> [<c02e4994>]
>> (mmc_blk_issue_rw_rq+0x230/0x9d8)
>>     [ 6676.678589] [<c02e4994>] (mmc_blk_issue_rw_rq+0x230/0x9d8) from
>> [<c02e52e0>] (mmc_blk_issue_rq+0x1a4/0x468)
>>     [ 6676.678608] [<c02e52e0>] (mmc_blk_issue_rq+0x1a4/0x468) from
>> [<c02e5c68>] (mmc_queue_thread+0x88/0x118)
>>     [ 6676.678632] [<c02e5c68>] (mmc_queue_thread+0x88/0x118) from
>> [<c004d8b8>] (kthread+0xb4/0xb8)
>>     [ 6676.678655] [<c004d8b8>] (kthread+0xb4/0xb8) from [<c000e298>]
>> (ret_from_fork+0x14/0x3c)
>>     [ 6676.678664] Mem-info:
>>
>
>
>L&T Technology Services Ltd
>
>www.LntTechservices.com<http://www.lnttechservices.com/>
>
>This Email may contain confidential or privileged information for the inte=
nded recipient (s). If you are not the intended recipient, please do not us=
e or disseminate the information, notify the sender and delete it from your=
 system.
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
