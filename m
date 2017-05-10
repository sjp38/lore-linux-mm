Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 88D682808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 11:21:07 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id k4so18646344uaa.0
        for <linux-mm@kvack.org>; Wed, 10 May 2017 08:21:07 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id x3si1488820uab.185.2017.05.10.08.21.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 08:21:06 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
 <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
 <20170510080542.GF31466@dhcp22.suse.cz>
 <885311a2-5b9f-4402-0a71-5a3be7870aa0@huawei.com>
 <20170510114319.GK31466@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <1a8cc1f4-0b72-34ea-43ad-5ece22a8d5cf@huawei.com>
Date: Wed, 10 May 2017 18:19:30 +0300
MIME-Version: 1.0
In-Reply-To: <20170510114319.GK31466@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Laura Abbott <labbott@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 10/05/17 14:43, Michal Hocko wrote:
> On Wed 10-05-17 11:57:42, Igor Stoppa wrote:
>> On 10/05/17 11:05, Michal Hocko wrote:
> [...]
>>> To me it seems that this being an initialization mostly thingy a simple
>>> allocator which manages a pool of pages (one set of sealed and one for
>>> allocations) 
>>
>> Shouldn't also the set of pages used for keeping track of the others be
>> sealed? Once one is ro, also the other should not change.
> 
> Heh, that really depends how much consistency and robustness you want to
> achieve. It is really hard to defend against targeted attacks against
> the allocator metadata when a code is running in the kernel.

Taking the trouble to implement the sealing, then anything that doesn't
have a justification for staying R/W is fair game for sealing, IMHO.

>>> and which only appends new objects as they fit to unsealed
>>> pages would be sufficient for starter.
>>
>> Any "free" that might happen during the initialization transient, would
>> actually result in an untracked gap, right?
> 
> yes. And once the whole page is free it would get unsealed and returned
> to the (page) allocator.

Which means that there must be some way to track the freeing.
I intentionally omitted it, because I wasn't sure it would still be
compatible with the idea of a simple linear allocator.

> This approach would inevitably lead to internal
> fragmentation but reducing that would require a pool which is shared for
> objects with the common life cycle which is quite hard with requirements
> you have (you would have to convey the allocation context to all users
> somehow).

What if the users were unaware of most of the context and would only use
some flag, say GFP_SEAL?
Shouldn't the allocator be the only one aware of the context?
Context being the actual set of pages used.

Other idea: for each logical group of objects having same lifecycle,
define a pool, then do linear allocation within the pool for the
respective logical group.

Still some way would be needed to track the utilization of each page,
but it would ensure that when a logical group is discarded, all its
related pages are freed.

>> What about the size of the pool of pages?
> 
> I wouldn't see that as a big deal. New pages would be allocated as
> needed.

ok

[...]

>> - modules: unloading and reloading modules will eventually lead to
>> permanently lost pages, in increasing number.
> 
> Each module should free all objects that were allocated on its behalf
> and that should result in pages being freed as well

Only if the objects are enforced to be contiguous and the start is at
the beginning of a page, which seems to go in the direction of having a
memory pool for each module.

>> Loading/unloading repeatedly the same module is probably not so common,
>> with a major exception being USB, where almost anything can show up.
>> And disappear.
>> This seems like a major showstopper for the linear allocator you propose.
> 
> I am not sure I understand. If such a module kept allocations behind it
> would be a memory leak no matter what.

What I had in mind is that, with a global linear allocator _without_
support for returning "freed" pages, there would be a memory consumption
progressively increasing.

But even if the module frees correctly its allocations and they are
tracked correctly, it's still possible that some page doesn't get
returned, unless the module had started using data from the beginning of
a brand new page and nothing else but that module used it.

So it really looks like we are discussing a per-module (linear) allocator.

Probably that's what you meant all the time and I just realized it now ...

>> My reasoning in pursuing the kmalloc approach was that it is already
>> equipped with mechanisms for dealing with these sort of cases, where
>> memory can be fragmented.
> 
> Yeah, but kmalloc is optimized for a completely different usecase. You
> can reuse same pages again and again while you clearly cannot do the
> same once you seal a page and make it read only.

No, but during the allocation transient, I could.

Cons: less protection for what is already in the page.
Pros: tighter packing.

> Well unless you want to
> open time windows when the page stops being RO or use a different
> mapping for the allocator.

Yes, I was proposing to temporarily make the specific page RW.

> But try to consider how many features of the slab allocator you are
> actually going to need wrt. to tweaks it would have to implement to
> support this new use case. Maybe duplicating general purpose caches and
> creating specialized explicitly is a viable path. I haven't tried
> it.
> 
>> I also wouldn't risk introducing bugs with my homebrew allocator ...
>>
>> The initial thought was that there could be a master toggle to
>> seal/unseal all the memory affected.
>>
>> But you were not too excited, iirc :-D
> 
> yes, If there are different users a pool (kmem_cache like) would be more
> natural.
> 
>> Alternatively, kmalloc could be enhanced to unseal only the pages it
>> wants to modify.
> 
> You would have to stop the world to prevent from an accidental overwrite
> during that time. Which makes the whole thing quite dubious IMHO.
> 
>> I don't think much can be done for data that is placed together, in the
>> same page with something that needs to be altered.
>> But what is outside of that page could still enjoy the protection from
>> the seal.

Recap
-----
The latest proposal would be (I can create a new version of the RFC if
preferred):

Have a per-module linear memory allocator, using on on-demand new pages,
with some way to track:

* pages used in each pool (ex: a next ptr in each page)
* free space at the end of the page
  the allocation would be aligned accordingly to arch requirements
  implemented, for example, with a counter

Pages are sealed as soon as they fill up and a next one is allocated.
Or they are explicitly sealed by their respective module.

In the typical case the freeing would happen on the entire pool, for
example when the module is unloaded.
It might be even nicer to have a master teardown call, for the whole pool.


There is still the problem  of how to deal with large physical pages and
kmalloc.
Having a per-module pool of pages is likely to generate even more waste,
if the pages are particularly large.

So I'd like to play a little what-if scenario:
what if I was to support exclusively virtual memory and convert to it
everything that might need sealing?

I cannot find any reason why this could not be done, even if the
original code uses kmalloc.

Extension
---------
What I discussed so far is about things that are not expected to change.
At most they would be freed, as units.

However, if some other data exhibits quasi-or-characteristics, it could
be protected as well.

With the understanding that there would be holes in the memory
allocation and a linear allocator probably would not be enough anymore.

This could be achieved by keeping a bitmaps of machine aligned words.

Ex: a 4k page with 8bytes words would need 64 bytes.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
