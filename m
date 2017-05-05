Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 97CFB6B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 08:09:40 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f102so4212346ioi.7
        for <linux-mm@kvack.org>; Fri, 05 May 2017 05:09:40 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id l45si1843179ote.188.2017.05.05.05.09.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 May 2017 05:09:39 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <20170504112159.GC31540@dhcp22.suse.cz>
 <83d4556c-b21c-7ae5-6e83-4621a74f9fd5@huawei.com>
 <20170504131131.GI31540@dhcp22.suse.cz>
 <df1b34fb-f90b-da9e-6723-49e8f1cb1757@huawei.com>
 <20170504140126.GJ31540@dhcp22.suse.cz>
 <361e39e9-517a-2fc2-016c-23f9359fef0a@intel.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <bfc487a0-0e3e-efb5-8790-bbe052a62362@huawei.com>
Date: Fri, 5 May 2017 15:08:31 +0300
MIME-Version: 1.0
In-Reply-To: <361e39e9-517a-2fc2-016c-23f9359fef0a@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/05/17 20:24, Dave Hansen wrote:
> On 05/04/2017 07:01 AM, Michal Hocko wrote:
>> Just to make my proposal more clear. I suggest the following workflow
>>
>> cache = kmem_cache_create(foo, object_size, ..., SLAB_SEAL);
>>
>> obj = kmem_cache_alloc(cache, gfp_mask);
>> init_obj(obj)
>> [more allocations]
>> kmem_cache_seal(cache);
>>
>> All slab pages belonging to the cache would get write protection. All
>> new allocations from this cache would go to new slab pages. Later
>> kmem_cache_seal will write protect only those new pages.
> 
> Igor, what sizes of objects are you after here, mostly?

Theoretically, anything, since I have not really looked in details into
all the various subsystems, however, taking a more pragmatical approach
and referring to SE Linux and LSM Hooks, which were my initial target,

For SE Linux, I'm taking as example the policy db [1]:
The sizes are mostly small-ish: from 4-6 bytes to 16-32, overall.
There are some exceptions: the main policydb structure is way larger,
but it's not supposed to be instantiated repeatedly.


For LSM Hooks, the sublists in that hydra which goes under the name of
struct security_hook_heads, which are of type struct security_hook_list,
so a handful of bytes for the generic element [2].


> I ask because slub, at least, doesn't work at all for objects
>> PAGE_SIZE.  It just punts those to the page allocator.  But, you
> _could_ still use vmalloc() for those.


I would be surprised to find many objects that are larger than PAGE_SIZE
and qqualify for post-init-read-only protection,  even if the page size
was only 4kB.

>From that perspective, I'm more concerned about avoiding taking a lot of
pages and leaving them mostly unused.

[1] security/selinux/ss/policydb.h
[2] include/linux/lsm_hooks.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
