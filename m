Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4969C6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 16:11:13 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 64so55581932itb.1
        for <linux-mm@kvack.org>; Tue, 23 May 2017 13:11:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m130sor806969ioa.61.2017.05.23.13.11.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 May 2017 13:11:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <656b6465-16cd-ab0a-b439-ab5bea42006d@huawei.com>
References: <20170519103811.2183-1-igor.stoppa@huawei.com> <20170519103811.2183-2-igor.stoppa@huawei.com>
 <CAGXu5j+3-CZpZ4Vj2fHH+0UPAa_jOdJQxHtrQ=F_FvvzWvE00Q@mail.gmail.com> <656b6465-16cd-ab0a-b439-ab5bea42006d@huawei.com>
From: Kees Cook <keescook@google.com>
Date: Tue, 23 May 2017 13:11:10 -0700
Message-ID: <CAGXu5jK25XvX4vSODg7rkdBPj_FzveUSODFUKu1=KatmKhFVzg@mail.gmail.com>
Subject: Re: [PATCH 1/1] Sealable memory support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Casey Schaufler <casey@schaufler-ca.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Micay <danielmicay@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, James Morris <james.l.morris@oracle.com>, Stephen Smalley <sds@tycho.nsa.gov>

On Tue, May 23, 2017 at 2:43 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> On 23/05/17 00:38, Kees Cook wrote:
>> On Fri, May 19, 2017 at 3:38 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>
> [...]
>
>> For the first bit of bikeshedding, should this really be called
>> seal/unseal? My mind is probably just broken from having read TPM
>> documentation, but this isn't really "sealing" as I'd understand it
>> (it's not tied to a credential, for example). It's "only" rw/ro.
>> Perhaps "protect/unprotect" or just simply "readonly/writable", and
>> call the base function "romalloc"?
>
> I was not aware of the specific mean of "seal", in this context.
> The term was implicitly proposed by Michal Hocko, while discussing about
> the mechanism and I liked it more than what I was using initially:
> "lockable".
>
> tbh I like the sound of "smalloc" better than "romalloc"
>
> But this is really the least of my worries :-P
>
>> This is fundamentally a heap allocator, with linked lists, etc. I'd
>> like to see as much attention as possible given to hardening it
>> against attacks, especially adding redzoning around the metadata at
>> least, and perhaps requiring that CONFIG_DEBUG_LIST be enabled.
>
> My initial goal was to provide something that is useful without
> affecting performance.
>
> You seem to be pushing for a more extreme approach.

I don't know about pushing, but it seemed like the API provided for
arbitrary unsealing, etc. More below...

> While I have nothing against it and I actually agree that it can be
> useful, I would not make it mandatory.
>
> More on this later.
>
>> And as
>> part of that, I'd like hardened usercopy to grow knowledge of these
>> allocations so we can bounds-check objects. Right now, mm/usercopy.c
>> just looks at PageSlab(page) to decide if it should do slab checks. I
>> think adding a check for this type of object would be very important
>> there.
>
> I am not familiar with this and I need to study it, however I still
> think that if there is a significant trade-off in terms of performance
> vs resilience, it should be optional, for those who want it.

I would want hardened usercopy support as a requirement for using
smalloc(). Without it, we're regressing the over-read protection that
already exists for slab objects, if kernel code switched from slab to
smalloc. It should be very similar to the existing slab checks. "Is
this a smalloc object? Have we read beyond the end of a given object?"
etc. The metadata is all there, except for an efficient way to mark a
page as a smalloc page, but I think that just requires a new Page$Name
bit test, as done for slab.

> Maybe there could be a master toggle for these options, if it makes
> sense to group them logically. How does this sound?
>
>> The ro/rw granularity here is the _entire_ pool, not a specific
>> allocation (or page containing the allocation). I'm concerned that
>> makes this very open to race conditions where, especially in the
>> global pool, one thread can be trying to write to ro data in a pool
>> and another has made the pool writable.
>
> I have the impression we are thinking to something different.
> Close, but different enough.
>
> First of all, how using a mutex can create races?
> Do you mean with respect of other resources that might be held by
> competing users of the pool?

I meant this:

CPU 1     CPU 2
create
alloc
write
seal
...
unseal
                write
write
seal

The CPU 2 write would be, for example, an attacker using a
vulnerability to attempt to write to memory in the sealed area. All it
would need to do to succeed would be to trigger an action in the
kernel that would do a "legitimate" write (which requires the unseal),
and race it. Unsealing should be CPU-local, if the API is going to
support this kind of access.

> That, imho, is a locking problem that cannot be solved here.
> You can try to mitigate it, by reducing the chances it will happen, but
> basically you are trying to make do with an user of the API that is not
> implementing locking correctly.
> I'd say that it's better to fix the user.
>
> If you meant something else, I really didn't get it :-)
>
> More about the frequency of the access: you seem to expect very often
> seal/unseal - or lock/unlock, while I don't.

I am more concerned about _any_ unseal after initial seal. And even
then, it'd be nice to keep things CPU-local. My concerns are related
to the write-rarely proposal (https://lkml.org/lkml/2017/3/29/704)
which is kind of like this, but focused on the .data section, not
dynamic memory. It has similar concerns about CPU-locality.
Additionally, even writing to memory and then making it read-only
later runs risks (see threads about BPF JIT races vs making things
read-only: https://patchwork.kernel.org/patch/9662653/ Alexei's NAK
doesn't change the risk this series is fixing: races with attacker
writes during assignment but before read-only marking).

So, while smalloc would hugely reduce the window an attacker has
available to change data contents, this API doesn't eliminate it. (To
eliminate it, there would need to be a CPU-local page permission view
that let only the current CPU to the page, and then restore it to
read-only to match the global read-only view.)

> What I envision as primary case for unlocking is the tear down of the
> entire pool, for example preceding the unloading of the module.
>
> Think about __ro_after_init : once it is r/o, it stays r/o.

Ah! In that case, sure. This isn't what the proposed API provided,
though, so let's adjust it to only perform the unseal at destroy time.
That makes it much saner, IMO. "Write once" dynamic allocations, or
"read-only after seal". woalloc? :P yay naming

> Which also means that there would be possibly a busy transient, when
> allocations are made. That is true.
> But only for shared pools. If a module uses one pool, I would expect the
> initialization of the module to be mostly sequential.
> So, no chance of races. Do you agree?

I think a shared global pool would need to be eliminated for true
write-once semantics.

> Furthermore, if a module _really_ wants to do parallel allocation, then
> maybe it's simpler and cleaner to have one pool per "thread" or whatever
> is the mechanism used.

Right.

> The global pool is mostly there for completing the offering of
> __ro_after_init. If one wants ot use it, it's available.
> It saves the trouble of having own pool, it means competing with the
> rest of the kernel for locking.
>
> If it seems a bad idea, it can be easily removed.

I think they need to be explicit, yes.

> I'd rather not add extra locking to something that doesn't need it:
> Allocate - write - seal - read, read, read, ... - unseal - destroy.

Yup, I would be totally fine with this. It still has a race between
allocate and seal, but it's a huge improvement over the existing state
of the world where all dynamic memory is writable. :)

>> Finding a user for this would help clarify its protection properties,
>> too. (The LSM example is likely not the best starting point for that,
>> as it would depend on other changes that are under discussion.)
>
> Well, I *have* to do the LSM - and SE Linux too.
>
> That's where this started and why I'm here with this patch.

Ah, okay. Most of the LSM is happily covered by __ro_after_init. If we
could just drop the runtime disabling of SELinux, we'd be fine.

I'd like to see what you have in mind for LSM, since the only runtime
change would be the SELinux piece, and that would violate the
alloc-write-seal-read-read-destroy lifetime (since you'd need to
unseal-write-seal to change the state of SELinux during runtime).

> From what I could understand about the discussion, the debate about the
> changes is settled (is it?).
>
> Casey seemed to be ok with this.
>
> If something else is needed, ok, I can do that too, but I didn't see any
> specific reason why LSM should not be good enough as first example.
>
> If you can provide a specific reason why it's not suitable, I can
> reconsider.

Hopefully we're on the same page now? I love being able to work off a
patch example, so if you agree about the changes in lifetime
management, and you've got some examples of how/where to use smalloc,
I'd love to review those too. I think there are a LOT of places this
could get used.

> [...]
>
>>> +       if (!pool) {
>>> +               pr_err("No memory for allocating pool.");
>>
>> It might be handy to have pools named like they are for the slab allocator.
>
> I considered this.
> The only reason I could come up with why it might be desirable is if the
> same pool needs to be accessed from two or more places that do not share
> the pointer. It doesn't seem particularly useful.
> The only upside I can think of is that it would save a memory page, vs
> the case of creating 2 separate pools.
> It would also introduce locking cross-dependency.
>
> Did I overlook some reason why it would be desirable?

Hm, I just meant add a char[] to the metadata and pass it in during
create(). Then it's possible to report which smalloc cache is being
examined during hardened usercopy checks.

>
> [...]
>
>>> +int smalloc_destroy(struct smalloc_pool *pool)
>>> +{
>>> +       struct list_head *pos, *q;
>>> +       struct smalloc_node *node;
>>> +
>>> +       if (!pool)
>>> +               return -EINVAL;
>
> locking was missing, I added it in the new version
> also I moved to goto-like error handling, since there were several
> similar exit paths.

It seems like smalloc pools could also be refcounted?

> [...]
>
>>> +typedef uint64_t align_t;
>>> +
>>> +enum seal_t {
>>> +       SMALLOC_UNSEALED,
>>> +       SMALLOC_SEALED,
>>> +};
>>> +
>>> +#define __SMALLOC_ALIGNED__ __aligned(sizeof(align_t))
>
> How about the alignment? Is it a desirable feature?
> Did I overlook some reason why it would not work?

I think alignment makes sense. It makes sure there aren't crazy
problems with structs allocated after the header.

>>> +#define NODE_HEADER                                    \
>>> +       struct {                                        \
>>> +               __SMALLOC_ALIGNED__ struct {            \
>>> +                       struct list_head list;          \
>>> +                       align_t *free;                  \
>>> +                       unsigned long available_words;  \
>>> +               };                                      \
>>> +       }
>
> Does this look ok? ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It's probably a sufficient starting point, depending on how the API
shakes out. Without unseal-write-seal properties, I case much less
about redzoning, etc.

> [...]
>
>> I'd really like to see kernel-doc for the API functions (likely in the .c file).
>
> Yes, I just see no point right now, since the API doesn't seem to be
> agreed/finalized yet.

Sure thing. I guess I was looking for more docs because of my
questions/concerns about lifetime management, etc. :)

>> Thanks again for working on this! If you can find examples of file
>> operations living in the heap, those would be great examples for using
>> this API (assuming the other properties can be improved).
>
> As I explained above, I would prefer to continue with LSM, unless you
> have some specific reason against it.

I think I just lack the imagination for what you're trying to do that
isn't already covered by the existing __ro_after_init changes. :)

> If you have some example in mind about file operations living on the
> heap - which I suspect you do have :) - we could discuss also about
> those and if the locking needs to be modified, but from my perspective
> the use case is significantly different and I wouldn't pile it up with this.
> Of course I might be missing the point you are trying to make.
> In that case, I'm afraid that further explanation is needed from you, as
> I do not get it :-)

Well, a poor example would be struct sock, since it needs to be
regularly written to, but it has function pointers near the end which
have been a very common target for attackers. (Though this is less so
now that INET_DIAG no longer exposes the kernel addresses to allocated
struct socks.)

> Thanks a lot for the review, this is exactly the sort of early feedback
> I was hoping to receive.

Great! Gaining a ro_after_init-like API for dynamic memory would be
quite valuable, I think. And once we have a write-rarely
infrastructure for the .rodata segment, perhaps we can extend it to
the dynamic memory areas too (in the future).

Thanks!

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
