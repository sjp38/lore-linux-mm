Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 6194B6B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:29:55 -0400 (EDT)
Received: by lagz14 with SMTP id z14so4985358lag.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 15:29:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALWz4ixm+s8tS6cHcpac4MNshB9GiZrpuQO+hjY1rOqEA=o-_w@mail.gmail.com>
References: <1334000524-23972-1-git-send-email-yinghan@google.com>
	<20120409125055.c6f6fdf0.akpm@linux-foundation.org>
	<CALWz4ixm+s8tS6cHcpac4MNshB9GiZrpuQO+hjY1rOqEA=o-_w@mail.gmail.com>
Date: Mon, 9 Apr 2012 15:29:52 -0700
Message-ID: <CALWz4ixJ_AZg=p3SNEYTszbY=gP8X_Yi5TJCeSgeJj9jB-uU8g@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm: vmscan: fix misused nr_reclaimed in shrink_mem_cgroup_zone()"
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Mon, Apr 9, 2012 at 2:23 PM, Ying Han <yinghan@google.com> wrote:
> On Mon, Apr 9, 2012 at 12:50 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Mon, =A09 Apr 2012 12:42:04 -0700
>> Ying Han <yinghan@google.com> wrote:
>>
>>> This reverts commit c38446cc65e1f2b3eb8630c53943b94c4f65f670.
>>>
>>> Before the commit, the code makes senses to me but not after the commit=
. The
>>> "nr_reclaimed" is the number of pages reclaimed by scanning through the=
 memcg's
>>> lru lists. The "nr_to_reclaim" is the target value for the whole functi=
on. For
>>> example, we like to early break the reclaim if reclaimed 32 pages under=
 direct
>>> reclaim (not DEF_PRIORITY).
>>>
>>> After the reverted commit, the target "nr_to_reclaim" is decremented ea=
ch time
>>> by "nr_reclaimed" but we still use it to compare the "nr_reclaimed". It=
 just
>>> doesn't make sense to me...
>>>
>>> Signed-off-by: Ying Han <yinghan@google.com>
>>> ---
>>> =A0mm/vmscan.c | =A0 =A07 +------
>>> =A01 files changed, 1 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index 33c332b..1a51868 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -2107,12 +2107,7 @@ restart:
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* with multiple processes reclaiming pag=
es, the total
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* freeing target can get unreasonably la=
rge.
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>>> - =A0 =A0 =A0 =A0 =A0 =A0 if (nr_reclaimed >=3D nr_to_reclaim)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_to_reclaim =3D 0;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 else
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_to_reclaim -=3D nr_reclaim=
ed;
>>> -
>>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!nr_to_reclaim && priority < DEF_PRIORITY=
)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (nr_reclaimed >=3D nr_to_reclaim && priori=
ty < DEF_PRIORITY)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>> =A0 =A0 =A0 }
>>> =A0 =A0 =A0 blk_finish_plug(&plug);
>>
>> This code is all within a loop: the "goto restart" thing. =A0We reset
>> nr_reclaimed to zero each time around that loop. =A0nr_to_reclaim is (or
>> rather, was) constant throughout the entire function.
>>
>> Comparing nr_reclaimed (whcih is reset each time around the loop) to
>> nr_to_reclaim made no sense.
>>
>> I think the code as it stands is ugly. =A0It would be better to make
>> nr_to_reclaim a const and to add another local total_reclaimed, and
>> compare that with nr_to_reclaim.
>
> Ok, I will resend the patch w/ the "total_reclaimed" change.
>
> --Ying


I have the patch ready but I am not sure if that is what we want. If
we use total_reclaimed to compare w/ nr_to_reclaim, we end up reducing
the amount of work to reclaim before
compaction(should_continue_reclaim() is true case).

--Ying

>
> Or just stop resetting nr_reclaimed
>> each time around the loop.
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
