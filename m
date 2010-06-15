Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 45C946B01CC
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 02:58:37 -0400 (EDT)
Message-ID: <4C172499.7090800@redhat.com>
Date: Tue, 15 Jun 2010 09:58:33 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
References: <20100611045600.GE5191@balbir.in.ibm.com> <4C15E3C8.20407@redhat.com> <20100614084810.GT5191@balbir.in.ibm.com> <4C16233C.1040108@redhat.com> <20100614125010.GU5191@balbir.in.ibm.com> <4C162846.7030303@redhat.com> <1276529596.6437.7216.camel@nimitz> <4C164E63.2020204@redhat.com> <1276530932.6437.7259.camel@nimitz> <4C1659F8.3090300@redhat.com> <20100614174548.GB5191@balbir.in.ibm.com>
In-Reply-To: <20100614174548.GB5191@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/14/2010 08:45 PM, Balbir Singh wrote:
>
>> There are two decisions that need to be made:
>>
>> - how much memory a guest should be given
>> - given some guest memory, what's the best use for it
>>
>> The first question can perhaps be answered by looking at guest I/O
>> rates and giving more memory to more active guests.  The second
>> question is hard, but not any different than running non-virtualized
>> - except if we can detect sharing or duplication.  In this case,
>> dropping a duplicated page is worthwhile, while dropping a shared
>> page provides no benefit.
>>      
> I think there is another way of looking at it, give some free memory
>
> 1. Can the guest run more applications or run faster
>    

That's my second question.  How to best use this memory.  More 
applications == drop the page from cache, faster == keep page in cache.

All we need is to select the right page to drop.

> 2. Can the host potentially get this memory via ballooning or some
> other means to start newer guest instances
>    

Well, we already have ballooning.  The question is can we improve the 
eviction algorithm.

> I think the answer to 1 and 2 is yes.
>
>    
>> How the patch helps answer either question, I'm not sure.  I don't
>> think preferential dropping of unmapped page cache is the answer.
>>
>>      
> Preferential dropping as selected by the host, that knows about the
> setup and if there is duplication involved. While we use the term
> preferential dropping, remember it is still via LRU and we don't
> always succeed. It is a best effort (if you can and the unmapped pages
> are not highly referenced) scenario.
>    

How can the host tell if there is duplication?  It may know it has some 
pagecache, but it has no idea whether or to what extent guest pagecache 
duplicates host pagecache.

>>> Those tell you how to balance going after the different classes of
>>> things that we can reclaim.
>>>
>>> Again, this is useless when ballooning is being used.  But, I'm thinking
>>> of a more general mechanism to force the system to both have MemFree
>>> _and_ be acting as if it is under memory pressure.
>>>        
>> If there is no memory pressure on the host, there is no reason for
>> the guest to pretend it is under pressure.  If there is memory
>> pressure on the host, it should share the pain among its guests by
>> applying the balloon.  So I don't think voluntarily dropping cache
>> is a good direction.
>>
>>      
> There are two situations
>
> 1. Voluntarily drop cache, if it was setup to do so (the host knows
> that it caches that information anyway)
>    

It doesn't, really.  The host only has aggregate information about 
itself, and no information about the guest.

Dropping duplicate pages would be good if we could identify them.  Even 
then, it's better to drop the page from the host, not the guest, unless 
we know the same page is cached by multiple guests.

But why would the guest voluntarily drop the cache?  If there is no 
memory pressure, dropping caches increases cpu overhead and latency even 
if the data is still cached on the host.

> 2. Drop the cache on either a special balloon option, again the host
> knows it caches that very same information, so it prefers to free that
> up first.
>    

Dropping in response to pressure is good.  I'm just not convinced the 
patch helps in selecting the correct page to drop.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
