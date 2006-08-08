Date: Tue, 8 Aug 2006 18:16:45 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
In-Reply-To: <Pine.LNX.4.64.0608081001220.27866@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0608081807380.24142@skynet.skynet.ie>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608081748070.24142@skynet.skynet.ie>
 <Pine.LNX.4.64.0608081001220.27866@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Christoph Lameter wrote:

> On Tue, 8 Aug 2006, Mel Gorman wrote:
>
>> On Tue, 8 Aug 2006, Christoph Lameter wrote:
>>
>>> Add a new gfp flag __GFP_THISNODE to avoid fallback to other nodes. This
>>> flag
>>> is essential if a kernel component requires memory to be located on a
>>> certain node. It will be needed for alloc_pages_node() to force allocation
>>> on the indicated node and for alloc_pages() to force allocation on the
>>> current node.
>>>
>>
>> GFP flags are getting a bit tight. Could this also be done by providing
>
> Right they are gettin scarce.
>
>> alloc_pages_zonelist(int nid, gfp_t gfp_mask, unsigned int order,  struct
>> zonelist *));
>>
>> alloc_pages_node() would be altered to call alloc_pages_zonelist() with the
>> currect zonelist. To avoid fallbacks, callers would need a helper function
>> that provided a zonelist with just zones in a single node.
>
> We would need a whole selection of allocators for this purpose. Some
> candidates:
>
> alloc_pages_current
> alloc_pages_node
> vmalloc
> vmalloc_node
> dma_alloc_coherent
>

>From your set of patches, it's only used for page migration and the IA64 
uncached allocator both of which are using alloc_pages_node() at the 
moment. Do you see a widespread need to avoid fallbacks in other areas?

Also, I just noticed you didn't update GFP_LEVEL_MASK with your new flag. 
That may cause interesting failures in the future, particularly if you 
call into the slab allocator with the new flag.

I'm not rabidly against the use of a GFP flag, I just want to be sure it's 
the only option.

> etc
>
>
> > That would give the ability to avoid fallbacks at least. Avoiding policy
>> temporarily is a bit harder but it is really needed?
>
> Policy and cpusets can redirect allocations. That is one of the key
> problems.
>

Could the policies and cpusets be avoided by allowing a zonelist to be 
specified?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
