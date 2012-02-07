Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 453826B13F0
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 07:45:20 -0500 (EST)
Received: by wera13 with SMTP id a13so6713319wer.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 04:45:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328568978-17553-1-git-send-email-mgorman@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
Date: Tue, 7 Feb 2012 20:45:18 +0800
Message-ID: <CAJd=RBAvvzK=TXwDaEjq2t+uEuP2PSi6zaUj7EW4UbL_AUsJAg@mail.gmail.com>
Subject: Re: [PATCH 00/15] Swap-over-NBD without deadlocking V8
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, Feb 7, 2012 at 6:56 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> The core issue is that network block devices do not use mempools like nor=
mal
> block devices do. As the host cannot control where they receive packets f=
rom,
> they cannot reliably work out in advance how much memory they might need.
>
>
> Patch 1 serialises access to min_free_kbytes. It's not strictly needed
> =C2=A0 =C2=A0 =C2=A0 =C2=A0by this series but as the series cares about w=
atermarks in
> =C2=A0 =C2=A0 =C2=A0 =C2=A0general, it's a harmless fix. It could be merg=
ed independently.
>
>
Any light shed on tuning min_free_kbytes for every day work?


> Patch 2 adds knowledge of the PFMEMALLOC reserves to SLAB and SLUB to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0preserve access to pages allocated under low m=
emory situations
> =C2=A0 =C2=A0 =C2=A0 =C2=A0to callers that are freeing memory.
>
> Patch 3 introduces __GFP_MEMALLOC to allow access to the PFMEMALLOC
> =C2=A0 =C2=A0 =C2=A0 =C2=A0reserves without setting PFMEMALLOC.
>
> Patch 4 opens the possibility for softirqs to use PFMEMALLOC reserves
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for later use by network packet processing.
>
> Patch 5 ignores memory policies when ALLOC_NO_WATERMARKS is set.
>
> Patches 6-11 allows network processing to use PFMEMALLOC reserves when
> =C2=A0 =C2=A0 =C2=A0 =C2=A0the socket has been marked as being used by th=
e VM to clean
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pages. If packets are received and stored in p=
ages that were
> =C2=A0 =C2=A0 =C2=A0 =C2=A0allocated under low-memory situations and are =
unrelated to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0the VM, the packets are dropped.
>
> Patch 12 is a micro-optimisation to avoid a function call in the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0common case.
>
> Patch 13 tags NBD sockets as being SOCK_MEMALLOC so they can use
> =C2=A0 =C2=A0 =C2=A0 =C2=A0PFMEMALLOC if necessary.
>
If it is feasible to bypass hang by tuning min_mem_kbytes, things may
become simpler if NICs are also tagged. Sock buffers, pre-allocated if
necessary just after NICs are turned on, are not handed back to kmem
cache but queued on local lists which are maintained by NIC driver, based
the on the info of min_mem_kbytes or similar, for tagged NICs.
Upside is no changes in VM core. Downsides?


> Patch 14 notes that it is still possible for the PFMEMALLOC reserve
> =C2=A0 =C2=A0 =C2=A0 =C2=A0to be depleted. To prevent this, direct reclai=
mers get
> =C2=A0 =C2=A0 =C2=A0 =C2=A0throttled on a waitqueue if 50% of the PFMEMAL=
LOC reserves are
> =C2=A0 =C2=A0 =C2=A0 =C2=A0depleted. =C2=A0It is expected that kswapd and=
 the direct reclaimers
> =C2=A0 =C2=A0 =C2=A0 =C2=A0already running will clean enough pages for th=
e low watermark
> =C2=A0 =C2=A0 =C2=A0 =C2=A0to be reached and the throttled processes are =
woken up.
>
> Patch 15 adds a statistic to track how often processes get throttled
>
>
> For testing swap-over-NBD, a machine was booted with 2G of RAM with a
> swapfile backed by NBD. 8*NUM_CPU processes were started that create
> anonymous memory mappings and read them linearly in a loop. The total
> size of the mappings were 4*PHYSICAL_MEMORY to use swap heavily under
> memory pressure. Without the patches, the machine locks up within
> minutes and runs to completion with them applied.
>
>
While testing, what happens if the network wire is plugged off over
three minutes?

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
