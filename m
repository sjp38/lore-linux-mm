Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id BAA6D6B0292
	for <linux-mm@kvack.org>; Sun, 28 May 2017 14:23:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i206so31479126ita.10
        for <linux-mm@kvack.org>; Sun, 28 May 2017 11:23:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d137sor1208574iog.113.2017.05.28.11.23.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 May 2017 11:23:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <138740ab-ba0b-053c-d5b9-a71d6a5c7187@huawei.com>
References: <20170519103811.2183-1-igor.stoppa@huawei.com> <20170519103811.2183-2-igor.stoppa@huawei.com>
 <CAGXu5j+3-CZpZ4Vj2fHH+0UPAa_jOdJQxHtrQ=F_FvvzWvE00Q@mail.gmail.com>
 <656b6465-16cd-ab0a-b439-ab5bea42006d@huawei.com> <CAGXu5jK25XvX4vSODg7rkdBPj_FzveUSODFUKu1=KatmKhFVzg@mail.gmail.com>
 <138740ab-ba0b-053c-d5b9-a71d6a5c7187@huawei.com>
From: Kees Cook <keescook@google.com>
Date: Sun, 28 May 2017 11:23:02 -0700
Message-ID: <CAGXu5jKEmEzAFssmBu2=kJvXikTZ12CF4f8gQy+7UBh8F24PAw@mail.gmail.com>
Subject: Re: [PATCH 1/1] Sealable memory support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Casey Schaufler <casey@schaufler-ca.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Micay <danielmicay@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, James Morris <james.l.morris@oracle.com>, Stephen Smalley <sds@tycho.nsa.gov>

On Wed, May 24, 2017 at 10:45 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> On 23/05/17 23:11, Kees Cook wrote:
>> On Tue, May 23, 2017 at 2:43 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>> I meant this:
>>
>> CPU 1     CPU 2
>> create
>> alloc
>> write
>> seal
>> ...
>> unseal
>>                 write
>> write
>> seal
>>
>> The CPU 2 write would be, for example, an attacker using a
>> vulnerability to attempt to write to memory in the sealed area. All it
>> would need to do to succeed would be to trigger an action in the
>> kernel that would do a "legitimate" write (which requires the unseal),
>> and race it. Unsealing should be CPU-local, if the API is going to
>> support this kind of access.
>
> I see.
> If the CPU1 were to forcibly halt anything that can race with it, then
> it would be sure that there was no interference.

Correct. This is actually what ARM does for doing kernel memory
writing when poking stuff for kprobes, etc. It's rather dramatic,
though. :)

> A reactive approach could be, instead, to re-validate the content after
> the sealing, assuming that it is possible.

I would prefer to avoid this, as that allows an attacker to still have
made the changes (which could even result in them then disabling the
re-validation during the attack).

>> I am more concerned about _any_ unseal after initial seal. And even
>> then, it'd be nice to keep things CPU-local. My concerns are related
>> to the write-rarely proposal (https://lkml.org/lkml/2017/3/29/704)
>> which is kind of like this, but focused on the .data section, not
>> dynamic memory. It has similar concerns about CPU-locality.
>> Additionally, even writing to memory and then making it read-only
>> later runs risks (see threads about BPF JIT races vs making things
>> read-only: https://patchwork.kernel.org/patch/9662653/ Alexei's NAK
>> doesn't change the risk this series is fixing: races with attacker
>> writes during assignment but before read-only marking).
>
> If you are talking about an attacker, rather than protection against
> accidental overwrites, how hashing can be enough?
> Couldn't the attacker compromise that too?

In theory, yes, though the goal was to dedicate a register to the
hash, which would make it hard/impossible for an attacker to reach.
(The BPF JIT situation is just an example of this kind of race,
though. I'm still in favor of reducing the write window to init-time
from full run-time.)

>> So, while smalloc would hugely reduce the window an attacker has
>> available to change data contents, this API doesn't eliminate it. (To
>> eliminate it, there would need to be a CPU-local page permission view
>> that let only the current CPU to the page, and then restore it to
>> read-only to match the global read-only view.)
>
> That or, if one is ready to take the hit, freeze every other possible
> attack vector. But I'm not sure this could be justifiable.

I would expect other people would NAK using "stop all other CPUs"
approach. Better to have the CPU-local writes.

>> Ah! In that case, sure. This isn't what the proposed API provided,
>> though, so let's adjust it to only perform the unseal at destroy time.
>> That makes it much saner, IMO. "Write once" dynamic allocations, or
>> "read-only after seal". woalloc? :P yay naming
>
> For now I'm still using smalloc.
> Anything that is either [x]malloc or [yz]malloc is fine, lengthwise.
> Other options might require some re-formatting.

Yeah, I don't have any better idea for names. :)

>> Ah, okay. Most of the LSM is happily covered by __ro_after_init. If we
>> could just drop the runtime disabling of SELinux, we'd be fine.
>
> I am not sure I understand this point.
> If the kernel is properly configured, the master toggle variable
> disappears, right?
> Or do you mean the disabling through modifications of the linked list of
> the hooks?

We might be talking past each-other. Right now, the LSM is marked with
__ro_after_init, which will make all the list structures, entries, etc
read-only already. There is one case where this is not true, and
that's for CONFIG_SECURITY_WRITABLE_HOOKS for
CONFIG_SECURITY_SELINUX_DISABLE, which wants to do run-time removal of
SELinux. Are you talking about the SELinux policy installed during
early boot? Which things did you want to use smalloc() on?

>> It seems like smalloc pools could also be refcounted?
>
> I am not sure what you mean.
> What do you want to count?
> Number of pools? Nodes per pool? Allocations per node?

I meant things that point into an smalloc() pool could keep a refcount
and when nothing was pointing into it, it could be destroyed. (i.e.
using refcount garbage collection instead of explicit destruction.)

> And what for?

It might be easier to reason about later if allocations get complex.
It's certainly not required for the first version of this.

> At least in the case of tearing down a pool, when a module is unloaded,
> nobody needs to free anything that was allocated with smalloc.
> The teardown function will free the pages from each node.

Right, yeah.

>>>>> +#define NODE_HEADER                                    \
>>>>> +       struct {                                        \
>>>>> +               __SMALLOC_ALIGNED__ struct {            \
>>>>> +                       struct list_head list;          \
>>>>> +                       align_t *free;                  \
>>>>> +                       unsigned long available_words;  \
>>>>> +               };                                      \
>>>>> +       }
>>>
>>> Does this look ok? ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>
>> It's probably a sufficient starting point, depending on how the API
>> shakes out. Without unseal-write-seal properties, I case much less
>> about redzoning, etc.
>
> ok, but my question (I am not sure if it was clear) was about the use of
> a macro for the nameless structure that contains the header.

I don't really have an opinion on this. It might be more readable with
a named structure?

> One more thing: how should I tie this allocator to the rest?
> I have verified that is seems to work with both SLUB and SLAB.
> Can I make it depend on either of them being enabled?

It seems totally unrelated. The only relationship I see would be
interaction with hardened usercopy. In a perfect world, none of the
smalloc pools would be allowed to be copied to/from userspace, which
would make integration really easy: if smalloc_pool(ptr) return NOPE;
:P

> Should it be optionally enabled?
> What to default to, if it's not enabled? vmalloc?

I don't see any reason to make it optional.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
