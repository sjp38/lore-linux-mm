Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D106A6B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 08:20:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b28so570678wrb.2
        for <linux-mm@kvack.org>; Fri, 05 May 2017 05:20:33 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id n46si6180098wrn.248.2017.05.05.05.20.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 May 2017 05:20:32 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <20170504112159.GC31540@dhcp22.suse.cz>
 <83d4556c-b21c-7ae5-6e83-4621a74f9fd5@huawei.com>
 <20170504131131.GI31540@dhcp22.suse.cz>
 <df1b34fb-f90b-da9e-6723-49e8f1cb1757@huawei.com>
 <20170504140126.GJ31540@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <3e798c43-1726-ee7d-add5-762c7e17cb88@huawei.com>
Date: Fri, 5 May 2017 15:19:19 +0300
MIME-Version: 1.0
In-Reply-To: <20170504140126.GJ31540@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>



On 04/05/17 17:01, Michal Hocko wrote:
> On Thu 04-05-17 16:37:55, Igor Stoppa wrote:

[...]

>> The disadvantage is that anything can happen, undetected, while the seal
>> is lifted.
> 
> Yes and I think this makes it basically pointless

ok, this goes a bit beyond what I had in mind initially, but I see your
point

[...]

> Just to make my proposal more clear. I suggest the following workflow
> 
> cache = kmem_cache_create(foo, object_size, ..., SLAB_SEAL);
>
> obj = kmem_cache_alloc(cache, gfp_mask);
> init_obj(obj)
> [more allocations]
> kmem_cache_seal(cache);

In case one doesn't want the feature, at which point would it be disabled?

* not creating the slab
* not sealing it
* something else?

> All slab pages belonging to the cache would get write protection. All
> new allocations from this cache would go to new slab pages. Later
> kmem_cache_seal will write protect only those new pages.

ok

> The main discomfort with this approach is that you have to create those
> caches in advance, obviously. We could help by creating some general
> purpose caches for common sizes but this sound like an overkill to me.
> The caller will know which objects will need the protection so the
> appropriate cache can be created on demand. But this reall depends on
> potential users...

Yes, I provided a more detailed answer in another branch of this thread.
Right now I can answer only for what I have already looked into: SE
Linux policy DB and LSM Hooks, and they do not seem very large.

I do not expect a large footprint, overall, although there might be some
exception.


--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
