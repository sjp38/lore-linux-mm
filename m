Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2541E6B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 11:50:42 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Date: Fri, 3 Apr 2009 02:51:20 +1100
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200904022224.31060.nickpiggin@yahoo.com.au> <20090402113400.GC3010@duck.suse.cz>
In-Reply-To: <20090402113400.GC3010@duck.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904030251.22197.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Ying Han <yinghan@google.com>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thursday 02 April 2009 22:34:01 Jan Kara wrote:
> On Thu 02-04-09 22:24:29, Nick Piggin wrote:
> > On Thursday 02 April 2009 09:36:13 Ying Han wrote:
> > > Hi Jan:
> > >     I feel that the problem you saw is kind of differnt than mine. As
> > > you mentioned that you saw the PageError() message, which i don't see
> > > it on my system. I tried you patch(based on 2.6.21) on my system and
> > > it runs ok for 2 days, Still, since i don't see the same error message
> > > as you saw, i am not convineced this is the root cause at least for
> > > our problem. I am still looking into it.
> > >     So, are you seeing the PageError() every time the problem happened?
> > 
> > So I asked if you could test with my workaround of taking truncate_mutex
> > at the start of ext2_get_blocks, and report back. I never heard of any
> > response after that.
> > 
> > To reiterate: I was able to reproduce a problem with ext2 (I was testing
> > on brd to get IO rates high enough to reproduce it quite frequently).
> > I think I narrowed the problem down to block allocation or inode block
> > tree corruption because I was unable to reproduce it with that hack in
> > place.
>   Nick, what load did you use for reproduction? I'll try to reproduce it
> here so that I can debug ext2...

OK, I set up the filesystem like this:

modprobe rd rd_size=$[3*1024*1024]   #almost fill memory so we reclaim buffers
dd if=/dev/zero of=/dev/ram0 bs=4k   #prefill brd so we don't get alloc deadlock
mkfs.ext2 -b1024 /dev/ram0           #1K buffers

Test is basically unmodified except I use 64MB files, and start 8 of them
at once to (8 core system, so improve chances of hitting the bug). Although I
do see it with only 1 running it takes longer to trigger.

I also run a loop doing 'sync ; echo 3 > /proc/sys/vm/drop_caches' but I don't
know if that really helps speed up reproducing it. It is quite random to hit,
but I was able to hit it IIRC in under a minute with that setup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
