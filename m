Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id B93F06B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 15:24:51 -0400 (EDT)
Received: by lbao2 with SMTP id o2so2427848lba.14
        for <linux-mm@kvack.org>; Thu, 12 Apr 2012 12:24:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120412190507.GO1787@cmpxchg.org>
References: <1334253782-22755-1-git-send-email-yinghan@google.com>
	<20120412190507.GO1787@cmpxchg.org>
Date: Thu, 12 Apr 2012 12:24:49 -0700
Message-ID: <CALWz4izqWMa9JueuCE8oHuoyBRXu1Qs=wL7F8NcO=J1wquucuA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix up the vmscan stat in vmstat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, Apr 12, 2012 at 12:05 PM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> On Thu, Apr 12, 2012 at 11:03:02AM -0700, Ying Han wrote:
>> It is always confusing on stat "pgsteal" where it counts both direct
>> reclaim as well as background reclaim. However, we have "kswapd_steal"
>> which also counts background reclaim value.
>>
>> This patch fixes it and also makes it match the existng "pgscan_" stats.
>>
>> Test:
>> pgsteal_kswapd_dma32 447623
>> pgsteal_kswapd_normal 42272677
>> pgsteal_kswapd_movable 0
>> pgsteal_direct_dma32 2801
>> pgsteal_direct_normal 44353270
>> pgsteal_direct_movable 0
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0include/linux/vm_event_item.h | =A0 =A05 +++--
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 ++++++++---
>> =A0mm/vmstat.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++--
>> =A03 files changed, 13 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item=
.h
>> index 03b90cdc..06f8e38 100644
>> --- a/include/linux/vm_event_item.h
>> +++ b/include/linux/vm_event_item.h
>> @@ -26,13 +26,14 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOU=
T,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 PGFREE, PGACTIVATE, PGDEACTIVATE,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 PGFAULT, PGMAJFAULT,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 FOR_ALL_ZONES(PGREFILL),
>> - =A0 =A0 =A0 =A0 =A0 =A0 FOR_ALL_ZONES(PGSTEAL),
>> + =A0 =A0 =A0 =A0 =A0 =A0 FOR_ALL_ZONES(PGSTEAL_KSWAPD),
>> + =A0 =A0 =A0 =A0 =A0 =A0 FOR_ALL_ZONES(PGSTEAL_DIRECT),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 FOR_ALL_ZONES(PGSCAN_KSWAPD),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 FOR_ALL_ZONES(PGSCAN_DIRECT),
>> =A0#ifdef CONFIG_NUMA
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 PGSCAN_ZONE_RECLAIM_FAILED,
>> =A0#endif
>> - =A0 =A0 =A0 =A0 =A0 =A0 PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSW=
APD_INODESTEAL,
>> + =A0 =A0 =A0 =A0 =A0 =A0 PGINODESTEAL, SLABS_SCANNED, KSWAPD_INODESTEAL=
,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WM=
ARK_HIT_QUICKLY,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 KSWAPD_SKIP_CONGESTION_WAIT,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 PAGEOUTRUN, ALLOCSTALL, PGROTATED,
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 33c332b..078c9fd 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1568,9 +1568,14 @@ shrink_inactive_list(unsigned long nr_to_scan, st=
ruct mem_cgroup_zone *mz,
>> =A0 =A0 =A0 reclaim_stat->recent_scanned[0] +=3D nr_anon;
>> =A0 =A0 =A0 reclaim_stat->recent_scanned[1] +=3D nr_file;
>>
>> - =A0 =A0 if (current_is_kswapd())
>> - =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_events(KSWAPD_STEAL, nr_reclaimed);
>> - =A0 =A0 __count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
>> + =A0 =A0 if (global_reclaim(sc)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSTEAL=
_KSWAPD, zone,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0nr_reclaimed);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSTEAL=
_DIRECT, zone,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0nr_reclaimed);
>> + =A0 =A0 }
>
> Hey, you changed more than the changelog said! =A0Why no longer count
> memcg hard limit-triggered activity?

To make it consistent with "PGSCAN_*" stats, as in the commit log..
Although i could be more specific. :(

I think it is good to keep those stats to be global reclaim, and memcg
hardlimit-triggered should go to memory.vmscan_stat as you presented.

--Ying
>
> Agreed with everything else, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
