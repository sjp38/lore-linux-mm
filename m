Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 62F806B0033
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 21:18:11 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id ha11so752836vcb.7
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 18:18:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
Date: Wed, 24 Jul 2013 09:18:10 +0800
Message-ID: <CAA_GA1ciCDJeBqZv1gHNpQ2VVyDRAVF9_au+fo2dwVvLqnkygA@mail.gmail.com>
Subject: Re: Possible deadloop in direct reclaim?
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>

On Tue, Jul 23, 2013 at 12:58 PM, Lisa Du <cldu@marvell.com> wrote:
> Dear Sir:
>
> Currently I met a possible deadloop in direct reclaim. After run plenty o=
f
> the application, system run into a status that system memory is very
> fragmentized. Like only order-0 and order-1 memory left.
>
> Then one process required a order-2 buffer but it enter an endless direct
> reclaim. From my trace log, I can see this loop already over 200,000 time=
s.
> Kswapd was first wake up and then go back to sleep as it cannot rebalance
> this order=E2=80=99s memory. But zone->all_unreclaimable remains 1.
>
> Though direct_reclaim every time returns no pages, but as
> zone->all_unreclaimable =3D 1, so it loop again and again. Even when
> zone->pages_scanned also becomes very large. It will block the process fo=
r
> long time, until some watchdog thread detect this and kill this process.
> Though it=E2=80=99s in __alloc_pages_slowpath, but it=E2=80=99s too slow =
right? Maybe cost
> over 50 seconds or even more.

You must be mean zone->all_unreclaimable =3D 0?

>
> I think it=E2=80=99s not as expected right?  Can we also add below check =
in the
> function all_unreclaimable() to terminate this loop?
>
>
>
> @@ -2355,6 +2355,8 @@ static bool all_unreclaimable(struct zonelist
> *zonelist,
>
>                         continue;
>
>                 if (!zone->all_unreclaimable)
>
>                         return false;
>
> +               if (sc->nr_reclaimed =3D=3D 0 && !zone_reclaimable(zone))
>
> +                       return true;
>

How about replace the checking in kswapd_shrink_zone()?

@@ -2824,7 +2824,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
        /* Account for the number of pages attempted to reclaim */
        *nr_attempted +=3D sc->nr_to_reclaim;

-       if (nr_slab =3D=3D 0 && !zone_reclaimable(zone))
+       if (sc->nr_reclaimed =3D=3D 0 && !zone_reclaimable(zone))
                zone->all_unreclaimable =3D 1;

        zone_clear_flag(zone, ZONE_WRITEBACK);


I think the current check is wrong, reclaimed a slab doesn't mean
reclaimed a page.

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
