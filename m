Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C79276B01B7
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 05:28:04 -0400 (EDT)
Message-ID: <4B9DFD9C.8030608@redhat.com>
Date: Mon, 15 Mar 2010 11:27:56 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315091720.GC18054@balbir.in.ibm.com>
In-Reply-To: <20100315091720.GC18054@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 03/15/2010 11:17 AM, Balbir Singh wrote:
> * Avi Kivity<avi@redhat.com>  [2010-03-15 10:27:45]:
>
>    
>> On 03/15/2010 10:07 AM, Balbir Singh wrote:
>>      
>>> * Avi Kivity<avi@redhat.com>   [2010-03-15 09:48:05]:
>>>
>>>        
>>>> On 03/15/2010 09:22 AM, Balbir Singh wrote:
>>>>          
>>>>> Selectively control Unmapped Page Cache (nospam version)
>>>>>
>>>>> From: Balbir Singh<balbir@linux.vnet.ibm.com>
>>>>>
>>>>> This patch implements unmapped page cache control via preferred
>>>>> page cache reclaim. The current patch hooks into kswapd and reclaims
>>>>> page cache if the user has requested for unmapped page control.
>>>>> This is useful in the following scenario
>>>>>
>>>>> - In a virtualized environment with cache!=none, we see
>>>>>    double caching - (one in the host and one in the guest). As
>>>>>    we try to scale guests, cache usage across the system grows.
>>>>>    The goal of this patch is to reclaim page cache when Linux is running
>>>>>    as a guest and get the host to hold the page cache and manage it.
>>>>>    There might be temporary duplication, but in the long run, memory
>>>>>    in the guests would be used for mapped pages.
>>>>>            
>>>> Well, for a guest, host page cache is a lot slower than guest page cache.
>>>>
>>>>          
>>> Yes, it is a virtio call away, but is the cost of paying twice in
>>> terms of memory acceptable?
>>>        
>> Usually, it isn't, which is why I recommend cache=off.
>>
>>      
> cache=off works for *direct I/O* supported filesystems and my concern is that
> one of the side-effects is that idle VM's can consume a lot of memory
> (assuming all the memory is available to them). As the number of VM's
> grow, they could cache a whole lot of memory. In my experiments I
> found that the total amount of memory cached far exceeded the mapped
> ratio by a large amount when we had idle VM's. The philosophy of this
> patch is to move the caching to the _host_ and let the host maintain
> the cache instead of the guest.
>    

That's only beneficial if the cache is shared.  Otherwise, you could use 
the balloon to evict cache when memory is tight.

Shared cache is mostly a desktop thing where users run similar 
workloads.  For servers, it's much less likely.  So a modified-guest 
doesn't help a lot here.

>>> One of the reasons I created a boot
>>> parameter was to deal with selective enablement for cases where
>>> memory is the most important resource being managed.
>>>
>>> I do see a hit in performance with my results (please see the data
>>> below), but the savings are quite large. The other solution mentioned
>>> in the TODOs is to have the balloon driver invoke this path. The
>>> sysctl also allows the guest to tune the amount of unmapped page cache
>>> if needed.
>>>
>>> The knobs are for
>>>
>>> 1. Selective enablement
>>> 2. Selective control of the % of unmapped pages
>>>        
>> An alternative path is to enable KSM for page cache.  Then we have
>> direct read-only guest access to host page cache, without any guest
>> modifications required.  That will be pretty difficult to achieve
>> though - will need a readonly bit in the page cache radix tree, and
>> teach all paths to honour it.
>>
>>      
> Yes, it is, I've taken a quick look. I am not sure if de-duplication
> would be the best approach, may be dropping the page in the page cache
> might be a good first step. Data consistency would be much easier to
> maintain that way, as long as the guest is not writing frequently to
> that page, we don't need the page cache in the host.
>    

Trimming the host page cache should happen automatically under 
pressure.  Since the page is cached by the guest, it won't be re-read, 
so the host page is not frequently used and then dropped.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
