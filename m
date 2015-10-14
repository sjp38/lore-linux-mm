Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 09AE26B0255
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 04:39:20 -0400 (EDT)
Received: by igsu6 with SMTP id u6so11678108igs.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 01:39:19 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id n10si6223617ion.89.2015.10.14.01.39.18
        for <linux-mm@kvack.org>;
        Wed, 14 Oct 2015 01:39:19 -0700 (PDT)
Message-ID: <561E13FD.2070206@intel.com>
Date: Wed, 14 Oct 2015 16:36:13 +0800
From: Pan Xinhui <xinhuix.pan@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] gfp: GFP_RECLAIM_MASK should include __GFP_NO_KSWAPD
References: <561DE9F3.504@intel.com> <561DEEED.7070609@intel.com> <20151014074134.GD28333@dhcp22.suse.cz>
In-Reply-To: <20151014074134.GD28333@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, nasa4836@gmail.com, mgorman@suse.de, alexander.h.duyck@redhat.com, aneesh.kumar@linux.vnet.ibm.com, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>

hello, Michal
	thanks for your kind reply!
On 2015a1'10ae??14ae?JPY 15:41, Michal Hocko wrote:
> On Wed 14-10-15 13:58:05, Pan Xinhui wrote:
>> Hi, all
>> 	I am working on some debug features' development.
>> I use kmalloc in some places of *scheduler*.
> 
> This sounds inherently dangerous.
> 
that's how we found weird bugs. :)

>> And the gfp_flag is GFP_ATOMIC, code looks like 
>> p = kmalloc(sizeof(*p), GFP_ATOMIC);
>>
>> however I notice GFP_ATOMIC is still not enough. because when system
>> is at low memory state, slub might try to wakeup kswapd. then some
>> weird issues hit.
> 
> gfp flags have been reworked in the current mmotm tree so you want
> __GFP_ATOMIC here. This will be non sleeping allocation which won't even
> wake up kswapd. I guess you do not want/need to touch memory reserves
> for something like a debugging feature (so you do not have to abuse
> __GFP_HIGH)
> 

In my debug patches, I need __GFP_HIGH.
There is one special test case, in boot stage, we will reserve a big range of memory, to try to detect if all drivers can handle low-memory in correct ways.
So maybe I need my own kmalloc succeed.

what I need to do now is just clear __GFP_KSWAPD_RECLAIM in kmalloc.

> [...]
> 
>> After some simple check, I change my codes. this time code looks like:
>> p = kmalloc(sizeof(*p), GFP_ATOMIC | __GFP_NO_KSWAPD);
>> I think this flag will forbid slub to call any scheduler codes. But issue still hit. :(
>>
>> my test result shows that __GFP_NO_KSWAPD is cleared when slub pass gfp_flag to page allocator!!!
>>
>> at last I found it is clear by codes below.
>> 1441 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>> 1442 {
>> 1443         if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
>> 1444                 pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
>> 1445                 BUG();
>> 1446         }
>> 1447 
>> 1448         return allocate_slab(s,
>> 1449                 flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);//all other flags will be cleared. my god!!!
>> 1450 }
>>
>> I think GFP_RECLAIM_MASK should include as many available flags as possible. :)
> 
> Not really. It should only contain those which are really reclaim
> related. The fact that SLUB drops other flags is an internal detail
> of the allocator. If the resulting memory doesn't match the original
> requirements (e.g. zone placing etc...) then it is certainly a bug
> but not a bug in GFP_RECLAIM_MASK.
> 
oh, yes. thanks for explanation.

> Anyway you are right that GFP_RECLAIM_MASK should contain
> __GFP_NO_KSWAPD resp. its new representation which is the case in the
> current mmotm tree as pointed out in previous response.
> 

I am glad to see someone has fix it, too :)


thanks
xinhui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
