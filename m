Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9E342808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 07:43:22 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p62so7902639wrc.13
        for <linux-mm@kvack.org>; Wed, 10 May 2017 04:43:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k24si635630wmc.165.2017.05.10.04.43.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 04:43:21 -0700 (PDT)
Date: Wed, 10 May 2017 13:43:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
Message-ID: <20170510114319.GK31466@dhcp22.suse.cz>
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
 <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
 <20170510080542.GF31466@dhcp22.suse.cz>
 <885311a2-5b9f-4402-0a71-5a3be7870aa0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <885311a2-5b9f-4402-0a71-5a3be7870aa0@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Wed 10-05-17 11:57:42, Igor Stoppa wrote:
> On 10/05/17 11:05, Michal Hocko wrote:
[...]
> > To me it seems that this being an initialization mostly thingy a simple
> > allocator which manages a pool of pages (one set of sealed and one for
> > allocations) 
> 
> Shouldn't also the set of pages used for keeping track of the others be
> sealed? Once one is ro, also the other should not change.

Heh, that really depends how much consistency and robustness you want to
achieve. It is really hard to defend against targeted attacks against
the allocator metadata when a code is running in the kernel.

> > and which only appends new objects as they fit to unsealed
> > pages would be sufficient for starter.
> 
> Any "free" that might happen during the initialization transient, would
> actually result in an untracked gap, right?

yes. And once the whole page is free it would get unsealed and returned
to the (page) allocator. This approach would inevitably lead to internal
fragmentation but reducing that would require a pool which is shared for
objects with the common life cycle which is quite hard with requirements
you have (you would have to convey the allocation context to all users
somehow).

> What about the size of the pool of pages?

I wouldn't see that as a big deal. New pages would be allocated as
needed.

> No predefined size, instead request a new page, when the memory
> remaining from the page currently in use is not enough to fit the latest
> allocation request?

exactly

> There are also two aspect we discussed earlier:
> 
> - livepatch: how to deal with it? Identify the page it wants to modify
> and temporarily un-protect it?

Livepatch doesn't support data structures patching currently and even if
it would have to understand those data structures and do something like
copy&replace...
 
> - modules: unloading and reloading modules will eventually lead to
> permanently lost pages, in increasing number.

Each module should free all objects that were allocated on its behalf
and that should result in pages being freed as well

> Loading/unloading repeatedly the same module is probably not so common,
> with a major exception being USB, where almost anything can show up.
> And disappear.
> This seems like a major showstopper for the linear allocator you propose.

I am not sure I understand. If such a module kept allocations behind it
would be a memory leak no matter what.

> My reasoning in pursuing the kmalloc approach was that it is already
> equipped with mechanisms for dealing with these sort of cases, where
> memory can be fragmented.

Yeah, but kmalloc is optimized for a completely different usecase. You
can reuse same pages again and again while you clearly cannot do the
same once you seal a page and make it read only. Well unless you want to
open time windows when the page stops being RO or use a different
mapping for the allocator.

But try to consider how many features of the slab allocator you are
actually going to need wrt. to tweaks it would have to implement to
support this new use case. Maybe duplicating general purpose caches and
creating specialized explicitly is a viable path. I haven't tried
it.

> I also wouldn't risk introducing bugs with my homebrew allocator ...
> 
> The initial thought was that there could be a master toggle to
> seal/unseal all the memory affected.
> 
> But you were not too excited, iirc :-D

yes, If there are different users a pool (kmem_cache like) would be more
natural.

> Alternatively, kmalloc could be enhanced to unseal only the pages it
> wants to modify.

You would have to stop the world to prevent from an accidental overwrite
during that time. Which makes the whole thing quite dubious IMHO.

> I don't think much can be done for data that is placed together, in the
> same page with something that needs to be altered.
> But what is outside of that page could still enjoy the protection from
> the seal.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
