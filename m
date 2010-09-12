Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BAFAA6B00B2
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 12:20:57 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so5526979iwn.14
        for <linux-mm@kvack.org>; Sun, 12 Sep 2010 09:20:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=4kwu0Y5-MDye3TD+zZiku62NtNCMtWLn==p12@mail.gmail.com>
References: <1283697637-3117-1-git-send-email-minchan.kim@gmail.com>
	<20100908054831.GB20955@cmpxchg.org>
	<20100908154527.GA5936@barrios-desktop>
	<20100908151929.2586ace5.akpm@linux-foundation.org>
	<AANLkTi=4kwu0Y5-MDye3TD+zZiku62NtNCMtWLn==p12@mail.gmail.com>
Date: Mon, 13 Sep 2010 01:20:56 +0900
Message-ID: <AANLkTimzidMtKs073bxrYz8GsenRNuAAnQMy7a=FS5Sf@mail.gmail.com>
Subject: Re: [PATCH] vmscan: check all_unreclaimable in direct reclaim path
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "M. Vefa Bicakci" <bicave@superonline.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Thanks, Dave.

On Fri, Sep 10, 2010 at 5:24 PM, Dave Young <hidave.darkstar@gmail.com> wro=
te:
> On Thu, Sep 9, 2010 at 6:19 AM, Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>> On Thu, 9 Sep 2010 00:45:27 +0900
>> Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>>> +static inline bool zone_reclaimable(struct zone *zone)
>>> +{
>>> + =A0 =A0 return zone->pages_scanned < zone_reclaimable_pages(zone) * 6=
;
>>> +}
>>> +
>>> +static inline bool all_unreclaimable(struct zonelist *zonelist,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc)
>>> +{
>>> + =A0 =A0 struct zoneref *z;
>>> + =A0 =A0 struct zone *zone;
>>> + =A0 =A0 bool all_unreclaimable =3D true;
>>> +
>>> + =A0 =A0 if (!scanning_global_lru(sc))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return false;
>>> +
>>> + =A0 =A0 for_each_zone_zonelist_nodemask(zone, z, zonelist,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_zone(sc->gfp_mask), sc->n=
odemask) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!cpuset_zone_allowed_hardwall(zone, GFP_K=
ERNEL))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (zone_reclaimable(zone)) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 all_unreclaimable =3D false;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>>> + =A0 =A0 }
>>> +
>>> =A0 =A0 =A0 return all_unreclaimable;
>>> =A0}
>>
>> Could we have some comments over these functions please? =A0Why they
>> exist, what problem they solve, how they solve them, etc. =A0Stuff which
>> will be needed for maintaining this code three years from now.
>>
>> We may as well remove the `inline's too. =A0gcc will tkae care of that.
>>
>>> - =A0 =A0 =A0 =A0 =A0 =A0 if (nr_slab =3D=3D 0 &&
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->pages_scanned >=3D (zone_reclaim=
able_pages(zone) * 6))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (nr_slab =3D=3D 0 && !zone_reclaimable(zon=
e))
>>
>> Extra marks for working out and documenting how we decided on the value
>> of "6". =A0Sigh. =A0It's hopefully in the git record somewhere.
>
> Here it is (necessary to add additional comment?):
>
> commit 4ff1ffb4870b007b86f21e5f27eeb11498c4c077
> Author: Nick Piggin <npiggin@suse.de>
> Date: =A0 Mon Sep 25 23:31:28 2006 -0700
>
> =A0 =A0[PATCH] oom: reclaim_mapped on oom
>
> =A0 =A0Potentially it takes several scans of the lru lists before we can =
even start
> =A0 =A0reclaiming pages.
>
> =A0 =A0mapped pages, with young ptes can take 2 passes on the active list=
 + one on
> =A0 =A0the inactive list. =A0But reclaim_mapped may not always kick in
> instantly, so it
> =A0 =A0could take even more than that.
>
> =A0 =A0Raise the threshold for marking a zone as all_unreclaimable from a
> factor of 4
> =A0 =A0time the pages in the zone to 6. =A0Introduce a mechanism to force
> =A0 =A0reclaim_mapped if we've reached a factor 3 and still haven't made =
progress.
>
> =A0 =A0Previously, a customer doing stress testing was able to easily OOM=
 the box
> =A0 =A0after using only a small fraction of its swap (~100MB). =A0After t=
he
> patches, it
> =A0 =A0would only OOM after having used up all swap (~800MB).
>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>>
>
>
>
> --
> Regards
> dave
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
