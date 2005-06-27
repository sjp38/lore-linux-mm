Subject: Re: VFS scalability (was: [rfc] lockless pagecache)
References: <42BF9CD1.2030102@yahoo.com.au> <42BFA014.9090604@yahoo.com.au>
From: Andi Kleen <ak@suse.de>
Date: 27 Jun 2005 09:13:27 +0200
In-Reply-To: <42BFA014.9090604@yahoo.com.au>
Message-ID: <p733br4w9uw.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> This is with the filesystem mounted as noatime, so I can't work
> out why update_atime is so high on the list. I suspect maybe a
> false sharing issue with some other fields.

Did all the 64CPUs write to the same file?

Then update_atime was just the messenger - it is the first function
to read the inode so it eats the cache miss overhead.

Maybe adding a prefetch for it at the beginning of sys_read() 
might help, but then with 64CPUs writing to parts of the inode
it will always thrash no matter how many prefetches.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
