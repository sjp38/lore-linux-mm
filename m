Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1628B6B000D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 23:21:57 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 13-v6so3702486oiq.1
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 20:21:57 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p196-v6si2499758oic.450.2018.08.02.20.21.55
        for <linux-mm@kvack.org>;
        Thu, 02 Aug 2018 20:21:55 -0700 (PDT)
Subject: Re: [RFC 1/2] slub: Avoid trying to allocate memory on offline nodes
References: <20180801200418.1325826-1-jeremy.linton@arm.com>
 <20180801200418.1325826-2-jeremy.linton@arm.com>
 <20180802091554.GE10808@dhcp22.suse.cz>
From: Jeremy Linton <jeremy.linton@arm.com>
Message-ID: <c6caddbf-e275-219e-12b6-538a53ced17d@arm.com>
Date: Thu, 2 Aug 2018 22:21:53 -0500
MIME-Version: 1.0
In-Reply-To: <20180802091554.GE10808@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, vbabka@suse.cz, Punit.Agrawal@arm.com, Lorenzo.Pieralisi@arm.com, linux-arm-kernel@lists.infradead.org, bhelgaas@google.com, linux-kernel@vger.kernel.org

Hi,

On 08/02/2018 04:15 AM, Michal Hocko wrote:
> On Wed 01-08-18 15:04:17, Jeremy Linton wrote:
> [...]
>> @@ -2519,6 +2519,8 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
>>   		if (unlikely(!node_match(page, searchnode))) {
>>   			stat(s, ALLOC_NODE_MISMATCH);
>>   			deactivate_slab(s, page, c->freelist, c);
>> +			if (!node_online(searchnode))
>> +				node = NUMA_NO_NODE;
>>   			goto new_slab;
> 
> This is inherently racy. Numa node can get offline at any point after
> you check it here. Making it race free would involve some sort of
> locking and I am not really convinced this is a good idea.

I spent some time looking/thinking about this, and i'm pretty sure its 
not creating any new problems. But OTOH, I think the node_online() check 
is probably a bit misleading as what we really want to assure is that 
node<MAX_NUMNODES and that there is going to be a valid entry in 
NODE_DATA() so we don't deference null.


> 
>>   		}
>>   	}
>> -- 
>> 2.14.3
>>
> 
