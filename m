Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA03919
	for <linux-mm@kvack.org>; Fri, 15 Nov 2002 13:08:44 -0800 (PST)
Message-ID: <3DD56256.C0911282@digeo.com>
Date: Fri, 15 Nov 2002 13:08:38 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: get_user_pages rewrite rediffed against 2.5.47-mm1
References: <20021112205848.B5263@nightmaster.csn.tu-chemnitz.de> <3DD1642A.4A7C663C@digeo.com> <20021115085827.Z659@nightmaster.csn.tu-chemnitz.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser wrote:
> 
> ...
> I envision the following usage:
> 
> setup(&page_walk,...); /* currently done explicitly on stack */
> walk_user_pages(&page_walk);
> 
> /* Do fancy stuff with that pages */
> 
> cleanup(&page_walk); /* calling internal cleanup function
>                         and free the page array */
> 
> How does that sound?

Good.  The callers shouldn't have to know how to initialise the
state structure.
 
> > I suggest that it's time to fold all these arguments into a structure
> > which is on the caller's stack, and pass the address of that around.
> > This will simplify things, but one needs to be careful to think through
> > the ownership rules of the various parts of that structure.
> 
> I'm working on this, but that means a new header file, a new *.c
> file and exporting all the page walkers introduced by me to the
> modules.

That's OK.
 
> It sure will reduce stack usage although we recurse deeper.
> That's a good think already.
> 
> > Please review your ERR_PTR handling.
> 
> Done. Had it otherwise before, but got confused about the code in
> linux/err.h.
> 
> > Also, please rip everything which is appropriate out of mm/memory.c
> > and create a new file in mm/ for it.
> 
> Everything regarding page walking, or should I cleanup more?

I'd say just keep it to "pull the user pagetable access code out of
memory.c".  As much as you can, but not unrelated things.  One
concept per file would be nice.

> In fact mm/memory.c really looks like a mm/misc.c ;-)

Well, with a name like "memory.c", how is anyone to know what it
is supposed to contain? ;)
 
> > I cannot guarantee that we can get this merged up, frankly.  We need
> > a *reason* for doing that.  The current code is "good enough" for
> > current callers.
> 
> The current code sucks for char devices which have much IO
> traffic via DMA. That might not be much, but the number is
> increasing and I'm sure many drivers for measuring cards, which
> will never make it into the kernel, would benefit from that.

OK.
 
> All improvements in that direction have only been with block devices
> in mind so far. I even don't see how I could improve the usage in
> fs/dio.c, because it might sleep very long, so I can't use a page
> walker for it (which needs the mmap_sem).

Well I had plans there to reuse the page walker structure.  So it
would become a big stateful thing which you just feed into the
walker engine and it spits out pages.  With the callback page-processor
being able to return information such as "OK, that's enough pages
for now, let's start some IO".

It would have been rather complex, and just buffering the pages
in struct dio and using the current get_user_pages() was a reasonably
comfortable solution.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
