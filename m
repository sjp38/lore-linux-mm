Subject: Re: Why don't we make mmap MAP_SHARED with /dev/zero possible?
References: <Pine.LNX.4.10.9911031527070.6110-100000@chiara.csoma.elte.hu>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 03 Nov 1999 08:50:42 -0600
In-Reply-To: Ingo Molnar's message of "Wed, 3 Nov 1999 15:29:35 +0100 (CET)"
Message-ID: <m1r9i7y6gt.fsf@flinx.hidden>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, fxzhang@chpc.ict.ac.cn, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@chiara.csoma.elte.hu> writes:

> On 26 Oct 1999, Christoph Rohland wrote:
> 
> > This lines up with some remarks from Eric Biederman about his shmfs,
> > which is BTW a feature I would _love_ to have in Linux to do posix shm
> > and perhaps redo sysv shm. He said that he would like to make the
> > pagecache highmem-capable and AFAIK the main work for shmfs was
> > makeing the pagecache working with writeable pages.
> 
> hm, i've got the pagecache in high memory already on my box, patch under
> cleanup right now. It was the next natural step after doing all the hard
> work to get 64GB RAM support. Eric, is there any conflicting work here?

Not really.  I played with the idea, and the only really tricky aspect I saw
was how to write a version of copy_to/from_user that would handle the bigmem
case.   Because kmap ... copy .. kunmap  isn't safe as you can sleep due
to a page fault.

I got about half way to a solution by having the page fault handler basically
act like an exception handler, and switch the return address for this one specific
case.  So eventualy when the page fault would return area would magically
rekmap itself, and continue with life.  Duing it this was is important
as it only penalizes the uncommon case.  So within a clock or two
highmem_copy_to/from_user should be as fast as copy_to/from_user.

And I played with putting a wrapper around ll_rw_block calls in buffer.c
that would allocate bounce buffers from the buffer cache as needed.

I've been a little busy so keeping up with the kernel changes has been too much
just lately.  I wound up hacking on dosemu instead where I can out a six month
old patch and finish it up. . .

I'll probably get back to shmfs in a kernel version or two.
>From the last pre-2.3.25-3 it looks like everything I have proposed,
except moving bdflush to the page cache level is finding it's way into
the kernel.  And that last isn't critical for 2.4+

So when I get back to hacking it.  I'm going to concentrate on the
practical things needed to get shmfs working on 2.3.25+
And let some of the rest of you work on the generic mechanisms,
you are doing fine right now. . .

If you'd like to compare mechanisms or whatever I'd be happy too.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
