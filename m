Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 8BACC6B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 11:28:52 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <205ad2fe-50e6-4275-b90d-783e9f6c6984@default>
Date: Mon, 15 Apr 2013 08:28:46 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [Lsf] [LSF/MM TOPIC] Beyond NUMA
References: <9f091f23-9314-422c-9f97-525ddefd483b@default>
 <1365975590.2359.22.camel@dabdike>
In-Reply-To: <1365975590.2359.22.camel@dabdike>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org

> From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> Subject: Re: [Lsf] [LSF/MM TOPIC] Beyond NUMA
>=20
> On Thu, 2013-04-11 at 17:29 -0700, Dan Magenheimer wrote:
> > MM developers and all --
> >
> > It's a bit late to add a topic, but with such a great group of brains
> > together, it seems worthwhile to spend at least some time speculating
> > on "farther-out" problems.  So I propose for the MM track:
> >
> > Beyond NUMA
> >
> > NUMA now impacts even the smallest servers and soon, perhaps even embed=
ded
> > systems, but the performance effects are limited when the number of nod=
es
> > is small (e.g. two).  As the number of nodes grows, along with the numb=
er
> > of memory controllers, NUMA can have a big performance impact and the M=
M
> > community has invested a huge amount of energy into reducing this probl=
em.
> >
> > But as the number of memory controllers grows, the cost of the system
> > grows faster.  This is classic "scale-up" and certain workloads will
> > always benefit from having as many CPUs/cores and nodes as can be
> > packed into a single system.  System vendors are happy to oblige becaus=
e the
> > profit margin on scale-out systems can be proportionally much much
> > larger than on smaller commodity systems.  So the NUMA work will always
> > be necessary and important.
> >
> > But as scale-out grows to previously unimaginable levels, an increasing
> > fraction of workloads are unable to adequately benefit to compensate
> > for the non-linear increase in system cost.  And so more users, especia=
lly
> > cost-sensitive users, are turning instead to scale-out to optimize
> > cost vs benefit for their massive data centers.  Recent examples includ=
e
> > HP's Moonshot and Facebook's "Group Hug".  And even major data center
> > topology changes are being proposed which use super-high-speed links to
> > separate CPUs from RAM [1].
> >
> > While filesystems and storage have long ago adapted to handle large
> > numbers of servers effectively, the MM subsystem is still isolated,
> > managing its own private set of RAM, independent of and completely
> > partitioned from the RAM of other servers.  Perhaps we, the Linux
> > MM developers, should start considering how MM can evolve in this
> > new world.  In some ways, scale-out is like NUMA, but a step beyond.
> > In other ways, scale-out is very different.  The ramster project [2]
> > in the staging tree is a step in the direction of "clusterizing" RAM,
> > but may or may not be the right step.
>=20
> I've got to say from a physics, rather than mm perspective, this sounds
> to be a really badly framed problem.  We seek to eliminate complexity by
> simplification.  What this often means is that even though the theory
> allows us to solve a problem in an arbitrary frame, there's usually a
> nice one where it looks a lot simpler (that's what the whole game of
> eigenvector mathematics and group characters is all about).
>=20
> Saying we need to consider remote in-use memory as high numa and manage
> it from a local node looks a lot like saying we need to consider a
> problem in an arbitrary frame rather than looking for the simplest one.
> The fact of the matter is that network remote memory has latency orders
> of magnitude above local ... the effect is so distinct, it's not even
> worth calling it NUMA.  It does seem then that the correct frame to
> consider this in is local + remote separately with a hierarchical
> management (the massive difference in latencies makes this a simple
> observation from perturbation theory).  Amazingly this is what current
> clustering tools tend to do, so I don't really see there's much here to
> add to the current practice.

Hi James --

Key point...

> The fact of the matter is that network remote memory has latency orders
> of magnitude above local ... the effect is so distinct, it's not even
> worth calling it NUMA.

I didn't say "network remote memory", though I suppose the underlying
fabric might support TCP/IP traffic as well.  If there is a "fast
connection" between the nodes or from nodes to a "memory server", and
it is NOT cache-coherent, and the addressable unit is much larger
than a byte (i.e. perhaps a page), the "frame" is not so arbitrary.
For example "RDMA'ing" a page from one node's RAM to another
node's RAM might not be much slower than copying a page on
a large ccNUMA machine, and still orders of magnitude faster
than paging-in or swapping-in from remote storage.  And just
as today's kernel NUMA code attempts to anticipate if/when
data will be needed and copy it from remote NUMA node to local
NUMA node, this "RDMA-ish" technique could do the same between
cooperating kernels on different machines.

In other words, I'm positing a nice "correct frame" which, given
changes in system topology, fits between current ccNUMA machines
and JBON (just a bunch of nodes, connected via LAN), and proposing
that maybe the MM subsystem could be not only aware of it but
actively participate in it.

As I said, ramster is one such possibility... I'm wondering if
there are more and, if so, better ones.

Does that make more sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
