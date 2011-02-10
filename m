Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A7AC78D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 18:07:37 -0500 (EST)
Date: Thu, 10 Feb 2011 15:07:26 -0800
From: Joel Becker <jlbec@evilplan.org>
Subject: Re: [LSF/MM TOPIC] Utilizing T10/DIF in Filesystems
Message-ID: <20110210230725.GA18007@noexit>
References: <20110209200035.GG27190@tux1.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110209200035.GG27190@tux1.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <djwong@us.ibm.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, martin.petersen@oracle.com

On Wed, Feb 09, 2011 at 12:00:35PM -0800, Darrick J. Wong wrote:
> I would like to talk about the status and future direction of T10/DIF support
> in the kernel.  Here's something resembling an abstract:
> 
> Utilizing T10/DIF in Filesystems
> 
> For quite some time, we've been discussing the inclusion of T10/DIF
> functionality into the kernel to associate a small amount of checksum/integrity
> data with each sector.  Now that actual hardware is appearing on the market, it
> is time to take another look at what we can do with this feature.

	I like it.

> 2. How do we expose a API that enables userspace to read and write  application
>    tags that go with a file's data blocks?

	Martin and I have been working on an interface for this.  I was
going to propose it for LSF, but since I haven't had time to put
together code, I figured it could wait.  However, it might be worth
discussing under this umbrella, as it can easily fit the DIF/DIX stuff.

Joel

--------------------------

sys_dio_*() - A direct interface to batched direct I/O.

Joel Becker
Martin Petersen


[Introduction]

Direct I/O has a problem: it's coupled to the buffered I/O API.  It's an
advisory layer atop POSIX semantics.  The POSIX calls are fine for what
they are, but they interact with direct I/O in ways that are not
predictable.  In addition, asynchronous operations require a specialized
interface that frees some restrictions while imposing others.

Finally, the classic interfaces do not allow for expansion.  This
affects us directly when trying to pass Integrity information from an
application through to the hardware.  Currently there is no generic
facility to do so; Integrity can be attached after the payload has
entered the kernel, but not before.

We propose a new set of system calls, sys_dio_*(), that isolate direct
I/O in a new, batched API.  sys_dio_*() leverages various things we've
learned with block I/O.  It can batch up synchronous and asynchronous
operations, share file handles, and attach Integrity information to
operations.

The initial implementation works directly on block devices, bypassing
the pagecache completely.  This allows the most efficient operation for
block devices.  It does not preclude adding file operations later.


[The I/O Interface]

The I/O interface for sys_dio_*() is simple.  There are only three
actual I/O calls, sys_dio_submit(), sys_dio_wait(), and
sys_dio_collect().  They all work on a batch of requests.

All I/Os must be submitted at some point, so there is but one submission
interface, sys_dio_submit().  Any number of dios can be sent in one
batch.  These submissions are asynchronous and will be queued for
processing (or even perhaps complete) when sys_dio_submit() returns.

The sys_dio_wait() and sys_dio_collect() APIs handle synchronous and
asynchronous completion respectively.  If a process wishes to block for
one or more submitted I/Os, it passes a list to sys_dio_wait().  It will
not return until all I/Os in the list have completed.  Conversely,
sys_dio_collect() takes an empty array of request pointers.  It blocks
until some min_nr have been filled in by completed requests.


[Handles]

In today's world of thousands of disks, it is a significant penalty for
every process sharing disks to hold their own open descriptors.  It
takes up a lot of kernel memory.  sys_dio_*() contains an interface to
share handles among processes.

More specifically, sys_dio_open() converts a block device fd into a
sys_dio handle.  This handle is what gets passed to sys_dio_submit().
Thus, one process can open a block device and any coordinating
processes can use the handle however they wish to communicate it: shm,
tcp, $dontcare.  Unlike fd passing, it does not bloat each process's
task structures.

If more than one process in a context opens the same block device, they
will get the same handle.  The handle is just reference counted.  More
on contexts below.  In addition, the block device is claimed with
bd_claim(), giving the users of the context sole access to their device
(XXX should this be a flag to sys_dio_open()?).

The original fd can be closed as soon as sys_dio_open() has a reference.
The handle is released with sys_dio_close().  These handles are
automatically released when the opening process exits.  Note that the
lifetime of the handle is tied to the processes on the context that have
actually opened it.  If the opening process exits, other processes will
get errors from future submissions.


[Contexts]

We don't want all processes in the system sharing everything.  Instead,
sys_dio_*() defines a context.  All processes requesting the same
context will share handles.

But wait, there's more!  A context is requested via a unsigned int key,
but the actual context returned is a file descriptor.  This file
descriptor can be polled for completions.  This way sys_dio operations
can be added to the poll loop.

	if (pollfd.fd == context_fd)
		sys_dio_collect(context_fd, collect_list, sizeof(collect_list)); 


[The API]

/*
 * XXX Should we have flags?  What about O_CREAT|O_EXCL semantics on
 * key->context?
 */
int sys_dio_init(unsigned int key, unsigned int flags);
int sys_dio_exit(int context);

/*
 * XXX I'm providing int as the handle type because of my idea to have a
 * fd_table hanging off of the context.  But perhaps the handles should
 * be unsigned long or __u64 for future proofing?
 */
int sys_dio_open(int context, int fd, int flags);
int sys_dio_close(int context, int handle);

/*
 * All of these calls have read(2) semantics.  They return the number of
 * I/Os submitted/waited on/collected.  If they return less then
 * submitted, it means error (or possibly no more outstanding for
 * sys_dio_collect()).
 *
 * XXX struct dio_request *requests or **requests?  The former is easy
 * to set up but a pain to use later.  The latter is a pain to set up
 * for submission but much nicer later.  I'm thinking most users would
 * have the requests independent in memory, so I chose **requests.
 */
int sys_dio_submit(int context, struct dio_request **requests, int nr_requests);
int sys_dio_wait(int context, struct dio_request **waits, int nr_waits);
int sys_dio_collect(int context, struct dio_request **collects, int nr_collects);
-- 

"You look in her eyes, the music begins to play.
 Hopeless romantics, here we go again."

			http://www.jlbec.org/
			jlbec@evilplan.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
