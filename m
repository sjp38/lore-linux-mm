Date: Wed, 11 Jun 2008 12:07:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ext2: Use page_mkwrite vma_operations to get mmap write
 notification.
Message-Id: <20080611120749.d0c5a7de.akpm@linux-foundation.org>
In-Reply-To: <20080611150845.GA21910@skywalker>
References: <1212685513-32237-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20080605123045.445e380a.akpm@linux-foundation.org>
	<20080611150845.GA21910@skywalker>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: cmm@us.ibm.com, jack@suse.cz, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 20:38:45 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> On Thu, Jun 05, 2008 at 12:30:45PM -0700, Andrew Morton wrote:
> > On Thu,  5 Jun 2008 22:35:12 +0530
> > "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > 
> > > We would like to get notified when we are doing a write on mmap
> > > section.  The changes are needed to handle ENOSPC when writing to an
> > > mmap section of files with holes.
> > > 
> > 
> > Whoa.  You didn't copy anything like enough mailing lists for a change
> > of this magnitude.  I added some.
> > 
> > This is a large change in behaviour!
> > 
> > a) applications will now get a synchronous SIGBUS when modifying a
> >    page over an ENOSPC filesystem.  Whereas previously they could have
> >    proceeded to completion and then detected the error via an fsync().
> 
> Or not detect the error at all if we don't call fsync() right ? Isn't a
> synchronous SIGBUS the right behaviour ?
>

Not according to POSIX.  Or at least posix-several-years-ago, when this
last was discussed.  The spec doesn't have much useful to say about any
of this.

It's a significant change in the userspace interface.

> 
> > 
> >    It's going to take more than one skimpy little paragraph to
> >    justify this, and to demonstrate that it is preferable, and to
> >    convince us that nothing will break from this user-visible behaviour
> >    change.
> > 
> > b) we're now doing fs operations (and some I/O) in the pagefault
> >    code.  This has several implications:
> > 
> >    - performance changes
> > 
> >    - potential for deadlocks when a process takes the fault from
> >      within a copy_to_user() in, say, mm/filemap.c
> > 
> >    - performing additional memory allocations within that
> >      copy_to_user().  Possibility that these will reenter the
> >      filesystem.
> > 
> > And that's just ext2.
> > 
> > For ext3 things are even more complex, because we have the
> > journal_start/journal_end pair which is effectively another "lock" for
> > ranking/deadlock purposes.  And now we're taking i_alloc_sem and
> > lock_page and we're doing ->writepage() and its potential
> > journal_start(), all potentially within the context of a
> > copy_to_user().
> 
> One of the reason why we would need this in ext3/ext4 is that we cannot
> do block allocation in the writepage with the recent locking changes.

Perhaps those recent locking changes were wrong.

> The locking changes involve changing the locking order of journal_start
> and page_lock. With writepage we are already called with page_lock and
> we can't start new transaction needed for block allocation.

ext3_write_begin() has journal_start() nesting inside the lock_page().

> But if we agree that we should not do block allocation in page_mkwrite
> we need to add writepages and allocate blocks in writepages.

I'm not sure what writepages has to do with pagefaults?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
