Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92B766B0005
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 13:12:45 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w11-v6so971840plq.8
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 10:12:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12-v6sor6686485pfd.95.2018.08.15.10.12.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Aug 2018 10:12:44 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH 1/2] mm: rework memcg kernel stack accounting
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20180815165513.GA26330@castle.DHCP.thefacebook.com>
Date: Wed, 15 Aug 2018 10:12:42 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <2393E780-2B97-4BEE-8374-8E9E5249E5AD@amacapital.net>
References: <20180815003620.15678-1-guro@fb.com> <20180815163923.GA28953@cmpxchg.org> <20180815165513.GA26330@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>



> On Aug 15, 2018, at 9:55 AM, Roman Gushchin <guro@fb.com> wrote:
>=20
>> On Wed, Aug 15, 2018 at 12:39:23PM -0400, Johannes Weiner wrote:
>>> On Tue, Aug 14, 2018 at 05:36:19PM -0700, Roman Gushchin wrote:
>>> @@ -224,9 +224,14 @@ static unsigned long *alloc_thread_stack_node(struc=
t task_struct *tsk, int node)
>>>        return s->addr;
>>>    }
>>>=20
>>> +    /*
>>> +     * Allocated stacks are cached and later reused by new threads,
>>> +     * so memcg accounting is performed manually on assigning/releasing=

>>> +     * stacks to tasks. Drop __GFP_ACCOUNT.
>>> +     */
>>>    stack =3D __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
>>>                     VMALLOC_START, VMALLOC_END,
>>> -                     THREADINFO_GFP,
>>> +                     THREADINFO_GFP & ~__GFP_ACCOUNT,
>>>                     PAGE_KERNEL,
>>>                     0, node, __builtin_return_address(0));
>>>=20
>>> @@ -246,12 +251,41 @@ static unsigned long *alloc_thread_stack_node(stru=
ct task_struct *tsk, int node)
>>> #endif
>>> }
>>>=20
>>> +static void memcg_charge_kernel_stack(struct task_struct *tsk)
>>> +{
>>> +#ifdef CONFIG_VMAP_STACK
>>> +    struct vm_struct *vm =3D task_stack_vm_area(tsk);
>>> +
>>> +    if (vm) {
>>> +        int i;
>>> +
>>> +        for (i =3D 0; i < THREAD_SIZE / PAGE_SIZE; i++)
>>> +            memcg_kmem_charge(vm->pages[i], __GFP_NOFAIL,
>>> +                      compound_order(vm->pages[i]));
>>> +
>>> +        /* All stack pages belong to the same memcg. */
>>> +        mod_memcg_page_state(vm->pages[0], MEMCG_KERNEL_STACK_KB,
>>> +                     THREAD_SIZE / 1024);
>>> +    }
>>> +#endif
>>> +}
>>=20
>> Before this change, the memory limit can fail the fork, but afterwards
>> fork() can grow memory consumption unimpeded by the cgroup settings.
>>=20
>> Can we continue to use try_charge() here and fail the fork?
>=20
> We can, but I'm not convinced we should.
>=20
> Kernel stack is relatively small, and it's already allocated at this point=
.
> So IMO exceeding the memcg limit for 1-2 pages isn't worse than
> adding complexity and handle this case (e.g. uncharge partially
> charged stack). Do you have an example, when it does matter?

What bounds it to just a few pages?  Couldn=E2=80=99t there be lots of forks=
 in flight that all hit this path?  It=E2=80=99s unlikely, and there are sur=
ely easier DoS vectors, but still.=
