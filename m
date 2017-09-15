Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2296B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 03:28:51 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e9so4729576iod.4
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 00:28:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 76si191441oic.515.2017.09.15.00.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 00:28:49 -0700 (PDT)
Date: Fri, 15 Sep 2017 09:28:39 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Page allocator bottleneck
Message-ID: <20170915092839.690ea9e9@redhat.com>
In-Reply-To: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>
Cc: David Miller <davem@davemloft.net>, Mel Gorman <mgorman@techsingularity.net>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Linux Kernel Network Developers <netdev@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>, brouer@redhat.com

On Thu, 14 Sep 2017 19:49:31 +0300
Tariq Toukan <tariqt@mellanox.com> wrote:

> Hi all,
>=20
> As part of the efforts to support increasing next-generation NIC speeds,
> I am investigating SW bottlenecks in network stack receive flow.
>=20
> Here I share some numbers I got for a simple experiment, in which I=20
> simulate the page allocation rate needed in 200Gpbs NICs.

Thanks for bringing this up again.=20

> I ran the test below over 3 different (modified) mlx5 driver versions,
> loaded on server side (RX):
> 1) RX page cache disabled, 2 packets per page.

2 packets per page basically reduce the overhead you see from the page
allocator to half.

> 2) RX page cache disabled, one packet per page.

This, should stress the page allocator.

> 3) Huge RX page cache, one packet per page.

A driver level page-cache will look nice, as long as it "works". =20

Drivers usually have no other option than basing their recycle facility
to be based on the page-refcnt (as there is no destructor callback).
Which implies packets/pages need to be returned quickly enough for it
to work.

> All page allocations are of order 0.
>=20
> NIC: Connectx-5 100 Gbps.
> CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
>=20
> Test:
> 128 TCP streams (using super_netperf).
> Changing num of RX queues.
> HW LRO OFF, GRO ON, MTU 1500.

With TCP streams and GRO, is actually a good stress test for the page
allocator (or drivers page-recycle cache). As  Eric Dumazet have made
some nice optimizations, that (in most situations) cause us to quickly
free/recycle the SKB (coming from driver) and store the pages in 1-SKB.
This cause us to hit the SLUB fastpath for the SKBs, but once the pages
need to be free'ed this stress the page allocator more.

Also be aware that with TCP flows, the packets are likely delivered
into a socket, that is consumed on another CPU.  Thus, the pages are
allocated on one CPU and free'ed on another. AFAIK this stress the
order-0 cache PCP (Per-Cpu-Pages).


> Observe: BW as a function of num RX queues.
>=20
> Results:
>=20
> Driver #1:
> #rings	BW (Mbps)
> 1	23,813
> 2	44,086
> 3	62,128
> 4	78,058
> 6	94,210 (linerate)
> 8	94,205 (linerate)
> 12	94,202 (linerate)
> 16	94,191 (linerate)
>=20
> Driver #2:
> #rings	BW (Mbps)
> 1	18,835
> 2	36,716
> 3	50,521
> 4	61,746
> 6	63,637
> 8	60,299
> 12	51,048
> 16	43,337
>=20
> Driver #3:
> #rings	BW (Mbps)
> 1	19,316
> 2	44,850
> 3	69,549
> 4	87,434
> 6	94,342 (linerate)
> 8	94,350 (linerate)
> 12	94,327 (linerate)
> 16	94,327 (linerate)
>=20
>=20
> Insights:
> Major degradation between #1 and #2, not getting any close to linerate!
> Degradation is fixed between #2 and #3.
> This is because page allocator cannot stand the higher allocation rate.
> In #2, we also see that the addition of rings (cores) reduces BW (!!),=20
> as result of increasing congestion over shared resources.
>=20
> Congestion in this case is very clear.
> When monitored in perf top:
> 85.58% [kernel] [k] queued_spin_lock_slowpath

Well, we obviously need to know the caller of the spin_lock.  In this
case it is likely the page allocator lock.  It could also be the TCP
socket locks, but given GRO is enabled, they should be hit much less.


> I think that page allocator issues should be discussed separately:
> 1) Rate: Increase the allocation rate on a single core.
> 2) Scalability: Reduce congestion and sync overhead between cores.

Yes, but this no small task.  I is on my TODO-list (emacs org-mode),
but I have other tasks that have higher priority atm.  I'll be working
on XDP_REDIRECT for the next many months.  Currently trying to convince
people that we do an explicit packet-page return/free callback (which
would avoid many of these issues).


> This is clearly the current bottleneck in the network stack receive
> flow.
>=20
> I know about some efforts that were made in the past two years.
> For example the ones from Jesper et al.:
>
> - Page-pool (not accepted AFAIK).

The page-pool have many purposes.
 1. generic page-cache for drivers,
 2. keep pages DMA-mapped
 3. facilitate drivers to change RX-ring memory model

=46rom a MM-point-of-view the page pool is just a destructor callback,
that can "steal" the page.

If I can convince XDP_REDIRECT to use an explicit destructor callback,
then I almost get what I need.  Except for the generic part, and the
normal network path will not see the benefit.  Thus, not helping your
use-case, I guess.


> - Page-allocation bulking.

Notice, that page-allocator bulking, would still be needed by the
page-pool and other page-cache facilities. We should implement it
regardless of the page_pool. =20

Without a page pool facility to hide the use of page bulking.  You
could use page-bulk-alloc in driver RX-ring refill, and find where TCP
free the GRO packets, and do page-bulk-free there.


> - Optimize order-0 allocations in Per-Cpu-Pages.

There is a need to optimize PCP some more for the single-core XDP
performance target (~14Mpps).  I guess, the easiest way around this is
implement/integrate a page bulk API into PCP.

The TCP-GRO use-case you are hitting is a different bottleneck.
It is a multi-CPU parallel workload, that exceed the PCP cache size,
and cause you to hit the page buddy allocator.

I wonder if you could "solve"/mitigate the issue if you tune the size
of the PCP cache?
AFAIK it only keeps 128 pages cached per CPU... I know you can see this
via a proc file, but I cannot remember which(?).  And I'm not sure how
you tune this(?)


> I am not an mm expert, but wanted to raise the issue again, to combine=20
> the efforts and hear from you guys about status and possible directions.

Regarding recent changes... if you have you kernel compiled with
CONFIG_NUMA then the page-allocator is slower (due to keeping
numa-stats), except that this was recently optimized and merged(?)

What (exact) kernel git tree did you run these tests on?

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
