Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DEC26B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 11:01:40 -0400 (EDT)
Received: by yxe38 with SMTP id 38so3127656yxe.12
        for <linux-mm@kvack.org>; Sun, 28 Jun 2009 08:01:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090628142239.GA20986@localhost>
References: <32411.1245336412@redhat.com> <2015.1245341938@redhat.com>
	 <20090618095729.d2f27896.akpm@linux-foundation.org>
	 <7561.1245768237@redhat.com> <26537.1246086769@redhat.com>
	 <20090627125412.GA1667@cmpxchg.org> <20090628113246.GA18409@localhost>
	 <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com>
	 <28c262360906280636l93130ffk14086314e2a6dcb7@mail.gmail.com>
	 <20090628142239.GA20986@localhost>
Date: Mon, 29 Jun 2009 00:01:40 +0900
Message-ID: <2f11576a0906280801w417d1b9fpe10585b7a641d41b@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

> Yes, smaller inactive_anon means smaller (pointless) nr_scanned,
> and therefore less slab scans. Strictly speaking, it's not the fault
> of your patch. It indicates that the slab scan ratio algorithm should
> be updated too :)

I don't think this patch is related to minchan's patch.
but I think this patch is good.


> We could refine the estimation of "reclaimable" pages like this:

hmhm, reasonable idea.

>
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 416f748..e9c5b0e 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -167,14 +167,7 @@ static inline unsigned long zone_page_state(struct z=
one *zone,
> =A0}
>
> =A0extern unsigned long global_lru_pages(void);
> -
> -static inline unsigned long zone_lru_pages(struct zone *zone)
> -{
> - =A0 =A0 =A0 return (zone_page_state(zone, NR_ACTIVE_ANON)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 + zone_page_state(zone, NR_ACTIVE_FILE)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 + zone_page_state(zone, NR_INACTIVE_ANON)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 + zone_page_state(zone, NR_INACTIVE_FILE));
> -}
> +extern unsigned long zone_lru_pages(void);
>
> =A0#ifdef CONFIG_NUMA
> =A0/*
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 026f452..4281c6f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2123,10 +2123,31 @@ void wakeup_kswapd(struct zone *zone, int order)
>
> =A0unsigned long global_lru_pages(void)
> =A0{
> - =A0 =A0 =A0 return global_page_state(NR_ACTIVE_ANON)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 + global_page_state(NR_ACTIVE_FILE)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 + global_page_state(NR_INACTIVE_ANON)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 + global_page_state(NR_INACTIVE_FILE);
> + =A0 =A0 =A0 int nr;
> +
> + =A0 =A0 =A0 nr =3D global_page_state(zone, NR_ACTIVE_FILE) +
> + =A0 =A0 =A0 =A0 =A0 =A0global_page_state(zone, NR_INACTIVE_FILE);
> +
> + =A0 =A0 =A0 if (total_swap_pages)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D global_page_state(zone, NR_ACTIVE_A=
NON) +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 global_page_state(zone, NR_INAC=
TIVE_ANON);
> +
> + =A0 =A0 =A0 return nr;
> +}

Please change function name too.
Now, this function only account reclaimable pages.

Plus, total_swap_pages is bad. if we need to concern "reclaimable
pages", we should use nr_swap_pages.
I mean, swap-full also makes anon is unreclaimable althouth system
have sone swap device.



> +
> +
> +unsigned long zone_lru_pages(struct zone *zone)
> +{
> + =A0 =A0 =A0 int nr;
> +
> + =A0 =A0 =A0 nr =3D zone_page_state(zone, NR_ACTIVE_FILE) +
> + =A0 =A0 =A0 =A0 =A0 =A0zone_page_state(zone, NR_INACTIVE_FILE);
> +
> + =A0 =A0 =A0 if (total_swap_pages)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D zone_page_state(zone, NR_ACTIVE_ANO=
N) +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_page_state(zone, NR_INACTI=
VE_ANON);
> +
> + =A0 =A0 =A0 return nr;
> =A0}
>
> =A0#ifdef CONFIG_HIBERNATION
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
