Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 018A0831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 09:11:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w50so1626882wrc.4
        for <linux-mm@kvack.org>; Thu, 04 May 2017 06:11:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 22si2451503wrb.228.2017.05.04.06.11.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 06:11:35 -0700 (PDT)
Date: Thu, 4 May 2017 15:11:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
Message-ID: <20170504131131.GI31540@dhcp22.suse.cz>
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <20170504112159.GC31540@dhcp22.suse.cz>
 <83d4556c-b21c-7ae5-6e83-4621a74f9fd5@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <83d4556c-b21c-7ae5-6e83-4621a74f9fd5@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>

On Thu 04-05-17 15:14:10, Igor Stoppa wrote:
[...]
> I wonder if you are thinking about loadable modules or maybe livepatch.
> My proposal, in its current form, is only about what is done when the
> kernel initialization is performed. So it would not take those cases
> under its umbrella. Actually it might be incompatible with livepatch, if
> any of the read-only data is supposed to be updated.
> 
> Since it's meant to improve the current level of integrity, I would
> prefer to have a progressive approach and address modules/livepatch in a
> later phase, if this is not seen as a show stopper.

I believe that this is a fundamental question. Sealing sounds useful
for after-boot usecases as well and it would change the approach
considerably. Coming up with an ad-hoc solution for the boot only way
seems like a wrong way to me. And as you've said SELinux which is your
target already does the thing after the early boot.

[...]
> > Roughly it would mean that once kmem_cache_seal() is
> > called on a cache it would changed page tables to used slab pages to RO
> > state. This would obviously need some fiddling to make those pages not
> > usable for new allocations from sealed pages. It would also mean some
> > changes to kfree path but I guess this is doable.
> 
> Ok, as it probably has already become evident, I have just started
> peeking into the memory subsystem, so this is the sort of guidance I was
> hoping I could receive =) - thank you
> 
> Question: I see that some pages can be moved around. Would this apply to
> the slab-based solution, or can I assume that once I have certain
> physical pages sealed, they will not be altered anymore?

Slab pages are not migrateable currently. Even if they start being
migrateable it would be an opt-in because that requires pointers tracking
to make sure they are updated properly.
 
> >> * While I do not strictly need a new memory zone, memory zones are what
> >> kmalloc understands at the moment: AFAIK, it is not possible to tell
> >> kmalloc from which memory pool it should fish out the memory, other than
> >> having a reference to a memory zone.
> > 
> > As I've said already. I think that a zone is a completely wrong
> > approach. How would it help anyway. It is the allocator on top of the
> > page allocator which has to do clever things to support sealing.
> 
> 
> Ok, as long as there is a way forward that fits my needs and has the
> possibility to be merged upstream, I'm fine with it.
> 
> I suppose zones are the first thing one meets when reading the code, so
> they are probably the first target that comes to mind.
> That's what happened to me.
> 
> I will probably come back with further questions, but I can then start
> putting together some prototype of what you described.
> 
> I am fine with providing a generic solution, but I must make sure that
> it works with slub. I suppose what you proposed will do it, right?

I haven't researched that too deeply. In principle both SLAB and SLUB
maintain slab pages in a similar way so I do not see any fundamental
problems.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
