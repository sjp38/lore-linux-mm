Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA15849
	for <linux-mm@kvack.org>; Wed, 27 May 1998 11:32:02 -0400
Subject: Re: Q: Swap Locking Reinstatement
References: <m1somf2arx.fsf@flinx.npwt.net>
	<199805192246.XAA03125@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 27 May 1998 10:15:19 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Tue, 19 May 1998 23:46:01 +0100
Message-ID: <m13edv21a0.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

ST> Hi,
ST> On 12 May 1998 20:57:05 -0500, ebiederm+eric@npwt.net (Eric
ST> W. Biederman) said:

>> Recently the swap lockmap has been readded.

>> Was that just as a low cost sanity check, to use especially while
>> there were bugs in some of the low level disk drivers?

>> Was there something that really needs the swap lockmap?

ST> Yes, there was a bug.  The problem occurs when:

ST> 	page X is owned by process A
ST> 	process B tries to swap out page X from A's address space
ST> 	process A exits or execs
ST> 	process B's swap IO completes.

ST> The IO completion is an interrupt (we perform async swaps where
ST> possible).  Now, if we dereference the swap entry belonging to page X
ST> at IO completion time, then the entry is protected against reuse while
ST> the IO is in flight.  However, that requires making the entire swap map
ST> interrupt safe.  It is much more efficient to keep the lock map separate
ST> and to use atomic bitops on it to allow us to do the IO completion
ST> unlock in an interrupt-safe manner.

ST> A similar race occurs when

ST> 	process B tries to swap out page X from A's address space
ST> 	process A tries to swap it back in
ST> 	process B's swap IO completes.

ST> Now process A may, or may not, get the right data from disk depending on
ST> the (undefined) ordering of the IOs submitted by A and B.

Here is how I'm going to code it.

I'm going to modify swap_out to never remove a page from the page
cache until I/O is complete on it.  This should only affect
asynchrounous pages.

I'm going to modify shrink_mmap and friends so that when they remove
a swapper page from the page cache they will decrement the swap use
count, of the page. (Via a new generic inode function).

This should both remove the need for the swap lock map, and increase
performance on the second race condition you mentioned (because it
doesn't have to read the page back in).

Hopefully when we get reverse pte maps working we can remove the swap
use counts as well, and only worry if a swap page is in use.

Eric
