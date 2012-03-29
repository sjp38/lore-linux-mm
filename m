Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 67B9F6B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 07:23:14 -0400 (EDT)
Message-ID: <4F74460E.9070709@parallels.com>
Date: Thu, 29 Mar 2012 13:22:54 +0200
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] simple system for enable/disable slabs being tracked by
 memcg.
References: <1332952945-15909-1-git-send-email-glommer@parallels.com> <4F73A6E8.8010402@jp.fujitsu.com>
In-Reply-To: <4F73A6E8.8010402@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Johannes
 Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 03/29/2012 02:03 AM, KAMEZAWA Hiroyuki wrote:
> (2012/03/29 1:42), Glauber Costa wrote:
> 
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
> 
> I like to pass a word 'all' explicitly rather than wildcard..
I don't for a very simple reason:

We don't have a cache called "all", but one could very well come up with
one in a driver.
And then we have problems.

Now, it is a lot less likely that someone will ever create a cache
called "*"

Also, the wildcard allows us to do things like size-*. But that it is
not terribly important,
since I am leaving all the heavy processing for userspace, though. It is
convenient and I
like it, but if you really oppose, we can have * to mean all, but not
allow the * symbol to be
used as a wildcard in the middle of a string.

We could, of course, not even have it, and simply rely on userspace to
read all
caches from the available list and move them to the deny list.

But I think the "disable all" and "enable all" are somewhat special.
There can
be races associated with caches appearing in the middle of those two
operations,
and this semantics avoids them.

That actually applies to the use of * as a wildcard as well. The only
sane way to say:
"Enable/Disable" all size-type caches, is to have it done atomically.

> 
> Hmm, but having private format of list is good ?
> In another idea, how about having 3 files as device cgroup ?
> 
> 	memory.kmem.slabs.allow   (similar to device.allow)
> 	memory.kmem.slabs.deny    (similar to device.deny)
> 	memory.kmem.slabs.list	    (similar to device.list)
> 
> BTW, when a slab which is accounted is changed to be unaccounted,
> res_counter.usage will decrease properly ?
> 
> small comments in below.
> 
> 

>> -	if (cmpxchg(&memcg->slabs[idx], NULL, new_cachep) != NULL) {
>> +	if (cmpxchg(&memcg->slabs[idx].cache, NULL, new_cachep) != NULL) {
>>   		kmem_cache_destroy(new_cachep);
>>   		return cachep;
>>   	}
> 
> 
> I'm sorry if I misunderstand.... can we use cmpxchg in generic code of the kernel ?
> We need to put this under #if defined(__HAVE_ARCH_CMPXCHG) ?
> 
> 

The cmpxchg was already there. I am just patching the cache access.
Now for the question itself, If I'm not mistaken this macro should be
safe. xchg() seems
to be used quite extensively, and I would expect a emulation function to
be provided for arches
lacking cmpxchg ?

Still, is better to have Suleiman to confirm this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
