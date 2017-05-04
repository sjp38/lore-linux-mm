Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A351831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 07:22:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h19so1202466wmi.10
        for <linux-mm@kvack.org>; Thu, 04 May 2017 04:22:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l19si1250581wma.159.2017.05.04.04.22.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 04:22:07 -0700 (PDT)
Date: Thu, 4 May 2017 13:21:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
Message-ID: <20170504112159.GC31540@dhcp22.suse.cz>
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 03-05-17 15:06:36, Igor Stoppa wrote:
> Hello,
> 
> please review my (longish) line of thoughts, below.
> 
> I've restructured them so that they should be easier to follow.
> 
> 
> Observations
> ------------
> 
> * it is currently possible, by using prefix "__read_only", to have the
> linker place a static variable into a special memory region, which will
> become write-protected at the end of the init phase.
> 
> * the purpose is to write-protect data which is not expected to change,
> ever, after it has been initialized.
> 
> * The mechanism used for locking down the memory region is to program
> the MMU to trap writes to said region. It is fairly efficient and
> HW-backed, so it doesn't introduce any major overhead, but the MMU deals
> only with pages or supersets of pages, hence the need to collect all the
> soon-to-be-read-only data - and only that - into the "special region".
> The "__read_only" modifier is the admission ticket.
> 
> * the write-protecting feature helps supporting memory integrity in
> general and can also help spotting rogue writes, whatever their origin
> might be: uninitialized or expired pointers, wrong pointer arithmetic, etc.

I agree that such a feature can be really useful.

> Problem
> -------
> 
> The feature is available only for *static* data - it will not work with
> something like a linked list that is put together during init, for example.
> 
> 
> 
> Wish
> ----
> 
> My starting point are the policy DB of SE Linux and the LSM Hooks, but
> eventually I would like to extend the protection also to other
> subsystems, in a way that can be merged into mainline.
> 
> 
> 
> Analysis
> --------
> 
> * the solution I come up with has to be as little invasive as possible,
> at least for what concerns the various subsystems whose integrity I want
> to enhance.
> 
> * In most, if not all, the cases that could be enhanced, the code will
> be calling kmalloc/vmalloc, indicating GFP_KERNEL as the desired type of
> memory.

How do you tell that the seal is active? I have also asked about the
life time of these objects in the previous email thread. Do you expect
those objects get freed one by one or mostly at once? Is this supposed
to be boot time only or such allocations might happen anytime?

> * I suspect/hope that the various maintainer won't object too much if my
> changes are limited to replacing GFP_KERNEL with some other macro, for
> example what I previously called GFP_LOCKABLE, provided I can ensure that:
> 
>   -1) no penalty is introduced, at least when the extra protection
>       feature is not enabled, iow nobody has to suffer from my changes.
>       This means that GFP_LOCKABLE should fall back to GFP_KERNEL, when
>       it's not enabled.
> 
>   -2) when the extra protection feature is enabled, the code still
>       works as expected, as long as the data identified for this
>       enhancement is really unmodified after init.
> 
> * In my quest for improved memory integrity, I will deal with very
> different memory size being allocated, so if I start writing my own
> memory allocator, starting from a page-aligned chunk of normal memory,
> at best I will end up with a replica of kmalloc, at worst with something
> buggy. Either way, it will be extremely harder to push other subsystems
> to use it.
> I probably wouldn't like it either, if I was a maintainer.

The most immediate suggestion would be to extend SLAB caches with a new
sealing feature. Roughly it would mean that once kmem_cache_seal() is
called on a cache it would changed page tables to used slab pages to RO
state. This would obviously need some fiddling to make those pages not
usable for new allocations from sealed pages. It would also mean some
changes to kfree path but I guess this is doable.

> * While I do not strictly need a new memory zone, memory zones are what
> kmalloc understands at the moment: AFAIK, it is not possible to tell
> kmalloc from which memory pool it should fish out the memory, other than
> having a reference to a memory zone.

As I've said already. I think that a zone is a completely wrong
approach. How would it help anyway. It is the allocator on top of the
page allocator which has to do clever things to support sealing.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
