Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA17027
	for <linux-mm@kvack.org>; Mon, 29 Jun 1998 16:07:45 -0400
Subject: Re: (reiserfs) Re: More on Re: (reiserfs) Reiserfs and ext2fs (was Re: (reiserfs) Sum Benchmarks (these look typical?))
References: <Pine.HPP.3.96.980617035608.29950A-100000@ixion.honeywell.com>
	<199806221138.MAA00852@dax.dcs.ed.ac.uk>
	<358F4FBE.821B333C@ricochet.net> <m11zsgrvnf.fsf@flinx.npwt.net>
	<199806241154.MAA03544@dax.dcs.ed.ac.uk>
	<m11zse6ecw.fsf@flinx.npwt.net>
	<199806251100.MAA00835@dax.dcs.ed.ac.uk>
	<m1emwcf97d.fsf@flinx.npwt.net>
	<199806291035.LAA00733@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 29 Jun 1998 14:59:37 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Mon, 29 Jun 1998 11:35:15 +0100
Message-ID: <m1u354dlna.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Hans Reiser <reiser@ricochet.net>, Shawn Leas <sleas@ixion.honeywell.com>, Reiserfs <reiserfs@devlinux.com>, Ken Tetrick <ktetrick@ixion.honeywell.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

ST> Hi,
ST> In article <m1emwcf97d.fsf@flinx.npwt.net>, ebiederm+eric@npwt.net (Eric
ST> W. Biederman) writes:

>> Unless I have missed something write-back from the page cache is
>> important, because then when you delete a file you haven't written yet
>> you can completely avoid I/O.   For short lived files this should be a
>> performance win.

ST> We already do bforget() to deal with this in the buffer cache.  Having
ST> the outstanding IO labelled in the buffer cache will not result in
ST> redundant writes in this case.

That's good to know. It doesn't suprise me but I hadn't been through the
code enough to see that one.  I knew about bforget I just hadn't seen
it used.

>>>> This functionality is essentially what is implemented with brw_page,
>>>> and I have written the generic_page_write that does essentially
>>>> this.  There is no data copying however.  The fun angle is mapped
>>>> pages need to be unmapped (or at least read only mapped) for a write
>>>> to be successful.

ST> Indeed; however, it might be a reasonable compromise to do a copy out
ST> from the page cache to the buffer cache in this situation (we already
ST> have a copy in there, so this would not hurt performance relative to
ST> the current system).  

>> Agreed.  But it takes more work to write.

ST> On reflection, it's not an issue.  Mapped pages do not have to be
ST> unmapped at all.  We can continue to share between cache and buffers as
ST> long as we want.  Later modifications to the data in the cache page will
ST> update the buffer contents, true, but that's irrelevant as we will still
ST> be writing valid file contents to disk when the IO arrives.  Those
ST> semantics are just fine.

There are two problems I see.  

1) A DMA controller actively access the same memory the CPU is
accessing could be a problem.  Recall video flicker on old video
cards.

2) More importantly the cpu writes to the _cache_, and the DMA
controller reads from the RAM.  I don't see any consistency garnatees
there.  We may be able solve these problems on a per architecture or
device basis however. 

Eric
