Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA25288
	for <linux-mm@kvack.org>; Tue, 30 Jun 1998 22:31:53 -0400
Subject: Re: (reiserfs) Re: More on Re: (reiserfs) Reiserfs and ext2fs (was Re: (reiserfs) Sum Benchmarks (these look typical?))
References: <Pine.HPP.3.96.980617035608.29950A-100000@ixion.honeywell.com>
	<199806221138.MAA00852@dax.dcs.ed.ac.uk>
	<358F4FBE.821B333C@ricochet.net> <m11zsgrvnf.fsf@flinx.npwt.net>
	<199806241154.MAA03544@dax.dcs.ed.ac.uk>
	<m11zse6ecw.fsf@flinx.npwt.net>
	<199806251100.MAA00835@dax.dcs.ed.ac.uk>
	<m1emwcf97d.fsf@flinx.npwt.net>
	<199806291035.LAA00733@dax.dcs.ed.ac.uk>
	<m1u354dlna.fsf@flinx.npwt.net>
	<199806301610.RAA00957@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 30 Jun 1998 19:17:15 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Tue, 30 Jun 1998 17:10:46 +0100
Message-ID: <m1n2au77ck.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Hans Reiser <reiser@ricochet.net>, Shawn Leas <sleas@ixion.honeywell.com>, Reiserfs <reiserfs@devlinux.com>, Ken Tetrick <ktetrick@ixion.honeywell.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

ST> Hi,
ST> On 29 Jun 1998 14:59:37 -0500, ebiederm+eric@npwt.net (Eric
ST> W. Biederman) said:

>> There are two problems I see.  

>> 1) A DMA controller actively access the same memory the CPU is
>> accessing could be a problem.  Recall video flicker on old video
>> cards.

ST> Shouldn't be a problem.

When either I trace through the code, or a hardware guy convinces me,
that it is safe to both write to a page, and do DMA from a page
simultaneously I'll believe it.

>> 2) More importantly the cpu writes to the _cache_, and the DMA
>> controller reads from the RAM.  I don't see any consistency garnatees
>> there.  We may be able solve these problems on a per architecture or
>> device basis however.

ST> Again, not important.  If we ever modify a page which is already being
ST> written out to a device, then we mark that page dirty.  On write, we
ST> mark it clean (but locked) _before_ starting the IO, not after.  So, if
ST> there is ever an overlap of a filesystem/mmap write with an IO to disk,
ST> we will always schedule another IO later to clean the re-dirtied
ST> buffers.

Duh.  I wonder what I was thinking...

Anyhow I've implemented the conservative version.  The only
change needed is to change from unmapping pages to removing the dirty
bit, and the basic code stands. 

The most important change needed would be to tell unuse_page it can't
remove a a locked page from the page cache.  Either that or I need to
worry about incrementing the count for page writes, which wouldn't be
a bad idea either.

Eric
