Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B99AE8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 00:19:39 -0400 (EDT)
Received: by iwl42 with SMTP id 42so12824401iwl.14
        for <linux-mm@kvack.org>; Wed, 23 Mar 2011 21:19:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324111200.1AF4.A69D9226@jp.fujitsu.com>
References: <20110323174545.1AE2.A69D9226@jp.fujitsu.com>
	<AANLkTi=w62=WR5WACJGk6JNhyCYpgNhFQK3CyQ5Ag-Yj@mail.gmail.com>
	<20110324111200.1AF4.A69D9226@jp.fujitsu.com>
Date: Thu, 24 Mar 2011 13:19:37 +0900
Message-ID: <AANLkTim1=Z5VhWJyn596cyez3hDe1BgDHvPvj6eoPp1j@mail.gmail.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct
 reclaim path completely
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Mar 24, 2011 at 11:11 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Wed, Mar 23, 2011 at 5:44 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> > Boo.
>> >> > You seems forgot why you introduced current all_unreclaimable() function.
>> >> > While hibernation, we can't trust all_unreclaimable.
>> >>
>> >> Hmm. AFAIR, the why we add all_unreclaimable is when the hibernation is going on,
>> >> kswapd is freezed so it can't mark the zone->all_unreclaimable.
>> >> So I think hibernation can't be a problem.
>> >> Am I miss something?
>> >
>> > Ahh, I missed. thans correct me. Okay, I recognized both mine and your works.
>> > Can you please explain why do you like your one than mine?
>>
>> Just _simple_ :)
>> I don't want to change many lines although we can do it simple and very clear.
>>
>> >
>> > btw, Your one is very similar andrey's initial patch. If your one is
>> > better, I'd like to ack with andrey instead.
>>
>> When Andrey sent a patch, I though this as zone_reclaimable() is right
>> place to check it than out of zone_reclaimable. Why I didn't ack is
>> that Andrey can't explain root cause but you did so you persuade me.
>>
>> I don't mind if Andrey move the check in zone_reclaimable and resend
>> or I resend with concrete description.
>>
>> Anyway, most important thing is good description to show the root cause.
>> It is applied to your patch, too.
>> You should have written down root cause in description.
>
> honestly, I really dislike to use mixing zone->pages_scanned and
> zone->all_unreclaimable. because I think it's no simple. I don't
> think it's good taste nor easy to review. Even though you who VM
> expert didn't understand this issue at once, it's smell of too
> mess code.
>
> therefore, I prefore to take either 1) just remove the function or
> 2) just only check zone->all_unreclaimable and oom_killer_disabled
> instead zone->pages_scanned.

Nick's original goal is to prevent OOM killing until all zone we're
interested in are unreclaimable and whether zone is reclaimable or not
depends on kswapd. And Nick's original solution is just peeking
zone->all_unreclaimable but I made it dirty when we are considering
kswapd freeze in hibernation. So I think we still need it to handle
kswapd freeze problem and we should add original behavior we missed at
that time like below.

static bool zone_reclaimable(struct zone *zone)
{
        if (zone->all_unreclaimable)
                return false;

        return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
}

If you remove the logic, the problem Nick addressed would be showed
up, again. How about addressing the problem in your patch? If you
remove the logic, __alloc_pages_direct_reclaim lose the chance calling
dran_all_pages. Of course, it was a side effect but we should handle
it.

And my last concern is we are going on right way?
I think fundamental cause of this problem is page_scanned and
all_unreclaimable is race so isn't the approach fixing the race right
way?
If it is hard or very costly, your and my approach will be fallback.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
