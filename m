Date: Sun, 18 May 2008 04:26:18 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [xfs-masters] lockdep report (2.6.26-rc2)
Message-ID: <20080518082618.GA27923@infradead.org>
References: <1210858590.3900.1.camel@johannes.berg> <20080515220757.GS155679365@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080515220757.GS155679365@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: xfs-masters@oss.sgi.com, xfs <xfs@oss.sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 16, 2008 at 08:07:57AM +1000, David Chinner wrote:
> Fundamentally  - if a filesystem takes the same lock in
> ->file_aio_read as it does in ->release, then this will happen.
> The lock outside the filesystem (the mmap lock) is can be taken
> before we enter the filesystem or while we are inside a filesystem
> method reading or writing data.
> 
> In this case, XFS uses the iolock to serialise I/O vs truncate.
> We hold the iolock shared over read I/O, and exclusive when we
> do a truncate. The truncate in this case is a truncate of blocks
> past EOF on ->release. 
> 
> Whether this can deadlock depends on whether these two things can
> happen on the same mmap->sem and same inode at the same time.
> I know they can happen onteh same inode at the same time, but
> can this happen on the same mmap->sem? VM gurus?

I think it can.  Think of a process with two threads, and two open file
instances of the same inode.

thread 1:
	in read() fauling in from the inode via file 1

thread 2:
	at the same time dropping the last reference to a file via
	munmap.

Getting this right would mean not doing any fputs from under the
mmap_seem in munmap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
