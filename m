Date: Mon, 8 Jul 2002 09:00:15 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020708070015.GA1350@dualathlon.random>
References: <Pine.LNX.4.44.0207070041260.2262-100000@home.transmeta.com> <1083506661.1026032427@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1083506661.1026032427@[10.10.2.3]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <fletch@aracnet.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 07, 2002 at 09:00:27AM -0700, Martin J. Bligh wrote:
> clustered apic mode. Whilst trying to switch this back, he found it ran
> faster as the sequenced unicast, not only for NUMA-Q, but also for
> standard SMP boxes!!! I'm guessing the timing offset generated helps
> cacheline or lock contention ... interesting anyway.

makes sense. but it sounds like it should be fixed in the way we
synchronize with the ipis, rather than by executing them in sequence. We
should just have the smp_call_function poll (read-only) a list of
per-cpu data, and have all the other cpus inside the ipi modifying their
own per-cpu cachelines. Right now the ipi callback works on a shared
cacheline, that is call_data->started/finished, that could be probably
per-cpu without much problems, just having the smp_call_function reading
all the per-cpu fields rather than only the current global ones. things
like tlb flushing are all per-cpu, with per-cpu tlbdata informations,
the only bottleneck really only seems the smp_call_function_interrupt
implementation that uses global counter instead of a per-cpu counters.

it will be a bit similar to the big-reader-lock algorithm, the writer
polling the per-cpu counters here is the smp_call_function, and the
reader modifying its per-cpu counter is smp_call_function_interrupt.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
