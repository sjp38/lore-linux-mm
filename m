Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA01346
	for <linux-mm@kvack.org>; Fri, 26 Jun 1998 13:32:06 -0400
Subject: Re: (reiserfs) Re: More on Re: (reiserfs) Reiserfs and ext2fs (was Re: (reiserfs) Sum Benchmarks (these look typical?))
References: <Pine.HPP.3.96.980617035608.29950A-100000@ixion.honeywell.com>
	<199806221138.MAA00852@dax.dcs.ed.ac.uk>
	<358F4FBE.821B333C@ricochet.net> <m11zsgrvnf.fsf@flinx.npwt.net>
	<199806241154.MAA03544@dax.dcs.ed.ac.uk>
	<m11zse6ecw.fsf@flinx.npwt.net>
	<199806251100.MAA00835@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 26 Jun 1998 10:56:22 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Thu, 25 Jun 1998 12:00:56 +0100
Message-ID: <m1emwcf97d.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Hans Reiser <reiser@ricochet.net>, Shawn Leas <sleas@ixion.honeywell.com>, Reiserfs <reiserfs@devlinux.com>, Ken Tetrick <ktetrick@ixion.honeywell.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

ST> Hi,
ST> [CC:ed to linux-mm, who also have a great deal of interest in this
ST> stuff.]

ST> On 24 Jun 1998 09:53:03 -0500, ebiederm+eric@npwt.net (Eric
ST> W. Biederman) said:

ST> However, there's a lot of overlap, so I'd like to look at what we can do
ST> with this for 2.3.  In particular, I'd like 2.3's standard file writing
ST> mechanism to work essentially as write-through from the page cache,

>> The current system is write-through.  I hope you mean write back.

ST> The current system is write-through from the buffer cache.  The data
ST> is copied into the page cache only if there is already a page mapping
ST> that data.  That is really ugly, using the buffer cache both as an IO
ST> buffer and as a data cache.  THAT is what we need to fix.

You're right.  But if you implement the appropriate routines so you
can use generic_file_write we do a proper write through the page
cache now.

ST> The ideal solution IMHO would be something which does write-through
ST> from the page cache to the buffer cache and write-back from the buffer
ST> cache to disk; in other words, when you write to a page, buffers are
ST> generated to map that dirty data (without copying) there and then.
ST> The IO is then left to the buffer cache, as currently happens, but the
ST> buffer is deleted after IO (just like other temporary buffer_heads
ST> behave right now).  That leaves the IO buffering to the buffer cache
ST> and the caching to the page cache, which is the distinction that the
ST> the current scheme approaches but does not quite achieve.

Unless I have missed something write-back from the page cache is
important, because then when you delete a file you haven't written yet
you can completely avoid I/O.   For short lived files this should be a
performance win.

Coping the few pages that are actively engaged in being written into
the buffer cache may not be a bad idea, as it removes the lock from
the page cache page much sooner, and frees if for use again.

>> This functionality is essentially what is implemented with brw_page,
>> and I have written the generic_page_write that does essentially
>> this.  There is no data copying however.  The fun angle is mapped
>> pages need to be unmapped (or at least read only mapped) for a write
>> to be successful.

ST> Indeed; however, it might be a reasonable compromise to do a copy out
ST> from the page cache to the buffer cache in this situation (we already
ST> have a copy in there, so this would not hurt performance relative to
ST> the current system).  

Agreed.  But it takes more work to write.

ST> Doing COW at the page cache level is something we can implement later;
ST> there are other reasons for it to be desirable anyway.  For example,
ST> it lets you convert all read(2) and write(2) requests on whole pages
ST> into mmap()s, transparently, giving automatic zero-copy IO to user
ST> space.

Sounds neat but I wasn't advocating it, in this context.

>> I should have a working patch this weekend (the code compiles now, I
>> just need to make sure it works) and we can discuss it more when that
>> has been released.

ST> Excellent.  I look forward to seeing it.

I need to clean the patch up a bit (I built it on top of a patched
kernel, but I have it working right now!).   I have successfully
performaned two simultaneous kernel compiles which is a pretty good
test for races ;).

Hopefully I'll have a little time this weekend, to make a good patch,
otherwise I'll just release my mess.

Eric
