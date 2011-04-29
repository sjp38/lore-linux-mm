Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 249CE900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 13:44:20 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p3THiI11029012
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:44:18 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by wpaz13.hot.corp.google.com with ESMTP id p3THiHsO016352
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:44:17 -0700
Received: by qyg14 with SMTP id 14so2307086qyg.12
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:44:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110429130503.GA306@tiehlicka.suse.cz>
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
	<1304030226-19332-2-git-send-email-yinghan@google.com>
	<20110429130503.GA306@tiehlicka.suse.cz>
Date: Fri, 29 Apr 2011 10:44:16 -0700
Message-ID: <BANLkTinkB+qF6u6TtsSoahdPOmNtAht39A@mail.gmail.com>
Subject: Re: [PATCH 1/2] Add the soft_limit reclaim in global direct reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, Apr 29, 2011 at 6:05 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Thu 28-04-11 15:37:05, Ying Han wrote:
>> We recently added the change in global background reclaim which
>> counts the return value of soft_limit reclaim. Now this patch adds
>> the similar logic on global direct reclaim.
>>
>> We should skip scanning global LRU on shrink_zone if soft_limit reclaim
>> does enough work. This is the first step where we start with counting
>> the nr_scanned and nr_reclaimed from soft_limit reclaim into global
>> scan_control.
>
> Makes sense.
>
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
>
> This can cause more aggressive reclaiming, right? Shouldn't we check
> whether shrink_zone is still needed?

We decided to leave the shrink_zone for now before making further
changes for soft_limit reclaim. The same
patch I did last time for global background reclaim. It is safer to do
this step-by-step :)

--Ying
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
