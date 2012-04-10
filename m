Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 7B8AB6B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 12:44:55 -0400 (EDT)
Received: by lagz14 with SMTP id z14so7385lag.14
        for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:44:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBD6Sb4zmUkMTaT12cgwFLAQYmh6HuK1hLMa_Dda6FHBLQ@mail.gmail.com>
References: <1334000524-23972-1-git-send-email-yinghan@google.com>
	<CAJd=RBD6Sb4zmUkMTaT12cgwFLAQYmh6HuK1hLMa_Dda6FHBLQ@mail.gmail.com>
Date: Tue, 10 Apr 2012 09:44:52 -0700
Message-ID: <CALWz4iyZauXcfuepN6SE9bQpPXp5dH0XvXh6zByO_uNdWTt9ow@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm: vmscan: fix misused nr_reclaimed in shrink_mem_cgroup_zone()"
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Tue, Apr 10, 2012 at 8:00 AM, Hillf Danton <dhillf@gmail.com> wrote:
> On Tue, Apr 10, 2012 at 3:42 AM, Ying Han <yinghan@google.com> wrote:
>> This reverts commit c38446cc65e1f2b3eb8630c53943b94c4f65f670.
>>
>> Before the commit, the code makes senses to me but not after the commit.=
 The
>> "nr_reclaimed" is the number of pages reclaimed by scanning through the =
memcg's
>> lru lists. The "nr_to_reclaim" is the target value for the whole functio=
n. For
>> example, we like to early break the reclaim if reclaimed 32 pages under =
direct
>> reclaim (not DEF_PRIORITY).
>>
>> After the reverted commit, the target "nr_to_reclaim" is decremented eac=
h time
>> by "nr_reclaimed" but we still use it to compare the "nr_reclaimed". It =
just
>> doesn't make sense to me...
>>
> I downloaded mm/vmscan.c from the next tree a couple minutes ago, and
> see
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_to_reclaim =3D SWAP_CLUSTER_MAX,
> and
> =A0 =A0 =A0 =A0nr_reclaimed =3D do_try_to_free_pages(zonelist, &sc, &shri=
nk);
>
> in try_to_free_pages().
>
> I also see
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scanned +=3D sc->nr_scanned;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sc->nr_reclaimed >=3D sc->nr_to_reclai=
m)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;


> in do_try_to_free_pages(),
>
> then would you please say a few words about the sense
> of the check of nr_to_reclaim?

There are two places where we do early break out in direct reclaim path.

1. For each priority loop after calling shrink_zones(), we check
(sc->nr_reclaimed >=3D sc->nr_to_reclaim)

2. For each memcg reclaim (shrink_mem_cgroup_zone) under
shrink_zone(), we check (nr_reclaimed >=3D nr_to_reclaim)

The second one says "if 32 (nr_to_reclaim) pages being reclaimed from
this memcg under high priority, break". This check is necessary here
to prevent over pressure each memcg under shrink_zone().

Regarding the reverted patch, it tries to convert the "nr_reclaimed"
to "total_reclaimed" for outer loop (restart). First of all, it
changes the logic by doing less work each time
should_continue_reclaim() is true. Second, the fix is simply broken by
decrementing nr_to_reclaim each time.

--Ying

>
>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0mm/vmscan.c | =A0 =A07 +------
>> =A01 files changed, 1 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 33c332b..1a51868 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2107,12 +2107,7 @@ restart:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * with multiple processes reclaiming pag=
es, the total
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * freeing target can get unreasonably la=
rge.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_reclaimed >=3D nr_to_reclaim)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_to_reclaim =3D 0;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_to_reclaim -=3D nr_recl=
aimed;
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!nr_to_reclaim && priority < DEF_PRIOR=
ITY)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_reclaimed >=3D nr_to_reclaim && pri=
ority < DEF_PRIORITY)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0blk_finish_plug(&plug);
>> --
>> 1.7.7.3
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
