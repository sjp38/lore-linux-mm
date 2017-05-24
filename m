Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 75AA76B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 13:47:12 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t9so222252615oih.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:47:12 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id k143si10986229oib.247.2017.05.24.10.47.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 10:47:11 -0700 (PDT)
Subject: Re: [PATCH 1/1] Sealable memory support
References: <20170519103811.2183-1-igor.stoppa@huawei.com>
 <20170519103811.2183-2-igor.stoppa@huawei.com>
 <CAGXu5j+3-CZpZ4Vj2fHH+0UPAa_jOdJQxHtrQ=F_FvvzWvE00Q@mail.gmail.com>
 <656b6465-16cd-ab0a-b439-ab5bea42006d@huawei.com>
 <CAGXu5jK25XvX4vSODg7rkdBPj_FzveUSODFUKu1=KatmKhFVzg@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <138740ab-ba0b-053c-d5b9-a71d6a5c7187@huawei.com>
Date: Wed, 24 May 2017 20:45:30 +0300
MIME-Version: 1.0
In-Reply-To: <CAGXu5jK25XvX4vSODg7rkdBPj_FzveUSODFUKu1=KatmKhFVzg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Casey Schaufler <casey@schaufler-ca.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Micay <danielmicay@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, James Morris <james.l.morris@oracle.com>, Stephen Smalley <sds@tycho.nsa.gov>



On 23/05/17 23:11, Kees Cook wrote:
> On Tue, May 23, 2017 at 2:43 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:

[...]

> I would want hardened usercopy support as a requirement for using
> smalloc(). Without it, we're regressing the over-read protection that
> already exists for slab objects, if kernel code switched from slab to
> smalloc. It should be very similar to the existing slab checks. "Is
> this a smalloc object? Have we read beyond the end of a given object?"
> etc. The metadata is all there, except for an efficient way to mark a
> page as a smalloc page, but I think that just requires a new Page$Name
> bit test, as done for slab.

ok

[...]

> I meant this:
> 
> CPU 1     CPU 2
> create
> alloc
> write
> seal
> ...
> unseal
>                 write
> write
> seal
> 
> The CPU 2 write would be, for example, an attacker using a
> vulnerability to attempt to write to memory in the sealed area. All it
> would need to do to succeed would be to trigger an action in the
> kernel that would do a "legitimate" write (which requires the unseal),
> and race it. Unsealing should be CPU-local, if the API is going to
> support this kind of access.

I see.
If the CPU1 were to forcibly halt anything that can race with it, then
it would be sure that there was no interference.
A reactive approach could be, instead, to re-validate the content after
the sealing, assuming that it is possible.

[...]

> I am more concerned about _any_ unseal after initial seal. And even
> then, it'd be nice to keep things CPU-local. My concerns are related
> to the write-rarely proposal (https://lkml.org/lkml/2017/3/29/704)
> which is kind of like this, but focused on the .data section, not
> dynamic memory. It has similar concerns about CPU-locality.
> Additionally, even writing to memory and then making it read-only
> later runs risks (see threads about BPF JIT races vs making things
> read-only: https://patchwork.kernel.org/patch/9662653/ Alexei's NAK
> doesn't change the risk this series is fixing: races with attacker
> writes during assignment but before read-only marking).

If you are talking about an attacker, rather than protection against
accidental overwrites, how hashing can be enough?
Couldn't the attacker compromise that too?

> So, while smalloc would hugely reduce the window an attacker has
> available to change data contents, this API doesn't eliminate it. (To
> eliminate it, there would need to be a CPU-local page permission view
> that let only the current CPU to the page, and then restore it to
> read-only to match the global read-only view.)

That or, if one is ready to take the hit, freeze every other possible
attack vector. But I'm not sure this could be justifiable.

[...]

> Ah! In that case, sure. This isn't what the proposed API provided,
> though, so let's adjust it to only perform the unseal at destroy time.
> That makes it much saner, IMO. "Write once" dynamic allocations, or
> "read-only after seal". woalloc? :P yay naming

For now I'm still using smalloc.
Anything that is either [x]malloc or [yz]malloc is fine, lengthwise.
Other options might require some re-formatting.

[...]

> I think a shared global pool would need to be eliminated for true
> write-once semantics.

ok

[...]

>> I'd rather not add extra locking to something that doesn't need it:
>> Allocate - write - seal - read, read, read, ... - unseal - destroy.
> 
> Yup, I would be totally fine with this. It still has a race between
> allocate and seal, but it's a huge improvement over the existing state
> of the world where all dynamic memory is writable. :)

Great!


[...]

> Ah, okay. Most of the LSM is happily covered by __ro_after_init. If we
> could just drop the runtime disabling of SELinux, we'd be fine.

I am not sure I understand this point.
If the kernel is properly configured, the master toggle variable
disappears, right?
Or do you mean the disabling through modifications of the linked list of
the hooks?

[...]


> Hm, I just meant add a char[] to the metadata and pass it in during
> create(). Then it's possible to report which smalloc cache is being
> examined during hardened usercopy checks.

Ok, that is not a big deal.
wrt this, I have spent some time writing a debug module, which currently
dumps into a debugfs entry a bunch of info about the various pools.
I could split it across multiple entries, using the label to generate
their names.

[...]

> It seems like smalloc pools could also be refcounted?

I am not sure what you mean.
What do you want to count?
Number of pools? Nodes per pool? Allocations per node?

And what for?

At least in the case of tearing down a pool, when a module is unloaded,
nobody needs to free anything that was allocated with smalloc.
The teardown function will free the pages from each node.

Is this the place where you think there should be a check on the number
of pages freed?

[...]

>>>> +#define NODE_HEADER                                    \
>>>> +       struct {                                        \
>>>> +               __SMALLOC_ALIGNED__ struct {            \
>>>> +                       struct list_head list;          \
>>>> +                       align_t *free;                  \
>>>> +                       unsigned long available_words;  \
>>>> +               };                                      \
>>>> +       }
>>
>> Does this look ok? ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> It's probably a sufficient starting point, depending on how the API
> shakes out. Without unseal-write-seal properties, I case much less
> about redzoning, etc.

ok, but my question (I am not sure if it was clear) was about the use of
a macro for the nameless structure that contains the header.

[...]

> Well, a poor example would be struct sock, since it needs to be
> regularly written to, but it has function pointers near the end which
> have been a very common target for attackers. (Though this is less so
> now that INET_DIAG no longer exposes the kernel addresses to allocated
> struct socks.)

Ok, this could be the scope for a further set of patches, after this one
is done.



One more thing: how should I tie this allocator to the rest?
I have verified that is seems to work with both SLUB and SLAB.
Can I make it depend on either of them being enabled?

Should it be optionally enabled?
What to default to, if it's not enabled? vmalloc?

---
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
