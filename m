Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3889C6B005A
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 12:48:43 -0400 (EDT)
Received: by gxk3 with SMTP id 3so5627867gxk.14
        for <linux-mm@kvack.org>; Sun, 28 Jun 2009 09:50:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090628151026.GB25076@localhost>
References: <2015.1245341938@redhat.com> <7561.1245768237@redhat.com>
	 <26537.1246086769@redhat.com> <20090627125412.GA1667@cmpxchg.org>
	 <20090628113246.GA18409@localhost>
	 <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com>
	 <28c262360906280636l93130ffk14086314e2a6dcb7@mail.gmail.com>
	 <20090628142239.GA20986@localhost>
	 <2f11576a0906280801w417d1b9fpe10585b7a641d41b@mail.gmail.com>
	 <20090628151026.GB25076@localhost>
Date: Mon, 29 Jun 2009 01:50:14 +0900
Message-ID: <28c262360906280950i2f3924afgf75f80b285981c7@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

Looks good.

David, Can you test with this patch ?

On Mon, Jun 29, 2009 at 12:10 AM, Wu Fengguang<fengguang.wu@intel.com> wrot=
e:
> On Sun, Jun 28, 2009 at 11:01:40PM +0800, KOSAKI Motohiro wrote:
>> > Yes, smaller inactive_anon means smaller (pointless) nr_scanned,
>> > and therefore less slab scans. Strictly speaking, it's not the fault
>> > of your patch. It indicates that the slab scan ratio algorithm should
>> > be updated too :)
>>
>> I don't think this patch is related to minchan's patch.
>> but I think this patch is good.
>
> OK.
>
>>
>> > We could refine the estimation of "reclaimable" pages like this:
>>
>> hmhm, reasonable idea.
>
> Thank you.
>
>> >
>> > diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
>> > index 416f748..e9c5b0e 100644
>> > --- a/include/linux/vmstat.h
>> > +++ b/include/linux/vmstat.h
>> > @@ -167,14 +167,7 @@ static inline unsigned long zone_page_state(struc=
t zone *zone,
>> > =C2=A0}
>> >
>> > =C2=A0extern unsigned long global_lru_pages(void);
>> > -
>> > -static inline unsigned long zone_lru_pages(struct zone *zone)
>> > -{
>> > - =C2=A0 =C2=A0 =C2=A0 return (zone_page_state(zone, NR_ACTIVE_ANON)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + zone_page_state(z=
one, NR_ACTIVE_FILE)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + zone_page_state(z=
one, NR_INACTIVE_ANON)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + zone_page_state(z=
one, NR_INACTIVE_FILE));
>> > -}
>> > +extern unsigned long zone_lru_pages(void);
>> >
>> > =C2=A0#ifdef CONFIG_NUMA
>> > =C2=A0/*
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 026f452..4281c6f 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -2123,10 +2123,31 @@ void wakeup_kswapd(struct zone *zone, int orde=
r)
>> >
>> > =C2=A0unsigned long global_lru_pages(void)
>> > =C2=A0{
>> > - =C2=A0 =C2=A0 =C2=A0 return global_page_state(NR_ACTIVE_ANON)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + global_page_state=
(NR_ACTIVE_FILE)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + global_page_state=
(NR_INACTIVE_ANON)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + global_page_state=
(NR_INACTIVE_FILE);
>> > + =C2=A0 =C2=A0 =C2=A0 int nr;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 nr =3D global_page_state(zone, NR_ACTIVE_FILE) =
+
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(zone, NR_=
INACTIVE_FILE);
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 if (total_swap_pages)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr +=3D global_page=
_state(zone, NR_ACTIVE_ANON) +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 global_page_state(zone, NR_INACTIVE_ANON);
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 return nr;
>> > +}
>>
>> Please change function name too.
>> Now, this function only account reclaimable pages.
>
> Good suggestion - I did considered renaming them to *_relaimable_pages.
>
>> Plus, total_swap_pages is bad. if we need to concern "reclaimable
>> pages", we should use nr_swap_pages.
>
>> I mean, swap-full also makes anon is unreclaimable althouth system
>> have sone swap device.
>
> Right, changed to (nr_swap_pages > 0).
>
> Thanks,
> Fengguang
> ---
>
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 416f748..8d8aa20 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -166,15 +166,8 @@ static inline unsigned long zone_page_state(struct z=
one *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return x;
> =C2=A0}
>
> -extern unsigned long global_lru_pages(void);
> -
> -static inline unsigned long zone_lru_pages(struct zone *zone)
> -{
> - =C2=A0 =C2=A0 =C2=A0 return (zone_page_state(zone, NR_ACTIVE_ANON)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + zone_page_state(zone=
, NR_ACTIVE_FILE)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + zone_page_state(zone=
, NR_INACTIVE_ANON)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + zone_page_state(zone=
, NR_INACTIVE_FILE));
> -}
> +extern unsigned long global_reclaimable_pages(void);
> +extern unsigned long zone_reclaimable_pages(void);
>
> =C2=A0#ifdef CONFIG_NUMA
> =C2=A0/*
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index a91b870..74c3067 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -394,7 +394,8 @@ static unsigned long highmem_dirtyable_memory(unsigne=
d long total)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *z =3D
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 x +=3D zone_page_state=
(z, NR_FREE_PAGES) + zone_lru_pages(z);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 x +=3D zone_page_state=
(z, NR_FREE_PAGES) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zo=
ne_reclaimable_pages(z);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Make sure that the number of highmem pages =
is never larger
> @@ -418,7 +419,7 @@ unsigned long determine_dirtyable_memory(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long x;
>
> - =C2=A0 =C2=A0 =C2=A0 x =3D global_page_state(NR_FREE_PAGES) + global_lr=
u_pages();
> + =C2=A0 =C2=A0 =C2=A0 x =3D global_page_state(NR_FREE_PAGES) + global_re=
claimable_pages();
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!vm_highmem_is_dirtyable)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0x -=3D highmem_dir=
tyable_memory(x);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 026f452..3768332 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1693,7 +1693,7 @@ static unsigned long do_try_to_free_pages(struct zo=
nelist *zonelist,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 lru_pages +=3D zone_lru_pages(zone);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 lru_pages +=3D zone_reclaimable_pages(zone);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -1910,7 +1910,7 @@ loop_again:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i <=
=3D end_zone; i++) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0struct zone *zone =3D pgdat->node_zones + i;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 lru_pages +=3D zone_lru_pages(zone);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 lru_pages +=3D zone_reclaimable_pages(zone);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> @@ -1954,7 +1954,7 @@ loop_again:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (zone_is_all_unreclaimable(zone))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (nr_slab =3D=3D 0 && zone->pages_scanned >=3D
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 (zone_lru_pages(zone) * 6))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (zone_reclai=
mable_pages(zone) * 6))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_set_=
flag(zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ZONE_ALL_UNRECLAIMABLE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/*
> @@ -2121,12 +2121,33 @@ void wakeup_kswapd(struct zone *zone, int order)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0wake_up_interruptible(&pgdat->kswapd_wait);
> =C2=A0}
>
> -unsigned long global_lru_pages(void)
> +unsigned long global_reclaimable_pages(void)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 return global_page_state(NR_ACTIVE_ANON)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + global_page_state(NR=
_ACTIVE_FILE)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + global_page_state(NR=
_INACTIVE_ANON)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + global_page_state(NR=
_INACTIVE_FILE);
> + =C2=A0 =C2=A0 =C2=A0 int nr;
> +
> + =C2=A0 =C2=A0 =C2=A0 nr =3D global_page_state(zone, NR_ACTIVE_FILE) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(zone, NR_INA=
CTIVE_FILE);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (total_swap_pages)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr +=3D global_page_st=
ate(zone, NR_ACTIVE_ANON) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 g=
lobal_page_state(zone, NR_INACTIVE_ANON);
> +
> + =C2=A0 =C2=A0 =C2=A0 return nr;
> +}
> +
> +
> +unsigned long zone_reclaimable_pages(struct zone *zone)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int nr;
> +
> + =C2=A0 =C2=A0 =C2=A0 nr =3D zone_page_state(zone, NR_ACTIVE_FILE) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_page_state(zone, NR_INACT=
IVE_FILE);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (nr_swap_pages > 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr +=3D zone_page_stat=
e(zone, NR_ACTIVE_ANON) +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 z=
one_page_state(zone, NR_INACTIVE_ANON);
> +
> + =C2=A0 =C2=A0 =C2=A0 return nr;
> =C2=A0}
>
> =C2=A0#ifdef CONFIG_HIBERNATION
> @@ -2198,7 +2219,7 @@ unsigned long shrink_all_memory(unsigned long nr_pa=
ges)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0current->reclaim_state =3D &reclaim_state;
>
> - =C2=A0 =C2=A0 =C2=A0 lru_pages =3D global_lru_pages();
> + =C2=A0 =C2=A0 =C2=A0 lru_pages =3D global_reclaimable_pages();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_slab =3D global_page_state(NR_SLAB_RECLAIMA=
BLE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If slab caches are huge, it's better to hit=
 them first */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (nr_slab >=3D lru_pages) {
> @@ -2240,7 +2261,7 @@ unsigned long shrink_all_memory(unsigned long nr_pa=
ges)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0reclaim_state.reclaimed_slab =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0shrink_slab(sc.nr_scanned, sc.gfp_mask,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 global_lru_p=
ages());
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 global_reclaimable_pages()=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0sc.nr_reclaimed +=3D reclaim_state.reclaimed_slab;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (sc.nr_reclaimed >=3D nr_pages)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
> @@ -2257,7 +2278,8 @@ unsigned long shrink_all_memory(unsigned long nr_pa=
ges)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!sc.nr_reclaimed) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0do {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0reclaim_state.reclaimed_slab =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 shrink_slab(nr_pages, sc.gfp_mask,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 global_reclaimable_pages()=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0sc.nr_reclaimed +=3D reclaim_state.reclaimed_slab;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} while (sc.nr_rec=
laimed < nr_pages &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaim_state.reclaimed_slab > 0);
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
