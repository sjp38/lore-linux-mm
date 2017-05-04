Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 682BB6B0038
	for <linux-mm@kvack.org>; Thu,  4 May 2017 13:24:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f5so14359156pff.13
        for <linux-mm@kvack.org>; Thu, 04 May 2017 10:24:44 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i9si2590808pgn.205.2017.05.04.10.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 10:24:43 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <20170504112159.GC31540@dhcp22.suse.cz>
 <83d4556c-b21c-7ae5-6e83-4621a74f9fd5@huawei.com>
 <20170504131131.GI31540@dhcp22.suse.cz>
 <df1b34fb-f90b-da9e-6723-49e8f1cb1757@huawei.com>
 <20170504140126.GJ31540@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <361e39e9-517a-2fc2-016c-23f9359fef0a@intel.com>
Date: Thu, 4 May 2017 10:24:42 -0700
MIME-Version: 1.0
In-Reply-To: <20170504140126.GJ31540@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Igor Stoppa <igor.stoppa@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/04/2017 07:01 AM, Michal Hocko wrote:
> Just to make my proposal more clear. I suggest the following workflow
> 
> cache = kmem_cache_create(foo, object_size, ..., SLAB_SEAL);
> 
> obj = kmem_cache_alloc(cache, gfp_mask);
> init_obj(obj)
> [more allocations]
> kmem_cache_seal(cache);
> 
> All slab pages belonging to the cache would get write protection. All
> new allocations from this cache would go to new slab pages. Later
> kmem_cache_seal will write protect only those new pages.

Igor, what sizes of objects are you after here, mostly?

I ask because slub, at least, doesn't work at all for objects
>PAGE_SIZE.  It just punts those to the page allocator.  But, you
_could_ still use vmalloc() for those.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
