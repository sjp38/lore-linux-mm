Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id B5D6F6B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 13:36:51 -0400 (EDT)
Received: by igsu6 with SMTP id u6so22323113igs.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 10:36:51 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id p130si8212864iop.126.2015.10.14.10.36.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 10:36:51 -0700 (PDT)
Received: by igsu6 with SMTP id u6so22322896igs.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 10:36:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151014165729.GA12799@mtj.duckdns.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
	<CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
	<20151014165729.GA12799@mtj.duckdns.org>
Date: Wed, 14 Oct 2015 10:36:50 -0700
Message-ID: <CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 14, 2015 at 9:57 AM, Tejun Heo <tj@kernel.org> wrote:
>
> That enum is a bit of misnomer in this case.  It's more like
> WORK_CPU_LOCAL.

Well, that clearly is the new semantic guarantees you are pushing. I'm
not at all convinced it's a good idea, though.

> For both delayed and !delayed work items on per-cpu workqueues,
> queueing without specifying a specific CPU always meant queueing on
> the local CPU.

That's just not true, as far as I can tell.

I went back in the history to 2012, and it does

          if (unlikely(cpu != WORK_CPU_UNBOUND))
                  add_timer_on(timer, cpu);
          else
                  add_timer(timer);

so this whole WORK_CPU_UNBOUND means "add_timer()" without specifying
a CPU has been true for at least the last several years.

So the documentation, the code, and the name all agree:
WORK_CPU_UNBOUND does *not* mean that it's guaranteed to be the local
CPU. The documentation says "preferred", the code clearly doesn't
specify the CPU, and the name says "not bound to a particular CPU".


>> So I feel that this is *obviously* a vmstat bug, and that working
>> around it by adding ah-hoc crap to the workqueues is completely the
>> wrong thing to do. So I'm not going to pull this, because it seems to
>> be hiding the real problem rather than really "fixing" anything.
>
> I wish this were an ad-hoc thing but this has been the guaranteed
> behavior all along.  Switching the specific call-site to
> queue_work_on() would still be a good idea tho.

I really don't see who you say that it has been guaranteed behavior all along.

It clearly has not at all been guaranteed behavior. The fact that you
had to change the code to do that should have made it clear.

The code has *always* done that non-cpu-specific "add_timer()", as far
as I can tell. Even back when that non-bound CPU was indicated by a
negative CPU number, and the code did

                if (unlikely(cpu >= 0))
                        add_timer_on(timer, cpu);
                else
                        add_timer(timer);

(that's from 2007, btw).

So I really don't see your "guaranteed behavior" argument. It seems to
be downright pure bullshit. The lack of a specific CPU has _always_
(where "always" means "at least since 2007") meant "non-specific cpu",
rather than "local cpu".

If some particular interface ended up then actually using "local cpu"
instead, that was neither guaranteed nor implied - it was just a
random implementation detail, and shouldn't be something we guarantee
at all.

We strive to maintain user-space ABI issues even in the face of
unintentional bugs and misfeatures. But we do *not* keep broken random
in-kernel interfaces alive. We fix breakage and clean up code rather
than say "some random in-kernel user expects broken behavior".

And it seems very clear that WORK_CPU_UNBOUND does *not* mean "local
cpu", and code that depends on it meaning local cpu is broken.

Now, there are reasons why the *implementation* might want to choose
the local cpu for things - avoiding waking up other cpu's
unnecessarily with cross-cpu calls etc - but at the same time I think
it's quite clear that mm/vmstat.c is simply broken in using a
non-bound interface and then expecting/assuming a particular CPU.

>> (That said, it's not obvious to me why we don't just specify the cpu
>> in the work structure itself, and just get rid of the "use different
>> functions to schedule the work" model. I think it's somewhat fragile
>> how you can end up using the same work in different "CPU boundedness"
>> models like this).
>
> Hmmm... you mean associating a delayed work item with the target
> pool_workqueue on queueing and sharing the queueing paths for both
> delayed and !delayed work items?

I wouldn't necessarily even go that far. That's more of an
implementation detail.

I just wonder if we perhaps should add the CPU boundedness to the init
stage, and hide it away in the work structure. So if you just want to
do work (delayed or not), you'd continue to do

        INIT_DELAYED_WORK(&work, ...);

        schedule_delayed_work(&work, delay);

but if you want a percpu thing, you'd do

        INIT_DELAYED_WORK_CPU(&work, cpu, ...);

        schedule_delayed_work(&work, delay);

rather than have that "..work_on(cpu, &work, )" interface. The actual
*implementation* could stay the same, we'd just hide the CPU bound in
the work struct and use it as an implicit argument.

But it's not a big deal. I'm just saying that the current interface
obviously allows that confusion about whether a work is percpu or not,
on a per-call-site basis.

I don't think it's normally a problem. But mm/vmstat.c clearly *is*
confused, and uses both "schedule_delayed_work_on()" and
"schedule_delayed_work()" for the same work.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
