From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14328.64984.364562.947945@dukat.scot.redhat.com>
Date: Mon, 4 Oct 1999 20:19:52 +0100 (BST)
Subject: Re: MMIO regions
In-Reply-To: <Pine.LNX.4.10.9910041308080.8295-100000@imperial.edgeglobal.com>
References: <Pine.LNX.3.96.991004115631.500A-100000@kanga.kvack.org>
	<Pine.LNX.4.10.9910041308080.8295-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 4 Oct 1999 13:27:43 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> On Mon, 4 Oct 1999, Benjamin C.R. LaHaise wrote:
>> On Mon, 4 Oct 1999, James Simmons wrote:
>> 
>> > And if the process holding the locks dies then no other process can access
>> > this resource. Also if the program forgets to release the lock you end up
>> > with other process never being able to access this piece of hardware.   
>> 
>> Eh?  That's simply not true -- it's easy enough to handle via a couple of
>> different means: in the release fop or munmap which both get called on
>> termination of a task.  

> Which means only one application can ever have access to the MMIO. If
> another process wanted it then this application would have to tell the
> other appilcation hey I want it so unmap. Then the application demanding
> it would then have to mmap it.  

Look, we've already been over this --- if you have multiple accessors,
you have all the locking problems we talked about before.  The kernel
doesn't do anything automatically for you.  Any locking you want to do
can be done in the driver.

The problem is, what locking do you want to do?  We've talked about this
--- the fact is, if the hardware sucks badly enough that multiple
accessors can crash the bus but you need multiple accessors to access
certain functionality, then what do you want to do about it?  Sorry, you
can't just shrug this off as an O/S implementation problem --- the
hardware in this case doesn't give the software any clean way out.  The
*only* solutions are either slow in the general case, enforcing access
control via expensive VM operations; or they are best-effort, relying on
cooperative locking but allowing good performance.

>> or if you're really paranoid, you can save the pid in an owner field
>> in the lock and periodically check that the process is still there.
 
> How would you use this method?

Look at http://www.precisioninsight.com/dr/locking.html for a
description of the cooperative lightweight locking used in the DRI in
2.3 kernels to solve this problem.  Basically you have a shared memory
segment which processes can mmap allowing them to determine if they
still hold the lock via a simple locked memory operation, and a kernel
syscall which lets processes which don't have the lock arbitrate for
access.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
