Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9B48D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 12:44:19 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p2SGi3iQ017778
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:44:05 -0700
Received: from gwj16 (gwj16.prod.google.com [10.200.10.16])
	by wpaz9.hot.corp.google.com with ESMTP id p2SGhAxl021440
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:44:02 -0700
Received: by gwj16 with SMTP id 16so1212212gwj.9
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:44:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110328154033.F068.A69D9226@jp.fujitsu.com>
References: <1301292775-4091-1-git-send-email-yinghan@google.com>
	<1301292775-4091-2-git-send-email-yinghan@google.com>
	<20110328154033.F068.A69D9226@jp.fujitsu.com>
Date: Mon, 28 Mar 2011 09:44:01 -0700
Message-ID: <AANLkTikpPpNBg5bzG=cjaeArXXzzoZa_-T2ybSR38o+K@mail.gmail.com>
Subject: Re: [PATCH 1/2] check the return value of soft_limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sun, Mar 27, 2011 at 11:39 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> In the global background reclaim, we do soft reclaim before scanning the
>> per-zone LRU. However, the return value is ignored. This patch adds the =
logic
>> where no per-zone reclaim happens if the soft reclaim raise the free pag=
es
>> above the zone's high_wmark.
>>
>> I did notice a similar check exists but instead leaving a "gap" above th=
e
>> high_wmark(the code right after my change in vmscan.c). There are discus=
sions
>> on whether or not removing the "gap" which intends to balance pressures =
across
>> zones over time. Without fully understand the logic behind, I didn't try=
 to
>> merge them into one, but instead adding the condition only for memcg use=
rs
>> who care a lot on memory isolation.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>
> Looks good to me. But this depend on "memcg soft limit" spec. To be hones=
t,
> I don't know this return value ignorance is intentional or not. So I thin=
k
> you need to get ack from memcg folks.
>
>
>> ---
>> =A0mm/vmscan.c | =A0 16 +++++++++++++++-
>> =A01 files changed, 15 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 060e4c1..e4601c5 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2320,6 +2320,7 @@ static unsigned long balance_pgdat(pg_data_t *pgda=
t, int order,
>> =A0 =A0 =A0 int end_zone =3D 0; =A0 =A0 =A0 /* Inclusive. =A00 =3D ZONE_=
DMA */
>> =A0 =A0 =A0 unsigned long total_scanned;
>> =A0 =A0 =A0 struct reclaim_state *reclaim_state =3D current->reclaim_sta=
te;
>> + =A0 =A0 unsigned long nr_soft_reclaimed;
>> =A0 =A0 =A0 struct scan_control sc =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
>> @@ -2413,7 +2414,20 @@ loop_again:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Call soft limit reclaim=
 before calling shrink_zone.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* For now we ignore the r=
eturn value
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_limit_reclaim(=
zone, order, sc.gfp_mask);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_reclaimed =3D mem_cgro=
up_soft_limit_reclaim(zone,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order, sc.gfp_mask);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Check the watermark after=
 the soft limit reclaim. If
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the free pages is above t=
he watermark, no need to
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* proceed to the zone recla=
im.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_soft_reclaimed && zone_=
watermark_ok_safe(zone,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 order, high_wmark_pages(zone),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 end_zone, 0)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_zone_sta=
te(zone, NR_SKIP_RECLAIM_GLOBAL);
>
> NR_SKIP_RECLAIM_GLOBAL is defined by patch 2/2. please don't break bisect=
ability.

Thanks and I will fix that.

--Ying
>
>
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We put equal pressure o=
n every zone, unless
>> --
>> 1.7.3.1
>>
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
