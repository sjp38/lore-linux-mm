Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 8C2916B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 07:41:40 -0400 (EDT)
Message-ID: <4F61D517.7000307@parallels.com>
Date: Thu, 15 Mar 2012 15:40:07 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 07/13] memcg: Slab accounting.
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org> <1331325556-16447-8-git-send-email-ssouhlal@FreeBSD.org> <4F5C7D82.7030904@parallels.com> <CABCjUKDsYyg4ONGTEeh1oen-L=OuBrP53qRdpHAT8AYYQ-JqWA@mail.gmail.com> <4F60775F.20709@parallels.com> <CABCjUKCWaXTzsVaFHG57ELWV4Yk15vt=Ei8tvbsxpQKnxTmksg@mail.gmail.com>
In-Reply-To: <CABCjUKCWaXTzsVaFHG57ELWV4Yk15vt=Ei8tvbsxpQKnxTmksg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@hansenpartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>

On 03/15/2012 02:04 AM, Suleiman Souhlal wrote:
> On Wed, Mar 14, 2012 at 3:47 AM, Glauber Costa<glommer@parallels.com>  wrote:
>> On 03/14/2012 02:50 AM, Suleiman Souhlal wrote:
>>>
>>> On Sun, Mar 11, 2012 at 3:25 AM, Glauber Costa<glommer@parallels.com>
>>>   wrote:
>>>>
>>>> On 03/10/2012 12:39 AM, Suleiman Souhlal wrote:
>>>>>
>>>>> +static inline void
>>>>> +mem_cgroup_kmem_cache_prepare_sleep(struct kmem_cache *cachep)
>>>>> +{
>>>>> +       /*
>>>>> +        * Make sure the cache doesn't get freed while we have
>>>>> interrupts
>>>>> +        * enabled.
>>>>> +        */
>>>>> +       kmem_cache_get_ref(cachep);
>>>>> +       rcu_read_unlock();
>>>>> +}
>>>>
>>>>
>>>>
>>>> Is this really needed ? After this function call in slab.c, the slab code
>>>> itself accesses cachep a thousand times. If it could be freed, it would
>>>> already explode today for other reasons?
>>>> Am I missing something here?
>>>
>>>
>>> We need this because once we drop the rcu_read_lock and go to sleep,
>>> the memcg could get deleted, which could lead to the cachep from
>>> getting deleted as well.
>>>
>>> So, we need to grab a reference to the cache, to make sure that the
>>> cache doesn't disappear from under us.
>>
>>
>> Don't we grab a memcg reference when we fire the cache creation?
>> (I did that for slub, can't really recall from the top of my head if
>> you are doing it as well)
>>
>> That would prevent the memcg to go away, while relieving us from the
>> need to take a temporary reference for every page while sleeping.
>
> The problem isn't the memcg going away, but the cache going away.
>
I see the problem.

I still think there are ways to avoid getting a reference at every page,
but it might not be worth the complication...

> Keep in mind that this function is only called in workqueue context.
> (In the earlier revision of the patchset this function was called in
> the process context, but kmem_cache_create() would ignore memory
> limits, because of __GFP_NOACCOUNT.)

ok, fair.

>
> When mem_cgroup_get_kmem_cache() returns a memcg cache, that cache has
> already been created.
 >
> The memcg pointer is not stable between alloc and free: It can become
> NULL when the cgroup gets deleted, at which point the accounting has
> been "moved to root" (uncharged from the cgroup it was charged in).
> When that has happened, we don't want to uncharge it again.
> I think the current code already handles this situation.
>

Okay, convinced.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
