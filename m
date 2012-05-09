Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id CDA336B00F2
	for <linux-mm@kvack.org>; Wed,  9 May 2012 00:06:57 -0400 (EDT)
Message-ID: <4FA9ED64.4070909@kernel.org>
Date: Wed, 09 May 2012 13:07:00 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] zsmalloc: zsmalloc: align cache line size
References: <1336027242-372-1-git-send-email-minchan@kernel.org> <1336027242-372-4-git-send-email-minchan@kernel.org> <4FA28EFD.5070002@vflare.org> <4FA33E89.6080206@kernel.org> <alpine.LFD.2.02.1205071038090.2851@tux.localdomain> <4FA7C2BC.2090400@vflare.org> <4FA87837.3050208@kernel.org> <731b6638-8c8c-4381-a00f-4ecd5a0e91ae@default> <4FA9C127.5020908@kernel.org> <8a42cbff-f7f2-400a-a9c1-c3b3d73ab979@default>
In-Reply-To: <8a42cbff-f7f2-400a-a9c1-c3b3d73ab979@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org

On 05/09/2012 12:08 PM, Dan Magenheimer wrote:

>> From: Minchan Kim [mailto:minchan@kernel.org]
>> Subject: Re: [PATCH 4/4] zsmalloc: zsmalloc: align cache line size
>>
>> On 05/08/2012 11:00 PM, Dan Magenheimer wrote:
>>
>>>> From: Minchan Kim [mailto:minchan@kernel.org]
>>>>> zcache can potentially create a lot of pools, so the latter will save
>>>>> some memory.
>>>>
>>>>
>>>> Dumb question.
>>>> Why should we create pool per user?
>>>> What's the problem if there is only one pool in system?
>>>
>>> zcache doesn't use zsmalloc for cleancache pages today, but
>>> that's Seth's plan for the future.  Then if there is a
>>> separate pool for each cleancache pool, when a filesystem
>>> is umount'ed, it isn't necessary to walk through and delete
>>> all pages one-by-one, which could take quite awhile.
>>
>>> ramster needs one pool for each client (i.e. machine in the
>>> cluster) for frontswap pages for the same reason, and
>>> later, for cleancache pages, one per mounted filesystem
>>> per client
>>
>> Fair enough.
>>
>> Then, how about this interfaces like slab?
>>
>> 1. zs_handle zs_malloc(size_t size, gfp_t flags) - share a pool by many subsystem(like kmalloc)
>> 2. zs_handle zs_malloc_pool(struct zs_pool *pool, size_t size) - use own pool(like kmem_cache_alloc)
>>
>> Any thoughts?
> 
> Seems fine to me.
> 
>> But some subsystems can't want a own pool for not waste unnecessary memory.
> 
> Are you using zsmalloc for something else in the kernel?  I'm
> wondering what other subsystem would have random size allocations
> always less than a page.


Nope. It's a just wondering during review the code about interface.
I thought normal user can use zs_malloc without creating pool so that it's rather easy to use
and simillar to normal allocator which can help availability of zsmalloc.

And it will make space efficiency good.
For example, some subsystem makes own pool and use a object in a class which consists of 4-pages once during her life.
Other object unused in the class are just wasteful but if we can share a pool with others, we may reduce such inefficiency.

I think zsmalloc's goal should be biased on space efficiency.

> 
> Thanks,
> Dan
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
