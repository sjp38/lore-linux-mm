Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5396B0740
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 18:47:08 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so186210edm.18
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 15:47:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c58-v6sor5294147edc.24.2018.11.09.15.47.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 15:47:06 -0800 (PST)
Date: Fri, 9 Nov 2018 23:47:04 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/slub: skip node in case there is no slab to acquire
Message-ID: <20181109234704.xtabixem2ynbxlsc@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
 <20181109124806.f4f1b85c09b7cd977b5fbe8c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181109124806.f4f1b85c09b7cd977b5fbe8c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org

On Fri, Nov 09, 2018 at 12:48:06PM -0800, Andrew Morton wrote:
>On Thu,  8 Nov 2018 09:12:04 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
>
>> for_each_zone_zonelist() iterates the zonelist one by one, which means
>> it will iterate on zones on the same node. While get_partial_node()
>> checks available slab on node base instead of zone.
>> 
>> This patch skip a node in case get_partial_node() fails to acquire slab
>> on that node.
>
>This is rather hard to follow.
>
>I *think* the patch is a performance optimization: prevent
>get_any_partial() from checking a node which get_partial_node() has
>already looked at?

You are right :-)

>
>Could we please have a more complete changelog?

Hmm... I would like to.

But I am not sure which part makes you hard to follow. If you would like
to tell me the pain point, I am glad to think about how to make it more
obvious.

>
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -1873,7 +1873,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
>>   * Get a page from somewhere. Search in increasing NUMA distances.
>>   */
>>  static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
>> -		struct kmem_cache_cpu *c)
>> +		struct kmem_cache_cpu *c, int except)
>>  {
>>  #ifdef CONFIG_NUMA
>>  	struct zonelist *zonelist;
>> @@ -1882,6 +1882,9 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
>>  	enum zone_type high_zoneidx = gfp_zone(flags);
>>  	void *object;
>>  	unsigned int cpuset_mems_cookie;
>> +	nodemask_t nmask = node_states[N_MEMORY];
>> +
>> +	node_clear(except, nmask);
>
>And please add a comment describing what's happening here and why it is
>done.  Adding a sentence to the block comment over get_any_partial()
>would be suitable.
>

Sure, I would address this in next spin.

-- 
Wei Yang
Help you, Help me
