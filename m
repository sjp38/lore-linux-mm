Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B00386B000A
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 13:37:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d22-v6so839798pfn.3
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 10:37:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18-v6sor5450215pgi.86.2018.08.15.10.37.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Aug 2018 10:37:31 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH 1/2] mm: rework memcg kernel stack accounting
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CALvZod7TDLtr-DgqgW_0tOKei_54U1JHThpgLKr9_ObaqcC3MA@mail.gmail.com>
Date: Wed, 15 Aug 2018 10:37:28 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <19CD1E5B-CB86-493A-8BA6-7389E36291B4@amacapital.net>
References: <20180815003620.15678-1-guro@fb.com> <20180815163923.GA28953@cmpxchg.org> <20180815165513.GA26330@castle.DHCP.thefacebook.com> <2393E780-2B97-4BEE-8374-8E9E5249E5AD@amacapital.net> <20180815172557.GC26330@castle.DHCP.thefacebook.com> <CALvZod7TDLtr-DgqgW_0tOKei_54U1JHThpgLKr9_ObaqcC3MA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Michal Hocko <mhocko@kernel.org>, luto@kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>



> On Aug 15, 2018, at 10:32 AM, Shakeel Butt <shakeelb@google.com> wrote:
>=20
>> On Wed, Aug 15, 2018 at 10:26 AM Roman Gushchin <guro@fb.com> wrote:
>>=20
>>> On Wed, Aug 15, 2018 at 10:12:42AM -0700, Andy Lutomirski wrote:
>>>=20
>>>=20
>>>>> On Aug 15, 2018, at 9:55 AM, Roman Gushchin <guro@fb.com> wrote:
>>>>>=20
>>>>>> On Wed, Aug 15, 2018 at 12:39:23PM -0400, Johannes Weiner wrote:
>>>>>> On Tue, Aug 14, 2018 at 05:36:19PM -0700, Roman Gushchin wrote:
>>>>>> @@ -224,9 +224,14 @@ static unsigned long *alloc_thread_stack_node(st=
ruct task_struct *tsk, int node)
>>>>>>       return s->addr;
>>>>>>   }
>>>>>>=20
>>>>>> +    /*
>>>>>> +     * Allocated stacks are cached and later reused by new threads,
>>>>>> +     * so memcg accounting is performed manually on assigning/releas=
ing
>>>>>> +     * stacks to tasks. Drop __GFP_ACCOUNT.
>>>>>> +     */
>>>>>>   stack =3D __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
>>>>>>                    VMALLOC_START, VMALLOC_END,
>>>>>> -                     THREADINFO_GFP,
>>>>>> +                     THREADINFO_GFP & ~__GFP_ACCOUNT,
>>>>>>                    PAGE_KERNEL,
>>>>>>                    0, node, __builtin_return_address(0));
>>>>>>=20
>>>>>> @@ -246,12 +251,41 @@ static unsigned long *alloc_thread_stack_node(s=
truct task_struct *tsk, int node)
>>>>>> #endif
>>>>>> }
>>>>>>=20
>>>>>> +static void memcg_charge_kernel_stack(struct task_struct *tsk)
>>>>>> +{
>>>>>> +#ifdef CONFIG_VMAP_STACK
>>>>>> +    struct vm_struct *vm =3D task_stack_vm_area(tsk);
>>>>>> +
>>>>>> +    if (vm) {
>>>>>> +        int i;
>>>>>> +
>>>>>> +        for (i =3D 0; i < THREAD_SIZE / PAGE_SIZE; i++)
>>>>>> +            memcg_kmem_charge(vm->pages[i], __GFP_NOFAIL,
>>>>>> +                      compound_order(vm->pages[i]));
>>>>>> +
>>>>>> +        /* All stack pages belong to the same memcg. */
>>>>>> +        mod_memcg_page_state(vm->pages[0], MEMCG_KERNEL_STACK_KB,
>>>>>> +                     THREAD_SIZE / 1024);
>>>>>> +    }
>>>>>> +#endif
>>>>>> +}
>>>>>=20
>>>>> Before this change, the memory limit can fail the fork, but afterwards=

>>>>> fork() can grow memory consumption unimpeded by the cgroup settings.
>>>>>=20
>>>>> Can we continue to use try_charge() here and fail the fork?
>>>>=20
>>>> We can, but I'm not convinced we should.
>>>>=20
>>>> Kernel stack is relatively small, and it's already allocated at this po=
int.
>>>> So IMO exceeding the memcg limit for 1-2 pages isn't worse than
>>>> adding complexity and handle this case (e.g. uncharge partially
>>>> charged stack). Do you have an example, when it does matter?
>>>=20
>>> What bounds it to just a few pages?  Couldn=E2=80=99t there be lots of f=
orks in flight that all hit this path?  It=E2=80=99s unlikely, and there are=
 surely easier DoS vectors, but still.
>>=20
>> Because any following memcg-aware allocation will fail.
>> There is also the pid cgroup controlled which can be used to limit the nu=
mber
>> of forks.
>>=20
>> Anyway, I'm ok to handle the this case and fail fork,
>> if you think it does matter.
>=20
> Roman, before adding more changes do benchmark this. Maybe disabling
> the stack caching for CONFIG_MEMCG is much cleaner.
>=20
>=20

Unless memcg accounting is colossally slow, the caching should be left on. v=
malloc() isn=E2=80=99t inherently slow, but vfree() is, since we need to do a=
 global broadcast TLB flush after enough vfree() calls.=
