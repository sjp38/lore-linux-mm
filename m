Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 33ED16B0008
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 13:27:51 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 13:27:50 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3CD376E8057
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 13:27:45 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LIRjIq279922
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 13:27:46 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LIQ6sR016367
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:26:08 -0700
Message-ID: <512666B2.1020609@linux.vnet.ibm.com>
Date: Thu, 21 Feb 2013 12:25:54 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv6 0/8] zswap: compressed swap caching
References: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com> <9e251fb2-be82-41d2-b6cd-e46525b263cb@default>
In-Reply-To: <9e251fb2-be82-41d2-b6cd-e46525b263cb@default>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/21/2013 09:50 AM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: [PATCHv6 0/8] zswap: compressed swap caching
>>
>> Changelog:
>>
>> v6:
>> * fix improper freeing of rbtree (Cody)
> 
> Cody's bug fix reminded me of a rather fundamental question:
> 
> Why does zswap use a rbtree instead of a radix tree?
> 
> Intuitively, I'd expect that pgoff_t values would
> have a relatively high level of locality AND at any one time
> the set of stored pgoff_t values would be relatively non-sparse.
> This would argue that a radix tree would result in fewer nodes
> touched on average for lookup/insert/remove.

I considered using a radix tree, but I don't think there is a compelling
reason to choose a radix tree over a red-black tree in this case
(explanation below).

>From a runtime standpoint, a radix tree might be faster.  The swap
offsets will be largely in linearly bunched groups over the indexed
range.  However, there are also memory constraints to consider in this
particular situation.

Using a radix tree could result in intermediate radix_tree_node
allocations in the store (insert) path in addition to the zswap_entry
allocation.  Since we are under memory pressure, using the red-black
tree, whose metadata is included in the struct zswap_entry, reduces the
number of opportunities to fail.

On my system, the radix_tree_node structure is 568 bytes.  The
radix_tree_node cache requires 4 pages per slab, an order-2 page
allocation.  Growing that cache will be difficult under the pressure.

In my mind, cost of even a single node allocation failure resulting in
an additional page swapped to disk will more that wipe out any possible
performance advantage using a radix tree might have.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
