Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 4E5F16B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 04:55:00 -0400 (EDT)
Date: Tue, 16 Jul 2013 17:55:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 0/4] Transparent on-demand struct page initialization
 embedded in the buddy allocator
Message-ID: <20130716085502.GA31276@lge.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <20130712082756.GA4328@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712082756.GA4328@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Robin Holt <holt@sgi.com>, Borislav Petkov <bp@alien8.de>, Robert Richter <rric@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Jul 12, 2013 at 10:27:56AM +0200, Ingo Molnar wrote:
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
> 
> Robert, Boris, the following workflow would be pretty intuitive:
> 
>  - kernel developer sets boot flag: perf=boot,freq=1khz,size=16MB
> 
>  - we'd get a single (cycles?) event running once the perf subsystem is up
>    and running, with a sampling frequency of 1 KHz, sending profiling
>    trace events to a sufficiently sized profiling buffer of 16 MB per
>    CPU.
> 
>  - once the system reaches SYSTEM_RUNNING, profiling is stopped either
>    automatically - or the user stops it via a new tooling command.
> 
>  - the profiling buffer is extracted into a regular perf.data via a
>    special 'perf record' call or some other, new perf tooling 
>    solution/variant.
> 
>    [ Alternatively the kernel could attempt to construct a 'virtual'
>      perf.data from the persistent buffer, available via /sys/debug or
>      elsewhere in /sys - just like the kernel constructs a 'virtual' 
>      /proc/kcore, etc. That file could be copied or used directly. ]

Hello, Robert, Boris, Ingo.

How about executing a perf in usermodehelper and collecting output in
tmpfs? Using this approach, we can start a perf after rootfs
initialization, because we need a perf binary at least. But we can use
almost functionality of perf. If anyone have interest with
this approach, I will send patches implementing this idea.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
