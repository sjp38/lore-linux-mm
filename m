Date: Tue, 1 May 2001 17:32:10 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [Patch] deadlock on write in tmpfs
Message-ID: <20010501173210.S26638@redhat.com>
References: <m3hez5ci6p.fsf@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m3hez5ci6p.fsf@linux.local>; from cr@sap.com on Tue, May 01, 2001 at 03:39:47PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Stephen Tweedie <sct@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hi,

On Tue, May 01, 2001 at 03:39:47PM +0200, Christoph Rohland wrote:
> 
> tmpfs deadlocks when writing into a file from a mapping of the same
> file. 
> 
> So I see two choices: 
> 
> 1) Do not serialise the whole of shmem_getpage_locked but protect
>    critical pathes with the spinlock and do retries after sleeps
> 2) Add another semaphore to serialize shmem_getpage_locked and
>    shmem_truncate
> 
> I tried some time to get 1) done but the retry logic became way too
> complicated. So the attached patch implements 2)
> 
> I still think it's ugly to add another semaphore, but it works.

If the locking is for a completely different reason, then a different
semaphore is quite appropriate.  In this case you're trying to lock
the shm internal info structures, which is quite different from the
sort of inode locking which the VFS tries to do itself, so the new
semaphore appears quite clean --- and definitely needed.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
