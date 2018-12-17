Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 115E88E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 11:32:26 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id w6so7797801otb.6
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:32:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10sor7385428oik.158.2018.12.17.08.32.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 08:32:24 -0800 (PST)
MIME-Version: 1.0
References: <154483851047.1672629.15001135860756738866.stgit@dwillia2-desk3.amr.corp.intel.com>
 <2153922.MoOcIFpNeT@aspire.rjw.lan>
In-Reply-To: <2153922.MoOcIFpNeT@aspire.rjw.lan>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Dec 2018 08:32:10 -0800
Message-ID: <CAPcyv4iW1812gtiuKz8UTPJPhT0_fg+jgo6Z_6Kt9CR2N0Z4Jg@mail.gmail.com>
Subject: Re: [PATCH v5 0/5] mm: Randomize free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Keith Busch <keith.busch@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>, X86 ML <x86@kernel.org>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Dec 17, 2018 at 2:12 AM Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
>
> On Saturday, December 15, 2018 2:48:30 AM CET Dan Williams wrote:
> > Changes since v4: [1]
> > * Default the randomization to off and enable it dynamically based on
> >   the detection of a memory side cache advertised by platform firmware.
> >   In the case of x86 this enumeration comes from the ACPI HMAT. (Michal
> >   and Mel)
> > * Improve the changelog of the patch that introduces the shuffling to
> >   clarify the motivation and better explain the tradeoffs. (Michal and
> >   Mel)
> > * Include the required HMAT enabling in the series.
> >
> > [1]: https://lkml.kernel.org/r/153922180166.838512.8260339805733812034.stgit@dwillia2-desk3.amr.corp.intel.com
> >
> > ---
> >
> > Quote patch 3:
> >
> > Randomization of the page allocator improves the average utilization of
> > a direct-mapped memory-side-cache. Memory side caching is a platform
> > capability that Linux has been previously exposed to in HPC
> > (high-performance computing) environments on specialty platforms. In
> > that instance it was a smaller pool of high-bandwidth-memory relative to
> > higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> > be found on general purpose server platforms where DRAM is a cache in
> > front of higher latency persistent memory [2].
> >
> > Robert offered an explanation of the state of the art of Linux
> > interactions with memory-side-caches [3], and I copy it here:
> >
> >     It's been a problem in the HPC space:
> >     http://www.nersc.gov/research-and-development/knl-cache-mode-performance-coe/
> >
> >     A kernel module called zonesort is available to try to help:
> >     https://software.intel.com/en-us/articles/xeon-phi-software
> >
> >     and this abandoned patch series proposed that for the kernel:
> >     https://lkml.org/lkml/2017/8/23/195
> >
> >     Dan's patch series doesn't attempt to ensure buffers won't conflict, but
> >     also reduces the chance that the buffers will. This will make performance
> >     more consistent, albeit slower than "optimal" (which is near impossible
> >     to attain in a general-purpose kernel).  That's better than forcing
> >     users to deploy remedies like:
> >         "To eliminate this gradual degradation, we have added a Stream
> >          measurement to the Node Health Check that follows each job;
> >          nodes are rebooted whenever their measured memory bandwidth
> >          falls below 300 GB/s."
> >
> > A replacement for zonesort was merged upstream in commit cc9aec03e58f
> > "x86/numa_emulation: Introduce uniform split capability". With this
> > numa_emulation capability, memory can be split into cache sized
> > ("near-memory" sized) numa nodes. A bind operation to such a node, and
> > disabling workloads on other nodes, enables full cache performance.
> > However, once the workload exceeds the cache size then cache conflicts
> > are unavoidable. While HPC environments might be able to tolerate
> > time-scheduling of cache sized workloads, for general purpose server
> > platforms, the oversubscribed cache case will be the common case.
> >
> > The worst case scenario is that a server system owner benchmarks a
> > workload at boot with an un-contended cache only to see that performance
> > degrade over time, even below the average cache performance due to
> > excessive conflicts. Randomization clips the peaks and fills in the
> > valleys of cache utilization to yield steady average performance.
> >
> > See patch 3 for more details.
> >
> > [2]: https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
> > [3]: https://lkml.org/lkml/2018/9/22/54
>
> Has this hibernation been tested with this series applied?

It has not. Is QEMU sufficient? What's your concern?
