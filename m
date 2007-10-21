From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] rd: Use a private inode for backing storage
Date: Sun, 21 Oct 2007 14:28:55 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710181126.10559.borntraeger@de.ibm.com> <m1lk9yen0h.fsf_-_@ebiederm.dsl.xmission.com>
In-Reply-To: <m1lk9yen0h.fsf_-_@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200710211428.55611.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Saturday 20 October 2007 08:51, Eric W. Biederman wrote:
> Currently the ramdisk tries to keep the block device page cache pages
> from being marked clean and dropped from memory.  That fails for
> filesystems that use the buffer cache because the buffer cache is not
> an ordinary buffer cache user and depends on the generic block device
> address space operations being used.
>
> To fix all of those associated problems this patch allocates a private
> inode to store the ramdisk pages in.
>
> The result is slightly more memory used for metadata, an extra copying
> when reading or writing directly to the block device, and changing the
> software block size does not loose the contents of the ramdisk.  Most
> of all this ensures we don't loose data during normal use of the
> ramdisk.
>
> I deliberately avoid the cleanup that is now possible because this
> patch is intended to be a bug fix.

This just breaks coherency again like the last patch. That's a
really bad idea especially for stable (even if nothing actually
was to break, we'd likely never know about it anyway).

Christian's patch should go upstream and into stable. For 2.6.25-6,
my rewrite should just replace what's there. Using address spaces
to hold the ramdisk pages just confuses the issue even if they
*aren't* actually wired up to the vfs at all. Saving 20 lines is
not a good reason to use them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
