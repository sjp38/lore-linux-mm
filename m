Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 48F936B0093
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 04:24:03 -0400 (EDT)
Received: by qyk2 with SMTP id 2so2948502qyk.14
        for <linux-mm@kvack.org>; Fri, 10 Sep 2010 01:24:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100908151929.2586ace5.akpm@linux-foundation.org>
References: <1283697637-3117-1-git-send-email-minchan.kim@gmail.com>
	<20100908054831.GB20955@cmpxchg.org>
	<20100908154527.GA5936@barrios-desktop>
	<20100908151929.2586ace5.akpm@linux-foundation.org>
Date: Fri, 10 Sep 2010 16:24:00 +0800
Message-ID: <AANLkTi=4kwu0Y5-MDye3TD+zZiku62NtNCMtWLn==p12@mail.gmail.com>
Subject: Re: [PATCH] vmscan: check all_unreclaimable in direct reclaim path
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "M. Vefa Bicakci" <bicave@superonline.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 9, 2010 at 6:19 AM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Thu, 9 Sep 2010 00:45:27 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> +static inline bool zone_reclaimable(struct zone *zone)
>> +{
>> + =C2=A0 =C2=A0 return zone->pages_scanned < zone_reclaimable_pages(zone=
) * 6;
>> +}
>> +
>> +static inline bool all_unreclaimable(struct zonelist *zonelist,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct scan_control *sc)
>> +{
>> + =C2=A0 =C2=A0 struct zoneref *z;
>> + =C2=A0 =C2=A0 struct zone *zone;
>> + =C2=A0 =C2=A0 bool all_unreclaimable =3D true;
>> +
>> + =C2=A0 =C2=A0 if (!scanning_global_lru(sc))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>> +
>> + =C2=A0 =C2=A0 for_each_zone_zonelist_nodemask(zone, z, zonelist,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
gfp_zone(sc->gfp_mask), sc->nodemask) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!populated_zone(zone))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
continue;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!cpuset_zone_allowed_har=
dwall(zone, GFP_KERNEL))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
continue;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (zone_reclaimable(zone)) =
{
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
all_unreclaimable =3D false;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
break;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 }
>> +
>> =C2=A0 =C2=A0 =C2=A0 return all_unreclaimable;
>> =C2=A0}
>
> Could we have some comments over these functions please? =C2=A0Why they
> exist, what problem they solve, how they solve them, etc. =C2=A0Stuff whi=
ch
> will be needed for maintaining this code three years from now.
>
> We may as well remove the `inline's too. =C2=A0gcc will tkae care of that=
