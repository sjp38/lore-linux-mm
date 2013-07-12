Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id B56AA6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:19:18 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id l18so8006693wgh.14
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 02:19:17 -0700 (PDT)
Date: Fri, 12 Jul 2013 10:19:09 +0100
From: Robert Richter <rric@kernel.org>
Subject: Re: [RFC 0/4] Transparent on-demand struct page initialization
 embedded in the buddy allocator
Message-ID: <20130712091909.GC8731@rric.localhost>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <20130712082756.GA4328@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712082756.GA4328@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Robin Holt <holt@sgi.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On 12.07.13 10:27:56, Ingo Molnar wrote:
> 
> * Robin Holt <holt@sgi.com> wrote:
> 
> > [...]
> > 
> > With this patch, we did boot a 16TiB machine.  Without the patches, the 
> > v3.10 kernel with the same configuration took 407 seconds for 
> > free_all_bootmem.  With the patches and operating on 2MiB pages instead 
> > of 1GiB, it took 26 seconds so performance was improved.  I have no feel 
> > for how the 1GiB chunk size will perform.
> 
> That's pretty impressive.
> 
> It's still a 15x speedup instead of a 512x speedup, so I'd say there's 
> something else being the current bottleneck, besides page init 
> granularity.
> 
> Can you boot with just a few gigs of RAM and stuff the rest into hotplug 
> memory, and then hot-add that memory? That would allow easy profiling of 
> remaining overhead.
> 
> Side note:
> 
> Robert Richter and Boris Petkov are working on 'persistent events' support 
> for perf, which will eventually allow boot time profiling - I'm not sure 
> if the patches and the tooling support is ready enough yet for your 
> purposes.

The latest patch set is still this:

 git://git.kernel.org/pub/scm/linux/kernel/git/rric/oprofile.git persistent-v2

It requires the perf subsystem to be initialized first which might be
too late, see perf_event_init() in start_kernel(). The patch set is
currently also limited to tracepoints only.

If this is sufficient for you, you might register persistent events
with the function perf_add_persistent_event_by_id(), see
mcheck_init_tp() how to do this. Later you can fetch all samples with:

 # perf record -e persistent/<tracepoint>/ sleep 1

> Robert, Boris, the following workflow would be pretty intuitive:
> 
>  - kernel developer sets boot flag: perf=boot,freq=1khz,size=16MB
> 
>  - we'd get a single (cycles?) event running once the perf subsystem is up
>    and running, with a sampling frequency of 1 KHz, sending profiling
>    trace events to a sufficiently sized profiling buffer of 16 MB per
>    CPU.

I am not sure about the event you want to setup here, if it is a
tracepoint the sample_period should be always 1. The buffer size
parameter looks interesting, for now it is 512kB per cpu per default
(as perf tools setup the buffer).

> 
>  - once the system reaches SYSTEM_RUNNING, profiling is stopped either
>    automatically - or the user stops it via a new tooling command.
> 
>  - the profiling buffer is extracted into a regular perf.data via a
>    special 'perf record' call or some other, new perf tooling 
>    solution/variant.

See the perf-record command above...

> 
>    [ Alternatively the kernel could attempt to construct a 'virtual'
>      perf.data from the persistent buffer, available via /sys/debug or
>      elsewhere in /sys - just like the kernel constructs a 'virtual' 
>      /proc/kcore, etc. That file could be copied or used directly. ]
> 
>  - from that point on this workflow joins the regular profiling workflow: 
>    perf report, perf script et al can be used to analyze the resulting
>    boot profile.

Ingo, thanks for outlining this workflow. We will look how this could
fit into the new version of persistent events we currently working on.

Thanks,

-Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
