Date: Thu, 18 May 2000 15:29:03 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: [PATCHES] New kiobuf diffs for 2.3.99-pre9-2
Message-ID: <20000518152903.F5672@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu
Cc: Stephen Tweedie <sct@redhat.com>, "David S . Miller" <davem@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Prasanna Narayana <prasanna@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I've batched the current kiobuf code up at

  ftp://ftp.uk.linux.org/pub/linux/sct/fs/raw-io/kiobuf.2.3.99.pre9-2.tar.gz

There are a couple of new things in here since the last version.  In
particular, it includes Kanoj Sarcar's fork fixes and Dave Miller's
pipe speedup code, as well as a few minor bug fixes and fixes to error
return codes.

I'll wait for feedback and then file those bits which are clearly 
bugfixes on to Linus.  The more significant changes will probably 
be post-2.4 items.

>From the README:

This tarball contains the following patches, to be applied in order:

 01-mapfix.diff

	map_user_kiobuf() retries failed maps to cover a race in which
	the swapper steals a page before the kiobuf has grabbed and 
	locked it.

 02-iocount.diff

	Kanoj Sarcar's fixes to allow kiobufs to work properly over
	fork(), even on threaded applications.

 03-davem-pipe.diff

	Dave Miller's rocking pipe code using kiobufs for a 2*
	throughput improvement on simple streaming pipe I/O.

 04-eiofix.diff

	Fix to return -EIO instead of 0 if a raw I/O read or write
	encounters an error in the first block.

 05-kvmap.diff

	New code to allow:

	1) map_kernel_kiobuf: 	the analogue of map_user_kiobuf,
	   except that it works on kernel virtual addresses instead.
 	   Even vmalloc()ed regions work.

	2) Add a "flags" argument to map_*_kiobuf.  The only flag
	   honoured is

	   MAP_PRIVATE: any mappings of the kiobuf will be kept
			process-local over forks.  Without this,
			the pages will remain shared over fork 
			(which will cause real problems if you 
			map the pages into a MAP_PRIVATE vma in
			user space).

	   MAP_PRIVATE is used by the raw character device.

	3) Add kvmap infrastructure to allow mmap() of any kiobuf.
	   Includes a sample driver in Documentation/kiobuf.sample.c
	   to show how it can work.

 06-enxio.diff

	Return ENXIO on read/write at or beyond the end of the device
	for raw I/O

--Stephen Tweedie <sct@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
