Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <m17illeb8f.fsf@ebiederm.dsl.xmission.com>
References: <200710151028.34407.borntraeger@de.ibm.com>
	 <m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com>
	 <200710160956.58061.borntraeger@de.ibm.com>
	 <200710171814.01717.borntraeger@de.ibm.com>
	 <m1sl49ei8x.fsf@ebiederm.dsl.xmission.com>
	 <1192648456.15717.7.camel@think.oraclecorp.com>
	 <m17illeb8f.fsf@ebiederm.dsl.xmission.com>
Content-Type: text/plain
Date: Wed, 17 Oct 2007 16:54:41 -0400
Message-Id: <1192654481.15717.16.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-17 at 14:29 -0600, Eric W. Biederman wrote:
> Chris Mason <chris.mason@oracle.com> writes:
> 
> > In this case, the commit block isn't allowed to be dirty before reiserfs
> > decides it is safe to write it.  The journal code expects it is the only
> > spot in the kernel setting buffer heads dirty, and it only does so after
> > the rest of the log blocks are safely on disk.
> 
> Ok.  So the journal code here fundamentally depends on being able to
> control the order of the writes, and something else being able to set
> the buffer head dirty messes up that control.
> 

Right.

> >> At the same time I increasingly don't think we should allow user space
> >> to dirty or update our filesystem metadata buffer heads.  That seems
> >> like asking for trouble.
> >> 
> >
> > Demanding trouble ;)
> 
> Looks like it.  There are even comments in jbd about the same class
> of problems.  Apparently dump and tune2fs on mounted filesystems have
> triggered some of these issues.  The practical question is any of this
> trouble worth handling.
> 
> Thinking about it.  I don't believe anyone has ever intentionally built
> a filesystem tool that depends on being able to modify a file systems
> metadata buffer heads while the filesystem is running, and doing that
> would seem to be fragile as it would require a lot of cooperation
> between the tool and the filesystem about how the filesystem uses and
> implement things.
> 

That's right.  For example, ext2 is doing directories in the page cache
of the directory inode, so there's a cache alias between the block
device page cache and the directory inode page cache.

> Now I guess I need to see how difficult a patch would be to give
> filesystems magic inodes to keep their metadata buffer heads in.

Not hard, the block device inode is already a magic inode for metadata
buffer heads.  You could just make another one attached to the bdev.

But, I don't think I fully understand the problem you're trying to
solve?

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
