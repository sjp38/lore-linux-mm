Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id F04EF6B0068
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:30:53 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so5841850lbj.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 09:30:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FDE9857.7000801@jp.fujitsu.com>
References: <1339007031-10527-1-git-send-email-yinghan@google.com>
	<4FDE9857.7000801@jp.fujitsu.com>
Date: Mon, 18 Jun 2012 09:30:51 -0700
Message-ID: <CALWz4ixEumkGXQhiXMsBUwbZtfFAgOYLe1tMKTVkXPy=6C0K7Q@mail.gmail.com>
Subject: Re: [PATCH 3/5] mm: memcg detect no memcgs above softlimit under zone reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sun, Jun 17, 2012 at 7:54 PM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/06/07 3:23), Ying Han wrote:
>> In memcg kernel, cgroup under its softlimit is not targeted under global
>> reclaim. It could be possible that all memcgs are under their softlimit =
for
>> a particular zone. If that is the case, the current implementation will
>> burn extra cpu cycles without making forward progress.
>>
>> The idea is from LSF discussion where we detect it after the first round=
 of
>> scanning and restart the reclaim by not looking at softlimit at all. Thi=
s
>> allows us to make forward progress on shrink_zone().
>>
>> Signed-off-by: Ying Han<yinghan@google.com>
>
> Hm, how about adding sc->ignore_softlimit and preserve the result among p=
riority loops ?
>
> Is it better to check 'ignore_softlimit' at every priority updates ?

The softlimit and usage_in_bytes could change on each memcg, and we
might have to check the ignore_softlimit on each priority loop.

--Ying

>
> Thanks,
> -Kame
>
>> ---
>> =A0 mm/vmscan.c | =A0 18 ++++++++++++++++--
>> =A0 1 files changed, 16 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 0560783..5d036f5 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2142,6 +2142,10 @@ static void shrink_zone(int priority, struct zone=
 *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .priority =3D priority,
>> =A0 =A0 =A0 };
>> =A0 =A0 =A0 struct mem_cgroup *memcg;
>> + =A0 =A0 bool over_softlimit, ignore_softlimit =3D false;
>> +
>> +restart:
>> + =A0 =A0 over_softlimit =3D false;
>>
>> =A0 =A0 =A0 memcg =3D mem_cgroup_iter(root, NULL,&reclaim);
>> =A0 =A0 =A0 do {
>> @@ -2163,9 +2167,14 @@ static void shrink_zone(int priority, struct zone=
 *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we have to reclaim under softlimit inst=
ead of burning more
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* cpu cycles.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!global_reclaim(sc) || priority< =A0DEF_PR=
IORITY - 2 ||
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 should_reclaim=
_mem_cgroup(memcg))
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (ignore_softlimit || !global_reclaim(sc) ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority< =A0D=
EF_PRIORITY - 2 ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 should_reclaim=
_mem_cgroup(memcg)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(prior=
ity,&mz, sc);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 over_softlimit =3D true;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Limit reclaim has historically picked o=
ne memcg and
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned it with decreasing priority lev=
els until
>> @@ -2182,6 +2191,11 @@ static void shrink_zone(int priority, struct zone=
 *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg =3D mem_cgroup_iter(root, memcg,&recla=
im);
>> =A0 =A0 =A0 } while (memcg);
>> +
>> + =A0 =A0 if (!over_softlimit) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ignore_softlimit =3D true;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto restart;
>> + =A0 =A0 }
>> =A0 }
>>
>> =A0 /* Returns true if compaction should go ahead for a high-order reque=
st */
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
