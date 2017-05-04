Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5C2831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 10:01:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t129so160233wmd.10
        for <linux-mm@kvack.org>; Thu, 04 May 2017 07:01:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l19si2478276wrb.169.2017.05.04.07.01.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 07:01:29 -0700 (PDT)
Date: Thu, 4 May 2017 16:01:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
Message-ID: <20170504140126.GJ31540@dhcp22.suse.cz>
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <20170504112159.GC31540@dhcp22.suse.cz>
 <83d4556c-b21c-7ae5-6e83-4621a74f9fd5@huawei.com>
 <20170504131131.GI31540@dhcp22.suse.cz>
 <df1b34fb-f90b-da9e-6723-49e8f1cb1757@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df1b34fb-f90b-da9e-6723-49e8f1cb1757@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>

On Thu 04-05-17 16:37:55, Igor Stoppa wrote:
> On 04/05/17 16:11, Michal Hocko wrote:
> > On Thu 04-05-17 15:14:10, Igor Stoppa wrote:
> 
> > I believe that this is a fundamental question. Sealing sounds useful
> > for after-boot usecases as well and it would change the approach
> > considerably. Coming up with an ad-hoc solution for the boot only way
> > seems like a wrong way to me. And as you've said SELinux which is your
> > target already does the thing after the early boot.
> 
> I didn't spend too many thoughts on this so far, because the zone-based
> approach seemed almost doomed, so I wanted to wait for the evolution of
> the discussion :-)
> 
> The main question here is granularity, I think.
> 
> At least, as first cut, the simpler approach would be to have a master
> toggle: when some legitimate operation needs to happen, the seal is
> lifted across the entire range, then it is put back in place, once the
> operation has concluded.
> 
> Simplicity is the main advantage.
> 
> The disadvantage is that anything can happen, undetected, while the seal
> is lifted.

Yes and I think this makes it basically pointless

> OTOH the amount of code that could backfire should be fairly limited, so
> it doesn't seem a huge issue to me.
> 
> The alternative would be to somehow know what a write will change and
> make only the appropriate page(s) writable. But it seems overkill to me.
> Especially because in some cases, with huge pages, everything would fit
> anyway in one page.
> 
> One more option that comes to mind - but I do not know how realistic it
> would be - is to have multiple slabs, to be used for different purposes.
> Ex: one for the monolithic kernel and one for modules.
> It wouldn't help for livepatch, though, as it can modify both, so both
> would have to be unprotected.

Just to make my proposal more clear. I suggest the following workflow

cache = kmem_cache_create(foo, object_size, ..., SLAB_SEAL);

obj = kmem_cache_alloc(cache, gfp_mask);
init_obj(obj)
[more allocations]
kmem_cache_seal(cache);

All slab pages belonging to the cache would get write protection. All
new allocations from this cache would go to new slab pages. Later
kmem_cache_seal will write protect only those new pages.

The main discomfort with this approach is that you have to create those
caches in advance, obviously. We could help by creating some general
purpose caches for common sizes but this sound like an overkill to me.
The caller will know which objects will need the protection so the
appropriate cache can be created on demand. But this reall depends on
potential users...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
