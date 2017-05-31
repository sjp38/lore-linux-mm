Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A57086B02FD
	for <linux-mm@kvack.org>; Wed, 31 May 2017 17:23:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r203so5695184wmb.2
        for <linux-mm@kvack.org>; Wed, 31 May 2017 14:23:51 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id q11si5494409wrb.280.2017.05.31.14.23.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 14:23:50 -0700 (PDT)
Subject: Re: [PATCH 1/1] Sealable memory support
References: <20170519103811.2183-1-igor.stoppa@huawei.com>
 <20170519103811.2183-2-igor.stoppa@huawei.com>
 <CAGXu5j+3-CZpZ4Vj2fHH+0UPAa_jOdJQxHtrQ=F_FvvzWvE00Q@mail.gmail.com>
 <656b6465-16cd-ab0a-b439-ab5bea42006d@huawei.com>
 <CAGXu5jK25XvX4vSODg7rkdBPj_FzveUSODFUKu1=KatmKhFVzg@mail.gmail.com>
 <138740ab-ba0b-053c-d5b9-a71d6a5c7187@huawei.com>
 <CAGXu5jKEmEzAFssmBu2=kJvXikTZ12CF4f8gQy+7UBh8F24PAw@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <ea8ecd33-8126-6c75-a0b3-675a8c76fac6@huawei.com>
Date: Thu, 1 Jun 2017 00:22:20 +0300
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKEmEzAFssmBu2=kJvXikTZ12CF4f8gQy+7UBh8F24PAw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Casey Schaufler <casey@schaufler-ca.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Micay <danielmicay@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, James Morris <james.l.morris@oracle.com>, Stephen Smalley <sds@tycho.nsa.gov>

On 28/05/17 21:23, Kees Cook wrote:
> On Wed, May 24, 2017 at 10:45 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:

[...]

>> If the CPU1 were to forcibly halt anything that can race with it, then
>> it would be sure that there was no interference.
> 
> Correct. This is actually what ARM does for doing kernel memory
> writing when poking stuff for kprobes, etc. It's rather dramatic,
> though. :)

ok

>> A reactive approach could be, instead, to re-validate the content after
>> the sealing, assuming that it is possible.
> 
> I would prefer to avoid this, as that allows an attacker to still have
> made the changes (which could even result in them then disabling the
> re-validation during the attack).

ok


[...]

>> If you are talking about an attacker, rather than protection against
>> accidental overwrites, how hashing can be enough?
>> Couldn't the attacker compromise that too?
> 
> In theory, yes, though the goal was to dedicate a register to the
> hash, which would make it hard/impossible for an attacker to reach.
> (The BPF JIT situation is just an example of this kind of race,
> though. I'm still in favor of reducing the write window to init-time
> from full run-time.)

It looks like some compromise is needed between reliability and
performance ...

[...]

> I would expect other people would NAK using "stop all other CPUs"
> approach. Better to have the CPU-local writes.

ok, that could be a feature for the follow-up?

[...]

> Yeah, I don't have any better idea for names. :)

still clinging to smalloc for now, how about pmalloc,
as "protected malloc"?


> We might be talking past each-other. Right now, the LSM is marked with
> __ro_after_init, which will make all the list structures, entries, etc
> read-only already. There is one case where this is not true, and
> that's for CONFIG_SECURITY_WRITABLE_HOOKS for
> CONFIG_SECURITY_SELINUX_DISABLE, which wants to do run-time removal of
> SELinux. 

On this I'll just shut up and provide the patch. It seems easier :-)

> Are you talking about the SELinux policy installed during
> early boot? Which things did you want to use smalloc() on?

The policy DB.
And of course the policy cache has to go, as in: it must be possible to
disable it completely, in favor of re-evaluating the policies, when needed.

I'm pretty sure that it is absolutely needed in certain cases, but in
others I think the re-evaluation is negligible in comparison to the
overall duration of the use cases affected.

So it should be ok to let the system integrator gauge speed (if any) vs
resilience, by enablying/disabling the SE Linux policy cache.


>>> It seems like smalloc pools could also be refcounted?
> 
> I meant things that point into an smalloc() pool could keep a refcount
> and when nothing was pointing into it, it could be destroyed. (i.e.
> using refcount garbage collection instead of explicit destruction.)

ok, but it depends on the level of paranoia that we are talking about.

Counting smalloc vs sfree is easy.

Verifying that the free invocations are actually aligned with previous
allocations is a bit more onerous.

Validating that the free is done from the same entity that invoked the
smalloc might be hard.

>> And what for?
> 
> It might be easier to reason about later if allocations get complex.
> It's certainly not required for the first version of this.

good :-)
more clarifications are needed

[...]

> I don't really have an opinion on this. It might be more readable with
> a named structure?

Eventually I got rid of the macro.
The structure is intentionally unnamed to stress the grouping, without
adding a layer of indirection. But maybe it could be removed. I need to
test it.

>> One more thing: how should I tie this allocator to the rest?
>> I have verified that is seems to work with both SLUB and SLAB.
>> Can I make it depend on either of them being enabled?
> 
> It seems totally unrelated. The only relationship I see would be
> interaction with hardened usercopy. In a perfect world, none of the
> smalloc pools would be allowed to be copied to/from userspace, which
> would make integration really easy: if smalloc_pool(ptr) return NOPE;
> :P

I went down the harder path and implemented the check.

>> Should it be optionally enabled?
>> What to default to, if it's not enabled? vmalloc?
> 
> I don't see any reason to make it optional.

great \o/

So now I'm back to the LSM use case.
It shouldn't take too long.

--
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
