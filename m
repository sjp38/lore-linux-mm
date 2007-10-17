From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch][rfc] rewrite ramdisk
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710170808.30944.nickpiggin@yahoo.com.au>
	<m1ve96fwpa.fsf@ebiederm.dsl.xmission.com>
	<200710171028.23226.nickpiggin@yahoo.com.au>
Date: Tue, 16 Oct 2007 19:13:51 -0600
In-Reply-To: <200710171028.23226.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Wed, 17 Oct 2007 10:28:22 +1000")
Message-ID: <m1ir56fsq8.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> On Wednesday 17 October 2007 09:48, Eric W. Biederman wrote:
>> Nick Piggin <nickpiggin@yahoo.com.au> writes:
>> > On Wednesday 17 October 2007 07:28, Theodore Tso wrote:
>> >> On Tue, Oct 16, 2007 at 05:47:12PM +1000, Nick Piggin wrote:
>> >> > +	/*
>> >> > + * ram device BLKFLSBUF has special semantics, we want to actually
>> >> > +	 * release and destroy the ramdisk data.
>> >> > +	 */
>> >>
>> >> We won't be able to fix completely this for a while time, but the fact
>> >> that BLKFLSBUF has special semantics has always been a major wart.
>> >> Could we perhaps create a new ioctl, say RAMDISKDESTORY, and add a
>> >> deperecation printk for BLKFLSBUF when passed to the ramdisk?  I doubt
>> >> there are many tools that actually take advantage of this wierd aspect
>> >> of ramdisks, so hopefully it's something we could remove in a 18
>> >> months or so...
>> >
>> > It would be nice to be able to do that, I agree. The new ramdisk
>> > code will be able to flush the buffer cache and destroy its data
>> > separately, so it can actually be implemented.
>>
>> So the practical problem are peoples legacy boot setups but those
>> are quickly going away.
>
> After that, is the ramdisk useful for anything aside from testing?
>
>
>> The sane thing is probably something that can be taken as a low
>> level format command for the block device.
>>
>> Say: dd if=/dev/zero of=/dev/ramX
>
> We have 2 problems. First is that, for testing/consistency, we
> don't want BLKFLSBUF to throw out the data. Maybe hardly anything
> uses BLKFLSBUF now, so it could be just a minor problem, but still
> one to fix.

Hmm.  This is interesting because we won't be doing anything that
effects correctness if we don't special case BLKFLSBUF just something
that effects efficiency.  So I think we can get away with just
changing blkflsbuf as long as there is a way to get rid of
the data.

> Second is actually throwing out the ramdisk data. dd from /dev/null
> isn't trivial because it isn't a "command" from the kernel's POV.
> rd could examine the writes to see if they are zero and page aligned,
> I suppose... but if you're transitioning everyone over to a new
> method anyway, might as well make it a nice one ;)

Well I was thinking you can examine the page you just wrote to
and if it is all zero's you don't need to cache that page anymore.
Call it intelligent compression.

Further it does make forwards and backwards compatibility simple
because all you would have to do to reliably free a ramdisk is:

dd if=/dev/zero of=/dev/ramX
blockdev --flushbufs /dev/ramX


>> I know rewriting the drive with all zeroes can cause a modern
>> disk to redo it's low level format.  And that is something
>> we can definitely implement without any backwards compatibility
>> problems.
>>
>> Hmm. Do we have anything special for punching holes in files?
>> That would be another sane route to take to remove the special
>> case for clearing the memory.
>
> truncate_range, I suppose. A file descriptor syscall based
> alternative for madvise would be nice though (like fallocate).
>
> We could always put something in /sys/block/ram*/xxx

I guess when I look at this it looks like an operation that
is unique to a ramdisk.  Real hard drives have a low level
format operations and the like.  If we can find something
standard there that is guaranteed to trash your data we
can use that, and have gone from less consistency to more.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
