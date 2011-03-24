Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D37DB8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 03:25:47 -0400 (EDT)
Received: by iwl42 with SMTP id 42so12983510iwl.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 00:25:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324160349.CC83.A69D9226@jp.fujitsu.com>
References: <20110324151701.CC7F.A69D9226@jp.fujitsu.com>
	<AANLkTim_C+aKtFAt6XWd9KHHmsA7JBMFWxmScZKRjknk@mail.gmail.com>
	<20110324160349.CC83.A69D9226@jp.fujitsu.com>
Date: Thu, 24 Mar 2011 16:25:43 +0900
Message-ID: <AANLkTi=rOCdojotYG3wyX2Bt+aDrgxTO9DQWe7h1BQrC@mail.gmail.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct
 reclaim path completely
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Mar 24, 2011 at 4:03 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Thu, Mar 24, 2011 at 3:16 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Hi
>> >
>> >> Thanks for your effort, Kosaki.
>> >> But I still doubt this patch is good.
>> >>
>> >> This patch makes early oom killing in hibernation as it skip
>> >> all_unreclaimable check.
>> >> Normally, =C2=A0hibernation needs many memory so page_reclaim pressur=
e
>> >> would be big in small memory system. So I don't like early give up.
>> >
>> > Wait. When occur big pressure? hibernation reclaim pressure
>> > (sc->nr_to_recliam) depend on physical memory size. therefore
>> > a pressure seems to don't depend on the size.
>>
>> It depends on physical memory size and /sys/power/image_size.
>> If you want to tune image size bigger, reclaim pressure would be big.
>
> Ok, _If_ I want.
> However, I haven't seen desktop people customize it.
>
>
>> >> Do you think my patch has a problem? Personally, I think it's very
>> >> simple and clear. :)
>> >
>> > To be honest, I dislike following parts. It's madness on madness.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0static bool zone_reclaimable(struct zone *z=
one)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (zone->all_u=
nreclaimable)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0return false;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return zone->pa=
ges_scanned < zone_reclaimable_pages(zone) * 6;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> >
>> >
>> > The function require a reviewer know
>> >
>> > =C2=A0o pages_scanned and all_unreclaimable are racy
>>
>> Yes. That part should be written down of comment.
>>
>> > =C2=A0o at hibernation, zone->all_unreclaimable can be false negative,
>> > =C2=A0 but can't be false positive.
>>
>> The comment of all_unreclaimable already does explain it well, I think.
>
> Where is?
>
>
>> > And, a function comment of all_unreclaimable() says
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* As hibernation is going on, kswapd=
 is freezed so that it can't mark
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the zone into all_unreclaimable. I=
t can't handle OOM during hibernation.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* So let's check zone's unreclaimabl=
e in direct reclaim as well as kswapd.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> >
>> > But, now it is no longer copy of kswapd algorithm.
>>
>> The comment don't say it should be a copy of kswapd.
>
> I meant the comments says
>
> =C2=A0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* So let's check zone's unreclaim=
able in direct reclaim as well as kswapd.
>
> but now it isn't aswell as kswapd.
>
> I think it's critical important. If people can't understand why the
> algorithm was choosed, anyone will break the code again sooner or later.
>
>
>> > If you strongly prefer this idea even if you hear above explanation,
>> > please consider to add much and much comments. I can't say
>> > current your patch is enough readable/reviewable.
>>
>> My patch isn't a formal patch for merge but just a concept to show.
>> If you agree the idea, of course, I will add more concrete comment
>> when I send formal patch.
>>
>> Before, I would like to get a your agreement. :)
>> If you solve my concern(early give up in hibernation) in your patch, I
>> don't insist on my patch, either.
>
> Ok. Let's try.
>
> Please concern why priority=3D0 is not enough. zone_reclaimable_pages(zon=
e) * 6
> is a conservative value of worry about multi thread race. While one task
> is reclaiming, others can allocate/free memory concurrently. therefore,
> even after priority=3D0, we have a chance getting reclaimable pages on lr=
u.
> But, in hibernation case, almost all tasks was freezed before hibernation
> call shrink_all_memory(). therefore, there is no race. priority=3D0 recla=
im
> can cover all lru pages.
>
> Is this enough explanation for you?

For example, In 4G desktop system.
32M full scanning and fail to reclaim a page.
It's under 1% coverage.

Is it enough to give up?
I am not sure.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
