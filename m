Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CEAB8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 05:45:31 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id x18-v6so4192725lji.0
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 02:45:31 -0800 (PST)
Received: from cloudserver094114.home.pl (cloudserver094114.home.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id v4-v6si10865137ljk.83.2018.12.18.02.45.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Dec 2018 02:45:29 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v5 0/5] mm: Randomize free memory
Date: Tue, 18 Dec 2018 11:45:02 +0100
Message-ID: <11122411.AfX3tQF1aD@aspire.rjw.lan>
In-Reply-To: <CAPcyv4iW1812gtiuKz8UTPJPhT0_fg+jgo6Z_6Kt9CR2N0Z4Jg@mail.gmail.com>
References: <154483851047.1672629.15001135860756738866.stgit@dwillia2-desk3.amr.corp.intel.com> <2153922.MoOcIFpNeT@aspire.rjw.lan> <CAPcyv4iW1812gtiuKz8UTPJPhT0_fg+jgo6Z_6Kt9CR2N0Z4Jg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Keith Busch <keith.busch@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>, X86 ML <x86@kernel.org>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Monday, December 17, 2018 5:32:10 PM CET Dan Williams wrote:
> On Mon, Dec 17, 2018 at 2:12 AM Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> >
> > On Saturday, December 15, 2018 2:48:30 AM CET Dan Williams wrote:
> > > Changes since v4: [1]
> > > * Default the randomization to off and enable it dynamically based on
> > >   the detection of a memory side cache advertised by platform firmware.
> > >   In the case of x86 this enumeration comes from the ACPI HMAT. (Michal
> > >   and Mel)
> > > * Improve the changelog of the patch that introduces the shuffling to
> > >   clarify the motivation and better explain the tradeoffs. (Michal and
> > >   Mel)
> > > * Include the required HMAT enabling in the series.
> > >
> > > [1]: https://lkml.kernel.org/r/153922180166.838512.8260339805733812034.stgit@dwillia2-desk3.amr.corp.intel.com
> > >
> > > ---
> > >
> > > Quote patch 3:
> > >
> > > Randomization of the page allocator improves the average utilization of
> > > a direct-mapped memory-side-cache. Memory side caching is a platform
> > > capability that Linux has been previously exposed to in HPC
> > > (high-performance computing) environments on specialty platforms. In
> > > that instance it was a smaller pool of high-bandwidth-memory relative to
> > > higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> > > be found on general purpose server platforms where DRAM is a cache in
> > > front of higher latency persistent memory [2].
> > >
> > > Robert offered an explanation of the state of the art of Linux
> > > interactions with memory-side-caches [3], and I copy it here:
> > >
> > >     It's been a problem in the HPC space:
> > >     http://www.nersc.gov/research-and-development/knl-cache-mode-performance-coe/
> > >
> > >     A kernel module called zonesort is available to try to help:
> > >     https://software.intel.com/en-us/articles/xeon-phi-software
> > >
> > >     and this abandoned patch series proposed that for the kernel:
> > >     https://lkml.org/lkml/2017/8/23/195
> > >
> > >     Dan's patch series doesn't attempt to ensure buffers won't conflict, but
> > >     also reduces the chance that the buffers will. This will make performance
> > >     more consistent, albeit slower than "optimal" (which is near impossible
> > >     to attain in a general-purpose kernel).  That's better than forcing
> > >     users to deploy remedies like:
> > >         "To eliminate this gradual degradation, we have added a Stream
> > >          measurement to the Node Health Check that follows each job;
> > >          nodes are rebooted whenever their measured memory bandwidth
> > >          falls below 300 GB/s."
> > >
> > > A replacement for zonesort was merged upstream in commit cc9aec03e58f
> > > "x86/numa_emulation: Introduce uniform split capability". With this
> > > numa_emulation capability, memory can be split into cache sized
> > > ("near-memory" sized) numa nodes. A bind operation to such a node, and
> > > disabling workloads on other nodes, enables full cache performance.
> > > However, once the workload exceeds the cache size then cache conflicts
> > > are unavoidable. While HPC environments might be able to tolerate
> > > time-scheduling of cache sized workloads, for general purpose server
> > > platforms, the oversubscribed cache case will be the common case.
> > >
> > > The worst case scenario is that a server system owner benchmarks a
> > > workload at boot with an un-contended cache only to see that performance
> > > degrade over time, even below the average cache performance due to
> > > excessive conflicts. Randomization clips the peaks and fills in the
> > > valleys of cache utilization to yield steady average performance.
> > >
> > > See patch 3 for more details.
> > >
> > > [2]: https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
> > > [3]: https://lkml.org/lkml/2018/9/22/54
> >
> > Has this hibernation been tested with this series applied?
> 
> It has not. Is QEMU sufficient? What's your concern?

Well, hibernation does quite a bit of memory management and that involves
free memory too.  I'm not expecting any particular issues, but I may be
overlooking something and I would like to know that it doesn't break before
the changes go in.

QEMU should be sufficient, but let me talk to the power lab folks if they can
test that for you.

Is there a git branch with these changes available somewhere?
