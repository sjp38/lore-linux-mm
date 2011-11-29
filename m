Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 43CFD6B004D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 21:40:22 -0500 (EST)
Date: Tue, 29 Nov 2011 10:40:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/8] readahead: record readahead patterns
Message-ID: <20111129024015.GA19506@localhost>
References: <20111121091819.394895091@intel.com>
 <20111121093846.510441032@intel.com>
 <20111121151919.4b76a475.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121151919.4b76a475.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Mon, Nov 21, 2011 at 03:19:19PM -0800, Andrew Morton wrote:
> On Mon, 21 Nov 2011 17:18:23 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Record the readahead pattern in ra_flags and extend the ra_submit()
> > parameters, to be used by the next readahead tracing/stats patches.
> > 
> > 7 patterns are defined:
> > 
> >       	pattern			readahead for
> > -----------------------------------------------------------
> > 	RA_PATTERN_INITIAL	start-of-file read
> > 	RA_PATTERN_SUBSEQUENT	trivial sequential read
> > 	RA_PATTERN_CONTEXT	interleaved sequential read
> > 	RA_PATTERN_OVERSIZE	oversize read
> > 	RA_PATTERN_MMAP_AROUND	mmap fault
> > 	RA_PATTERN_FADVISE	posix_fadvise()
> > 	RA_PATTERN_RANDOM	random read
> 
> It would be useful to spell out in full detail what an "interleaved
> sequential read" is, and why a read is considered "oversized", etc. 
> The 'enum readahead_pattern' definition site would be a good place for
> this.

Good point, here is the added comments:

/*
 * Which policy makes decision to do the current read-ahead IO?
 *
 * RA_PATTERN_INITIAL           readahead window is initially opened,
 *                              normally when reading from start of file
 * RA_PATTERN_SUBSEQUENT        readahead window is pushed forward
 * RA_PATTERN_CONTEXT           no readahead window available, querying the
 *                              page cache to decide readahead start/size.
 *                              This typically happens on interleaved reads (eg.
 *                              reading pages 0, 1000, 1, 1001, 2, 1002, ...)
 *                              where one file_ra_state struct is not enough
 *                              for recording 2+ interleaved sequential read
 *                              streams.
 * RA_PATTERN_MMAP_AROUND       read-around on mmap page faults
 *                              (w/o any sequential/random hints)
 * RA_PATTERN_BACKWARDS         reverse reading detected
 * RA_PATTERN_FADVISE           triggered by POSIX_FADV_WILLNEED or FMODE_RANDOM
 * RA_PATTERN_OVERSIZE          a random read larger than max readahead size,
 *                              do max readahead to break down the read size
 * RA_PATTERN_RANDOM            a small random read
 */

> > Note that random reads will be recorded in file_ra_state now.
> > This won't deteriorate cache bouncing because the ra->prev_pos update
> > in do_generic_file_read() already pollutes the data cache, and
> > filemap_fault() will stop calling into us after MMAP_LOTSAMISS.
> > 
> > --- linux-next.orig/include/linux/fs.h	2011-11-20 20:10:48.000000000 +0800
> > +++ linux-next/include/linux/fs.h	2011-11-20 20:18:29.000000000 +0800
> > @@ -951,6 +951,39 @@ struct file_ra_state {
> >  
> >  /* ra_flags bits */
> >  #define	READAHEAD_MMAP_MISS	0x000003ff /* cache misses for mmap access */
> > +#define	READAHEAD_MMAP		0x00010000
> 
> Why leave a gap?

Never mind, it's now converted to a bit field :)

> And what is READAHEAD_MMAP anyway?

READAHEAD_MMAP will be set for mmap page faults.

> > +#define READAHEAD_PATTERN_SHIFT	28
> 
> Why 28?

Bits 28-32 are for READAHEAD_PATTERN.

Anyway it will be gone when breaking down the ra_flags fields into
individual variables.

> > +#define READAHEAD_PATTERN	0xf0000000
> > +
> > +/*
> > + * Which policy makes decision to do the current read-ahead IO?
> > + */
> > +enum readahead_pattern {
> > +	RA_PATTERN_INITIAL,
> > +	RA_PATTERN_SUBSEQUENT,
> > +	RA_PATTERN_CONTEXT,
> > +	RA_PATTERN_MMAP_AROUND,
> > +	RA_PATTERN_FADVISE,
> > +	RA_PATTERN_OVERSIZE,
> > +	RA_PATTERN_RANDOM,
> > +	RA_PATTERN_ALL,		/* for summary stats */
> > +	RA_PATTERN_MAX
> > +};
> 
> Again, the behaviour is all undocumented.  I see from the code that
> multiple flags can be set at the same time.  So afacit a file can be
> marked RANDOM and SUBSEQUENT at the same time, which seems oxymoronic.

Nope, it will be classified into one "pattern" exclusively.

> This reader wants to know what the implications of this are - how the
> code chooses, prioritises and acts.  But this code doesn't tell me.

Hope the comment addresses this issue. The precise logic happens
mainly inside ondemand_readahead().

> > +static inline unsigned int ra_pattern(unsigned int ra_flags)
> > +{
> > +	unsigned int pattern = ra_flags >> READAHEAD_PATTERN_SHIFT;
> 
> OK, no masking is needed because the code silently assumes that arg
> `ra_flags' came out of an ra_state.ra_flags and it also silently
> assumes that no higher bits are used in ra_state.ra_flags.
> 
> That's a bit of a handgrenade - if someone redoes the flags
> enumeration, the code will explode.

Yeah sorry for playing with such tricks. Will get rid of this function
totally and use a plain assign to ra->pattern.

> > +	return min_t(unsigned int, pattern, RA_PATTERN_ALL);
> > +}
> 
> <scratches head>
> 
> What the heck is that min_t() doing in there?

Just for safety... not really necessary given correct code.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
