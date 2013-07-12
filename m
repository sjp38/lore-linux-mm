Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 1A8E86B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 04:28:02 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id c1so6074671eek.4
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 01:28:00 -0700 (PDT)
Date: Fri, 12 Jul 2013 10:27:56 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC 0/4] Transparent on-demand struct page initialization
 embedded in the buddy allocator
Message-ID: <20130712082756.GA4328@gmail.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373594635-131067-1-git-send-email-holt@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>, Borislav Petkov <bp@alien8.de>, Robert Richter <rric@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Robin Holt <holt@sgi.com> wrote:

> [...]
> 
> With this patch, we did boot a 16TiB machine.  Without the patches, the 
> v3.10 kernel with the same configuration took 407 seconds for 
> free_all_bootmem.  With the patches and operating on 2MiB pages instead 
> of 1GiB, it took 26 seconds so performance was improved.  I have no feel 
> for how the 1GiB chunk size will perform.

That's pretty impressive.

It's still a 15x speedup instead of a 512x speedup, so I'd say there's 
something else being the current bottleneck, besides page init 
granularity.

Can you boot with just a few gigs of RAM and stuff the rest into hotplug 
memory, and then hot-add that memory? That would allow easy profiling of 
remaining overhead.

Side note:

Robert Richter and Boris Petkov are working on 'persistent events' support 
for perf, which will eventually allow boot time profiling - I'm not sure 
if the patches and the tooling support is ready enough yet for your 
purposes.

Robert, Boris, the following workflow would be pretty intuitive:

 - kernel developer sets boot flag: perf=boot,freq=1khz,size=16MB

 - we'd get a single (cycles?) event running once the perf subsystem is up
   and running, with a sampling frequency of 1 KHz, sending profiling
   trace events to a sufficiently sized profiling buffer of 16 MB per
   CPU.

 - once the system reaches SYSTEM_RUNNING, profiling is stopped either
   automatically - or the user stops it via a new tooling command.

 - the profiling buffer is extracted into a regular perf.data via a
   special 'perf record' call or some other, new perf tooling 
   solution/variant.

   [ Alternatively the kernel could attempt to construct a 'virtual'
     perf.data from the persistent buffer, available via /sys/debug or
     elsewhere in /sys - just like the kernel constructs a 'virtual' 
     /proc/kcore, etc. That file could be copied or used directly. ]

 - from that point on this workflow joins the regular profiling workflow: 
   perf report, perf script et al can be used to analyze the resulting
   boot profile.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
