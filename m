Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1798280858
	for <linux-mm@kvack.org>; Wed, 10 May 2017 04:59:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q91so6345463wrb.8
        for <linux-mm@kvack.org>; Wed, 10 May 2017 01:59:17 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id q16si2635930wrc.183.2017.05.10.01.59.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 01:59:16 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
 <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
 <20170510080542.GF31466@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <885311a2-5b9f-4402-0a71-5a3be7870aa0@huawei.com>
Date: Wed, 10 May 2017 11:57:42 +0300
MIME-Version: 1.0
In-Reply-To: <20170510080542.GF31466@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>
Cc: Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 10/05/17 11:05, Michal Hocko wrote:
> On Fri 05-05-17 13:42:27, Igor Stoppa wrote:

[...]

>> ... in the case I have in mind, I have various, heterogeneous chunks of
>> data, coming from various subsystems, not necessarily page aligned.
>> And, even if they were page aligned, most likely they would be far
>> smaller than a page, even a 4k page.
> 
> This aspect of various sizes makes the SLAB allocator not optimal
> because it operates on caches (pools of pages) which manage objects of
> the same size.

Indeed, that's why I wasn't too excited about caches, but probably I was
not able to explain sufficiently well why in the RFC :-/

> You could use the maximum size of all objects and waste
> some memory but you would have to know this max in advance which would
> make this approach less practical. You could create more caches of
> course but that still requires to know those sizes in advance.

Yes, and even generic per-architecture or even per board profiling
wouldn't necessarily do much good: taking SE Linux as example, one could
have two identical boards with almost identical binaries installed, only
differing in the rules/policy.
That difference alone could easily lead to very different size
requirements for the sealable page pool.

> So it smells like a dedicated allocator which operates on a pool of
> pages might be a better option in the end.

ok

> This depends on what you
> expect from the allocator. NUMA awareness? Very effective hotpath? Very
> good fragmentation avoidance? CPU cache awareness? Special alignment
> requirements? Reasonable free()? Etc...

>From the perspective of selling the feature to as many subsystems as
possible, I'd say that as primary requirement, it shouldn't affect
runtime performance.
I suppose (but it's just my guess) that trading milliseconds-scale
boot-time slowdown, for additional integrity is acceptable in the vast
majority of cases.

The only alignment requirements that I can think of, are coming from the
MMU capability of dealing only with physical pages, when it comes to
write-protect them.

> To me it seems that this being an initialization mostly thingy a simple
> allocator which manages a pool of pages (one set of sealed and one for
> allocations) 

Shouldn't also the set of pages used for keeping track of the others be
sealed? Once one is ro, also the other should not change.

> and which only appends new objects as they fit to unsealed
> pages would be sufficient for starter.

Any "free" that might happen during the initialization transient, would
actually result in an untracked gap, right?

What about the size of the pool of pages?
No predefined size, instead request a new page, when the memory
remaining from the page currently in use is not enough to fit the latest
allocation request?

There are also two aspect we discussed earlier:

- livepatch: how to deal with it? Identify the page it wants to modify
and temporarily un-protect it?

- modules: unloading and reloading modules will eventually lead to
permanently lost pages, in increasing number.
Loading/unloading repeatedly the same module is probably not so common,
with a major exception being USB, where almost anything can show up.
And disappear.
This seems like a major showstopper for the linear allocator you propose.

My reasoning in pursuing the kmalloc approach was that it is already
equipped with mechanisms for dealing with these sort of cases, where
memory can be fragmented.
I also wouldn't risk introducing bugs with my homebrew allocator ...

The initial thought was that there could be a master toggle to
seal/unseal all the memory affected.

But you were not too excited, iirc :-D
Alternatively, kmalloc could be enhanced to unseal only the pages it
wants to modify.

I don't think much can be done for data that is placed together, in the
same page with something that needs to be altered.
But what is outside of that page could still enjoy the protection from
the seal.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
