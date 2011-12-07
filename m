Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C95BE6B006E
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 04:18:30 -0500 (EST)
Date: Wed, 7 Dec 2011 17:18:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/9] readahead: add vfs/readahead tracing event
Message-ID: <20111207091820.GA7656@localhost>
References: <20111129130900.628549879@intel.com>
 <20111129131456.797240894@intel.com>
 <20111206153025.GA18974@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111206153025.GA18974@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Tue, Dec 06, 2011 at 11:30:25PM +0800, Christoph Hellwig wrote:
> > +	TP_printk("readahead-%s(dev=%d:%d, ino=%lu, "
> 
> please don't duplicate the tracepoint name in the output string.
> Also don't use braces, as it jsut complicates parsing.

OK. Changed to this format:

        TP_printk("pattern=%s bdi=%s ino=%lu "      
                  "req=%lu+%lu ra=%lu+%d-%d async=%d actual=%d",


> > +		  "req=%lu+%lu, ra=%lu+%d-%d, async=%d) = %d",
> > +			ra_pattern_names[__entry->pattern],
> 
> Instead of doing a manual array lookup please use __print_symbolic so
> that users of the binary interface (like trace-cmd) also get the
> right output.

The patch actually started with 

+#define show_pattern_name(val)                                            \
+       __print_symbolic(val,                                              \
+                       { RA_PATTERN_INITIAL,           "initial"       }, \
+                       { RA_PATTERN_SUBSEQUENT,        "subsequent"    }, \
+                       { RA_PATTERN_CONTEXT,           "context"       }, \
+                       { RA_PATTERN_THRASH,            "thrash"        }, \
+                       { RA_PATTERN_MMAP_AROUND,       "around"        }, \
+                       { RA_PATTERN_FADVISE,           "fadvise"       }, \
+                       { RA_PATTERN_RANDOM,            "random"        }, \
+                       { RA_PATTERN_ALL,               "all"           })

It's then converted to the current form so as to avoid duplicating the
num<>string mapping in two places.

The recently added writeback reason shares the same problem:

        TP_printk("bdi %s: sb_dev %d:%d nr_pages=%ld sync_mode=%d "
                  "kupdate=%d range_cyclic=%d background=%d reason=%s",
...
                  wb_reason_name[__entry->reason]
        )

Fortunately that's newly introduced in 3.2-rc1, so it's still the good
time to fix the writeback traces.

However the problem is, are we going to keep adding duplicate mappings
like this in future?

> > --- linux-next.orig/mm/readahead.c	2011-11-29 20:58:53.000000000 +0800
> > +++ linux-next/mm/readahead.c	2011-11-29 20:59:20.000000000 +0800
> > @@ -29,6 +29,9 @@ static const char * const ra_pattern_nam
> >  	[RA_PATTERN_ALL]                = "all",
> >  };
> >  
> > +#define CREATE_TRACE_POINTS
> > +#include <trace/events/vfs.h>
> 
> Maybe we should create a new fs/trace.c just for this instead of stickin
> it into the first file that created a tracepoint in the "vfs" namespace.

Yeah, it looks better to move it to a more general place.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
