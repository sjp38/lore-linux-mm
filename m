Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E77856B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 06:18:15 -0400 (EDT)
Received: by yxe14 with SMTP id 14so5566355yxe.12
        for <linux-mm@kvack.org>; Wed, 19 Aug 2009 03:18:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090819114408.ab9c8a78.minchan.kim@barrios-desktop>
References: <18eba5a10908181841t145e4db1wc2daf90f7337aa6e@mail.gmail.com>
	 <20090819114408.ab9c8a78.minchan.kim@barrios-desktop>
Date: Wed, 19 Aug 2009 19:18:19 +0900
Message-ID: <28c262360908190318i3a9f3915g2366679ae89809aa@mail.gmail.com>
Subject: Re: abnormal OOM killer message
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?7Jqw7Lap6riw?= <chungki.woo@gmail.com>, Nitin Gupta <ngupta@vflare.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, riel@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 11:44 AM, Minchan Kim<minchan.kim@gmail.com> wrote:
> On Wed, 19 Aug 2009 10:41:51 +0900
> =EC=9A=B0=EC=B6=A9=EA=B8=B0 <chungki.woo@gmail.com> wrote:
>
>> Hi all~
>> I have got a log message with OOM below. I don't know why this
>> phenomenon was happened.
>> When direct reclaim routine(try_to_free_pages) in __alloc_pages which
>> allocates kernel memory was failed,
>> one last chance is given to allocate memory before OOM routine is execut=
ed.
>> And that time, allocator uses ALLOC_WMARK_HIGH to limit watermark.
>> Then, zone_watermark_ok function test this value with current memory
>> state and decide 'can allocate' or 'cannot allocate'.
>>
>> Here is some kernel source code in __alloc_pages function to understand =
easily.
>> Kernel version is 2.6.18 for arm11. Memory size is 32Mbyte. And I use
>> compcache(0.5.2).
>> ------------------------------------------------------------------------=
---------------------------------------------------------------------------=
----------
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ...
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 did_some_progress =3D try_to_free_pages(zone=
list->zones,
>> gfp_mask); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0<=3D=3D direct page =
reclaim
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 p->reclaim_state =3D NULL;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 p->flags &=3D ~PF_MEMALLOC;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 cond_resched();
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(did_some_progress)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D get_pag=
e_from_freelist(gfp_mask, order,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 zonelist, alloc_flags);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 goto got_pg;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else if ((gfp_mask & __GFP_FS) && !(gfp_ma=
sk &
>> __GFP_NORETRY)) { =C2=A0 =C2=A0<=3D=3D when fail to reclaim
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Go throu=
gh the zonelist yet one more time, keep
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* very hig=
h watermark here, this is only to catch
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* a parall=
el oom killing, we must fail if we're still
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* under he=
avy pressure.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D get_pag=
e_from_freelist(gfp_mask|__GFP_HARDWALL,
>> order, =C2=A0<=3D=3D this is last chance
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zonelist,
>> ALLOC_WMARK_HIGH|ALLOC_CPUSET); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 <=3D=3D uses
>> ALLOC_WMARK_HIGH
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 goto got_pg;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 out_of_memory(zo=
nelist, gfp_mask, order);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto restart;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ...
>> ------------------------------------------------------------------------=
---------------------------------------------------------------------------=
----------
>>
>> In my case, you can see free pages(6804KB) is much more higher than
>> high watermark value(1084KB) in OOM message.
>> And order of allocating is also zero.(order=3D0)
>> In buddy system, the number of 4kbyte page is 867.
>> So, I think OOM can't be happend.
>>
>
> Yes. I think so.
>
> In that case, even we can also avoid zone defensive algorithm.
>
>> How do you think about this?
>> Is this side effect of compcache?
>
> I don't know compcache well.
> But I doubt it. Let's Cced Nitin.
>
>> Please explain me.
>> Thanks.
>>
>> This is OOM message.
>> ------------------------------------------------------------------------=
---------------------------------------------------------------------------=
----------
>> oom-killer: gfp_mask=3D0x201d2, order=3D0 =C2=A0 =C2=A0 =C2=A0 (=3D=3D> =
__GFP_HIGHMEM,
>> __GFP_WAIT, __GFP_IO, __GFP_FS, __GFP_COLD)
>> [<c00246c0>] (dump_stack+0x0/0x14) from [<c006ba68>] (out_of_memory+0x38=
/0x1d0)
>> [<c006ba30>] (out_of_memory+0x0/0x1d0) from [<c006d4cc>]
>> (__alloc_pages+0x244/0x2c4)
>> [<c006d288>] (__alloc_pages+0x0/0x2c4) from [<c006f054>]
>> (__do_page_cache_readahead+0x12c/0x2d4)
>> [<c006ef28>] (__do_page_cache_readahead+0x0/0x2d4) from [<c006f594>]
>> (do_page_cache_readahead+0x60/0x64)
>> [<c006f534>] (do_page_cache_readahead+0x0/0x64) from [<c006ac24>]
>> (filemap_nopage+0x1b4/0x438)
>> =C2=A0r7 =3D C0D8C320 =C2=A0r6 =3D C1422000 =C2=A0r5 =3D 00000001 =C2=A0=
r4 =3D 00000000
>> [<c006aa70>] (filemap_nopage+0x0/0x438) from [<c0075684>]
>> (__handle_mm_fault+0x398/0xb84)
>> [<c00752ec>] (__handle_mm_fault+0x0/0xb84) from [<c0027614>]
>> (do_page_fault+0xe8/0x224)
>> [<c002752c>] (do_page_fault+0x0/0x224) from [<c0027900>]
>> (do_DataAbort+0x3c/0xa0)
>> [<c00278c4>] (do_DataAbort+0x0/0xa0) from [<c001fde0>]
>> (ret_from_exception+0x0/0x10)
>> =C2=A0r8 =3D BE9894B8 =C2=A0r7 =3D 00000078 =C2=A0r6 =3D 00000130 =C2=A0=
r5 =3D 00000000
>> =C2=A0r4 =3D FFFFFFFF
>> Mem-info:
>> DMA per-cpu:
>> cpu 0 hot: high 6, batch 1 used:0
>> cpu 0 cold: high 2, batch 1 used:1
>> DMA32 per-cpu: empty
>> Normal per-cpu: empty
>> HighMem per-cpu: empty
>> Free pages: =C2=A0 =C2=A0 =C2=A0 =C2=A06804kB (0kB HighMem)
>> Active:101 inactive:1527 dirty:0 writeback:0 unstable:0 free:1701
>> slab:936 mapped:972 pagetables:379
>> DMA free:6804kB min:724kB low:904kB high:1084kB active:404kB
>> inactive:6108kB present:32768kB pages_scanned:0 all_unreclaimable? no
>> lowmem_reserve[]: 0 0 0 0
>> DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB
>> present:0kB pages_scanned:0 all_unreclaimable? no
>> lowmem_reserve[]: 0 0 0 0
>> Normal free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB
>> present:0kB pages_scanned:0 all_unreclaimable? no
>> lowmem_reserve[]: 0 0 0 0
>> HighMem free:0kB min:128kB low:128kB high:128kB active:0kB
>> inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
>> lowmem_reserve[]: 0 0 0 0
>> DMA: 867*4kB 273*8kB 36*16kB 2*32kB 0*64kB 0*128kB 0*256kB 1*512kB
>> 0*1024kB 0*2048kB 0*4096kB =3D 6804kB
>> DMA32: empty
>> Normal: empty
>> HighMem: empty
>> Swap cache: add 4597, delete 4488, find 159/299, race 0+0
>> Free swap =C2=A0=3D 67480kB
>> Total swap =3D 81916kB
>
> In addition, total swap : 79M??
>
>> Free swap: =C2=A0 =C2=A0 =C2=A0 =C2=A067480kB
>> 8192 pages of RAM
>> 1960 free pages
>> 978 reserved pages
>> 936 slab pages
>> 1201 pages shared
>> 109 pages swap cached
>
> free page : 6M
> page table + slab + reserved : 8M
> active + inacive : 6M
>
> Where is 12M?
>
>> Out of Memory: Kill process 47 (rc.local) score 849737 and children.
>> Out of memory: Killed process 49 (CTaskManager).
>> Killed
>> SW image is stopped..
>> script in BOOT is stopped...
>> Starting pid 348, console /dev/ttyS1: '/bin/sh'
>> -sh: id: not found
>> #
>> ------------------------------------------------------------------------=
---------------------------------------------------------------------------=
----------
>
> As you mentioned, your memory size is 32M and you use compcache.
> How is swap size bigger than your memory size ?
> Is the result of compression of swap pages ?
> Nitin. Could you answer the question?
>
> I can't imagine whey order 0 allocation failed although there are
> many pages in buddy.
>
> What do you mm guys think about this problem ?

I can only think that zonelists set up wrongly or freelist got damaged.
Could you print your zonelist about __GFP_HIGHMEM ?

> --
> Kind regards,
> Minchan Kim
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
