From: frankeh@us.ibm.com
Message-ID: <852568AA.0057CE24.00@D51MTA07.pok.ibm.com>
Date: Wed, 22 Mar 2000 10:56:15 -0500
Subject: Re: More VM balancing issues.. (fwd)
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: torvalds@transmeta.com, bcrl@redhat.com, zim@av.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Let me add my 2 cents here since I have been looking into this together
with Kanoj.
I have been tracking the 2.3.30++ kernel and have tried to make sense of
some of the developments.
Let me state first that we have a 2.3.36 kernel running on a true NUMA
machine comprised of 4 4-way XEON SMPs interconnected via a NUMA switch,
each node having 960MB if main memory located at full GB boundaries.

> From owner-linux-mm@kvack.org  Mon Mar 20 14:20:04 2000
> From: kanoj (Kanoj Sarcar)
> Message-Id: <200003202217.OAA94775@google.engr.sgi.com>
> Subject: Re: More VM balancing issues..
> To: torvalds@transmeta.com (Linus Torvalds)
> Date:   Mon, 20 Mar 2000 14:17:27 -0800 (PST)
> Cc: linux-mm@kvack.org, bcrl@redhat.com (Ben LaHaise),
>         zim@av.com (Christopher Zimmerman), sct@redhat.com (Stephen
Tweedie)
> In-Reply-To:
<Pine.LNX.4.10.10003201232410.4818-100000@penguin.transmeta.com> from
"Linus Torvalds" at Mar 20, 2000 01:27:46 PM
> X-Mailer: ELM [version 2.5 PL2]
> MIME-Version: 1.0
> Content-Type: text/plain; charset=us-ascii
> Content-Transfer-Encoding: 7bit
> X-Orcpt: rfc822;linux-mm@kvack.org
> Sender: owner-linux-mm@kvack.org
> Precedence: bulk
> X-Loop: majordomo@kvack.org
>
> >
> > They happen to be inclusive on x86 (ie DMA <= direct-mapped <=
> > everything), but I think it is a mistake to consider that a design.
It's
> > obviously not true on NUMA if you have per-CPU classes that fall back
onto
> > other CPU's zones. I would imagine, for example, that on NUMA the best
> > arrangement would be something like
> >
> >  - when making a NODE1 allocation, the "class" list is
> >
> >  NODE1, NODE2, NODE3, NODE4, NULL
> >
> >  - when making a NODE2 allocation it would be
> >
> >  NODE2, NODE3, NODE4, NODE1, NULL
> >
> >  etc...
> >
> > (So each node would preferentially always allocate from its own zone,
but
> > would fall back on other nodes memory if the local zone fills up).
>
> Okay, I think the crux of this discussion lies in this statement. I do
> not believe this is what the numa code will do, but note that we are
> not 100% certain at this stage. The numa code will be layered on top
> of the generic code, (the primary goal being generic code should be
> impacted by numa minimally), so for example, the numa version of
> alloc_pages() will invoke __alloc_pages() on different nodes. The
> other thing to note is, the sequence of nodes to allocate is not
> static, but dynamic (depending on other data structures that numa
> code will track). This gives the most flexibility to numa code to
> do the best thing performance wise for a wide variety of apps
> under different situations. So apriori, you can not claim the class
> list for NODE1 allocation will be "NODE1, NODE2, NODE3, NODE4, NULL".
> I am ccing Hubertus Franke from IBM, we have been working on numa
> issues together.

It has been shown that locality in NUMA machine can greatly increase
performance.
We see a need to provide flexible policies regarding allocation of memory
and their node affinity.
So what we would like to see and argue for is something like resource sets
used in NUMA-Q etc.
A process specifies a preferred set of nodes (and maybe a fallback set of
nodes) on where to
(a) allocate memory and (b) execute.
This affinity based memory allocation can be layered on top of the current
__alloc_pages() framework.
Regarding fallback zones and inclusion. It is not clear to us whether
allocation within a set of nodes should be horizontal or vertical first),
i.e. if we ask for a HIGHMEM page, (horizonal::=) should one first allocate
within the HIGHMEM zones of all specified nodes, or (vertical::=) should
they first fallback on the lower zones before moving on to other nodes.
What might weight into the discussion is that HIGHMEM pages have overhead
associated with them (copies etc.)
We adopted the horizontal approach. We have encountered various problems
(== strange behavior) with the current scheme. Either the paging behaviour
settles in too early or too late, it never seems quite right. We have seen
(2.3.36 - 2.3.51) that apps get killed although there is plenty of swap
space available, which we attribute to running out of low memory pages
which are necessary to make forward progress. We have also seen that simply
running __alloc_pages in a fixed order will result in paging request
without actually clearing file caches etc.
For each potential set of nodes (2**N) we order the allocation priority
dynamically to provide some memory balancing with in each node-set.

>
> >
> > With something like the above, there is no longer any true inclusion.
Each
> > class covers an "equal" amount of zones, but has a different structure.
> >
>
> The only example I can think of is a hole architecture, as I mentioned
> before, but even that can be handled with a "true inclusion" assumption.
>
> Unless you can point to a processor/architecture to the contrary, for
> the 2.4 timeframe, I would think we can assume true inclusion. (And that
> will be true even if we come up with a ZONE_PCI32 for 64bit machines).
>

Well on our architecture due to the IA32 memory layout all nodes but NODE-0
only provide HIGHMEM (> 1GB).
So inclusion doesn't exist and their is no equal amount of zones per node.
For NUMA it would be advantageous to actually have HIGH and NORMAL mem on
each node.
For that it would be sufficient to redefine the __va and __pa  macros to
provide a real non-linear translation, (I have done that once in the 2.2.7
kernel using 4MB memory segments and it seemed to work).

> > > 2. The body of zone_balance_memory() should be replaced with the pre1
> > > code, otherwise there are too many differences/problems to enumerate.
> > > Unless you are also proposing changes in this area.
> >
> > The pre1 code was broken, and never checked pages_low. The changes were
> > definitely pre-meditated - trying to think of the balancing as a "list
of
> > zones" issue.
>
> Agreed, I pointed out the breakage when the balancing patch was sent out.
> I patched the pre1 code to get back to 2.3.50 behavior, and Christopher
> Zimmerman zim@av.com tested it out.
>
> >
> > And I think it's fine that kswapd continues to run until we reach
"high".
> > Your patch makes kswapd stop when it reaches "low", but that makes
kswapd
> > go into this kind of "start/stop/start/stop" behaviour at around the
"low"
> > watermark.
> >
> > Maybe you meant to clear the flags the other way around: keep kswapd
> > running until it hits high, but remove the "low_on_mem" flag when we
are
> > above "low" (but we've gotten away from "min"). That might work, but I
> > think clearing both flags at "high" is actually the right thing to do,
> > because that way we will not get into a state where kswapd runs all the
> > time because somebody is still allocating pages without helping to free
> > anything up.
> >
>
> Okay, that is a change on top of 2.3.50 behavior, this can be easily
> implemented. As I mention in Documentation/vm/balance, low_on_memory
> is a hysteric flag, zone_wake_kswapd/kswapd poking is not, we can
> change that. Do you want me to create a new patch against 2.3.99-pre2?
>
> Kanoj
>
> > The pre-3 behaviour is: if you ever hit "min", you set a flag that
means
> > "ok, kswapd can't do this on its own, and needs some help from the
people
> > that allocate memory all the time". If you think of it that way, I
think
> > you'll agree that it shouldn't be cleared until after kswapd says
> > everything is ok again.
> >
> > I don't know..
> >
> >       Linus
> >
>
> --

Another issue that I'd like to bring up in this context is that of HOTSWAP
memory support.
With NUMA systems we should expect partitionability at least through the
switch.
We are working on dynamic node migration in the context of such systems.
This is a feature which pretty much all highend servers are now providing.
For that the kernel must be ready to accept new resources and release a set
of resources.
The NUMA discussions here seem at the heart of this issue.

Kanoj and I have come up with some means to allow higher level policy
implementation, as described above without impacting the base kernel code.
We also have a patch based on this, that allows the definition of a NUMA
machine from a memories point of view running on a single SMP, that will
allow to explore some of these issues mentioned above for those that don't
have a numa machine available. If there is some interest, I can make this
available.

-- Hubertus Franke
-- IBM T.J.Watson Research Center
-- frankeh@us.ibm.com




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
