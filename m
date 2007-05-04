Message-Id: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:26:51 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/40] Swap over Networked storage -v12
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

There is a fundamental deadlock associated with paging; when writing out a page
to free memory requires free memory to complete. The usually solution is to
keep a small amount of memory available at all times so we can overcome this
problem. This however assumes the amount of memory needed for writeout is
(constant and) smaller than the provided reserve.

It is this latter assumption that breaks when doing writeout over network.
Network can take up an unspecified amount of memory while waiting for a reply
to our write request. This re-introduces the deadlock; we might never complete
the writeout, for we might not have enough memory to receive the completion
message.

The proposed solution is simple, only allow traffic servicing the VM to make
use of the reserves.

This however implies you know what packets are for whom, which generally
speaking you don't. Hence we need to receive all packets but discard them as
soon as we encounter a non VM bound packet allocated from the reserves.

Also knowing it is headed towards the VM needs a little help, hence we
introduce the socket flag SOCK_VMIO to mark sockets with.

Of course, since we are paging all this has to happen in kernel-space, since
user-space might just not be there.

Since packet processing might also require memory, this all also implies that
those auxiliary allocations may use the reserves when an emergency packet is
processed. This is accomplished by using PF_MEMALLOC.

How much memory is to be reserved is also an issue, enough memory to saturate
both the route cache and IP fragment reassembly, along with various constants.

This patch-set comes in 6 parts:

1) introduce the memory reserve and make the SLAB allocator play nice with it.
   patches 01-10

2) add some needed infrastructure to the network code
   patches 11-13

3) implement the idea outlined above
   patches 14-20

4) teach the swap machinery to use generic address_spaces
   patches 21-24

5) implement swap over NFS using all the new stuff
   patches 25-31

6) implement swap over iSCSI
   patches 32-40

Patches can also be found here:
  http://programming.kicks-ass.net/kernel-patches/vm_deadlock/v12/

If I receive no feedback, I will assume the various maintainers do not object
and I will respin the series against -mm and submit for inclusion.

There is interest in this feature from the stateless linux world; that is both
the virtualization world, and the cluster world.

I have been contacted by various groups, some have just expressed their
interest, others have been testing this work in their environments.

Various hardware vendors have also expressed interest, and, of course, my
employer finds it important enough to have me work on it.

Also, while it doesn't present a full-fledged reserve-based allocator API yet,
it does lay most of the groundwork for it. There is a GFP_NOFAIL elimination
project wanting to use this as a foundation. Elimination of GFP_NOFAIL will
greatly improve the basic soundness and stability of the code that currently
uses that construct - most disk based filesystems.

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
