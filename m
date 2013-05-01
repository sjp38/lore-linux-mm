Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id B26C46B016B
	for <linux-mm@kvack.org>; Wed,  1 May 2013 04:07:03 -0400 (EDT)
Received: by mail-yh0-f52.google.com with SMTP id z41so244151yhz.39
        for <linux-mm@kvack.org>; Wed, 01 May 2013 01:07:02 -0700 (PDT)
Message-ID: <5180CD1C.7050206@gmail.com>
Date: Wed, 01 May 2013 16:06:52 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv6 0/8] zswap: compressed swap caching
References: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com> <9e251fb2-be82-41d2-b6cd-e46525b263cb@default> <512666B2.1020609@linux.vnet.ibm.com>
In-Reply-To: <512666B2.1020609@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hi Seth,
On 02/22/2013 02:25 AM, Seth Jennings wrote:
> On 02/21/2013 09:50 AM, Dan Magenheimer wrote:
>>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>>> Subject: [PATCHv6 0/8] zswap: compressed swap caching
>>>
>>> Changelog:
>>>
>>> v6:
>>> * fix improper freeing of rbtree (Cody)
>> Cody's bug fix reminded me of a rather fundamental question:
>>
>> Why does zswap use a rbtree instead of a radix tree?
>>
>> Intuitively, I'd expect that pgoff_t values would
>> have a relatively high level of locality AND at any one time
>> the set of stored pgoff_t values would be relatively non-sparse.
>> This would argue that a radix tree would result in fewer nodes
>> touched on average for lookup/insert/remove.
> I considered using a radix tree, but I don't think there is a compelling
> reason to choose a radix tree over a red-black tree in this case
> (explanation below).
>
>  From a runtime standpoint, a radix tree might be faster.  The swap
> offsets will be largely in linearly bunched groups over the indexed
> range.  However, there are also memory constraints to consider in this
> particular situation.
>
> Using a radix tree could result in intermediate radix_tree_node
> allocations in the store (insert) path in addition to the zswap_entry
> allocation.  Since we are under memory pressure, using the red-black

Then in which case radix tree is prefer and in which case redblack tree 
is better?

> tree, whose metadata is included in the struct zswap_entry, reduces the
> number of opportunities to fail.
>
> On my system, the radix_tree_node structure is 568 bytes.  The
> radix_tree_node cache requires 4 pages per slab, an order-2 page
> allocation.  Growing that cache will be difficult under the pressure.
>
> In my mind, cost of even a single node allocation failure resulting in
> an additional page swapped to disk will more that wipe out any possible
> performance advantage using a radix tree might have.
>
> Thanks,
> Seth
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
