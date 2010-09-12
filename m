Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5293F6B00B1
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 12:20:38 -0400 (EDT)
Received: by iwn33 with SMTP id 33so5526979iwn.14
        for <linux-mm@kvack.org>; Sun, 12 Sep 2010 09:20:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100908151929.2586ace5.akpm@linux-foundation.org>
References: <1283697637-3117-1-git-send-email-minchan.kim@gmail.com>
	<20100908054831.GB20955@cmpxchg.org>
	<20100908154527.GA5936@barrios-desktop>
	<20100908151929.2586ace5.akpm@linux-foundation.org>
Date: Mon, 13 Sep 2010 01:20:36 +0900
Message-ID: <AANLkTi=jmV=x2rJ=G4iicYFO6UqPbfob_VnkY7VNbP3X@mail.gmail.com>
Subject: Re: [PATCH] vmscan: check all_unreclaimable in direct reclaim path
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "M. Vefa Bicakci" <bicave@superonline.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 9, 2010 at 7:19 AM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Thu, 9 Sep 2010 00:45:27 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> +static inline bool zone_reclaimable(struct zone *zone)
>> +{
>> + =A0 =A0 return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
>> +}
>> +
>> +static inline bool all_unreclaimable(struct zonelist *zonelist,
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc)
>> +{
>> + =A0 =A0 struct zoneref *z;
>> + =A0 =A0 struct zone *zone;
>> + =A0 =A0 bool all_unreclaimable =3D true;
>> +
>> + =A0 =A0 if (!scanning_global_lru(sc))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return false;
>> +
>> + =A0 =A0 for_each_zone_zonelist_nodemask(zone, z, zonelist,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_zone(sc->gfp_mask), sc->no=
demask) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!cpuset_zone_allowed_hardwall(zone, GFP_KE=
RNEL))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (zone_reclaimable(zone)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 all_unreclaimable =3D false;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> +
>> =A0 =A0 =A0 return all_unreclaimable;
>> =A0}
>
> Could we have some comments over these functions please? =A0Why they
> exist, what problem they solve, how they solve them, etc. =A0Stuff which
> will be needed for maintaining this code three years from now.
>
> We may as well remove the `inline's too. =A0gcc will tkae care of that.

Okay. I will resend.

>
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (nr_slab =3D=3D 0 &&
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->pages_scanned >=3D (zone_reclaima=
ble_pages(zone) * 6))
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (nr_slab =3D=3D 0 && !zone_reclaimable(zone=
))
>
> Extra marks for working out and documenting how we decided on the value
> of "6". =A0Sigh. =A0It's hopefully in the git record somewhere.
>
Originally it is just following as.

                if (zone->pages_scanned > zone->present_pages * 2)
                        zone->all_unreclaimable =3D 1;

Nick change it with remained lru * 4 [1] and increased 6 [2].
But the description doesn't have why we determine it by "4".
So I can't handle it in my patch.

I don't like undocumented magic value. :(

[1]
commit 9d0aa0f7a99c88dd20bc188756b892f174d93fc1
Author: nickpiggin <nickpiggin>
Date:   Sun Oct 17 16:20:56 2004 +0000

    [PATCH] kswapd lockup fix

    Fix some bugs in the kswapd logic which can cause kswapd lockups.


[2]
commit 4ff1ffb4870b007b86f21e5f27eeb11498c4c077
Author: Nick Piggin <npiggin@suse.de>
Date:   Mon Sep 25 23:31:28 2006 -0700

    [PATCH] oom: reclaim_mapped on oom

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
