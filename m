From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Use a private inode for backing storage
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710181126.10559.borntraeger@de.ibm.com>
	<m1lk9yen0h.fsf_-_@ebiederm.dsl.xmission.com>
	<200710211428.55611.nickpiggin@yahoo.com.au>
Date: Sat, 20 Oct 2007 23:10:15 -0600
In-Reply-To: <200710211428.55611.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Sun, 21 Oct 2007 14:28:55 +1000")
Message-ID: <m1wsthcatk.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> On Saturday 20 October 2007 08:51, Eric W. Biederman wrote:
>> Currently the ramdisk tries to keep the block device page cache pages
>> from being marked clean and dropped from memory.  That fails for
>> filesystems that use the buffer cache because the buffer cache is not
>> an ordinary buffer cache user and depends on the generic block device
>> address space operations being used.
>>
>> To fix all of those associated problems this patch allocates a private
>> inode to store the ramdisk pages in.
>>
>> The result is slightly more memory used for metadata, an extra copying
>> when reading or writing directly to the block device, and changing the
>> software block size does not loose the contents of the ramdisk.  Most
>> of all this ensures we don't loose data during normal use of the
>> ramdisk.
>>
>> I deliberately avoid the cleanup that is now possible because this
>> patch is intended to be a bug fix.
>
> This just breaks coherency again like the last patch. That's a
> really bad idea especially for stable (even if nothing actually
> was to break, we'd likely never know about it anyway).

Not a chance.  The only way we make it to that inode is through block
device I/O so it lives at exactly the same level in the hierarchy as
a real block device.  My patch is the considered rewrite boiled down
to it's essentials and made a trivial patch.

It fundamentally fixes the problem, and doesn't attempt to reconcile
the incompatible expectations of the ramdisk code and the buffer cache.

> Christian's patch should go upstream and into stable. For 2.6.25-6,
> my rewrite should just replace what's there. Using address spaces
> to hold the ramdisk pages just confuses the issue even if they
> *aren't* actually wired up to the vfs at all. Saving 20 lines is
> not a good reason to use them.

Well is more like saving 100 lines.  Not having to reexamine complicated
infrastructure code and doing things the same way ramfs is.  I think
that combination is a good reason.  Especially since I can do with a
16 line patch as I just demonstrated.  It is a solid and simple
incremental change.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
