Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 876396B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 09:35:43 -0400 (EDT)
Received: by gxk3 with SMTP id 3so5478237gxk.14
        for <linux-mm@kvack.org>; Sun, 28 Jun 2009 06:36:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com>
References: <3901.1245848839@redhat.com> <32411.1245336412@redhat.com>
	 <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com>
	 <20090618095729.d2f27896.akpm@linux-foundation.org>
	 <7561.1245768237@redhat.com> <26537.1246086769@redhat.com>
	 <20090627125412.GA1667@cmpxchg.org> <20090628113246.GA18409@localhost>
	 <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com>
Date: Sun, 28 Jun 2009 22:36:49 +0900
Message-ID: <28c262360906280636l93130ffk14086314e2a6dcb7@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 28, 2009 at 10:30 PM, Minchan Kim<minchan.kim@gmail.com> wrote:
> HI, Wu.
>
> On Sun, Jun 28, 2009 at 8:32 PM, Wu Fengguang<fengguang.wu@intel.com> wro=
te:
>> On Sat, Jun 27, 2009 at 08:54:12PM +0800, Johannes Weiner wrote:
>>> On Sat, Jun 27, 2009 at 08:12:49AM +0100, David Howells wrote:
>>> >
>>> > I've managed to bisect things to find the commit that causes the OOMs=
. =C2=A0It's:
>>> >
>>> > =C2=A0 =C2=A0 commit 69c854817566db82c362797b4a6521d0b00fe1d8
>>> > =C2=A0 =C2=A0 Author: MinChan Kim <minchan.kim@gmail.com>
>>> > =C2=A0 =C2=A0 Date: =C2=A0 Tue Jun 16 15:32:44 2009 -0700
>>> >
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 vmscan: prevent shrinking of active anon =
lru list in case of no swap space V3
>>> >
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 shrink_zone() can deactivate active anon =
pages even if we don't have a
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 swap device. =C2=A0Many embedded products=
 don't have a swap device. =C2=A0So the
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 deactivation of anon pages is unnecessary=
.
>>> >
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 This patch prevents unnecessary deactivat=
ion of anon lru pages. =C2=A0But, it
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 don't prevent aging of anon pages to swap=
 out.
>>> >
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 Signed-off-by: Minchan Kim <minchan.kim@g=
mail.com>
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 Acked-by: KOSAKI Motohiro <kosaki.motohir=
o@jp.fujitsu.com>
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 Acked-by: Rik van Riel <riel@redhat.com>
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 Signed-off-by: Andrew Morton <akpm@linux-=
foundation.org>
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 Signed-off-by: Linus Torvalds <torvalds@l=
inux-foundation.org>
>>> >
>>> > This exhibits the problem. =C2=A0The previous commit:
>>> >
>>> > =C2=A0 =C2=A0 commit 35282a2de4e5e4e173ab61aa9d7015886021a821
>>> > =C2=A0 =C2=A0 Author: Brice Goglin <Brice.Goglin@ens-lyon.org>
>>> > =C2=A0 =C2=A0 Date: =C2=A0 Tue Jun 16 15:32:43 2009 -0700
>>> >
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 migration: only migrate_prep() once per m=
ove_pages()
>>> >
>>> > survives 16 iterations of the LTP syscall testsuite without exhibitin=
g the
>>> > problem.
>>>
>>> Here is the patch in question:
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index 7592d8e..879d034 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -1570,7 +1570,7 @@ static void shrink_zone(int priority, struct zone=
 *zone,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* Even if we did not try to evict anon pages=
 at all, we want to
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* rebalance the anon lru active/inactive rat=
io.
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>>> - =C2=A0 =C2=A0 if (inactive_anon_is_low(zone, sc))
>>> + =C2=A0 =C2=A0 if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0=
)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shrink_active_list(SWA=
P_CLUSTER_MAX, zone, sc, priority, 0);
>>>
>>> =C2=A0 =C2=A0 =C2=A0 throttle_vm_writeout(sc->gfp_mask);
>>>
>>> When this was discussed, I think we missed that nr_swap_pages can
>>> actually get zero on swap systems as well and this should have been
>>> total_swap_pages - otherwise we also stop balancing the two anon lists
>>> when swap is _full_ which was not the intention of this change at all.
>>
>> Exactly. In Jesse's OOM case, the swap is exhausted.
>> total_swap_pages is the better choice in this situation.
>>
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426766] Active_anon:290797 ac=
tive_file:28 inactive_anon:97034
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426767] =C2=A0inactive_file:6=
1 unevictable:11322 dirty:0 writeback:0 unstable:0
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426768] =C2=A0free:3341 slab:=
13776 mapped:5880 pagetables:6851 bounce:0
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426772] DMA free:7776kB min:4=
0kB low:48kB high:60kB active_anon:556kB inactive_anon:524kB
>> +active_file:16kB inactive_file:0kB unevictable:0kB present:15340kB page=
s_scanned:30 all_unreclaimable? no
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426775] lowmem_reserve[]: 0 1=
935 1935 1935
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426781] DMA32 free:5588kB min=
:5608kB low:7008kB high:8412kB active_anon:1162632kB
>> +inactive_anon:387612kB active_file:96kB inactive_file:256kB unevictable=
:45288kB present:1982128kB pages_scanned:980
>> +all_unreclaimable? no
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426784] lowmem_reserve[]: 0 0=
 0 0
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426787] DMA: 64*4kB 77*8kB 45=
*16kB 18*32kB 4*64kB 2*128kB 2*256kB 3*512kB 1*1024kB
>> +1*2048kB 0*4096kB =3D 7800kB
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426796] DMA32: 871*4kB 149*8k=
B 1*16kB 2*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB
>> +0*2048kB 0*4096kB =3D 5588kB
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426804] 151250 total pagecach=
e pages
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426806] 18973 pages in swap c=
ache
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426808] Swap cache stats: add=
 610640, delete 591667, find 144356/181468
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426810] Free swap =C2=A0=3D 0=
kB
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426811] Total swap =3D 979956=
kB
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434828] 507136 pages RAM
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434831] 23325 pages reserved
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434832] 190892 pages shared
>> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434833] 248816 pages non-shar=
ed
>>
>>
>> In David's OOM case, there are two symptoms:
>> 1) 70000 unaccounted/leaked pages as found by Andrew
>> =C2=A0 (plus rather big number of PG_buddy and pagetable pages)
>> 2) almost zero active_file/inactive_file; small inactive_anon;
>> =C2=A0 many slab and active_anon pages.
>>
>> In the situation of (2), the slab cache is _under_ scanned. So David
>> got OOM when vmscan should have squeezed some free pages from the slab
>> cache. Which is one important side effect of MinChan's patch?
>
> My patch's side effect is (2).
>
> My guessing is following as.
>
> 1. The number of page scanned in shrink_slab is increased in shrink_page_=
list.
> And it is doubled for mapped page or swapcache.
> 2. shrink_page_list is called by shrink_inactive_list
> 3. shrink_inactive_list is called by shrink_list
>
> Look at the shrink_list.
> If inactive lru list is low, it always call shrink_active_list not
> shrink_inactive_list in case of anon.

I missed most important point.
My patch's side effect is that it keeps inactive anon's lru low.
So I think it is caused by my patch's side effect.

> It means it doesn't increased sc->nr_scanned.
> Then shrink_slab can't shrink enough slab pages.
> So, David OOM have a lot of slab pages and active anon pages.
>
> Does it make sense ?
> If it make sense, we have to change shrink_slab's pressure method.
> What do you think ?
>
>
> --
> Kinds regards,
> Minchan Kim
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
