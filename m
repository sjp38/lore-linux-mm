Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id C55C06B0005
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 13:33:17 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id b77-v6so30286vke.4
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 10:33:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r33-v6sor9227372uar.284.2018.08.15.10.33.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Aug 2018 10:33:16 -0700 (PDT)
MIME-Version: 1.0
References: <20180815003620.15678-1-guro@fb.com> <20180815163923.GA28953@cmpxchg.org>
 <20180815165513.GA26330@castle.DHCP.thefacebook.com> <2393E780-2B97-4BEE-8374-8E9E5249E5AD@amacapital.net>
 <20180815172557.GC26330@castle.DHCP.thefacebook.com>
In-Reply-To: <20180815172557.GC26330@castle.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 15 Aug 2018 10:32:41 -0700
Message-ID: <CALvZod7TDLtr-DgqgW_0tOKei_54U1JHThpgLKr9_ObaqcC3MA@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] mm: rework memcg kernel stack accounting
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: luto@amacapital.net, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Michal Hocko <mhocko@kernel.org>, luto@kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Wed, Aug 15, 2018 at 10:26 AM Roman Gushchin <guro@fb.com> wrote:
>
> On Wed, Aug 15, 2018 at 10:12:42AM -0700, Andy Lutomirski wrote:
> >
> >
> > > On Aug 15, 2018, at 9:55 AM, Roman Gushchin <guro@fb.com> wrote:
> > >
> > >> On Wed, Aug 15, 2018 at 12:39:23PM -0400, Johannes Weiner wrote:
> > >>> On Tue, Aug 14, 2018 at 05:36:19PM -0700, Roman Gushchin wrote:
> > >>> @@ -224,9 +224,14 @@ static unsigned long *alloc_thread_stack_node(=
struct task_struct *tsk, int node)
> > >>>        return s->addr;
> > >>>    }
> > >>>
> > >>> +    /*
> > >>> +     * Allocated stacks are cached and later reused by new threads=
,
> > >>> +     * so memcg accounting is performed manually on assigning/rele=
asing
> > >>> +     * stacks to tasks. Drop __GFP_ACCOUNT.
> > >>> +     */
> > >>>    stack =3D __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
> > >>>                     VMALLOC_START, VMALLOC_END,
> > >>> -                     THREADINFO_GFP,
> > >>> +                     THREADINFO_GFP & ~__GFP_ACCOUNT,
> > >>>                     PAGE_KERNEL,
> > >>>                     0, node, __builtin_return_address(0));
> > >>>
> > >>> @@ -246,12 +251,41 @@ static unsigned long *alloc_thread_stack_node=
(struct task_struct *tsk, int node)
> > >>> #endif
> > >>> }
> > >>>
> > >>> +static void memcg_charge_kernel_stack(struct task_struct *tsk)
> > >>> +{
> > >>> +#ifdef CONFIG_VMAP_STACK
> > >>> +    struct vm_struct *vm =3D task_stack_vm_area(tsk);
> > >>> +
> > >>> +    if (vm) {
> > >>> +        int i;
> > >>> +
> > >>> +        for (i =3D 0; i < THREAD_SIZE / PAGE_SIZE; i++)
> > >>> +            memcg_kmem_charge(vm->pages[i], __GFP_NOFAIL,
> > >>> +                      compound_order(vm->pages[i]));
> > >>> +
> > >>> +        /* All stack pages belong to the same memcg. */
> > >>> +        mod_memcg_page_state(vm->pages[0], MEMCG_KERNEL_STACK_KB,
> > >>> +                     THREAD_SIZE / 1024);
> > >>> +    }
> > >>> +#endif
> > >>> +}
> > >>
> > >> Before this change, the memory limit can fail the fork, but afterwar=
ds
> > >> fork() can grow memory consumption unimpeded by the cgroup settings.
> > >>
> > >> Can we continue to use try_charge() here and fail the fork?
> > >
> > > We can, but I'm not convinced we should.
> > >
> > > Kernel stack is relatively small, and it's already allocated at this =
point.
> > > So IMO exceeding the memcg limit for 1-2 pages isn't worse than
> > > adding complexity and handle this case (e.g. uncharge partially
> > > charged stack). Do you have an example, when it does matter?
> >
> > What bounds it to just a few pages?  Couldn=E2=80=99t there be lots of =
forks in flight that all hit this path?  It=E2=80=99s unlikely, and there a=
re surely easier DoS vectors, but still.
>
> Because any following memcg-aware allocation will fail.
> There is also the pid cgroup controlled which can be used to limit the nu=
mber
> of forks.
>
> Anyway, I'm ok to handle the this case and fail fork,
> if you think it does matter.

Roman, before adding more changes do benchmark this. Maybe disabling
the stack caching for CONFIG_MEMCG is much cleaner.

Shakeel
