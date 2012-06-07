Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 8B4F16B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 19:49:59 -0400 (EDT)
Message-ID: <4FD13E26.4000902@kernel.org>
Date: Fri, 08 Jun 2012 08:49:58 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: zsmalloc concerns
References: <030ff158-3b2b-47a6-98d7-5010f7a9ce6b@default> <4FCDA87B.7020209@kernel.org> <0e40bc09-4e05-426e-8379-bb4eb5b36fab@default> <4FD060E9.7000502@kernel.org> <4e6739af-dd1e-4c40-a85b-9f67c0ddaa13@default>
In-Reply-To: <4e6739af-dd1e-4c40-a85b-9f67c0ddaa13@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>

On 06/08/2012 12:40 AM, Dan Magenheimer wrote:

>> From: Minchan Kim [mailto:minchan@kernel.org]
>> Subject: Re: zsmalloc concerns
>>
>> On 06/07/2012 02:34 AM, Dan Magenheimer wrote:
>>
>>>> From: Minchan Kim [mailto:minchan@kernel.org]
>>>
>>>
>>> However, whenever a compressed item crosses a page
>>> boundary in zsmalloc, zsmalloc creates a special "pair"
>>> mapping of the two pages, and kmap/kunmaps the pair for
>>> every access.  This is why special TLB tricks must
>>> be used by zsmalloc.  I think this can be expensive
>>> so I consider this a disadvantage of zsmalloc, even
>>> though it is very clever and very useful for storing
>>> a large number of items with size larger than PAGE_SIZE/2.
>>
>> Fair.
> 
> By breaking down the opaqueness somewhat, I think
> it is not hard to eliminate this requirement.  The
> caller needs to be aware that an item may cross
> a page boundary and zsmalloc could provide
> hooks such as "map/unmap_first/second_page".
> 
> (In fact, that gives me some ideas on how to improve
> zbud to handle cross-page items.)
> 
>>>> Could you tell us your detailed requirement?
>>>> Let's see it's possible or not at current zsmalloc.
>>>
>>> The objective of the shrinker is to reclaim full
>>> pageframes.  Due to the way zsmalloc works, when
>>> it stores N items in M pages, worst case it
>>> may take N-M zsmalloc "item evictions" before even
>>> a single pageframe is reclaimed.
>>
>> Right.
>>
>>> Last, when that metadata is purged from tmem, for ephemeral
>>> pages the actual stored data can be discarded.  BUT when
>>> the pages are persistent, the data cannot be discarded.
>>> I have preliminary code that decompresses and pushes this
>>> data back into the swapcache.  This too must be atomic.
>>
>> I agree zsmalloc isn't good for you.
>> Then, you can use your allocator "zbud". What's the problem?
>> Do you want to replace zsmalloc with zbud in zram, too?
> 
> No, see below.
> 
>>>>> RAMster maintains data structures to both point to zpages
>>>>> that are local and remote.  Remote pages are identified
>>>>> by a handle-like bit sequence while local pages are identified
>>>>> by a true pointer.  (Note that ramster currently will not
>>>>> run on a HIGHMEM machine.)  RAMster currently differentiates
>>>>> between the two via a hack: examining the LSB.  If the
>>>>> LSB is set, it is a handle referring to a remote page.
>>>>> This works with xvmalloc and zbud but not with zsmalloc's
>>>>> opaque handle.  A simple solution would require zsmalloc
>>>>> to reserve the LSB of the opaque handle as must-be-zero.
>>>>
>>>> As you know, it's not difficult but break opaque handle's concept.
>>>> I want to avoid that and let you put some identifier into somewhere in zcache.
>>>
>>> That would be OK with me if it can be done without a large
>>> increase in memory use.  We have so far avoided adding
>>> additional data to each tmem "pampd".  Adding another
>>> unsigned long worth of data is possible but would require
>>> some bug internal API changes.
>>>
>>> There are many data structures in the kernel that take
>>> advantage of unused low bits in a pointer, like what
>>> ramster is doing.
>>
>> But this case is different. It's a generic library and even it's a HANDLE.
>> I don't want to add such special feature to generic library's handle.
> 
> Zsmalloc is not a generic library yet.  It is currently used
> in zram and for half of zcache.  I think Seth and Nitin had

> planned for it to be used for all of zcache.  I was describing

> the issues I see with using it for all of zcache and even
> for continuing to use it with half of zcache.
> 
>>>> In summary, I WANT TO KNOW your detailed requirement for shrinking zsmalloc.
>>>
>>> My core requirement is that an implementation exists that can
>>> handle pageframe reclaim efficiently and race-free.  AND for
>>> persistent pages, ensure it is possible to return the data
>>> to the swapcache when the containing pageframe is reclaimed.
>>>
>>> I am not saying that zsmalloc *cannot* meet this requirement.
>>> I just think it is already very difficult with a simple
>>> non-opaque allocator such as zbud.  That's why I am trying
>>> to get it all working with zbud first.
>>
>> Agreed. Go ahead with zbud.
>> Again, I can't understand your concern. :)
>> Sorry if I miss your point.
> 
> You asked for my requirements for shrinking with zsmalloc.
> 
> I hoped that Nitin and Seth (or you) could resolve the issues
> so that zsmalloc could be used for zcache.  But making it
> more opaque seems to be going in the wrong direction to me.
> I think it is also the wrong direction for zram (see
> comment above about the TLB issues) *especially* if
> zcache never uses zsmalloc:  Why have a generic allocator
> that is opaque if it only has one user?


It's a just staging now and not a long time.
Who can make sure it doesn't have any users any more in future?
If we decide making it specific to zcache and create ugly interface and
coupling, Potential user for zsmalloc might invent the wheel.

> 
> But if you are the person driving to promote zram and zsmalloc
> out of staging, that is your choice.


I see your concern exactly now.
I'm not strong against breaking opaque if Nitin drive that.
But I hope we can do it without breaking generic allocator's concept.
If we need some more functionality, it would be better to be done in caller's layer.
Otherwise, we can provide new mode of zsmalloc like "Don't store this object crossing page boundary"
and warn "it could lose the space efficiency" to user.

Anyhow, I understand your requirement and will try to understand zcache's requirement as I review the code.
I believe we can solve the issue.

Thanks for the input, Dan!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
