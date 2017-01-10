Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB1A6B0261
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 11:02:29 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id d201so118573960qkg.2
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 08:02:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q1si1617849qtq.167.2017.01.10.08.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 08:02:28 -0800 (PST)
Date: Tue, 10 Jan 2017 17:02:24 +0100
From: Kevin Wolf <kwolf@redhat.com>
Subject: [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170110160224.GC6179@noname.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>

Hi all,

when I mentioned the I/O error handling problem especially with fsync()
we have in QEMU to Christoph Hellwig, he thought it would be great topic
for LSF/MM, so here I am. This came up a few months ago on qemu-devel [1]
and we managed to ignore it for a while, but it's a real and potentially
serious problem, so I think I agree with Christoph that it makes sense
to get it discussed at LSF/MM.


At the heart of it is the semantics of fsync(). A few years ago, fsync()
was fixed to actually flush data to the disk, so we now have a defined
and useful meaning of fsync() as long as all your fsync() calls return
success.

However, as soon as one fsync() call fails, even if the root problem is
solved later (network connection restored, some space freed for thin
provisioned storage, etc.), the state we're in is mostly undefined. As
Ric Wheeler told me back in the qemu-devel discussion, when a writeout
fails, you get an fsync() error returned (once), but the kernel page
cache simply marks the respective page as clean and consequently won't
ever retry the writeout. Instead, it can evict it from the cache even
though it isn't actually consistent with the state on disk, which means
throwing away data that was written by some process.

So if you do another fsync() and it returns success, this doesn't
currently mean that all of the data you wrote is on disk, but if
anything, it's just about the data you wrote after the failed fsync().
This isn't very helpful, to say the least, because you called fsync() in
order to get a consistent state on disk, and you still don't have that.

Essentially this means that once you got a fsync() failure, there is no
hope to recover for the application and it has to stop using the file.


To give some context about my perspective as the maintainer for the QEMU
block subsystem: QEMU has a mode (which is usually enabled in
production) where I/O failure isn't communicated to the guest, which
would probably offline the filesystem, thinking its hard disk has died,
but instead QEMU pauses the VM and allows the administrator to resume
when the problem has been fixed. Often the problem is only temporary,
e.g. a network hiccup when a disk image is stored on NFS, so this is a
quite helpful approach.

When QEMU is told to resume the VM, the request is just resubmitted.
This works fine for read/write, but not so much for fsync, because after
the first failure all bets are off even if a subsequent fsync()
succeeds.

So this is the aspect that directly affects me, even though the problem
is much broader and by far doesn't only affect QEMU.


This leads to a few invidivual points to be discussed:

1. Fix the data corruption problem that follows from the current
   behaviour. Imagine the following scenario:

   Process A writes to some file, calls fsync() and gets a failure. The
   data it wrote is marked clean in the page cache even though it's
   inconsistent with the disk. Process A knows that fsync() fails, so
   maybe it can deal with it, at least by stop using the file.

   Now process B opens the same file, reads the updated data that
   process A wrote, makes some additional changes based on that and
   calls fsync() again.  Now fsync() return success. The data written by
   B is on disk, but the data written by A isn't. Oops, this is data
   corruption, and process B doesn't even know about it because all its
   operations succeeded.

2. Define fsync() semantics that include the state after a failure (this
   probably goes a long way towards fixing 1.).

   The semantics that QEMU uses internally (and which it needs to map)
   is that after a successful flush, all writes to the disk image that
   have successfully completed before the flush was issued are stable on
   disk (no matter whether a previous flush failed).

   A possible adaption to Linux, which considers that unlike QEMU
   images, files can be opened more than once, might be that a
   succeeding fsync() on a file descriptor means that all data that has
   been read or written through this file descriptor is consistent
   between the page cache and the disk (the read part is for avoiding
   the scenario from 1.; it means that fsync flushes data written on a
   different file descriptor if it has been seen by this one; hence, the
   page cache can't contain non-dirty pages which aren't consistent with
   the disk).

3. Actually make fsync() failure recoverable.

   You can implement 2. by making sure that a file descriptor for which
   pages have been thrown away always returns an error and never goes
   back to suceeding (it can't succeed according to the definition of 2.
   because the data that would have to be written out is gone). This is
   already a much better interface, but it doesn't really solve the
   actual problem we have.

   We also need to make sure that after a failed fsync() there is a
   chance to recover. This means that the pages shouldn't be thrown away
   immediately; but at the same time, you probably also don't want to
   keep pages indefinitely when there is a permanent writeout error.
   However, if we can make sure that these pages are only evicted in
   case of actual memory pressure, and only if there are no actually
   clean page to evict, I think a lot would be already won.

   In the common case, you could then recover from a temporary failure,
   but if this state isn't maintainable, at least we get consistent
   fsync() failure telling us that the data is gone.


I think I've summarised most aspects here, but if something is unclear
or you'd like to see some more context, please refer to the qemu-devel
discussion [1] that I mentioned, or feel free to just ask.

Thanks,
Kevin

[1] https://lists.gnu.org/archive/html/qemu-block/2016-04/msg00576.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
