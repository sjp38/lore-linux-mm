Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C29336B004D
	for <linux-mm@kvack.org>; Sat, 21 Apr 2012 14:15:47 -0400 (EDT)
Date: Sat, 21 Apr 2012 14:15:41 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 00/16] Swap-over-NBD without deadlocking V9
Message-ID: <20120421181541.GC17039@mgebm.net>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gr/z0/N6AeWAPJVB"
Content-Disposition: inline
In-Reply-To: <1334578624-23257-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>


--gr/z0/N6AeWAPJVB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 16 Apr 2012, Mel Gorman wrote:

> Changelog since V8
>   o Rebase to 3.4-rc2
>   o Use page flag instead of slab fields to keep structures the same size
>   o Properly detect allocations from softirq context that use PF_MEMALLOC
>   o Ensure kswapd does not sleep while processes are throttled
>   o Do not accidentally throttle !_GFP_FS processes indefinitely
>=20
> Changelog since V7
>   o Rebase to 3.3-rc2
>   o Take greater care propagating page->pfmemalloc to skb
>   o Propagate pfmemalloc from netdev_alloc_page to skb where possible
>   o Release RCU lock properly on preempt kernel
>=20
> Changelog since V6
>   o Rebase to 3.1-rc8
>   o Use wake_up instead of wake_up_interruptible()
>   o Do not throttle kernel threads
>   o Avoid a potential race between kswapd going to sleep and processes be=
ing
>     throttled
>=20
> Changelog since V5
>   o Rebase to 3.1-rc5
>=20
> Changelog since V4
>   o Update comment clarifying what protocols can be used		(Michal)
>   o Rebase to 3.0-rc3
>=20
> Changelog since V3
>   o Propogate pfmemalloc from packet fragment pages to skb		(Neil)
>   o Rebase to 3.0-rc2
>=20
> Changelog since V2
>   o Document that __GFP_NOMEMALLOC overrides __GFP_MEMALLOC		(Neil)
>   o Use wait_event_interruptible					(Neil)
>   o Use !! when casting to bool to avoid any possibilitity of type
>     truncation								(Neil)
>   o Nicer logic when using skb_pfmemalloc_protocol			(Neil)
>=20
> Changelog since V1
>   o Rebase on top of mmotm
>   o Use atomic_t for memalloc_socks		(David Miller)
>   o Remove use of sk_memalloc_socks in vmscan	(Neil Brown)
>   o Check throttle within prepare_to_wait	(Neil Brown)
>   o Add statistics on throttling instead of printk
>=20
> When a user or administrator requires swap for their application, they
> create a swap partition and file, format it with mkswap and activate it
> with swapon. Swap over the network is considered as an option in diskless
> systems. The two likely scenarios are when blade servers are used as part
> of a cluster where the form factor or maintenance costs do not allow the
> use of disks and thin clients.
>=20
> The Linux Terminal Server Project recommends the use of the
> Network Block Device (NBD) for swap according to the manual at
> https://sourceforge.net/projects/ltsp/files/Docs-Admin-Guide/LTSPManual.p=
df/download
> There is also documentation and tutorials on how to setup swap over NBD
> at places like https://help.ubuntu.com/community/UbuntuLTSP/EnableNBDSWAP
> The nbd-client also documents the use of NBD as swap. Despite this, the
> fact is that a machine using NBD for swap can deadlock within minutes if
> swap is used intensively. This patch series addresses the problem.
>=20
> The core issue is that network block devices do not use mempools like
> normal block devices do. As the host cannot control where they receive
> packets from, they cannot reliably work out in advance how much memory
> they might need. Some years ago, Peter Ziljstra developed a series of
> patches that supported swap over an NFS that at least one distribution
> is carrying within their kernels. This patch series borrows very heavily
> from Peter's work to support swapping over NBD as a pre-requisite to
> supporting swap-over-NFS. The bulk of the complexity is concerned with
> preserving memory that is allocated from the PFMEMALLOC reserves for use
> by the network layer which is needed for both NBD and NFS.
>=20
> Patch 1 serialises access to min_free_kbytes. It's not strictly needed
> 	by this series but as the series cares about watermarks in
> 	general, it's a harmless fix. It could be merged independently
> 	and may be if CMA is merged in advance.
>=20
> Patch 2 adds knowledge of the PFMEMALLOC reserves to SLAB and SLUB to
> 	preserve access to pages allocated under low memory situations
> 	to callers that are freeing memory.
>=20
> Patch 3 introduces __GFP_MEMALLOC to allow access to the PFMEMALLOC
> 	reserves without setting PFMEMALLOC.
>=20
> Patch 4 opens the possibility for softirqs to use PFMEMALLOC reserves
> 	for later use by network packet processing.
>=20
> Patch 5 ignores memory policies when ALLOC_NO_WATERMARKS is set.
>=20
> Patches 6-13 allows network processing to use PFMEMALLOC reserves when
> 	the socket has been marked as being used by the VM to clean pages. If
> 	packets are received and stored in pages that were allocated under
> 	low-memory situations and are unrelated to the VM, the packets
> 	are dropped.
>=20
> 	Patch 11 reintroduces __netdev_alloc_page which the networking
> 	folk may object to but is needed in some cases to propogate
> 	pfmemalloc from a newly allocated page to an skb. If there is a
> 	strong objection, this patch can be dropped with the impact being
> 	that swap-over-network will be slower in some cases but it should
> 	not fail.
>=20
> Patch 13 is a micro-optimisation to avoid a function call in the
> 	common case.
>=20
> Patch 14 tags NBD sockets as being SOCK_MEMALLOC so they can use
> 	PFMEMALLOC if necessary.
>=20
> Patch 15 notes that it is still possible for the PFMEMALLOC reserve
> 	to be depleted. To prevent this, direct reclaimers get throttled on
> 	a waitqueue if 50% of the PFMEMALLOC reserves are depleted.  It is
> 	expected that kswapd and the direct reclaimers already running
> 	will clean enough pages for the low watermark to be reached and
> 	the throttled processes are woken up.
>=20
> Patch 16 adds a statistic to track how often processes get throttled
>=20
> Some basic performance testing was run using kernel builds, netperf
> on loopback for UDP and TCP, hackbench (pipes and sockets), iozone
> and sysbench. Each of them were expected to use the sl*b allocators
> reasonably heavily but there did not appear to be significant
> performance variances.
>=20
> For testing swap-over-NBD, a machine was booted with 2G of RAM with a
> swapfile backed by NBD. 8*NUM_CPU processes were started that create
> anonymous memory mappings and read them linearly in a loop. The total
> size of the mappings were 4*PHYSICAL_MEMORY to use swap heavily under
> memory pressure.
>=20
> Without the patches and using SLUB, the machine locks up within minutes a=
nd
> runs to completion with them applied. With SLAB, the story is different
> as an unpatched kernel run to completion. However, the patched kernel
> completed the test 40% faster.
>=20
>                                          3.4.0-rc2     3.4.0-rc2
>                                       vanilla-slab     swapnbd
> Sys Time Running Test (seconds)              87.90     73.45
> User+Sys Time Running Test (seconds)         91.93     76.91
> Total Elapsed Time (seconds)               4174.37   2953.96
>=20

I have tested these with an artificial swap benchmark and with a large proj=
ect
compile on a beagle board.  They work great for me.  My tests only used this
set via swap over NFS so it probably wasn't very thorough coverage.

Tested-by: Eric B Munson <emunson@mgebm.net>

--gr/z0/N6AeWAPJVB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPkvlNAAoJEKhG9nGc1bpJRPoQAJO1IfGuAqk+XqSvjs8XkQhl
/brlTujCwnmTIZNQfROhz5vRolbWWhvnuVmC2sDiU+U3EDIn/HvYtgUsPVKLs05y
HENF2fly7PCueVOEE9O1T/xwdh1vWkGlwU0J0LIQZVIUm+CAz2zub+JTGuM1ZDxJ
L8e6JlISEm84Kdra2URY22QmaEKLx+dKE47U3yW8aqcq+ZJUH6B/CSaegbLResGi
B+pggQsWECgQD7RK5B1PuS6F9sdlqGBNnFciNoHaIm2wdj6T60PddNb87rNw0qG9
2carJuYZiI3OvKh+1/mE3AfwA6UgnX25qEQdBOJ6dCJLpGzrRWsCQpFAfOrDmecl
vWo/ZjOLSI1ANzIT/BHhcmWhuCRdywJC9AlHPfxDwNt5JUfcUwM3cR2TwIrcCu3C
sZUG88UkL9QkC+qWCnST+cxyDnN1xtX8ydXwbmvaObEObC1zP6xbEZeripXdw2yb
+FTi9q1sXNFwIXa6RrjmSPM3RKdA0MUnGUz0nao+gAMxuT/Xil7BMGIzJFrHgzFx
RRo7PD63zYlhFAvp9vpbg8QeqSbVXSjZ8pqvDGddgc0tFmXxeKxRs1690GnyNyc0
B3VWRL0I5Hs1OIUNaCoUphEYmC1OH9ruTlwK+AEjC//ugmJyKlOf7DIWrdUZLy21
UQFknRonUTItVS2AUmZ3
=A3T4
-----END PGP SIGNATURE-----

--gr/z0/N6AeWAPJVB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
