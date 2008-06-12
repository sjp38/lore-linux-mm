Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5C46mEn005563
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:06:48 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5C46c854485188
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:06:39 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5C46wcB013050
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:06:58 +1000
Date: Thu, 12 Jun 2008 09:36:43 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] ext2: Use page_mkwrite vma_operations to get mmap
	write notification.
Message-ID: <20080612040643.GA5518@skywalker>
References: <1212685513-32237-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20080605123045.445e380a.akpm@linux-foundation.org> <20080611150845.GA21910@skywalker> <20080611120749.d0c5a7de.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080611120749.d0c5a7de.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cmm@us.ibm.com, jack@suse.cz, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 11, 2008 at 12:07:49PM -0700, Andrew Morton wrote:
> On Wed, 11 Jun 2008 20:38:45 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > On Thu, Jun 05, 2008 at 12:30:45PM -0700, Andrew Morton wrote:
> > > On Thu,  5 Jun 2008 22:35:12 +0530
> > > "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > 
> > > > We would like to get notified when we are doing a write on mmap
> > > > section.  The changes are needed to handle ENOSPC when writing to an
> > > > mmap section of files with holes.
> > > > 
> > > 
> > > Whoa.  You didn't copy anything like enough mailing lists for a change
> > > of this magnitude.  I added some.
> > > 
> > > This is a large change in behaviour!
> > > 
> > > a) applications will now get a synchronous SIGBUS when modifying a
> > >    page over an ENOSPC filesystem.  Whereas previously they could have
> > >    proceeded to completion and then detected the error via an fsync().
> > 
> > Or not detect the error at all if we don't call fsync() right ? Isn't a
> > synchronous SIGBUS the right behaviour ?
> >
> 
> Not according to POSIX.  Or at least posix-several-years-ago, when this
> last was discussed.  The spec doesn't have much useful to say about any
> of this.
> 
> It's a significant change in the userspace interface.
> 
> > 
> > > 
> > >    It's going to take more than one skimpy little paragraph to
> > >    justify this, and to demonstrate that it is preferable, and to
> > >    convince us that nothing will break from this user-visible behaviour
> > >    change.
> > > 
> > > b) we're now doing fs operations (and some I/O) in the pagefault
> > >    code.  This has several implications:
> > > 
> > >    - performance changes
> > > 
> > >    - potential for deadlocks when a process takes the fault from
> > >      within a copy_to_user() in, say, mm/filemap.c
> > > 
> > >    - performing additional memory allocations within that
> > >      copy_to_user().  Possibility that these will reenter the
> > >      filesystem.
> > > 
> > > And that's just ext2.
> > > 
> > > For ext3 things are even more complex, because we have the
> > > journal_start/journal_end pair which is effectively another "lock" for
> > > ranking/deadlock purposes.  And now we're taking i_alloc_sem and
> > > lock_page and we're doing ->writepage() and its potential
> > > journal_start(), all potentially within the context of a
> > > copy_to_user().
> > 
> > One of the reason why we would need this in ext3/ext4 is that we cannot
> > do block allocation in the writepage with the recent locking changes.
> 
> Perhaps those recent locking changes were wrong.
> 
> > The locking changes involve changing the locking order of journal_start
> > and page_lock. With writepage we are already called with page_lock and
> > we can't start new transaction needed for block allocation.
> 
> ext3_write_begin() has journal_start() nesting inside the lock_page().
> 

All those are changed as a part of lock inversion changes.



> > But if we agree that we should not do block allocation in page_mkwrite
> > we need to add writepages and allocate blocks in writepages.
> 
> I'm not sure what writepages has to do with pagefaults?
> 

The idea is to have ext3/4_writepages. In writepages start a transaction
and iterate over the pages take the lock and do block allocation. With
that change we should be able to not do block allocation in the
page_mkwrite path. We may still want to do block reservation there.

Something like.

ext4_writepages()
{
	journal_start()
	for_each_page()
	lock_page
	if (bh_unmapped()...)
		block_alloc()
	unlock_page
	journal_stop()

}

ext4_writepage()
{
	for_each_buffer_head()
		if (bh_unmapped()) {
			redirty_page
			unlock_page
			return;
		}
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
