Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5903C6B02A5
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 08:05:07 -0400 (EDT)
Received: by pvc30 with SMTP id 30so4718382pvc.14
        for <linux-mm@kvack.org>; Sat, 24 Jul 2010 05:05:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100724174405.3C99.A69D9226@jp.fujitsu.com>
References: <20100722190100.GA22269@amd>
	<20100724174038.3C96.A69D9226@jp.fujitsu.com>
	<20100724174405.3C99.A69D9226@jp.fujitsu.com>
Date: Sat, 24 Jul 2010 21:05:05 +0900
Message-ID: <AANLkTimno0L3_6VmF11XavxLpQ1BibQ=kZUzFyF7axdb@mail.gmail.com>
Subject: Re: [PATCH 1/2] vmscan: shrink_all_slab() use reclaim_state instead
	the return value of shrink_slab()
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

2010/7/24 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> Now, shrink_slab() doesn't return number of reclaimed objects. IOW,
> current shrink_all_slab() is broken. Thus instead we use reclaim_state
> to detect no reclaimable slab objects.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> =A0mm/vmscan.c | =A0 20 +++++++++-----------
> =A01 files changed, 9 insertions(+), 11 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d7256e0..bfa1975 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -300,18 +300,16 @@ static unsigned long shrink_slab(struct zone *zone,=
 unsigned long scanned, unsig
> =A0void shrink_all_slab(void)
> =A0{
> =A0 =A0 =A0 =A0struct zone *zone;
> - =A0 =A0 =A0 unsigned long nr;
> + =A0 =A0 =A0 struct reclaim_state reclaim_state;
>
> -again:
> - =A0 =A0 =A0 nr =3D 0;
> - =A0 =A0 =A0 for_each_zone(zone)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D shrink_slab(zone, 1, 1, 1, GFP_KERN=
EL);
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* If we reclaimed less than 10 objects, might as well ca=
ll
> - =A0 =A0 =A0 =A0* it a day. Nothing special about the number 10.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (nr >=3D 10)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto again;
> + =A0 =A0 =A0 current->reclaim_state =3D &reclaim_state;
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim_state.reclaimed_slab =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_zone(zone)

Oops, this should be for_each_populated_zone().


> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_slab(zone, 1, 1, 1, =
GFP_KERNEL);
> + =A0 =A0 =A0 } while (reclaim_state.reclaimed_slab);
> +
> + =A0 =A0 =A0 current->reclaim_state =3D NULL;
> =A0}
>
> =A0static inline int is_page_cache_freeable(struct page *page)
> --
> 1.6.5.2
>
>
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
