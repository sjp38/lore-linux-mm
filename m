Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id D1AD96B0034
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 14:36:21 -0400 (EDT)
Date: Mon, 17 Jun 2013 18:36:20 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] mm: Revert pinned_vm braindamage
In-Reply-To: <20130617110832.GP3204@twins.programming.kicks-ass.net>
Message-ID: <0000013f536c60ee-9a1ca9da-b798-416a-a32e-c896813d3bac-000000@email.amazonses.com>
References: <20130606124351.GZ27176@twins.programming.kicks-ass.net> <0000013f1ad00ec0-9574a936-3a75-4ccc-a84c-4a12a7ea106e-000000@email.amazonses.com> <20130607110344.GA27176@twins.programming.kicks-ass.net> <0000013f1f1f79d1-2cf8cb8c-7e63-4e83-9f2b-7acc0e0638a1-000000@email.amazonses.com>
 <20130617110832.GP3204@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, mingo@kernel.org, tglx@linutronix.de, kosaki.motohiro@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org

On Mon, 17 Jun 2013, Peter Zijlstra wrote:

> They did no such thing; being one of those who wrote such code. I
> expressly used RLIMIT_MEMLOCK for its the one limit userspace has to
> limit pages that are exempt from paging.

Dont remember reviewing that. Assumptions were wrong in that patch then.

> > Pinned pages are exempted by the kernel. A device driver or some other
> > kernel process (reclaim, page migration, io etc) increase the page count.
> > There is currently no consistent accounting for pinned pages. The
> > vm_pinned counter was introduced to allow the largest pinners to track
> > what they did.
>
> No, not the largest, user space controlled pinnners. The thing that
> makes all the difference is the _USER_ control.

The pinning *cannot* be done from user space. Here it is the IB subsystem
that is doing it.

> > Pinning is kernel controlled...
>
> That's pure bull; perf and IB have user controlled pinning.

Pinning is a side effect of memory registratin in IB.

> > Ok but this is similar to reclaim and other such things that are unmapping
> > pages.
>
> Which are avoided by mlock() an mlock()ed page will (typically) not get
> unmapped.

Oh it will get unmapped definitely by page migration and such. Otherwise
it could not be moved.

> But we don't want to disable defrag, defrag is good for the general
> health of the system. Also not all applications are RT; we want a kernel
> that's able to run general purpose stuff along with some RT apps.

Still have no idea what you mean by RT.

> *sigh*.. we have shared goals up to a point. RT bounds and if possible
> lowers the worst case latency. The worst case is absolutely most
> important for us.

Ok that differs then.

> By doing so we often also lower the avg latency, but its not the primary
> goal.

So far we have mostly seen these measures to increase the average latency.

> And argue until your face is blue but IB and perf are very much user
> controlled pins.

Sure the user controls the memory registred with IB but the pinning is
done because a device maps the memory. Side effect.

> And while page migration and defrag have CONFIG knobs, reclaim does not;
> file based reclaim is unconditional (except as already noted when using
> mlock()).

Yes that is a big problem.

> I just want to be able to have all that enabled and still have
> applications be able to express their needs and be able to run.

That is not working because these goodies all cause additional latency,
by taking the processor away and disturbing the caches.
You cannot have the cake and eat it too.

> But yes, the intention was very much for the page (and mapping) to be
> left alone by the OS -- its unfortunate the specs wording don't clarify
> this.

All the talks amount this with the mm developers that I have been with had
a different impression and we have implemented it according to the
understanding that mlocked pages are movable. Its not that I am that fond
of it but I accepted it and worked with that notion.

> > > I'm talking about the proposed mpin() stuff.
> >
> > Could you write that up in detail? I am not sure how this could work at
> > this point.
>
> *omg*.. I did. mpin() (and we'll include IB and perf here) is a stronger
> mlock() in that it must avoid all faults, not only the major faults.

Looked like hand waving to me. How exactly does mpin get implemented and
how does it interact with the vm? Do we have to create an additional LRU
for this? Does this do any good given that there is still reclaim and lots
of other stuff going on?

> But I don't much care about the implementation per-se. All I've been
> really arguing for is semantics.

Yes you are arguing to change the established semantics for mlocked pages.

> > Both IB and Perf are kernel subsystems that pin as a side effect of
> > another syscall.
>
> Yeah so? You still have user controlled pinning; the kernel can not rid
> of these resources on its own

Oh there is an mmu_notifier subsystem for this purpose. You can setup a
callback that can unpin pages. Again this is kernel specific. The device
driver needs to register the mmu notifier.

> All _user_ controlled pages exempt from paging. This would be mlock() +
> IB + perf. AFAIK there's nothing else that a user can do to exempt pages
> from paging.

What about dirtying pages, writeback?

> Our big disconnect seems to be user controlled vs kernel controlled.
>
> Why do you care about kernel pins? Those are transient are they not?

Nope the pins for page migration, ib etc can be quite long. And I suspect
that there are multiple subsystems that we are not aware of that also pin
for a longer time period but do not account for their pinning actions.

> > mlockall does not require CAP_IPC_LOCK. Never had an issue.
>
> MCL_FUTURE does absolutely require CAP_IPC_LOCK, MCL_CURRENT requires a
> huge (as opposed to the default 64k) RLIMIT or CAP_IPC_LOCK.
>
> There's no argument there, look at the code.

I am sorry but we have been mlockall() for years now without the
issues that you are bringing up. AFAICT mlockall does not require
MCL_FUTURE.

> > The pinned pages do not need to have a separate limit. They are kernel
> > resources and could be bounded in other ways together with other resources
> > that could cause danger to the kernel (such as too many dirty pages).
> > Pinned pages are often not associated with a process.
>
> So why is grouping user spaced pinned pages with mlock()ed pages such a
> bad idea? Both can cause vm deadlocks for not allowing to reclaim pages.

So can other things.

> > What do you exactly mean by realtime guarantees? (Given that "realtime" is
> > such an overloaded marketing term).
>
> Bounded and preferred low as possible worst case latency. The bound
> gives determinism the second finer resolution.

Well and you still want to run reclaim on the processor etc? What is the
point of all of that when the OS can come in an take the processor away
for a much longer time frame.

> So while we want our self driving car to not collide with stuff, we also
> want to map the road, download maps, track other moving objects etc. Not
> all of that has the same constraints; sensor data must always precede
> maps if at all available, mapping/updating maps isn't at all important
> but nice to have etc.

Well if there is a big boulder on the road (reclaim) then I would worry
about that rather but extensive effort in to clear the road of small
stones (like minor faults).

> That's not what I said. Also you failed to provide rationale for your
> desire to do so. Why would we need to track the transient kernel pins?
> Those will go away on themselves.

I was not talking about transient pins but the longer term ones.

> The IB/perf/mpin() pins are special in that they're dependent on
> userspace and will not go away on their own. Also they need to be
> limited lest userspace would consume too much of them and VM deadlocks
> might ensure.

Yes that is what I said should be done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
