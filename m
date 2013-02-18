Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 3A84D6B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 14:50:18 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 18 Feb 2013 14:50:16 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 4A58D6E801A
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 14:50:13 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1IJoD5T157988
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 14:50:14 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1IJni80017456
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 12:49:47 -0700
Message-ID: <512285C4.4050809@linux.vnet.ibm.com>
Date: Mon, 18 Feb 2013 11:49:24 -0800
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 4/8] zswap: add to mm/
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-5-git-send-email-sjenning@linux.vnet.ibm.com> <511F0536.5030802@gmail.com> <51227FDA.7040000@linux.vnet.ibm.com>
In-Reply-To: <51227FDA.7040000@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Ric Mason <ric.masonn@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/18/2013 11:24 AM, Seth Jennings wrote:
> On 02/15/2013 10:04 PM, Ric Mason wrote:
>> On 02/14/2013 02:38 AM, Seth Jennings wrote:
> <snip>
>>> +/* invalidates all pages for the given swap type */
>>> +static void zswap_frontswap_invalidate_area(unsigned type)
>>> +{
>>> +    struct zswap_tree *tree = zswap_trees[type];
>>> +    struct rb_node *node, *next;
>>> +    struct zswap_entry *entry;
>>> +
>>> +    if (!tree)
>>> +        return;
>>> +
>>> +    /* walk the tree and free everything */
>>> +    spin_lock(&tree->lock);
>>> +    node = rb_first(&tree->rbroot);
>>> +    while (node) {
>>> +        entry = rb_entry(node, struct zswap_entry, rbnode);
>>> +        zs_free(tree->pool, entry->handle);
>>> +        next = rb_next(node);
>>> +        zswap_entry_cache_free(entry);
>>> +        node = next;
>>> +    }
>>> +    tree->rbroot = RB_ROOT;
>>
>> Why don't need rb_erase for every nodes?
>
> We are freeing the entire tree here.  try_to_unuse() in the swapoff
> syscall should have already emptied the tree, but this is here for
> completeness.
>
> rb_erase() will do things like rebalancing the tree; something that
> just wastes time since we are in the process of freeing the whole
> tree.  We are holding the tree lock here so we are sure that no one
> else is accessing the tree while it is in this transient broken state.

If we have a sub-tree like:
     ...
    /
   A
  / \
B   C

B == rb_next(tree)
A == rb_next(B)
C == rb_next(A)

The current code free's A (via zswap_entry_cache_free()) prior to 
examining C, and thus rb_next(C) results in a use after free of A.

You can solve this by doing a post-order traversal of the tree, either

a) in the destructive manner used in a number of filesystems, see 
fs/ubifs/orphan.c ubifs_add_orphan(), for example.

b) or by doing something similar to this commit: 
https://github.com/jmesmon/linux/commit/d9e43aaf9e8a447d6802531d95a1767532339fad 
, which I've been using for some yet-to-be-merged code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
