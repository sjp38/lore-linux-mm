Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 57F446B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 23:38:43 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id hr11so5149811vcb.37
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 20:38:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B62F8F61A@SC-VEXCH4.marvell.com>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
	<CAA_GA1ciCDJeBqZv1gHNpQ2VVyDRAVF9_au+fo2dwVvLqnkygA@mail.gmail.com>
	<89813612683626448B837EE5A0B6A7CB3B62F8F61A@SC-VEXCH4.marvell.com>
Date: Wed, 24 Jul 2013 11:38:42 +0800
Message-ID: <CAA_GA1cruj2-T-+bLb-SfEjC+MuCA7VyopczQSFc=Rx-6s-2kg@mail.gmail.com>
Subject: Re: Possible deadloop in direct reclaim?
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>

On Wed, Jul 24, 2013 at 10:23 AM, Lisa Du <cldu@marvell.com> wrote:
> Dear Bob
>    Also from my check before kswapd sleep, though nr_slab =3D 0 but zone_=
reclaimable(zone) returns true, so zone->all_unreclaimable can't be changed=
 to 1; So even when change the nr_slab to sc->nr_reclaimed, it can't help.
>

Then the other fix might be set zone->all_unreclaimable in direct
reclaim path also, like:

@@ -2278,6 +2278,8 @@ static bool shrink_zones(struct zonelist
*zonelist, struct scan_control *sc)
                }

                shrink_zone(zone, sc);
+               if (sc->nr_reclaimed =3D=3D 0 && !zone_reclaimable(zone))
+                       zone->all_unreclaimable =3D 1;
        }

> Thanks!
>
> Best Regards
> Lisa Du
>
>
> -----Original Message-----
> From: Lisa Du
> Sent: 2013=E5=B9=B47=E6=9C=8824=E6=97=A5 9:31
> To: 'Bob Liu'
> Cc: linux-mm@kvack.org; Christoph Lameter; Mel Gorman
> Subject: RE: Possible deadloop in direct reclaim?
>
> Dear Bob
>     Thank you so much for the careful review, Yes, it's a typo, I mean zo=
ne->all_unreclaimable =3D 0.
>     You mentioned add the check in kswapd_shrink_zone(), sorry that I did=
n't find this function in kernel3.4 or kernel3.9.
>     Is this function called in direct_reclaim?
>     As I mentioned this issue happened after kswapd thread sleep, if it o=
nly called in kswapd, then I think it can't help.
>
> Thanks!
>
> Best Regards
> Lisa Du
>
>
> -----Original Message-----
> From: Bob Liu [mailto:lliubbo@gmail.com]
> Sent: 2013=E5=B9=B47=E6=9C=8824=E6=97=A5 9:18
> To: Lisa Du
> Cc: linux-mm@kvack.org; Christoph Lameter; Mel Gorman
> Subject: Re: Possible deadloop in direct reclaim?
>
> On Tue, Jul 23, 2013 at 12:58 PM, Lisa Du <cldu@marvell.com> wrote:
>> Dear Sir:
>>
>> Currently I met a possible deadloop in direct reclaim. After run plenty =
of
>> the application, system run into a status that system memory is very
>> fragmentized. Like only order-0 and order-1 memory left.
>>
>> Then one process required a order-2 buffer but it enter an endless direc=
t
>> reclaim. From my trace log, I can see this loop already over 200,000 tim=
es.
>> Kswapd was first wake up and then go back to sleep as it cannot rebalanc=
e
>> this order=E2=80=99s memory. But zone->all_unreclaimable remains 1.
>>
>> Though direct_reclaim every time returns no pages, but as
>> zone->all_unreclaimable =3D 1, so it loop again and again. Even when
>> zone->pages_scanned also becomes very large. It will block the process f=
or
>> long time, until some watchdog thread detect this and kill this process.
>> Though it=E2=80=99s in __alloc_pages_slowpath, but it=E2=80=99s too slow=
 right? Maybe cost
>> over 50 seconds or even more.
>
> You must be mean zone->all_unreclaimable =3D 0?
>
>>
>> I think it=E2=80=99s not as expected right?  Can we also add below check=
 in the
>> function all_unreclaimable() to terminate this loop?
>>
>>
>>
>> @@ -2355,6 +2355,8 @@ static bool all_unreclaimable(struct zonelist
>> *zonelist,
>>
>>                         continue;
>>
>>                 if (!zone->all_unreclaimable)
>>
>>                         return false;
>>
>> +               if (sc->nr_reclaimed =3D=3D 0 && !zone_reclaimable(zone)=
)
>>
>> +                       return true;
>>
>
> How about replace the checking in kswapd_shrink_zone()?
>
> @@ -2824,7 +2824,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
>         /* Account for the number of pages attempted to reclaim */
>         *nr_attempted +=3D sc->nr_to_reclaim;
>
> -       if (nr_slab =3D=3D 0 && !zone_reclaimable(zone))
> +       if (sc->nr_reclaimed =3D=3D 0 && !zone_reclaimable(zone))
>                 zone->all_unreclaimable =3D 1;
>
>         zone_clear_flag(zone, ZONE_WRITEBACK);
>
>
> I think the current check is wrong, reclaimed a slab doesn't mean
> reclaimed a page.
>
> --
> Regards,
> --Bob



--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
