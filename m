Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA05551
	for <linux-mm@kvack.org>; Wed, 17 Jun 1998 06:26:36 -0400
Subject: Re: PTE chaining, kswapd and swapin readahead
References: <Pine.LNX.3.96.980617000413.6859C-100000@mirkwood.dummy.home>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 17 Jun 1998 04:24:17 -0500
In-Reply-To: Rik van Riel's message of Wed, 17 Jun 1998 00:10:07 +0200 (CEST)
Message-ID: <m17m2gz8hq.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

RR> Hi,
RR> In the PTE chaining discussion/patches a while ago, I saw
RR> that kswapd was changed in a way that it scanned memory
RR> in physical order instead of walking the pagetables.

RR> This has the advantage of deallocating memory in physically
RR> adjecant chunks, which will be nice while we still have the
RR> primitive buddy allocator we're using now.

Also it has the advantage that shared pages are only scanned once, and
empty address space needn't be scanned.

RR> However, it will be a major performance bottleneck when we
RR> get around to implementing the zone allocator and swapin
RR> readahead. This is because we don't need physical deallocation
RR> with the zone allocatore and because swapin readahead is just
RR> an awful lot faster when the pages are contiguous in swap.

Just what is your zone allocator?  I have a few ideas based on the
name but my ideas don't seem to jive with your descriptions.
This part about not needing physically contigous memory is really
puzzling.

RR> I write this to let the PTE people (Stephen and Ben) know
RR> that they probably shouldn't remove the pagetable walking
RR> routines from kswapd...

If we get around to using a true LRU algorithm we aren't too likely
too to swap out address space adjacent pages...  Though I can see the
advantage for pages of the same age.

Also for swapin readahead the only effective strategy I know is to
implement a kernel system call, that says I'm going to be accessing
this chunck of my address space soon.  The clustering people have
already implemented a system call of this nature for their own use.
It would probably be a good idea to do something similiar...

Eric
