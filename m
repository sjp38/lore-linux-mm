Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D47D76B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 07:30:43 -0500 (EST)
Received: by wicr5 with SMTP id r5so2646075wic.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 04:30:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120123104731.GA1707@cmpxchg.org>
References: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
	<20120123104731.GA1707@cmpxchg.org>
Date: Mon, 23 Jan 2012 20:30:42 +0800
Message-ID: <CAJd=RBDUK=LQVhQm_P3DO-bgWka=gK9cKUkm8esOaZs261EexA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: check mem cgroup over reclaimed
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 23, 2012 at 6:47 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Mon, Jan 23, 2012 at 09:55:07AM +0800, Hillf Danton wrote:
>> To avoid reduction in performance of reclaimee, checking overreclaim is =
added
>> after shrinking lru list, when pages are reclaimed from mem cgroup.
>>
>> If over reclaim occurs, shrinking remaining lru lists is skipped, and no=
 more
>> reclaim for reclaim/compaction.
>>
>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>> ---
>>
>> --- a/mm/vmscan.c =C2=A0 =C2=A0 Mon Jan 23 00:23:10 2012
>> +++ b/mm/vmscan.c =C2=A0 =C2=A0 Mon Jan 23 09:57:20 2012
>> @@ -2086,6 +2086,7 @@ static void shrink_mem_cgroup_zone(int p
>> =C2=A0 =C2=A0 =C2=A0 unsigned long nr_reclaimed, nr_scanned;
>> =C2=A0 =C2=A0 =C2=A0 unsigned long nr_to_reclaim =3D sc->nr_to_reclaim;
>> =C2=A0 =C2=A0 =C2=A0 struct blk_plug plug;
>> + =C2=A0 =C2=A0 bool memcg_over_reclaimed =3D false;
>>
>> =C2=A0restart:
>> =C2=A0 =C2=A0 =C2=A0 nr_reclaimed =3D 0;
>> @@ -2103,6 +2104,11 @@ restart:
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_reclaimed +=3D shrink_list(lru, nr_to=
_scan,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mz, sc, priorit=
y);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg_over_reclaimed =3D !scanning_global_lru(m=
z)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 && (nr_reclaimed >=
=3D nr_to_reclaim);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (memcg_over_reclaimed)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>
> Since this merge window, scanning_global_lru() is always false when
> the memory controller is enabled, i.e. most common configurations and
> distribution kernels.
>
> This will with quite likely have bad effects on zone balancing,
> pressure balancing between anon/file lru etc, while you haven't shown
> that any workloads actually benefit from this.
>
Hi Johannes

Thanks for your comment, first.

Impact on zone balance and lru-list balance is introduced actually, but I
dont think the patch is totally responsible for the balance mentioned,
because soft limit, embedded in mem cgroup, is setup by users according to
whatever tastes they have.

Though there is room for the patch to be fine tuned in this direction or th=
at,
over reclaim should not be neglected entirely, but be avoided as much as we
could, or users are enforced to set up soft limit with much care not to mes=
s
up zone balance.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
