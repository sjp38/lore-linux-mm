Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E89886B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 11:47:18 -0400 (EDT)
Date: Wed, 11 Mar 2009 11:47:16 -0400 (EDT)
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
In-Reply-To: <20090311160223.638b4bc9@mjolnir.ossman.eu>
Message-ID: <alpine.DEB.2.00.0903111115010.3062@gandalf.stny.rr.com>
References: <20090310105523.3dfd4873@mjolnir.ossman.eu> <20090310122210.GA8415@localhost> <20090310131155.GA9654@localhost> <20090310212118.7bf17af6@mjolnir.ossman.eu> <20090311013739.GA7078@localhost> <20090311075703.35de2488@mjolnir.ossman.eu>
 <20090311071445.GA13584@localhost> <20090311082658.06ff605a@mjolnir.ossman.eu> <20090311073619.GA26691@localhost> <20090311085738.4233df4e@mjolnir.ossman.eu> <20090311130022.GA22453@localhost> <20090311160223.638b4bc9@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Pierre Ossman wrote:

> On Wed, 11 Mar 2009 21:00:22 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > 
> > I worked up a simple debugging patch. Since the missing pages are
> > continuously spanned, several stack dumping shall be enough to catch
> > the page consumer.
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 27b8681..c0df7fd 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1087,6 +1087,13 @@ again:
> >  			goto failed;
> >  	}
> >  
> > +	/* wfg - hunting the 40000 missing pages */
> > +	{
> > +		unsigned long pfn = page_to_pfn(page);
> > +		if (pfn > 0x1000 && (pfn & 0xfff) <= 1)
> > +			dump_stack();
> > +	}
> > +
> >  	__count_zone_vm_events(PGALLOC, zone, 1 << order);
> >  	zone_statistics(preferred_zone, zone);
> >  	local_irq_restore(flags);
> 
> This got very noisy, but here's what was in the ring buffer once it had
> booted.
> 
> Note that this is where only the "noflags" pages have been allocated,
> not "lru".

BTW, which kernel are you testing?  2.6.27, ftrace had its own special 
buffering system. It played tricks with the page structs of the pages in 
the buffer. It used the lru parts of the pages to link list itself.
I just booted on a straight 2.6.27 with tracing configured.

# cat /debug/tracing/trace_entries 
65586

This is the old method to see the amount of data used. There are a total 
of 65,586 entries all of 88 bytes each:  5,771,568  And since we also have
a "snapshot" buffer for max latencies, the total is: 11,543,136. That is 
quite a lot of memory for one CPU :-/

Starting with 2.6.28, we now have the unified ring buffer. It removes all 
of the page struct hackery in the original code.

In 2.6.28, the trace_entries is a misnomer. The conversion to the ring 
buffer brought had the change from representing the number of entries 
(entries in the ring buffer are now variable length) and the count is the 
number of bytes each CPU buffer takes up (*2 because of the "snapshot" 
buffer).

# cat /debug/tracing/trace_entries 
1441792

Now we have 1,441,792 or about 3 megs as the default.

Today, we now have it as:

# cat /debug/tracing/buffer_size_kb 
1410


Still the 3 megs. But going from 10Megs a CPU, to 3Megs is a big 
difference. Do you see the same amout of lost memory with the later 
kernels?

I'll have to make the option to expand the ring buffer when a tracer is 
registered. That will be the default option.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
