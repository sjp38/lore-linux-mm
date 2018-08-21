Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09B686B1FDA
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 13:23:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y8-v6so7195235edr.12
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 10:23:01 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b38-v6si4497708ede.355.2018.08.21.10.23.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 10:23:00 -0700 (PDT)
Date: Tue, 21 Aug 2018 10:22:39 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH 1/2] mm: rework memcg kernel stack accounting
Message-ID: <20180821172236.GA27058@tower.DHCP.thefacebook.com>
References: <20180815003620.15678-1-guro@fb.com>
 <20180815163923.GA28953@cmpxchg.org>
 <20180815165513.GA26330@castle.DHCP.thefacebook.com>
 <2393E780-2B97-4BEE-8374-8E9E5249E5AD@amacapital.net>
 <20180815172557.GC26330@castle.DHCP.thefacebook.com>
 <CALvZod7TDLtr-DgqgW_0tOKei_54U1JHThpgLKr9_ObaqcC3MA@mail.gmail.com>
 <19CD1E5B-CB86-493A-8BA6-7389E36291B4@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <19CD1E5B-CB86-493A-8BA6-7389E36291B4@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Michal Hocko <mhocko@kernel.org>, luto@kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Wed, Aug 15, 2018 at 10:37:28AM -0700, Andy Lutomirski wrote:
> 
> 
> > On Aug 15, 2018, at 10:32 AM, Shakeel Butt <shakeelb@google.com> wrote:
> > 
> >> On Wed, Aug 15, 2018 at 10:26 AM Roman Gushchin <guro@fb.com> wrote:
> >> 
> >>> On Wed, Aug 15, 2018 at 10:12:42AM -0700, Andy Lutomirski wrote:
> >>> 
> >>> 
> >>>>> On Aug 15, 2018, at 9:55 AM, Roman Gushchin <guro@fb.com> wrote:
> >>>>> 
> >>>>>> On Wed, Aug 15, 2018 at 12:39:23PM -0400, Johannes Weiner wrote:
> >>>>>> On Tue, Aug 14, 2018 at 05:36:19PM -0700, Roman Gushchin wrote:
> >>>>>> @@ -224,9 +224,14 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
> >>>>>>       return s->addr;
> >>>>>>   }
> >>>>>> 
> >>>>>> +    /*
> >>>>>> +     * Allocated stacks are cached and later reused by new threads,
> >>>>>> +     * so memcg accounting is performed manually on assigning/releasing
> >>>>>> +     * stacks to tasks. Drop __GFP_ACCOUNT.
> >>>>>> +     */
> >>>>>>   stack = __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
> >>>>>>                    VMALLOC_START, VMALLOC_END,
> >>>>>> -                     THREADINFO_GFP,
> >>>>>> +                     THREADINFO_GFP & ~__GFP_ACCOUNT,
> >>>>>>                    PAGE_KERNEL,
> >>>>>>                    0, node, __builtin_return_address(0));
> >>>>>> 
> >>>>>> @@ -246,12 +251,41 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
> >>>>>> #endif
> >>>>>> }
> >>>>>> 
> >>>>>> +static void memcg_charge_kernel_stack(struct task_struct *tsk)
> >>>>>> +{
> >>>>>> +#ifdef CONFIG_VMAP_STACK
> >>>>>> +    struct vm_struct *vm = task_stack_vm_area(tsk);
> >>>>>> +
> >>>>>> +    if (vm) {
> >>>>>> +        int i;
> >>>>>> +
> >>>>>> +        for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++)
> >>>>>> +            memcg_kmem_charge(vm->pages[i], __GFP_NOFAIL,
> >>>>>> +                      compound_order(vm->pages[i]));
> >>>>>> +
> >>>>>> +        /* All stack pages belong to the same memcg. */
> >>>>>> +        mod_memcg_page_state(vm->pages[0], MEMCG_KERNEL_STACK_KB,
> >>>>>> +                     THREAD_SIZE / 1024);
> >>>>>> +    }
> >>>>>> +#endif
> >>>>>> +}
> >>>>> 
> >>>>> Before this change, the memory limit can fail the fork, but afterwards
> >>>>> fork() can grow memory consumption unimpeded by the cgroup settings.
> >>>>> 
> >>>>> Can we continue to use try_charge() here and fail the fork?
> >>>> 
> >>>> We can, but I'm not convinced we should.
> >>>> 
> >>>> Kernel stack is relatively small, and it's already allocated at this point.
> >>>> So IMO exceeding the memcg limit for 1-2 pages isn't worse than
> >>>> adding complexity and handle this case (e.g. uncharge partially
> >>>> charged stack). Do you have an example, when it does matter?
> >>> 
> >>> What bounds it to just a few pages?  Couldna??t there be lots of forks in flight that all hit this path?  Ita??s unlikely, and there are surely easier DoS vectors, but still.
> >> 
> >> Because any following memcg-aware allocation will fail.
> >> There is also the pid cgroup controlled which can be used to limit the number
> >> of forks.
> >> 
> >> Anyway, I'm ok to handle the this case and fail fork,
> >> if you think it does matter.
> > 
> > Roman, before adding more changes do benchmark this. Maybe disabling
> > the stack caching for CONFIG_MEMCG is much cleaner.
> > 
> > 
> 
> Unless memcg accounting is colossally slow, the caching should be left on. vmalloc() isna??t inherently slow, but vfree() is, since we need to do a global broadcast TLB flush after enough vfree() calls.

It's not.

BTW, is the test, which you used to measure the performance
gains of stack caching, available publicly?

Thanks!
