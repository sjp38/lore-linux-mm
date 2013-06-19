Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 05AB86B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 07:25:05 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id fr10so4520268lab.4
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 04:25:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130618110151.GI13677@dhcp22.suse.cz>
References: <008a01ce6b4e$079b6a50$16d23ef0$%kim@samsung.com>
	<20130617131551.GA5018@dhcp22.suse.cz>
	<CAOK=xRMYZokH1rg+dfE0KfPk9NsqPmmaTg-k8sagqRqvR+jG+w@mail.gmail.com>
	<CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
	<20130618110151.GI13677@dhcp22.suse.cz>
Date: Wed, 19 Jun 2013 20:25:03 +0900
Message-ID: <CAOK=xRPM90muz5nFh8oUVAPFU=e4cwyWPZELVKoXke2FUN9Xsg@mail.gmail.com>
Subject: Re: [PATCH v3] memcg: event control at vmpressure.
From: Hyunhee Kim <hyunhee.kim@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Anton Vorontsov <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, Kyungmin Park <kyungmin.park@samsung.com>

2013/6/18 Michal Hocko <mhocko@suse.cz>:
> On Tue 18-06-13 17:00:06, Hyunhee Kim wrote:
>> 2013/6/18 Hyunhee Kim <hyunhee.kim@samsung.com>:
>> > 2013/6/17 Michal Hocko <mhocko@suse.cz>:
>> >> On Mon 17-06-13 20:30:11, Hyunhee Kim wrote:
>> >> [...]
>> >>> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
>> >>> index 736a601..a18fdb3 100644
>> >>> --- a/mm/vmpressure.c
>> >>> +++ b/mm/vmpressure.c
>> >> [...]
>> >>> @@ -150,14 +151,16 @@ static bool vmpressure_event(struct vmpressure *vmpr,
>> >>>       level = vmpressure_calc_level(scanned, reclaimed);
>> >>>
>> >>>       mutex_lock(&vmpr->events_lock);
>> >>> -
>> >>>       list_for_each_entry(ev, &vmpr->events, node) {
>> >>>               if (level >= ev->level) {
>> >>> +                     if (ev->edge_trigger && (level == vmpr->last_level
>> >>
>> >>> +                             || level != ev->level))
>> >>
>> >> Hmm, why this differs from the "always" semantic? You do not want to see
>> >> lower events? Why?
>> >
>> > Yes, I didn't want to see every lower level events whenever the higher
>> > level event occurs because the higher event signal implies that the
>> > lower memory situation also occurs.
>
> Is there any guarantee that such a condition would be also signalled?

I think so. In the original implementation, ev is signaled if (level
>= ev->level).
This means that on "level == CRITICAL", LOW and MEDIUM are always
signaled if these are registered and somebody listen to them.
What I wanted to do can be seperated two parts: (1) don't send signals
if the current level is same as the last level. (2) only send the
current level not every lower level.
But, I think that (1) is more close to "edge trigger" and I'll
implement "edge trigger".

>
>> > For example, if CRITICAL event
>> > occurs, it means that LOW and MEDIUM also occur. So, I think that
>> > triggering these lower level events are redundant. And, some users
>> > don't want to see this every event. But, I think that if I don't want
>> > to see lower events, I should add another option.
>
> I think the interface should be consistent with `always' unless there is
> very good reason to do otherwise.
>
>> > Currently, as you mentioned, for edge_trigger option, I'll remove
>> > "level != ev->level" part.
>> >
>> >>
>> >>> +                             continue;
>> >>>                       eventfd_signal(ev->efd, 1);
>> >>>                       signalled = true;
>> >>>               }
>> >>>       }
>> >>> -
>> >>> +     vmpr->last_level = level;
>> >>>       mutex_unlock(&vmpr->events_lock);
>> >>
>> >> I have already asked in the previous version but there was no answer for
>> >> it. So let's try again.
>> >>
>> >> What is the expected semantic when an event is triggered but there is
>> >> nobody to consume it?
>> >> I am not sure that the current implementation is practical. Say that
>> >> last_level is LOW and you just registered your event. Should you see the
>> >> first event or not?
>> >>
>> >> I think that last_level should be per-vmpressure_event and the edge
>> >> would be defined as the even seen for the first time since registration.
>> >
>> > Right. The current implementation could not cover those situations. As
>> > you mentioned, I think that this could be solved by having last_level
>> > per vmpressure_event (after removing "level != ev->level"). If
>> > last_level of each event is set to valid level only after the first
>> > event is signaled, we cannot miss the first signal even when an event
>> > is registered in the middle of runtime.
>> >
>>
>> How about initializing vmpr->last_level = -1 everytime new event is
>> registered? (having last_level per vmpr).
>
> So all those consumers that have seen an event already would be
> surprised that they get the very same event again without transition to
> other level (so it won't be edge triggered anymore). No this doesn't
> make any sense to me.

Right. As you mentioned, if edge trigger option is enabled but same
events are triggered,
it does not mean edge triggered any more. I'll modify it to keep
last_level per vmpressure event.

>
> Please try to think about the interface, what it is supposed to do and
> how it is supposed to behave. The current implementation seems hackish
> to me and it is an example of a single-use-case-designed interface which
> tend to be hard to maintain and a bad idea in long term.
>
>> I think that if we have last_level for each event, only new event
>> could be triggered when the current level is same as the last
>> level. And I think that this is a little awkward.
>
> Why? I might be wrong here but when I register an event I would like to
> get a notification when the event is triggered for the first time from
> my POV. I have no way to find out that such an event has been already
> triggered for somebody else.

Okay, I think that I should keep the meaning of "edge trigger".

>
>> But, if we set vmpr->last_level = -1 when new event is registered,
>> we can see all events with new event even though the level is not
>> changed.
>
> Which basically ruins the idea of the edge triggered event.

Agreed.

Thanks for the comments.
I'll update the patch soon.

Hyunhee Kim.

>
> [...]
> --
> Michal Hocko
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
