Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id DDB8E6B0089
	for <linux-mm@kvack.org>; Wed, 30 May 2012 10:47:02 -0400 (EDT)
Message-ID: <1338389200.26856.273.camel@twins>
Subject: Re: [PATCH 00/35] AutoNUMA alpha14
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 30 May 2012 16:46:40 +0200
In-Reply-To: <CA+55aFxpD+LsE+aNvDJtz9sGsGMvdusisgOY3Csbzyx1mEqW-w@mail.gmail.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <4FC112AB.1040605@redhat.com>
	 <CA+55aFxpD+LsE+aNvDJtz9sGsGMvdusisgOY3Csbzyx1mEqW-w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Sat, 2012-05-26 at 13:42 -0700, Linus Torvalds wrote:

> I'm a *firm* believer that if it cannot be done automatically "well
> enough", the absolute last thing we should ever do is worry about the
> crazy people who think they can tweak it to perfection with complex
> interfaces.
>=20
> You can't do it, except for trivial loads (often benchmarks), and for
> very specific machines.
>=20
> So I think very strongly that we should entirely dismiss all the
> people who want to do manual placement and claim that they know what
> their loads do. They're either full of sh*t (most likely), or they
> have a very specific benchmark and platform that they are tuning for
> that is totally irrelevant to everybody else.
>=20
> What we *should* try to aim for is a system that doesn't do horribly
> badly right out of the box. IOW, no tuning what-so-ever (at most a
> kind of "yes, I want you to try to do the NUMA thing" flag to just
> enable it at all), and try to not suck.
>=20
> Seriously. "Try to avoid sucking" is *way* superior to "We can let the
> user tweak things to their hearts content". Because users won't get it
> right.
>=20
> Give the anal people a knob they can tweak, and tell them it does
> something fancy. And never actually wire the damn thing up. They'll be
> really happy with their OCD tweaking, and do lots of nice graphs that
> just show how the error bars are so big that you can find any damn
> pattern you want in random noise.

So the thing is, my homenode-per-process approach should work for
everything except the case where a single process out-strips a single
node in either cpu utilization or memory consumption.

Now I claim such processes are rare since nodes are big, typically 6-8
cores. Writing anything that can sustain parallel execution larger than
that is very specialist (and typically already employs strong data
separation).

Yes there are such things out there, some use JVMs some are virtual
machines some regular applications, but by and large processes are small
compared to nodes.

So my approach is focus on the normal case, and provide 2 system calls
to replace sched_setaffinity() and mbind() for the people who use those.

Now, maybe I shouldn't have bothered with the system calls.. but I
thought providing something better than hard-affinity would be nice.


Andrea went the other way and focused on these big processes. His
approach relies on a pte scanner and faults. His code builds a
page<->thread map using this data either moves memory around or
processes (I'm a little vague on the details simply because I haven't
seen it explained anywhere yet -- and the code is non-obvious).

I have a number of problems with both the approach as well as the
implementation.=20

On the approach my biggest complaints are:

 - the complexity, it focuses on the rarest sort of processes and thus
   results in a rather complex setup.

 - load-balance state explosion, the page-tables become part of the
   load-balance state -- this is a lot of extra state making
   reproduction more 'interesting'.

 - the overhead, since its per page, it needs per-page state.

 - I don't see how it can reliably work for virtual machines, because
   the host page<->thread (vcpu) relation doesn't reflect a
   data<->compute relation in this case. The guest scheduler can move
   the guest thread (the compute) part around between the vcpus at a
   much higher rate than the host will update its page<->vcpu map.

On the implementation:

 - he works around the scheduler instead of with it.

 - its x86 only (although he claims adding archs is trivial
   I've yet to see the first !x86 support).

 - complete lack of useful comments describing the balancing goal and
   approach.

The worst part is that I've asked for this stuff several times, but
nothing seems forth-coming.

Anyway, I prefer doing the simple thing first and then seeing if there's
need for more complexity, esp. given the overheads involved. But if you
prefer we can dive off the deep end :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
