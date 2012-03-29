Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 47D176B004A
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 07:10:42 -0400 (EDT)
Message-ID: <4F744327.3010704@parallels.com>
Date: Thu, 29 Mar 2012 13:10:31 +0200
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] simple system for enable/disable slabs being tracked by
 memcg.
References: <1332952945-15909-1-git-send-email-glommer@parallels.com> <CABCjUKDVK2wpCXBxK-J=s9BL+Gaa_E=qA=R_YZhY0xujwf-4Tg@mail.gmail.com>
In-Reply-To: <CABCjUKDVK2wpCXBxK-J=s9BL+Gaa_E=qA=R_YZhY0xujwf-4Tg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: linux-mm@kvack.org, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 03/29/2012 02:01 AM, Suleiman Souhlal wrote:
> Hi Glauber,
>
> On Wed, Mar 28, 2012 at 9:42 AM, Glauber Costa<glommer@parallels.com>  wrote:
>> Hi.
>>
>> This is a proposal I've got for how to finally settle down the
>> question of which slabs should be tracked. The patch I am providing
>> is for discussion only, and should apply ontop of Suleiman's latest
>> version posted to the list.
>>
>> The idea is to create a new file, memory.kmem.slabs_allowed.
>> I decided not to overload the slabinfo file for that, but I can,
>> if you ultimately want to. I just think it is cleaner this way.
>> As a small rationale, I'd like to somehow show which caches are
>> available but disabled. And yet, keep the format compatible with
>> /proc/slabinfo.
>>
>> Reading from this file will provide this information
>> Writers should write a string:
>>   [+-]cache_name
>>
>> The wild card * is accepted, but only that. I am leaving
>> any complex processing to userspace.
>>
>> The * wildcard, though, is nice. It allows us to do:
>>   -* (disable all)
>>   +cache1
>>   +cache2
>>
>> and so on.
>>
>> Part of this patch is actually converting the slab pointers in memcg
>> to a complex memcg-specific structure that can hold a disabled pointer.
>>
>> We could actually store it in a free bit in the address, but that is
>> a first version. Let me know if this is how you would like me to tackle
>> this.
>>
>> With a system like this (either this, or something alike), my opposition
>> to Suleiman's idea of tracking everything under the sun basically vanishes,
>> since I can then selectively disable most of them.
>>
>> I still prefer a special kmalloc call than a GFP flag, though.
>
> How would something like this interact with slab types that will have
> a per-memcg shrinker?
> Only do memcg shrinking for a slab type if it's not disabled?

The idea is that if the slab type is disabled, it should not even be 
created.

I actually plan to include some tests to disallow disabling slabs after 
either they are created already, or we have tasks in the cgroup.

Regardless of the path, this is only sane if it is a setup-like thing 
much like it is for use_hierarchy today.

Enabling a disabled cache, though, can always be fine...

So if the cache was never created, there is nothing to worry about wrt 
shrinkers.

> While I like the idea of making it configurable by the user, I wonder
> if we should be adding even more complexity to an already large
> patchset, at this point.
I don't see a reason not to, specially because it is pretty 
self-contained. Moreover, one of the reasons I moved forward with this, 
is that I believe the kind of interfaces we'll have at hand can 
interfere in some design decisions.

Now, whether or not we should *merge* them all at the same time, is a 
different story. We do can phase it if needed.

> I am also afraid that we might make this too hard setup correctly and use.

Can you please try to make this a bit more sound? At this point, I think 
that getting the interface right is more important than the 
implementation, so your concerns would be a very nice outcome of this 
discussion.

> If it's ok, I'd prefer to keep going with a slab flag being passed to
> kmem_cache_create, to determine if a slab type should be accounted or
> not (opt-in), for now.
See, now that's something I don't agree with.

It's too important of a change for us to keep flipping. So I believe if
everybody agrees with a general interface for disabling/enabling the 
caches, we should design with that in mind (even if we phase the 
merging), and stick to it.

What works best for your use case, I'll leave to you: if it is tracking 
everything, or have a flag for the tracked ones.

But let's make the decision based on how it should look like, not as an 
intermediate step.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
