Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7246B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:54:35 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j2-v6so1389967qtl.1
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 08:54:35 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q8si2006795qkl.53.2018.04.18.08.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 08:54:33 -0700 (PDT)
Date: Wed, 18 Apr 2018 11:54:30 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/79] Generic page write protection and a solution
 to page waitqueue
Message-ID: <20180418155429.GA3476@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
 <20180418141337.mrnxqolo6aar3ud3@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180418141337.mrnxqolo6aar3ud3@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tim Chen <tim.c.chen@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Tejun Heo <tj@kernel.org>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

On Wed, Apr 18, 2018 at 04:13:37PM +0200, Jan Kara wrote:
> Hello,
> 
> so I finally got to this :)
> 
> On Wed 04-04-18 15:17:50, jglisse@redhat.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>

[...]

> > ----------------------------------------------------------------------
> > The Why ?
> > 
> > I have two objectives: duplicate memory read only accross nodes and or
> > devices and work around PCIE atomic limitations. More on each of those
> > objective below. I also want to put forward that it can solve the page
> > wait list issue ie having each page with its own wait list and thus
> > avoiding long wait list traversale latency recently reported [1].
> > 
> > It does allow KSM for file back pages (truely generic KSM even between
> > both anonymous and file back page). I am not sure how useful this can
> > be, this was not an objective i did pursue, this is just a for free
> > feature (see below).
> 
> I know some people (Matthew Wilcox?) wanted to do something like KSM for
> file pages - not all virtualization schemes use overlayfs and e.g. if you
> use reflinks (essentially shared on-disk extents among files) for your
> container setup, you could save significant amounts of memory with the
> ability to share pages in page cache among files that are reflinked.

Yes i believe they are still use case where KSM with file back page make
senses, i am just not familiar enough with those workload to know how big
of a deal this is.

> > [1] https://groups.google.com/forum/#!topic/linux.kernel/Iit1P5BNyX8
> > 
> > ----------------------------------------------------------------------
> > Per page wait list, so long page_waitqueue() !
> > 
> > Not implemented in this RFC but below is the logic and pseudo code
> > at bottom of this email.
> > 
> > When there is a contention on struct page lock bit, the caller which
> > is trying to lock the page will add itself to a waitqueue. The issues
> > here is that multiple pages share the same wait queue and on large
> > system with a lot of ram this means we can quickly get to a long list
> > of waiters for differents pages (or for the same page) on the same
> > list [1].
> > 
> > The present patchset virtualy kills all places that need to access the
> > page->mapping field and only a handfull are left, namely for testing
> > page truncation and for vmscan. The former can be remove if we reuse
> > the PG_waiters flag for a new PG_truncate flag set on truncation then
> > we can virtualy kill all derefence of page->mapping (this patchset
> > proves it is doable). NOTE THIS DOES NOT MEAN THAT MAPPING is FREE TO
> > BE USE BY ANYONE TO STORE WHATEVER IN STRUCT PAGE. SORRY NO !
> 
> It is interesting that you can get rid of page->mapping uses in most
> places. For page reclaim (vmscan) you'll still need a way to get from a
> page to an address_space so that you can reclaim the page so you can hardly
> get rid of page->mapping completely but you're right that with such limited
> use that transition could be more complex / expensive.

Idea for vmscan is that you either have regular mapping pointer store in
page->mapping or you have a pointer to special struct which has a function
pointer to a reclaim/walker function (rmap_walk_ksm)

> What I wonder though is what is the cost of this (in the terms of code size
> and speed) - propagating the mapping down the stack costs something... Also
> in terms of maintainability, code readability suffers a bit.

I haven't checked that, i will, i was not so concern because in the vast
majority of places there is already struct address_space on the stack
frame (ie local variable in function being call) so moving it to function
argument shouldn't impact that. However as i expect this will be merge
over multiple kernel release cycle and the intermediary step will see an
increase in stack size. The code size should only grow marginaly i expect.
I will provide numbers with my next posting after LSF/MM.


> This could be helped though. In some cases it seems we just use the mapping
> because it was easily available but could get away without it. In other
> case (e.g. lot of fs/buffer.c) we could make bh -> mapping transition easy
> by storing the mapping in the struct buffer_head - possibly it could
> replace b_bdev pointer as we could get to that from the mapping with a bit
> of magic and pointer chasing and accessing b_bdev is not very performance
> critical. OTOH such optimizations make a rather complex patches from mostly
> mechanical replacement so I can see why you didn't go that route.

I am willing to do the buffer_head change, i remember considering it but
i don't remember why not doing it (i failed to take note of that).


> Overall I think you'd need to make a good benchmarking comparison showing
> how much this helps some real workloads (your motivation) and also how
> other loads on lower end machines are affected.

Do you have any specific benchmark you would like to see ? My list was:
  https://github.com/01org/lkp-tests
  https://github.com/gormanm/mmtests
  https://github.com/akopytov/sysbench/
  http://git.infradead.org/users/dhowells/unionmount-testsuite.git

For workload i care this will be CUDA workload. We are still working on
the OpenCL open source stack but i don't expect we will have someting
that can shows the same performance improvement with OpenCL as soon as
with CUDA.

> > ----------------------------------------------------------------------
> > The What ?
> > 
> > Aim of this patch serie is to introduce generic page write protection
> > for any kind of regular page in a process (private anonymous or back
> > by regular file). This feature already exist, in one form, for private
> > anonymous page, as part of KSM (Kernel Share Memory).
> > 
> > So this patch serie is two fold. First it factors out the page write
> > protection of KSM into a generic write protection mechanim which KSM
> > becomes the first user of. Then it add support for regular file back
> > page memory (regular file or share memory aka shmem). To achieve this
> > i need to cut the dependency lot of code have on page->mapping so i
> > can set page->mapping to point to special structure when write
> > protected.
> 
> So I'm interested in this write protection mechanism but I didn't find much
> about it in the series. How does it work? I can see KSM writeprotects pages
> in page tables so that works for userspace mappings but what about
> in-kernel users modifying pages - e.g. pages in page cache carrying
> filesystem metadata do get modified a lot like this.

So i only care about page which are mmaped into a process address space.
At first i only want to intercept CPU write access through mmap of file
but i also intend to extend write syscall to also "fault" on the write
protection ie it will call a callback to unprotect the page allowing the
write protector to take proper action while write syscall is happening.

I am affraid truely generic write protection for metadata pages is bit
out of scope of what i am doing. However the mechanism i am proposing
can be extended for that too. Issue is that all place that want to write
to those page need to be converted to something where write happens
between write_begin and write_end section (mmap and CPU pte does give
this implicitly through page fault, so does write syscall). Basicly
there is a need to make sure that write and write protection can be
ordered against one another without complex locking.


> > ----------------------------------------------------------------------
> > The How ?
> > 
> > The corner stone assumption in this patch serie is that page->mapping
> > is always the same as vma->vm_file->f_mapping (modulo when a page is
> > truncated). The one exception is in respect to swaping with nfs file.
> > 
> > Am i fundamentaly wrong in my assumption ?
> 
> AFAIK you're right.
> 
> > I believe this is a do-able plan because virtually all place do know
> > the address_space a page belongs to, or someone in the callchain do.
> > Hence this patchset is all about passing down that information. The
> > only exception i am aware of is page reclamation (vmscan) but this can
> > be handled as a special case as there we not interested in the page
> > mapping per say but in reclaiming memory.
> > 
> > Once you have both struct page and mapping (without relying on the
> > struct page to get the latter) you can use mapping that as a unique
> > key to lookup page->private/page->index value. So all dereference of
> > those fields become:
> >     page_offset(page) -> page_offset(page, mapping)
> >     page_buffers(page) -> page_buffers(page, mapping)
> > 
> > Note than this only need special handling for write protected page ie
> > it is the same as before if page is not write protected so it just add
> > a test each time code call either helper.
> > 
> > Sinful function (all existing usage are remove in this patchset):
> >     page_mapping(page)
> > 
> > You can also use the page buffer head as a unique key. So following
> > helpers are added (thought i do not use them):
> >     page_mapping_with_buffers(page, (struct buffer_head *)bh)
> >     page_offset_with_buffers(page, (struct buffer_head *)bh)
> > 
> > A write protected page has page->mapping pointing to a structure like
> > struct rmap_item for KSM. So this structure has a list for each unique
> > combination:
> >     struct write_protect {
> >         struct list_head *mappings; /* write_protect_mapping list */
> >         ...
> >     };
> > 
> >     struct write_protect_mapping {
> >         struct list_head list
> >         struct address_space *mapping;
> >         unsigned long offset;
> >         unsigned long private;
> >         ...
> >     };
> 
> Auch, the fact that we could share a page as data storage for several
> inode+offset combinations that are not sharing underlying storage just
> looks viciously twisted ;) But is it really that useful to warrant
> complications? In particular I'm afraid that filesystems expect consistency
> between their internal state (attached to page->private) and page state
> (e.g. page->flags) and when there are multiple internal states attached to
> the same page this could go easily wrong...

So at first i want to limit to write protect (not KSM) thus page->flags
will stay consistent (ie page is only ever associated with a single
mapping). For KSM yes the page->flags can be problematic, however here
we can assume that page is clean (and uptodate) and not under write
back. So problematic flags for KSM:
  - private (page_has_buffers() or PagePrivate (nfs, metadata, ...))
  - private_2 (FsCache)
  - mappedtodisk
  - swapcache
  - error

Idea again would be to PageFlagsWithMapping(page, mapping) so that for
non KSM write protected page you test the usual page->flags and for
write protected page you find the flag value using mapping as lookup
index. Usualy those flag are seldomly changed/accessed. Again the
overhead (ignoring code size) would only be for page which are KSM.
So maybe KSM will not make sense because perf overhead it has with
page->flags access (i don't think so but i haven't tested this).


Thank you for taking time to read over all this.

Cheers,
Jerome
