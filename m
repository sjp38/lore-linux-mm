Date: Wed, 22 Mar 2000 16:54:09 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: MADV_DONTNEED
In-Reply-To: <20000322184357.C7271@pcep-jamie.cern.ch>
Message-ID: <Pine.BSO.4.10.10003221641400.17378-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Mar 2000, Jamie Lokier wrote:
> > if you look at the implementation of nopage_sequential_readahead, you'll
> > see that it doesn't use MADV_DONTNEED, but the internal implementation of
> > msync(MS_INVALIDATE).  i'm not completely confident in this
> > implementation, but my intent was to release behind, not discard data.
> 
> If I knew what msync(MS_INVALIDATE) did I could think about this! :-)
> But the msync documentation is unhelpful and possibly misleading.

well, the doc's accurate, as far as i can tell.  but my use of it is a
side-effect of the behavior described in the man page.

> > function 2 (could be MADV_FREE; currently msync(MS_INVALIDATE)):
> >   release pages, syncing dirty data.  if they are referenced again, the
> >   process causes page faults to read in latest data.
> 
> Oh, I see, this is what msync(MS_INVALIDATE) does :-)

more or less.  it removes the mappings, but also schedules writes for any
dirty pages it finds.

> > function 4 (for comparison; currently munmap):
> >   release pages, syncing dirty data.  if they are referenced again, the
> >   process causes invalid memory access faults.
> 
> > for MADV_DONTNEED, i re-used code.
> 
> From where?

you can find logic that invokes zap_page_range throughout the mm code, but
especially in do_munmap.  if my implementation is broken in this regard,
then i'd bet do_munmap is broken too.

> > i'm not convinced that it's correct, though, as i stated when i
> > submitted the patch.  it may abandon swap cache pages, and there may
> > be some undefined interaction between file truncation and
> > MADV_DONTNEED.
> 
> Oh dear -- because it's in pre2.4 already :-)
> Better work out what it's supposed to do and fix it :-)

it's not too serious, i hope, since madvise is not used by any existing
Linux apps.  this area of the kernel has been changing so much in the past
6-9 months that it's been difficult to know what is the blessed way to get
my implementation to work.

it now works in the simple cases.  i'm waiting to hear about real world
usage.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
