Message-Id: <20071030160401.296770000@chello.nl>
Date: Tue, 30 Oct 2007 17:04:01 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/33] Swap over NFS -v14
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hi,

Another posting of the full swap over NFS series. 

[ I tried just posting the first part last time around, but
  that just gets more confusion by lack of a general picture ]

[ patches against 2.6.23-mm1, also to be found online at:
  http://programming.kicks-ass.net/kernel-patches/vm_deadlock/v2.6.23-mm1/ ]

The patch-set can be split in roughtly 5 parts, for each of which I shall give
a description.


  Part 1, patches 1-12

The problem with swap over network is the generic swap problem: needing memory
to free memory. Normally this is solved using mempools, as can be seen in the
BIO layer.

Swap over network has the problem that the network subsystem does not use fixed
sized allocations, but heavily relies on kmalloc(). This makes mempools
unusable.

This first part provides a generic reserve framework.

Care is taken to only affect the slow paths - when we're low on memory.

Caveats: it is currently SLUB only.

 1 - mm: gfp_to_alloc_flags()
 2 - mm: tag reseve pages
 3 - mm: slub: add knowledge of reserve pages
 4 - mm: allow mempool to fall back to memalloc reserves
 5 - mm: kmem_estimate_pages()
 6 - mm: allow PF_MEMALLOC from softirq context
 7 - mm: serialize access to min_free_kbytes
 8 - mm: emergency pool
 9 - mm: system wide ALLOC_NO_WATERMARK
10 - mm: __GFP_MEMALLOC
11 - mm: memory reserve management
12 - selinux: tag avc cache alloc as non-critical


  Part 2, patches 13-15

Provide some generic network infrastructure needed later on.

13 - net: wrap sk->sk_backlog_rcv()
14 - net: packet split receive api
15 - net: sk_allocation() - concentrate socket related allocations


  Part 3, patches 16-23

Now that we have a generic memory reserve system, use it on the network stack.
The thing that makes this interesting is that, contrary to BIO, both the
transmit and receive path require memory allocations. 

That is, in the BIO layer write back completion is usually just an ISR flipping
a bit and waking stuff up. A network write back completion involved receiving
packets, which when there is no memory, is rather hard. And even when there is
memory there is no guarantee that the required packet comes in in the window
that that memory buys us.

The solution to this problem is found in the fact that network is to be assumed
lossy. Even now, when there is no memory to receive packets the network card
will have to discard packets. What we do is move this into the network stack.

So we reserve a little pool to act as a receive buffer, this allows us to
inspect packets before tossing them. This way, we can filter out those packets
that ensure progress (writeback completion) and disregard the others (as would
have happened anyway). [ NOTE: this is a stable mode of operation with limited
memory usage, exactly the kind of thing we need ]

Again, care is taken to keep much of the overhead of this to only affect the
slow path. Only packets allocated from the reserves will suffer the extra
atomic overhead needed for accounting.

16 - netvm: network reserve infrastructure
17 - sysctl: propagate conv errors
18 - netvm: INET reserves.
19 - netvm: hook skb allocation to reserves
20 - netvm: filter emergency skbs.
21 - netvm: prevent a TCP specific deadlock
22 - netfilter: NF_QUEUE vs emergency skbs
23 - netvm: skb processing


  Part 4, patches 24-26

Generic vm infrastructure to handle swapping to a filesystem instead of a block
device. The approach here has been questioned, people would like to see a less
invasive approach.

One suggestion is to create and use a_ops->swap_{in,out}().

24 - mm: prepare swap entry methods for use in page methods
25 - mm: add support for non block device backed swap files
26 - mm: methods for teaching filesystems about PG_swapcache pages


  Part 5, patches 27-33

Finally, convert NFS to make use of the new network and vm infrastructure to
provide swap over NFS.

27 - nfs: remove mempools
28 - nfs: teach the NFS client how to treat PG_swapcache pages
29 - nfs: disable data cache revalidation for swapfiles
30 - nfs: swap vs nfs_writepage
31 - nfs: enable swap on NFS
32 - nfs: fix various memory recursions possible with swap over NFS.
33 - nfs: do not warn on radix tree node allocation failures



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
