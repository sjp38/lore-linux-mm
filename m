Date: Wed, 19 Mar 2008 16:12:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-Id: <20080319161211.2df88adc.akpm@linux-foundation.org>
In-Reply-To: <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
References: <20080318209.039112899@firstfloor.org>
	<20080318003620.d84efb95.akpm@linux-foundation.org>
	<20080318141828.GD11966@one.firstfloor.org>
	<20080318095715.27120788.akpm@linux-foundation.org>
	<20080318172045.GI11966@one.firstfloor.org>
	<20080318104437.966c10ec.akpm@linux-foundation.org>
	<20080319083228.GM11966@one.firstfloor.org>
	<20080319020440.80379d50.akpm@linux-foundation.org>
	<a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@gmail.com>
Cc: andi@firstfloor.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Mar 2008 15:45:16 -0700
"Ulrich Drepper" <drepper@gmail.com> wrote:

> On Wed, Mar 19, 2008 at 2:04 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> >  The requirement to write to an executable sounds like a bit of a
> >  showstopper.
> 
> Agreed.  In addition, it makes all kinds of tools misbehave.  I can
> see extensions to the ELF format and those would require relinking
> binaries, but without this you create chaos.  ELF is so nice because
> it describes the entire file and we can handle everything according to
> rules.  If you just somehow magically patch some new data structure in
> this will break things.
> 
> Furthermore, by adding all this data to the end of the file you'll
> normally create unnecessary costs.  The parts of the binaries which
> are used at runtime start at the front.  At the end there might be a
> lot of data which isn't needed at runtime and is therefore normally
> not read.
> 
> 
> >  if it proves useful, build it all into libc..
> 
> I could see that.  But to handle it efficiently kernel support is
> needed.  Especially since I don't think the currently proposed
> "learning mode" is adequate.  Over many uses of a program all kinds of
> pages will be needed.  Far more than in most cases.  The prefetching
> should really only cover the commonly used code paths in the program.
> If you pull in everything, this will have advantages if you have that
> much page cache to spare.  In that case just prefetching the entire
> file is even easier.  No, such an improved method has to be more
> selective.

yes, ultimately we'd end up pulling in most of the executable that way, and
a 90%-good-enough solution is perhaps to just suck the whole thing into
pagecache.

I did some work on that many years ago and I do recall that it helped, but
I forget how much.

There's a very very easy way of testing this though.  filemap_fault()
_already_ does readaround when it gets a major fault.  And this is tunable
via /sys/block/sda/queue/read_ahead_kb.  So set that to "infinity" to pull
the whole file into pagecache at the first major fault and run some
benchmarks.

If that proves useful we could look at separating read()'s readahead
tunable from filemap_fault()'s tunable.

Note!  Due to interaction between the linker and common filesystems,
executables tend to be very poorly laid out on disk: the blocks are
out-of-order, often grossly.  So one shouldn't do performance testing of
this form against executable files which were written directly by
/usr/bin/ld.  First use `cp' to straighten the file out..

> But if we're selective in the loading of the pages we'll
> (unfortunately) end up with holes.  Possibly many of them.  This would
> mean with today's interfaces a large number of madvise() calls.  What
> would be needed is kernel support which takes a bitmap, each bit
> representing a page.  This bitmap could be allocated as part of the
> binary by the linker.  With appropriate ELF data structures supporting
> it so that strip et.al won't stumble.  To fill in the bitmaps one can
> have separate a separate tool which is explicitly asked to update the
> bitmap data. To collect the page fault data one could use systemtap.
> It's easy enough to write a script which monitors the minor page
> faults for each binary and writes the data into a file.  The binary
> update tool and can use the information from that file to generate the
> bitmap.

bitmap-based madvise() or fadvise() sounds pretty easy to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
