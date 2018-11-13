Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 682606B0008
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 08:26:27 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so5902714edb.1
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 05:26:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l37sor6600053edb.2.2018.11.13.05.26.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 05:26:26 -0800 (PST)
Date: Tue, 13 Nov 2018 13:26:24 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/slub: skip node in case there is no slab to acquire
Message-ID: <20181113132624.xjnvxhrt4jk7mt3m@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
 <20181113131751.GC16182@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113131751.GC16182@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, cl@linux.com, penberg@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Nov 13, 2018 at 02:17:51PM +0100, Michal Hocko wrote:
>On Thu 08-11-18 09:12:04, Wei Yang wrote:
>> for_each_zone_zonelist() iterates the zonelist one by one, which means
>> it will iterate on zones on the same node. While get_partial_node()
>> checks available slab on node base instead of zone.
>> 
>> This patch skip a node in case get_partial_node() fails to acquire slab
>> on that node.
>
>If this is an optimization then it should be accompanied by some
>numbers.

Let me try to get some test result.

Do you have some suggestion on the test suite? Is kernel build a proper
test?

>
>> @@ -1882,6 +1882,9 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
>>  	enum zone_type high_zoneidx = gfp_zone(flags);
>>  	void *object;
>>  	unsigned int cpuset_mems_cookie;
>> +	nodemask_t nmask = node_states[N_MEMORY];
>
>This will allocate a large bitmask on the stack and that is no-go for
>something that might be called from a potentially deep call stack
>already. Also are you sure that the micro-optimization offsets the
>copying overhead?
>

You are right. I didn't pay attention to this.

I got one other idea to achieve this effect, like the one in
get_page_from_freelist().

In get_page_from_freelist(), we use last_pgdat_dirty_limit to track the
last node out of dirty limit. I am willing to borrow this idea in
get_any_partial() to skip a node.

Well, let me do some tests to see whether this is visible.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
