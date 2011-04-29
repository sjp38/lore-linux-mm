Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8A850900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 13:42:25 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p3THgJ4P020747
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:42:19 -0700
Received: from qyk32 (qyk32.prod.google.com [10.241.83.160])
	by hpaq14.eem.corp.google.com with ESMTP id p3THfm1p004342
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:42:18 -0700
Received: by qyk32 with SMTP id 32so489976qyk.8
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:42:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110429102649.GK6547@balbir.in.ibm.com>
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
	<1304030226-19332-2-git-send-email-yinghan@google.com>
	<20110429102649.GK6547@balbir.in.ibm.com>
Date: Fri, 29 Apr 2011 10:42:18 -0700
Message-ID: <BANLkTik297jFZk1PUXLHhS9OY-paLn8Qgg@mail.gmail.com>
Subject: Re: [PATCH 1/2] Add the soft_limit reclaim in global direct reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, Apr 29, 2011 at 3:26 AM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * Ying Han <yinghan@google.com> [2011-04-28 15:37:05]:
>
>> We recently added the change in global background reclaim which
>> counts the return value of soft_limit reclaim. Now this patch adds
>> the similar logic on global direct reclaim.
>>
>> We should skip scanning global LRU on shrink_zone if soft_limit reclaim
>> does enough work. This is the first step where we start with counting
>> the nr_scanned and nr_reclaimed from soft_limit reclaim into global
>> scan_control.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0mm/vmscan.c | =A0 16 ++++++++++++++--
>> =A01 files changed, 14 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index b3a569f..84003cc 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1959,11 +1959,14 @@ restart:
>> =A0 * If a zone is deemed to be full of pinned pages then just give it a=
 light
>> =A0 * scan then give up on it.
>> =A0 */
>> -static void shrink_zones(int priority, struct zonelist *zonelist,
>> +static unsigned long shrink_zones(int priority, struct zonelist *zoneli=
st,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct scan_control *sc)
>> =A0{
>> =A0 =A0 =A0 struct zoneref *z;
>> =A0 =A0 =A0 struct zone *zone;
>> + =A0 =A0 unsigned long nr_soft_reclaimed;
>> + =A0 =A0 unsigned long nr_soft_scanned;
>> + =A0 =A0 unsigned long total_scanned =3D 0;
>>
>> =A0 =A0 =A0 for_each_zone_zonelist_nodemask(zone, z, zonelist,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 gfp_zone(sc->gfp_mask), sc->nodemask) {
>> @@ -1980,8 +1983,17 @@ static void shrink_zones(int priority, struct zon=
elist *zonelist,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue; =
=A0 =A0 =A0 /* Let kswapd poll it */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_scanned =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_reclaimed =3D mem_cgroup_soft_limit_re=
claim(zone,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->order, sc->gfp_mask,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &nr_soft_scanned);
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_reclaimed +=3D nr_soft_reclaimed;
>> + =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D nr_soft_scanned;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);
>> =A0 =A0 =A0 }
>> +
>> + =A0 =A0 return total_scanned;
>> =A0}
>>
>> =A0static bool zone_reclaimable(struct zone *zone)
>> @@ -2045,7 +2057,7 @@ static unsigned long do_try_to_free_pages(struct z=
onelist *zonelist,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!priority)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();
>> - =A0 =A0 =A0 =A0 =A0 =A0 shrink_zones(priority, zonelist, sc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D shrink_zones(priority, zone=
list, sc);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Don't shrink slabs when reclaiming memo=
ry from
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* over limit cgroups
>
> Seems reasonable to me, are you able to see the benefits of setting
> soft limits and then adding back the stats on global LRU scan if
> soft limits did a good job?

I can list the stats on my next post which shows the how many reclaimed fro=
m
soft_limit reclaim vs per-zone recalim before and after the patch.

Thanks

--Ying
>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
