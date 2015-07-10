Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A04186B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 04:28:51 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so36745984pdb.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 01:28:51 -0700 (PDT)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id cj15si13458169pdb.199.2015.07.10.01.28.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jul 2015 01:28:50 -0700 (PDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Fri, 10 Jul 2015 18:28:46 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C84B72CE8040
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 18:28:42 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6A8SVuj66584734
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 18:28:40 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6A8S92b003967
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 18:28:09 +1000
Date: Fri, 10 Jul 2015 16:27:51 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/page: refine the calculation of highest possible node
 id
Message-ID: <20150710082751.GA21679@richard>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1436509581-9370-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20150710003555.4398c8ad.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710003555.4398c8ad.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, tj@kernel.org, linux-mm@kvack.org

On Fri, Jul 10, 2015 at 12:35:55AM -0700, Andrew Morton wrote:
>On Fri, 10 Jul 2015 14:26:21 +0800 Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>
>> nr_node_ids records the highest possible node id, which is calculated by
>> scanning the bitmap node_states[N_POSSIBLE]. Current implementation scan
>> the bitmap from the beginning, which will scan the whole bitmap.
>> 
>> This patch reverse the order by scanning from the end. By doing so, this
>> will save some time whose worst case is the best case of current
>> implementation.
>
>It hardly matters - setup_nr_node_ids() is called a single time, at boot.

Hi, Andrew,

Glad to receive your comment :-)

Yes, the hardly matters on the performance side, while scanning from the end is
a better way to me. Hope you like it.

>
>> --- a/include/linux/nodemask.h
>> +++ b/include/linux/nodemask.h
>> @@ -253,6 +253,12 @@ static inline int __first_node(const nodemask_t *srcp)
>>  	return min_t(int, MAX_NUMNODES, find_first_bit(srcp->bits, MAX_NUMNODES));
>>  }
>>  
>> +#define last_node(src) __last_node(&(src))
>> +static inline int __last_node(const nodemask_t *srcp)
>> +{
>> +	return min_t(int, MAX_NUMNODES, find_last_bit(srcp->bits, MAX_NUMNODES));
>> +}
>
>hm.  Why isn't this just
>
>	return find_last_bit(srcp->bits, MAX_NUMNODES);
>
>?

I found this comment in the code:

/* FIXME: better would be to fix all architectures to never return
          > MAX_NUMNODES, then the silly min_ts could be dropped. */

While I didn't find the original commit for this change, so not dear to change
the related code format.

>
>> @@ -360,10 +366,20 @@ static inline void __nodes_fold(nodemask_t *dstp, const nodemask_t *origp,
>>  	for ((node) = first_node(mask);			\
>>  		(node) < MAX_NUMNODES;			\
>>  		(node) = next_node((node), (mask)))
>> +
>> +static inline int highest_node_id(const nodemask_t possible)
>> +{
>> +	return last_node(possible);
>> +}
>
>`possible' isn't a good identifier.  This function doesn't *know* that
>its caller passed node_possible_map.  Another caller could pass some
>other nodemask.
>

Agree. I would change it.

>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5453,8 +5453,7 @@ void __init setup_nr_node_ids(void)
>>  	unsigned int node;
>>  	unsigned int highest = 0;
>
>The "= 0" can now be removed.
>
>> -	for_each_node_mask(node, node_possible_map)
>> -		highest = node;
>> +	highest = highest_node_id(node_possible_map);
>
>I suspect we can just open-code a find_last_bit() here and all the
>infrastructure isn't needed.
>

This is reasonable. If so, the code would be more clear.

>>  	nr_node_ids = highest + 1;
>>  }
>
>
>And I suspect the "#if MAX_NUMNODES > 1" around setup_nr_node_ids() can
>be removed.  Because if MAX_NUMNODES is ever <= 1 when
>CONFIG_HAVE_MEMBLOCK_NODE_MAP=y, the kernel won't compile.

Hmm... for this one, I am not sure.

#define MAX_NUMNODES    (1 << NODES_SHIFT)
#define NODES_SHIFT     CONFIG_NODES_SHIFT

CONFIG_NODES_SHIFT depends on CONFIG_NEED_MULTIPLE_NODES, which depends on
CONFIG_DISCONTIGMEM or CONFIG_NUMA.

And I grep the kernel tree, not see other configuration would depend on
HAVE_MEMBLOCK_NODE_MAP.

So I am don't get a clear clue for this suspection.

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
