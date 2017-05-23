Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2E576B02C3
	for <linux-mm@kvack.org>; Tue, 23 May 2017 05:47:03 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y65so158479515pff.13
        for <linux-mm@kvack.org>; Tue, 23 May 2017 02:47:03 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id l91si20424298plb.86.2017.05.23.02.47.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 02:47:03 -0700 (PDT)
Subject: Re: [PATCH 1/1] Sealable memory support
References: <20170519103811.2183-1-igor.stoppa@huawei.com>
 <20170519103811.2183-2-igor.stoppa@huawei.com>
 <CAGXu5j+3-CZpZ4Vj2fHH+0UPAa_jOdJQxHtrQ=F_FvvzWvE00Q@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <656b6465-16cd-ab0a-b439-ab5bea42006d@huawei.com>
Date: Tue, 23 May 2017 12:43:02 +0300
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+3-CZpZ4Vj2fHH+0UPAa_jOdJQxHtrQ=F_FvvzWvE00Q@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Casey Schaufler <casey@schaufler-ca.com>
Cc: Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Micay <danielmicay@gmail.com>Laura Abbott <labbott@redhat.com>, Greg KH <gregkh@linuxfoundation.org>, James Morris <james.l.morris@oracle.com>, Stephen Smalley <sds@tycho.nsa.gov>

On 23/05/17 00:38, Kees Cook wrote:
> On Fri, May 19, 2017 at 3:38 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:

[...]

> For the first bit of bikeshedding, should this really be called
> seal/unseal? My mind is probably just broken from having read TPM
> documentation, but this isn't really "sealing" as I'd understand it
> (it's not tied to a credential, for example). It's "only" rw/ro.
> Perhaps "protect/unprotect" or just simply "readonly/writable", and
> call the base function "romalloc"?

I was not aware of the specific mean of "seal", in this context.
The term was implicitly proposed by Michal Hocko, while discussing about
the mechanism and I liked it more than what I was using initially:
"lockable".

tbh I like the sound of "smalloc" better than "romalloc"

But this is really the least of my worries :-P

> This is fundamentally a heap allocator, with linked lists, etc. I'd
> like to see as much attention as possible given to hardening it
> against attacks, especially adding redzoning around the metadata at
> least, and perhaps requiring that CONFIG_DEBUG_LIST be enabled.

My initial goal was to provide something that is useful without
affecting performance.

You seem to be pushing for a more extreme approach.
While I have nothing against it and I actually agree that it can be
useful, I would not make it mandatory.

More on this later.

> And as
> part of that, I'd like hardened usercopy to grow knowledge of these
> allocations so we can bounds-check objects. Right now, mm/usercopy.c
> just looks at PageSlab(page) to decide if it should do slab checks. I
> think adding a check for this type of object would be very important
> there.

I am not familiar with this and I need to study it, however I still
think that if there is a significant trade-off in terms of performance
vs resilience, it should be optional, for those who want it.

Maybe there could be a master toggle for these options, if it makes
sense to group them logically. How does this sound?

> The ro/rw granularity here is the _entire_ pool, not a specific
> allocation (or page containing the allocation). I'm concerned that
> makes this very open to race conditions where, especially in the
> global pool, one thread can be trying to write to ro data in a pool
> and another has made the pool writable.

I have the impression we are thinking to something different.
Close, but different enough.

First of all, how using a mutex can create races?
Do you mean with respect of other resources that might be held by
competing users of the pool?

That, imho, is a locking problem that cannot be solved here.
You can try to mitigate it, by reducing the chances it will happen, but
basically you are trying to make do with an user of the API that is not
implementing locking correctly.
I'd say that it's better to fix the user.

If you meant something else, I really didn't get it :-)

More about the frequency of the access: you seem to expect very often
seal/unseal - or lock/unlock, while I don't.

What I envision as primary case for unlocking is the tear down of the
entire pool, for example preceding the unloading of the module.

Think about __ro_after_init : once it is r/o, it stays r/o.

Which also means that there would be possibly a busy transient, when
allocations are made. That is true.
But only for shared pools. If a module uses one pool, I would expect the
initialization of the module to be mostly sequential.
So, no chance of races. Do you agree?

Furthermore, if a module _really_ wants to do parallel allocation, then
maybe it's simpler and cleaner to have one pool per "thread" or whatever
is the mechanism used.


The global pool is mostly there for completing the offering of
__ro_after_init. If one wants ot use it, it's available.
It saves the trouble of having own pool, it means competing with the
rest of the kernel for locking.

If it seems a bad idea, it can be easily removed.

[...]

>> +#include "smalloc.h"
> 
> Shouldn't this just be <linux/smalloc.h> ?

yes, I have fixed it in the next revision

[...]

>> +       /* If no pool specified, use the global one. */
>> +       if (!pool)
>> +               pool = global_pool;
> 
> It should be impossible, but this should check for global_pool == NULL too, IMO.

I'm curious: why do you think it could happen?
I'd rather throw an exception, if I cannot initialize global_pool.

[...]

>> +       if (pool->seal == seal) {
>> +               mutex_unlock(&pool->lock);
>> +               return;
> 
> I actually think this should be a BUG condition, since this means a
> mismatched seal/unseal happened. The pool should never be left
> writable at rest, a user should create a pool, write to it, seal. 

On this I agree.

> Any
> updates should unseal, write, seal. To attempt an unseal and find it
> already unsealed seems bad.

But what you are describing seems exactly the case where there could be
a race.
EX: 2 writers try to unseal and add/change something.
They could have a collision both when trying to seal and unseal.

One could argue that there should be an atomic unseal-update-seal and
maybe unseal-allocate-seal.

I would understand the need for that - and maybe that's really how it
should be implemented, for doing what you seem to envision.

But that's where I think we have different use-cases in mind.

I'd rather not add extra locking to something that doesn't need it:
Allocate - write - seal - read, read, read, ... - unseal - destroy.

What you describe is more complex and does need extra logging, but I
would advocate a different implementation, at least initially.
Later, if it makes sense, fold them into one.

> Finding a user for this would help clarify its protection properties,
> too. (The LSM example is likely not the best starting point for that,
> as it would depend on other changes that are under discussion.)

Well, I *have* to do the LSM - and SE Linux too.

That's where this started and why I'm here with this patch.

>From what I could understand about the discussion, the debate about the
changes is settled (is it?).

Casey seemed to be ok with this.

If something else is needed, ok, I can do that too, but I didn't see any
specific reason why LSM should not be good enough as first example.

If you can provide a specific reason why it's not suitable, I can
reconsider.

[...]

>> +       if (!pool) {
>> +               pr_err("No memory for allocating pool.");
> 
> It might be handy to have pools named like they are for the slab allocator.

I considered this.
The only reason I could come up with why it might be desirable is if the
same pool needs to be accessed from two or more places that do not share
the pointer. It doesn't seem particularly useful.
The only upside I can think of is that it would save a memory page, vs
the case of creating 2 separate pools.
It would also introduce locking cross-dependency.

Did I overlook some reason why it would be desirable?

[...]

>> +int smalloc_destroy(struct smalloc_pool *pool)
>> +{
>> +       struct list_head *pos, *q;
>> +       struct smalloc_node *node;
>> +
>> +       if (!pool)
>> +               return -EINVAL;

locking was missing, I added it in the new version
also I moved to goto-like error handling, since there were several
similar exit paths.

>> +       list_for_each_safe(pos, q, &pool->list) {
>> +               node = list_entry(pos, struct smalloc_node, list);

btw, here and in other places I have switched to list_for_each_entry

[...]

> typo: space after "un"

ok

[...]

>> +typedef uint64_t align_t;
>> +
>> +enum seal_t {
>> +       SMALLOC_UNSEALED,
>> +       SMALLOC_SEALED,
>> +};
>> +
>> +#define __SMALLOC_ALIGNED__ __aligned(sizeof(align_t))

How about the alignment? Is it a desirable feature?
Did I overlook some reason why it would not work?

>> +#define NODE_HEADER                                    \
>> +       struct {                                        \
>> +               __SMALLOC_ALIGNED__ struct {            \
>> +                       struct list_head list;          \
>> +                       align_t *free;                  \
>> +                       unsigned long available_words;  \
>> +               };                                      \
>> +       }

Does this look ok? ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

[...]

> I'd really like to see kernel-doc for the API functions (likely in the .c file).

Yes, I just see no point right now, since the API doesn't seem to be
agreed/finalized yet.

> Thanks again for working on this! If you can find examples of file
> operations living in the heap, those would be great examples for using
> this API (assuming the other properties can be improved).

As I explained above, I would prefer to continue with LSM, unless you
have some specific reason against it.

If you have some example in mind about file operations living on the
heap - which I suspect you do have :) - we could discuss also about
those and if the locking needs to be modified, but from my perspective
the use case is significantly different and I wouldn't pile it up with this.
Of course I might be missing the point you are trying to make.
In that case, I'm afraid that further explanation is needed from you, as
I do not get it :-)


Thanks a lot for the review, this is exactly the sort of early feedback
I was hoping to receive.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
