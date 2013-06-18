Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id A0FE36B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 04:00:08 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z5so3266093lbh.21
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 01:00:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOK=xRMYZokH1rg+dfE0KfPk9NsqPmmaTg-k8sagqRqvR+jG+w@mail.gmail.com>
References: <008a01ce6b4e$079b6a50$16d23ef0$%kim@samsung.com>
	<20130617131551.GA5018@dhcp22.suse.cz>
	<CAOK=xRMYZokH1rg+dfE0KfPk9NsqPmmaTg-k8sagqRqvR+jG+w@mail.gmail.com>
Date: Tue, 18 Jun 2013 17:00:06 +0900
Message-ID: <CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
Subject: Re: [PATCH v3] memcg: event control at vmpressure.
From: Hyunhee Kim <hyunhee.kim@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Anton Vorontsov <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, Kyungmin Park <kyungmin.park@samsung.com>

2013/6/18 Hyunhee Kim <hyunhee.kim@samsung.com>:
> 2013/6/17 Michal Hocko <mhocko@suse.cz>:
>> On Mon 17-06-13 20:30:11, Hyunhee Kim wrote:
>> [...]
>>> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
>>> index 736a601..a18fdb3 100644
>>> --- a/mm/vmpressure.c
>>> +++ b/mm/vmpressure.c
>> [...]
>>> @@ -150,14 +151,16 @@ static bool vmpressure_event(struct vmpressure *vmpr,
>>>       level = vmpressure_calc_level(scanned, reclaimed);
>>>
>>>       mutex_lock(&vmpr->events_lock);
>>> -
>>>       list_for_each_entry(ev, &vmpr->events, node) {
>>>               if (level >= ev->level) {
>>> +                     if (ev->edge_trigger && (level == vmpr->last_level
>>
>>> +                             || level != ev->level))
>>
>> Hmm, why this differs from the "always" semantic? You do not want to see
>> lower events? Why?
>
> Yes, I didn't want to see every lower level events whenever the higher
> level event occurs because the higher event signal implies that the
> lower memory situation also occurs. For example, if CRITICAL event
> occurs, it means that LOW and MEDIUM also occur. So, I think that
> triggering these lower level events are redundant. And, some users
> don't want to see this every event. But, I think that if I don't want
> to see lower events, I should add another option. Currently, as you
> mentioned, for edge_trigger option, I'll remove "level != ev->level"
> part.
>
>>
>>> +                             continue;
>>>                       eventfd_signal(ev->efd, 1);
>>>                       signalled = true;
>>>               }
>>>       }
>>> -
>>> +     vmpr->last_level = level;
>>>       mutex_unlock(&vmpr->events_lock);
>>
>> I have already asked in the previous version but there was no answer for
>> it. So let's try again.
>>
>> What is the expected semantic when an event is triggered but there is
>> nobody to consume it?
>> I am not sure that the current implementation is practical. Say that
>> last_level is LOW and you just registered your event. Should you see the
>> first event or not?
>>
>> I think that last_level should be per-vmpressure_event and the edge
>> would be defined as the even seen for the first time since registration.
>
> Right. The current implementation could not cover those situations. As
> you mentioned, I think that this could be solved by having last_level
> per vmpressure_event (after removing "level != ev->level"). If
> last_level of each event is set to valid level only after the first
> event is signaled, we cannot miss the first signal even when an event
> is registered in the middle of runtime.
>

How about initializing vmpr->last_level = -1 everytime new event is
registered? (having last_level per vmpr). I think that if we have
last_level for each event, only new event could be triggered when the
current level is same as the last level. And I think that this is a
little awkward. But, if we set vmpr->last_level = -1 when new event is
registered, we can see all events with new event even though the level
is not changed.

>>
>>>       return signalled;
>>> @@ -290,9 +293,11 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
>>>   *
>>>   * This function associates eventfd context with the vmpressure
>>>   * infrastructure, so that the notifications will be delivered to the
>>> - * @eventfd. The @args parameter is a string that denotes pressure level
>>> + * @eventfd. The @args parameters are a string that denotes pressure level
>>>   * threshold (one of vmpressure_str_levels, i.e. "low", "medium", or
>>> - * "critical").
>>> + * "critical") and a trigger option that decides whether events are triggered
>>> + * continuously or only on edge ("always" or "edge" if "edge", only the current
>>> + * pressure level is triggered when the pressure level changes.
>>>   *
>>>   * This function should not be used directly, just pass it to (struct
>>>   * cftype).register_event, and then cgroup core will handle everything by
>>> @@ -303,10 +308,14 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>>>  {
>>>       struct vmpressure *vmpr = cg_to_vmpressure(cg);
>>>       struct vmpressure_event *ev;
>>> +     char strlevel[32], strtrigger[32] = "always";
>>>       int level;
>>>
>>> +     if ((sscanf(args, "%s %s\n", strlevel, strtrigger) > 2))
>>> +             return -EINVAL;
>>
>> Ouch! You should rather not let your users write over your stack, should
>> you?
>>
>
> Sorry, this should be fixed in the next patch.
>
>>> +
>>>       for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
>>> -             if (!strcmp(vmpressure_str_levels[level], args))
>>> +             if (!strcmp(vmpressure_str_levels[level], strlevel))
>>>                       break;
>>>       }
>>>
>> [...]
>> --
>> Michal Hocko
>> SUSE Labs
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> Thanks,
> Hyunhee Kim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
