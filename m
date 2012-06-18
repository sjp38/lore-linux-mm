Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 064E76B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:39:09 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so5767581lbj.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 08:39:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FDE9969.1090706@jp.fujitsu.com>
References: <1339007051-10672-1-git-send-email-yinghan@google.com>
	<4FDE9969.1090706@jp.fujitsu.com>
Date: Mon, 18 Jun 2012 08:39:07 -0700
Message-ID: <CALWz4izv1G2gd6PX45BvaoVm7pkQd+2KEgQ1urOrFMHc-PQzMQ@mail.gmail.com>
Subject: Re: [PATCH 5/5] mm: memcg discount pages under softlimit from
 per-zone reclaimable_pages
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sun, Jun 17, 2012 at 7:58 PM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/06/07 3:24), Ying Han wrote:
>> The function zone_reclaimable() marks zone->all_unreclaimable based on
>> per-zone pages_scanned and reclaimable_pages. If all_unreclaimable is tr=
ue,
>> alloc_pages could go to OOM instead of getting stuck in page reclaim.
>>
>> In memcg kernel, cgroup under its softlimit is not targeted under global
>> reclaim. So we need to remove those pages from reclaimable_pages, otherw=
ise
>> it will cause reclaim mechanism to get stuck trying to reclaim from
>> all_unreclaimable zone.
>>
>> Signed-off-by: Ying Han<yinghan@google.com>
>> ---
>> =A0 mm/vmscan.c | =A0 24 ++++++++++++++++++------
>> =A0 1 files changed, 18 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 65febc1..163b197 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -3142,14 +3142,26 @@ unsigned long global_reclaimable_pages(void)
>>
>> =A0 unsigned long zone_reclaimable_pages(struct zone *zone)
>> =A0 {
>> - =A0 =A0 int nr;
>> + =A0 =A0 int nr =3D 0;
>> + =A0 =A0 struct mem_cgroup *memcg;
>>
>> - =A0 =A0 nr =3D zone_page_state(zone, NR_ACTIVE_FILE) +
>> - =A0 =A0 =A0 =A0 =A0zone_page_state(zone, NR_INACTIVE_FILE);
>> + =A0 =A0 memcg =3D mem_cgroup_iter(NULL, NULL, NULL);
>> + =A0 =A0 do {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup_zone mz =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
>> + =A0 =A0 =A0 =A0 =A0 =A0 };
>>
>> - =A0 =A0 if (nr_swap_pages> =A00)
>> - =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D zone_page_state(zone, NR_ACTIVE_ANON) =
+
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_page_state(zone, NR_INACTIVE_=
ANON);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (should_reclaim_mem_cgroup(memcg)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D zone_nr_lru_pages(&mz,=
 LRU_INACTIVE_FILE) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_nr_lru_pages(=
&mz, LRU_ACTIVE_FILE);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_swap_pages> =A00)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D zone_n=
r_lru_pages(&mz, LRU_ACTIVE_ANON) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zo=
ne_nr_lru_pages(&mz, LRU_INACTIVE_ANON);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 memcg =3D mem_cgroup_iter(NULL, memcg, NULL);
>> + =A0 =A0 } while (memcg);
>>
>
> Shouldn't you handle 'ignore_softlimit' case ?
> Anyway, Kosaki-san is now trying to modify zone->all_unreclaimable etc..
> we need to check it with softlimit context.

Yes, I am about to post the next version which I included Kosaki's
patch as replacement

Thanks ~

--Ying

>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
