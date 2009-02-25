Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4F2606B00DB
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 03:13:38 -0500 (EST)
Received: by gxk7 with SMTP id 7so8565618gxk.14
        for <linux-mm@kvack.org>; Wed, 25 Feb 2009 00:13:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090225023830.GA1611@cmpxchg.org>
References: <20090225023830.GA1611@cmpxchg.org>
Date: Wed, 25 Feb 2009 17:13:36 +0900
Message-ID: <28c262360902250013q7c2151c3x4bb093509b065fe0@mail.gmail.com>
Subject: Re: [patch] mm: move pagevec stripping to save unlock-relock
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nice catch!

Reviewed-by: MinChan Kim <minchan.kim@gmail.com>

On Wed, Feb 25, 2009 at 11:38 AM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> In shrink_active_list() after the deactivation loop, we strip buffer
> heads from the potentially remaining pages in the pagevec.
>
> Currently, this drops the zone's lru lock for stripping, only to
> reacquire it again afterwards to update statistics.
>
> It is not necessary to strip the pages before updating the stats, so
> move the whole thing out of the protected region and save the extra
> locking.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 =C2=A07 ++-----
> =C2=A01 file changed, 2 insertions(+), 5 deletions(-)
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1298,14 +1298,11 @@ static void shrink_active_list(unsigned
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__mod_zone_page_state(zone, NR_LRU_BASE + lru,=
 pgmoved);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdeactivate +=3D pgmoved;
> - =C2=A0 =C2=A0 =C2=A0 if (buffer_heads_over_limit) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone-=
>lru_lock);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pagevec_strip(&pvec);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irq(&zone->l=
ru_lock);
> - =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__count_zone_vm_events(PGREFILL, zone, pgscann=
ed);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__count_vm_events(PGDEACTIVATE, pgdeactivate);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irq(&zone->lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 if (buffer_heads_over_limit)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pagevec_strip(&pvec);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vm_swap_full())
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pagevec_swap_free(=
&pvec);
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
