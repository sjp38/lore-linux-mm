Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA26836
	for <linux-mm@kvack.org>; Wed, 3 Jun 1998 23:51:56 -0400
Subject: Re: Q: Swap Locking Reinstatement
References: <m1somf2arx.fsf@flinx.npwt.net>
	<199805192246.XAA03125@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 03 Jun 1998 22:20:56 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Tue, 19 May 1998 23:46:01 +0100
Message-ID: <m1bts9vomf.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

Just to add another case to the list.

>> Recently the swap lockmap has been readded.

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

Also ipc/shm.c does no sanity checks about which swap pages are in
flight. So the lock can't be removed until this is fixed as well.

Eric
