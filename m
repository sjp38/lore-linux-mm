Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 82E986B01F3
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 01:19:43 -0400 (EDT)
Received: from az10vts04.mot.com (il27vts04.cig.mot.com [10.17.196.88])
	by mdgate2.corp.mot.com (8.14.3/8.14.3) with SMTP id o325JWBQ012580
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 23:19:32 -0600 (MDT)
Received: from mail-gx0-f217.google.com (mail-gx0-f217.google.com [209.85.217.217])
	by mdgate2.corp.mot.com (8.14.3/8.14.3) with ESMTP id o325JDvu012529
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 23:19:31 -0600 (MDT)
Received: by mail-gx0-f217.google.com with SMTP id 9so1508503gxk.8
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 22:19:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100402135955.645F.A69D9226@jp.fujitsu.com>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
	 <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
	 <20100402135955.645F.A69D9226@jp.fujitsu.com>
Date: Fri, 2 Apr 2010 13:19:40 +0800
Message-ID: <o2n5f4a33681004012219ra05a9e99p315a1b62dfc18c3b@mail.gmail.com>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding page->lru?
From: TAO HU <tghk48@motorola.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: TAO HU <taohu@motorola.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org, Mel Gorman <mel@csn.ul.ie>, arve@android.com
List-ID: <linux-mm.kvack.org>

Hi, KOSAKI Motohiro

I'm glad to know your're considering patch "mm: Check if any ..."
though it is not my original purpose :)

cc: Arve Hj=F8nnev=E5g who is the author


On Fri, Apr 2, 2010 at 1:03 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Cc to Mel,
>
>> 2 patches related to page_alloc.c were applied.
>> Does anyone see a connection between the 2 patches and the panic?
>> NOTE: the full patches are attached.
>
> I think your attached two patches are perfectly unrelated your problem.
>
> "mm: Add min_free_order_shift tunable." seems makes zero sense. I don't t=
hink this patch
> need to be merge.
>
> but "mm: Check if any page in a pageblock is reserved before marking it M=
IGRATE_RESERVE"
> treat strange hardware correctly, I think. If Mel ack this, I hope merge =
it.
> Mel, Can we hear your opinion?
>
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a596bfd..34a29e2 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2551,6 +2551,20 @@ static inline unsigned long
>> wait_table_bits(unsigned long size)
>> =A0#define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
>>
>> =A0/*
>> + * Check if a pageblock contains reserved pages
>> + */
>> +static int pageblock_is_reserved(unsigned long start_pfn)
>> +{
>> + =A0 =A0 unsigned long end_pfn =3D start_pfn + pageblock_nr_pages;
>> + =A0 =A0 unsigned long pfn;
>> +
>> + =A0 =A0 for (pfn =3D start_pfn; pfn < end_pfn; pfn++)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (PageReserved(pfn_to_page(pfn)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 return 0;
>> +}
>> +
>> +/*
>> =A0 * Mark a number of pageblocks as MIGRATE_RESERVE. The number
>> =A0 * of blocks reserved is based on zone->pages_min. The memory within =
the
>> =A0 * reserve will tend to store contiguous free pages. Setting min_free=
_kbytes
>> @@ -2579,7 +2593,7 @@ static void setup_zone_migrate_reserve(struct zone=
 *zone)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Blocks with reserved pages will never fre=
e, skip them. */
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (PageReserved(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pageblock_is_reserved(pfn))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 block_migratetype =3D get_pageblock_migratet=
ype(page);
>> --
>> 1.5.4.3
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 5c44ed4..a596bfd 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -119,6 +119,7 @@ static char * const zone_names[MAX_NR_ZONES] =3D {
>> =A0};
>>
>> =A0int min_free_kbytes =3D 1024;
>> +int min_free_order_shift =3D 1;
>>
>> =A0unsigned long __meminitdata nr_kernel_pages;
>> =A0unsigned long __meminitdata nr_all_pages;
>> @@ -1256,7 +1257,7 @@ int zone_watermark_ok(struct zone *z, int order,
>> unsigned long mark,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_pages -=3D z->free_area[o].nr_free << o=
;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Require fewer higher order pages to be fr=
ee */
>> - =A0 =A0 =A0 =A0 =A0 =A0 min >>=3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 min >>=3D min_free_order_shift;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (free_pages <=3D min)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> --
>>
>>
>> On Thu, Apr 1, 2010 at 12:05 PM, TAO HU <tghk48@motorola.com> wrote:
>> > Hi, all
>> >
>> > We got a panic on our ARM (OMAP) based HW.
>> > Our code is based on 2.6.29 kernel (last commit for mm/page_alloc.c is
>> > cc2559bccc72767cb446f79b071d96c30c26439b)
>> >
>> > It appears to crash while going through pcp->list in
>> > buffered_rmqueue() of mm/page_alloc.c after checking vmlinux.
>> > "00100100" implies LIST_POISON1 that suggests a race condition between
>> > list_add() and list_del() in my personal view.
>> > However we not yet figure out locking problem regarding page.lru.
>> >
>> > Any known issues about race condition in mm/page_alloc.c?
>> > And other hints are highly appreciated.
>> >
>> > =A0/* Find a page of the appropriate migrate type */
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cold) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ... ...
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_for_each_entry(pag=
e, &pcp->list, lru)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (pag=
e_private(page) =3D=3D migratetype)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0break;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> >
>> > <1>[120898.805267] Unable to handle kernel paging request at virtual
>> > address 00100100
>> > <1>[120898.805633] pgd =3D c1560000
>> > <1>[120898.805786] [00100100] *pgd=3D897b3031, *pte=3D00000000, *ppte=
=3D00000000
>> > <4>[120898.806457] Internal error: Oops: 17 [#1] PREEMPT
>> > ... ...
>> > <4>[120898.807861] CPU: 0 =A0 =A0Not tainted =A0(2.6.29-omap1 #1)
>> > <4>[120898.808044] PC is at get_page_from_freelist+0x1d0/0x4b0
>> > <4>[120898.808227] LR is at get_page_from_freelist+0xc8/0x4b0
>> > <4>[120898.808563] pc : [<c00a600c>] =A0 =A0lr : [<c00a5f04>] =A0 =A0p=
sr: 800000d3
>> > <4>[120898.808563] sp : c49fbd18 =A0ip : 00000000 =A0fp : c49fbd74
>> > <4>[120898.809020] r10: 00000000 =A0r9 : 001000e8 =A0r8 : 00000002
>> > <4>[120898.809204] r7 : 001200d2 =A0r6 : 60000053 =A0r5 : c0507c4c =A0=
r4 : c49fa000
>> > <4>[120898.809509] r3 : 001000e8 =A0r2 : 00100100 =A0r1 : c0507c6c =A0=
r0 : 00000001
>> > <4>[120898.809844] Flags: Nzcv =A0IRQs off =A0FIQs off =A0Mode SVC_32 =
=A0ISA
>> > ARM =A0Segment kernel
>> > <4>[120898.810028] Control: 10c5387d =A0Table: 82160019 =A0DAC: 000000=
17
>> > <4>[120898.948425] Backtrace:
>> > <4>[120898.948760] [<c00a5e3c>] (get_page_from_freelist+0x0/0x4b0)
>> > from [<c00a6398>] (__alloc_pages_internal+0xac/0x3e8)
>> > <4>[120898.949554] [<c00a62ec>] (__alloc_pages_internal+0x0/0x3e8)
>> > from [<c00b461c>] (handle_mm_fault+0x16c/0xbac)
>> > <4>[120898.950347] [<c00b44b0>] (handle_mm_fault+0x0/0xbac) from
>> > [<c00b51d0>] (__get_user_pages+0x174/0x2b4)
>> > <4>[120898.951019] [<c00b505c>] (__get_user_pages+0x0/0x2b4) from
>> > [<c00b534c>] (get_user_pages+0x3c/0x44)
>> > <4>[120898.951812] [<c00b5310>] (get_user_pages+0x0/0x44) from
>> > [<c00caf9c>] (get_arg_page+0x50/0xa4)
>> > <4>[120898.952636] [<c00caf4c>] (get_arg_page+0x0/0xa4) from
>> > [<c00cb1ec>] (copy_strings+0x108/0x210)
>> > <4>[120898.953430] =A0r7:beffffe4 r6:00000ffc r5:00000000 r4:00000018
>> > <4>[120898.954223] [<c00cb0e4>] (copy_strings+0x0/0x210) from
>> > [<c00cb330>] (copy_strings_kernel+0x3c/0x74)
>> > <4>[120898.955047] [<c00cb2f4>] (copy_strings_kernel+0x0/0x74) from
>> > [<c00cc778>] (do_execve+0x18c/0x2b0)
>> > <4>[120898.955841] =A0r5:0001e240 r4:0001e224
>> > <4>[120898.956329] [<c00cc5ec>] (do_execve+0x0/0x2b0) from
>> > [<c00400e4>] (sys_execve+0x3c/0x5c)
>> > <4>[120898.957153] [<c00400a8>] (sys_execve+0x0/0x5c) from
>> > [<c003ce80>] (ret_fast_syscall+0x0/0x2c)
>> > <4>[120898.957946] =A0r7:0000000b r6:0001e270 r5:00000000 r4:0001d580
>> > <4>[120898.958740] Code: e1530008 0a000006 e2429018 e1a03009 (e5b32018=
)
>> >
>> >
>> >
>> > --
>> > Best Regards
>> > Hu Tao
>> >
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
