Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 43A066B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 08:06:29 -0400 (EDT)
Date: Wed, 12 Aug 2009 13:06:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/6] tracing, documentation: Add a document describing
	how to do some performance analysis with tracepoints
Message-ID: <20090812120626.GB19269@csn.ul.ie>
References: <1249918915-16061-1-git-send-email-mel@csn.ul.ie> <1249918915-16061-6-git-send-email-mel@csn.ul.ie> <20090811113139.20bc276e@bike.lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090811113139.20bc276e@bike.lwn.net>
Sender: owner-linux-mm@kvack.org
To: Jonathan Corbet <corbet@lwn.net>
Cc: Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, Li Ming Chun <macli@brc.ubc.ca>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 11, 2009 at 11:31:39AM -0600, Jonathan Corbet wrote:
> On Mon, 10 Aug 2009 16:41:54 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > This patch adds a simple document intended to get someone started on the
> > different ways of using tracepoints to gather meaningful data.
> 
> It's really good stuff.  Here's a few nits which maybe help to make it
> imperceptibly better...
> 

It makes things much better, thanks. I'll send a fix to the patch as a
follow-up.

> > <SNIP>
> > +This document assumes that debugfs is mounted on /sys/kernel/debug and that
> > +the appropriate tracing options have been configured into the kernel. It is
> > +assumed that the PCL tool tools/perf has been installed and is in your path.
> 
> I would bet it is worth mentioning what those are.  In particular, "perf"
> failed for me until I turned on CONFIG_EVENT_PROFILE - which isn't under
> the tracing options and which doesn't appear to have a help text.
> 
> It might also be worth mentioning that "perf" is in tools/perf - it might
> be a bit before distributors ship it universally.
> 

Done.

> > <SNIP>
> > +2. Enabling Events
> > +==================
> > +
> > +2.1 System-Wide Event Enabling
> > +------------------------------
> > +
> > +See Documentation/trace/events.txt for a proper description on how events
> > +can be enabled system-wide. A short example of enabling all events related
> > +to page allocation would look something like
> > +
> > +  $ for i in `find /sys/kernel/debug/tracing/events -name "enable" | grep mm_`; do echo 1 > $i; done
> 
> This appears not to be necessary if you're using "perf."  If you're doing
> something else (just catting out the events, say),

The example was for people using cat and echo rather than perf. I'll
expand the example. I talk about using perf to enable system-wide
monitoring later.

> you also need to set .../tracing/tracing_enabled.
> 

I added that step.


> > <SNIP>
> > +2.5 Local Event Enablement with PCL
> > +-----------------------------------
> > +
> > +Events can be activate and tracked for the duration of a process on a local
> 
> "activated"
> 

Fixed.

> > <SNIP>
> > +4. Analysing Event Variances with PCL
> > +=====================================
> > +
> > +Any workload can exhibit variances between runs and it can be important
> > +to know what the standard deviation in. By and large, this is left to the
> 
> s/deviation in/deviation is/
> 
> > +performance analyst to do it by hand. In the event that the discrete event
> 
> s/to do it/to do/
> 

Both fixed.

> > <SNIP>
> > +5. Higher-Level Analysis with Helper Scripts
> > +============================================
> > +
> > +When events are enabled the events that are triggering can be read from
> > +/sys/kernel/debug/tracing/trace_pipe in human-readable format although binary
> > +options exist as well. By post-processing the output, further information can
> > +be gathered on-line as appropriate. Examples of post-processing might include
> > +
> > +  o Reading information from /proc for the PID that triggered the event
> > +  o Deriving a higher-level event from a series of lower-level events.
> > +  o Calculate latencies between two events
> 
> "Calculating" would match the tense of the first two items.
> 

True, fixed.

> > +
> > +Documentation/trace/postprocess/trace-pagealloc-postprocess.pl is an example
> 
> I don't have that file in current git...?
> 

You found it later.

> > +script that can read trace_pipe from STDIN or a copy of a trace. When used
> > +on-line, it can be interrupted once to generate a report without existing
> 
> That's why I don't have it!  It can generate reports without
> existing! :)
> 

It's the latest in "Pull It Out Of Your Ass Benchmarking" technology.

> > +and twice to exit.
> > +
> > +Simplistically, the script just reads STDIN and counts up events but it
> > +also can do more such as
> > +
> > +  o Derive high-level events from many low-level events. If a number of pages
> > +    are freed to the main allocator from the per-CPU lists, it recognises
> > +    that as one per-CPU drain even though there is no specific tracepoint
> > +    for that event
> > +  o It can aggregate based on PID or individual process number
> 
> A PID differs from an "individual process number" how?
> 

It's not, that should have been process name, not number ala

  o It can aggregate based on PID or process name

> > <SNIP>
> > +6. Lower-Level Analysis with PCL
> > +================================
> > +
> > +There may also be a requirement to identify what functions with a program
> > +were generating events within the kernel. To begin this sort of analysis, the
> > +data must be recorded. At the time of writing, this required root
> 
> It works happily without root on my -rc5++ system; I don't think I've
> tweaked anything to make that happen.
> 

/me slaps self

It was a permissions problem in the directory I was working from. I
dropped the line. I was so used of requiring root for oprofile that I
didn't think about it properly.

> > +
> > +  $ perf record -c 1 \
> > +	-e kmem:mm_page_alloc -e kmem:mm_page_free_direct \
> > +	-e kmem:mm_pagevec_free \
> > +	./hackbench 10
> > +  Time: 0.894
> > +  [ perf record: Captured and wrote 0.733 MB perf.data (~32010 samples) ]
> > +
> > +Note the use of '-c 1' to set the event period to sample. The default sample
> > +period is quite high to minimise overhead but the information collected can be
> > +very coarse as a result.
> 
> What are the units for -c?
> 

The documentation is somewhat fuzzy. My understanding is as follows and if
I'm wrong, someone will point it out to me.

====
Note the use of '-c 1' to set the sample period. The default sample period
is quite high to minimise overhead but the information collected can be very
coarse as a result.

The sample period is in units of "events occurred". For a hardware counter,
this would usually mean the PMU is programmed to "raise an interrupt after
this many events occured" and the event is recorded on interrupt receipt. For
software-events such as tracepoints, one event will be recorded every "sample
period" number of times the tracepoint triggered.  In this case, -c 1 means
"record a sample every time this tracepoint is triggered".
====

> > <SNIP>
> > +So, almost half of the events are occuring in a library. To get an idea which
> > +symbol.
> > +
> > +  $ perf report --sort comm,dso,symbol
> > +  # Samples: 27666
> > +  #
> > +  # Overhead  Command                            Shared Object  Symbol
> > +  # ........  .......  .......................................  ......
> > +  #
> > +      51.95%     Xorg  [vdso]                                   [.] 0x000000ffffe424
> > +      47.93%     Xorg  /opt/gfx-test/lib/libpixman-1.so.0.13.1  [.] pixmanFillsse2
> > +       0.09%     Xorg  /lib/i686/cmov/libc-2.9.so               [.] _int_malloc
> > +       0.01%     Xorg  /opt/gfx-test/lib/libpixman-1.so.0.13.1  [.] pixman_region32_copy_f
> > +       0.01%     Xorg  [kernel]                                 [k] read_hpet
> > +       0.01%     Xorg  /opt/gfx-test/lib/libpixman-1.so.0.13.1  [.] get_fast_path
> > +       0.00%     Xorg  [kernel]                                 [k] ftrace_trace_userstack
> 
> Worth mentioning that [k] marks kernel-space symbols?
> 

Another column has "[kernel]" in it but it does not hurt to point it
out.

> > +
> > +To see where within the function pixmanFillsse2 things are going wrong
> > +
> > +  $ perf annotate pixmanFillsse2
> > +  [ ... ]
> > +    0.00 :         34eeb:       0f 18 08                prefetcht0 (%eax)
> > +         :      }
> > +         :
> > +         :      extern __inline void __attribute__((__gnu_inline__, __always_inline__, _
> > +         :      _mm_store_si128 (__m128i *__P, __m128i __B) :      {
> > +         :        *__P = __B;
> > +   12.40 :         34eee:       66 0f 7f 80 40 ff ff    movdqa %xmm0,-0xc0(%eax)
> > +    0.00 :         34ef5:       ff 
> > +   12.40 :         34ef6:       66 0f 7f 80 50 ff ff    movdqa %xmm0,-0xb0(%eax)
> > +    0.00 :         34efd:       ff 
> > +   12.39 :         34efe:       66 0f 7f 80 60 ff ff    movdqa %xmm0,-0xa0(%eax)
> > +    0.00 :         34f05:       ff 
> > +   12.67 :         34f06:       66 0f 7f 80 70 ff ff    movdqa %xmm0,-0x90(%eax)
> > +    0.00 :         34f0d:       ff 
> > +   12.58 :         34f0e:       66 0f 7f 40 80          movdqa %xmm0,-0x80(%eax)
> > +   12.31 :         34f13:       66 0f 7f 40 90          movdqa %xmm0,-0x70(%eax)
> > +   12.40 :         34f18:       66 0f 7f 40 a0          movdqa %xmm0,-0x60(%eax)
> > +   12.31 :         34f1d:       66 0f 7f 40 b0          movdqa %xmm0,-0x50(%eax)
> > +
> > +At a glance, it looks like the time is being spent copying pixmaps to
> > +the card.  Further investigation would be needed to determine why pixmaps
> > +are being copied around so much but a starting point would be to take an
> > +ancient build of libpixmap out of the library path where it was totally
> > +forgotten about from months ago!
> 

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
