Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id D03386B0288
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 11:00:20 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id x185so8170503ybe.3
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 08:00:20 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id d11si4023362ywh.235.2018.01.01.08.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Jan 2018 08:00:19 -0800 (PST)
Date: Mon, 1 Jan 2018 11:00:11 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Message-ID: <20180101160011.GA27417@thunk.org>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171229014736.GA10341@X58A-UD3R>
 <20171229035146.GA11757@thunk.org>
 <20171229072851.GA12235@X58A-UD3R>
 <20171230061624.GA27959@bombadil.infradead.org>
 <20171230154041.GB3366@thunk.org>
 <20171230204417.GF27959@bombadil.infradead.org>
 <20171230224028.GC3366@thunk.org>
 <20171230230057.GB12995@thunk.org>
 <20180101101855.GA23567@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180101101855.GA23567@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com, kernel-team@lge.com, daniel@ffwll.ch

On Mon, Jan 01, 2018 at 02:18:55AM -0800, Matthew Wilcox wrote:
> > Clarification: all TCP connections that are used by kernel code would
> > need to be in their own separate lock class.  All TCP connections used
> > only by userspace could be in their own shared lock class.  You can't
> > use a one lock class for all kernel-used TCP connections, because of
> > the Network Block Device mounted on a local file system which is then
> > exported via NFS and squirted out yet another TCP connection problem.
> 
> So the false positive you're concerned about is write-comes-in-over-NFS
> (with socket lock held), NFS sends a write request to local filesystem,
> local filesystem sends write to block device, block device sends a
> packet to a socket which takes that socket lock.

It's not just the socket lock, but any of the locks/mutexes/"waiters"
that might be taken in the TCP code path and below, including in the
NIC driver.

> I don't think we need to be as drastic as giving each socket its own lock
> class to solve this.  All NFS sockets can be in lock class A; all NBD
> sockets can be in lock class B; all user sockets can be in lock class
> C; etc.

But how do you know which of the locks taken in the networking stack
are for the NBD versus the NFS sockets?  What manner of horrific
abstraction violation is going to pass that information all the way
down to all of the locks that might be taken at the socket layer and
below?

How is this "proper clasification" supposed to happen?  It's the
repeated handwaving which claims this is easy which is rather
frustrating.  The simple thing is to use a unique ID which is bumped
for each struct sock, each struct super, struct block_device, struct
request_queue, struct bdi, etc, but that runs into lockdep scalability
issues.

Anything else means that you have to somehow pass down through the
layers so that, in the general case, the socket knows that it is "an
NFS socket" versus "an NBD socket" --- and remember, if there is any
kind of completion handling done in the NIC driver, it's going to have
to passed down well below the TCP layer all the way down to the
network device drivers.  Or is the plan to do this add a bit ad hoc of
plumbing for each false positive which cross-release lockdep failures
are reported?

> > Also, what to do with TCP connections which are created in userspace
> > (with some authentication exchanges happening in userspace), and then
> > passed into kernel space for use in kernel space, is an interesting
> > question.
> 
> Yes!  I'd love to have a lockdep expert weigh in here.  I believe it's
> legitimate to change a lock's class after it's been used, essentially
> destroying it and reinitialising it.  If not, it should be because it's
> a reasonable design for an object to need different lock classes for
> different phases of its existance.

We just also need to be destroy a lock class after the transient
object has been deleted.  This is especially true for file system
testing, since we are constantly mounting and unmounting file systems,
and creating and destroying loop devices, potentially hundreds or
thousands of times during a test run.  So if we have to create a
unique lock class for "proper classification" each time a file system
is mounted, or loop device or device-mapper device (dm-error, etc.) is
created, we'll run into lockdep scalability issues really quickly.

So this is yet another example where the handwaving, "all you have to
do is proper classification" just doesn't work.

> > So "all you have to do is classify the locks 'properly'" is much like
> > the apocrophal, "all you have to do is bell the cat"[1].  Or like the
> > saying, "colonizing the stars is *easy*; all you have to do is figure
> > out faster than light travel."
> 
> This is only computer programming, not rocket surgery :-)

Given the current state of the lockdep technology, merging cross-lock
certainly feels like requiring the use of sledgehammers to do rocket
surgery in order to avoid false positives --- sorry, "proper
classification".

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
