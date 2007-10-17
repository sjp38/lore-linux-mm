Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <m1ve95ctuc.fsf@ebiederm.dsl.xmission.com>
References: <200710151028.34407.borntraeger@de.ibm.com>
	 <m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com>
	 <200710160956.58061.borntraeger@de.ibm.com>
	 <200710171814.01717.borntraeger@de.ibm.com>
	 <m1sl49ei8x.fsf@ebiederm.dsl.xmission.com>
	 <1192648456.15717.7.camel@think.oraclecorp.com>
	 <m17illeb8f.fsf@ebiederm.dsl.xmission.com>
	 <1192654481.15717.16.camel@think.oraclecorp.com>
	 <m1ve95ctuc.fsf@ebiederm.dsl.xmission.com>
Content-Type: text/plain
Date: Wed, 17 Oct 2007 18:58:09 -0400
Message-Id: <1192661889.15717.27.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-17 at 15:30 -0600, Eric W. Biederman wrote:
> Chris Mason <chris.mason@oracle.com> writes:
> 
> >> Thinking about it.  I don't believe anyone has ever intentionally built
> >> a filesystem tool that depends on being able to modify a file systems
> >> metadata buffer heads while the filesystem is running, and doing that
> >> would seem to be fragile as it would require a lot of cooperation
> >> between the tool and the filesystem about how the filesystem uses and
> >> implement things.
> >> 
> >
> > That's right.  For example, ext2 is doing directories in the page cache
> > of the directory inode, so there's a cache alias between the block
> > device page cache and the directory inode page cache.
> >
> >> Now I guess I need to see how difficult a patch would be to give
> >> filesystems magic inodes to keep their metadata buffer heads in.
> >
> > Not hard, the block device inode is already a magic inode for metadata
> > buffer heads.  You could just make another one attached to the bdev.
> >
> > But, I don't think I fully understand the problem you're trying to
> > solve?
> 
> 
> So the start:
> When we write buffers from the buffer cache we clear buffer_dirty
> but not PageDirty
>
> So try_to_free_buffers() will mark any page with clean buffer_heads
> that is not clean itself clean.
> 
> The ramdisk set pages dirty to keep them from being removed from the
> page cache, just like ramfs.
> 
So, the problem is using the Dirty bit to indicate pinned.  You're
completely right that our current setup of buffer heads and pages and
filesystem metadata is complex and difficult.

But, moving the buffer heads off of the page cache pages isn't going to
make it any easier to use dirty as pinned, especially in the face of
buffer_head users for file data pages.

You've already seen Nick fsblock code, but you can see my general
approach to replacing buffer heads here:

http://oss.oracle.com/mercurial/mason/btrfs-unstable/file/f89e7971692f/extent_map.h

(alpha quality implementation in extent_map.c and users in inode.c)  The
basic idea is to do extent based record keeping for mapping and state of
things in the filesystem, and to avoid attaching these things to the
page.

> Unfortunately when those dirty ramdisk pages get buffers on them and
> those buffers all go clean and we are trying to reclaim buffer_heads
> we drop those pages from the page cache.   Ouch!
> 
> We can fix the ramdisk by setting making certain that buffer_heads
> on ramdisk pages stay dirty as well.  The problem is this breaks
> filesystems like reiserfs and ext3 that expect to be able to make 
> buffer_heads clean sometimes.
> 
> There are other ways to solve this for ramdisks, such as changing
> where ramdisks are stored.  However fixing the ramdisks this way
> still leaves the general problem that there are other paths to the
> filesystem metadata buffers, and those other paths cause the code
> to be complicated and buggy.
> 
> So I'm trying to see if we can untangle this Gordian knot, so the
> code because more easily maintainable.  
> 

Don't get me wrong, I'd love to see a simple and coherent fix for what
reiserfs and ext3 do with buffer head state, but I think for the short
term you're best off pinning the ramdisk pages via some other means.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
