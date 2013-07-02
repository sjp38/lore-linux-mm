Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id E74126B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 04:29:08 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 13so3135349lba.16
        for <linux-mm@kvack.org>; Tue, 02 Jul 2013 01:29:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130702043256.GA14927@teo>
References: <20130628043411.GA9100@teo>
	<20130628050712.GA10097@teo>
	<20130628100027.31504abe@redhat.com>
	<20130628165722.GA12271@teo>
	<20130628170917.GA12610@teo>
	<20130628144507.37d28ed9@redhat.com>
	<20130628185547.GA14520@teo>
	<20130628154402.4035f2fa@redhat.com>
	<20130629005637.GA16068@teo>
	<CAOK=xROD2AKbgw4V65ddqWFODtn4B1-uYG-NF==oANqVFmZZtg@mail.gmail.com>
	<20130702043256.GA14927@teo>
Date: Tue, 2 Jul 2013 17:29:06 +0900
Message-ID: <CAOK=xRP9o7+qoOMmKj-ZZOHZtDqErS-SCnDXf86fvTjocQROTg@mail.gmail.com>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
From: Hyunhee Kim <hyunhee.kim@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org

2013/7/2 Anton Vorontsov <anton@enomsg.org>:
> On Mon, Jul 01, 2013 at 05:22:36PM +0900, Hyunhee Kim wrote:
>> >> > > for each event in memory.pressure_level; do
>> >> > >   /* register eventfd to be notified on "event" */
>> >> > > done
>> >> >
>> >> > This scheme registers "all" events.
>> >>
>> >> Yes, because I thought that's the user-case that matters for activity
>> >> manager :)
>> >
>> > Some activity managers use only low levels (Android), some might use only
>> > medium levels (simple load-balancing).
>>
>> When the platform like Android uses only "low" level, is it the
>> process you intended when designing vmpressure?
>>
>> 1. activity manager receives "low" level events
>> 2. it reads and checks the current memory (e.g. available memory) using vmstat
>> 3. if the available memory is not under the threshold (defined e.g. by
>> activity manager), activity manager does nothing
>> 4. if the available memory is under the threshold, activity manager
>> handles it by e.g. reclaiming or killing processes?
>
> Yup, exactly.
>
>> At first time when I saw this vmpressure, I thought that I should
>> register all events ("low", "medium", and "critical
>> ") and use different handler for each event. However, without the mode
>> like strict mode, I should see too many events. So, now, I think that
>> it is better to use only one level and run each handler after checking
>> available memory as you mentioned.
>
> Yup, this should work ideally.

Thanks for your reply.
I think that, as you mentioned, using one level event could work well
when activity manager checks available memory in user space.

I also think that Luiz's use case and the use case I thought at first
(registering "low", "medium", and "critical", and run each handler)
are another examples of use cases that could be widely used.
For example, let's think about the case when userland wants to know
"pressure level" (reclaim ratio calculated by vmpressure 0~60~100).
In this case, if we do not register all of these events and register
only "low" level, we cannot distinguish "low", "medium", and
"critical" pressure level in userland.
This reclaim ratio cannot be identified in userland.

Thanks.
Hyunhee Kim.

>
>> But,
>>
>> 1. Isn't it overhead to read event and check memory state every time
>> we receive events?
>
> Even if it is an overhead, is it measurable? Plus, vmstat/memcg stats are
> the only source of information that Activity Manager can use to make a
> decision, so there is no point in duplicating the information in the
> notifications.
>
>>     - sometimes, even when there are lots of available memory, low
>> level event could occur if most of them is reclaimable memory not free
>> pages.
>
> The point of low level is to signal [any] reclaiming activity. So, yes,
>
>>     - Don't most of platforms use available memory to judge their
>> current memory state?
>
> No, because you hardly want to monitor available memory only. You want to
> take into account the level of the page caches, etc.
>
>> Is there any reason vmpressure use reclaim rate?
>
> Yes, you can refer to this email:
>
>   http://lkml.org/lkml/2012/10/4/145
>
> And here is about the levels thing:
>
>   http://lkml.org/lkml/2012/10/22/177
>
>> IMO, activity manager doesn't have to check available memory if it
>> could receive signal based on the available memory.
>
> But userspace can define its own policy of managing the tasks/resouces
> based on different factors, other than just available memory. And that is
> exactly why we don't filter the events in the kernel anymore. The only
> filtering that we make is the levels, which, as it appears, can work for
> many use-cases.
>
>> 2. If we use only "medium" to avoid the overheads occurred when using
>> "low" level, isn't it possible to miss sending events when there is a
>> little available memory but reclaim ratio is high?
>
> If your app don't "trust" reclaim ratio idicator, then the application can
> use its own heuristics, using low level just to monitor reclaiming
> activity. More than that, you can change vmpressure itself to use
> different heuristics for low/med/crit levels: the point of introducing
> levels was also to hide the implementation and memory management details,
> so if you can come up with a better approach for vmpressure "internals"
> you are more than welcome to do so. :)
>
>> IMHO, we cannot consider and cover all the use cases, but considering
>> some use cases and giving some guides and directions to use this
>> vmpressure will be helpful to make many platform accept this for their
>> low memory manager.
>
> Can't argue with that. :) I guess I will need to better document current
> behavior of the levels and when exactly the events trigger.
>
> Thanks!
>
> Anton
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
