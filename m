Subject: Re: hugepage patches
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030202025546.2a29db61.akpm@digeo.com>
	<20030202195908.GD29981@holomorphy.com>
	<20030202124943.30ea43b7.akpm@digeo.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 03 Feb 2003 08:09:08 -0700
In-Reply-To: <20030202124943.30ea43b7.akpm@digeo.com>
Message-ID: <m1n0ld1jvv.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> writes:

> William Lee Irwin III <wli@holomorphy.com> wrote:
> >
> > On Sun, Feb 02, 2003 at 02:55:46AM -0800, Andrew Morton wrote:
> > > 6/4
> > > hugetlbfs: fix truncate
> > > - Opening a hugetlbfs file O_TRUNC calls the generic vmtruncate() functions
> > >   and nukes the kernel.
> > >   Give S_ISREG hugetlbfs files a inode_operations, and hence a setattr
> > >   which know how to handle these files.
> > > - Don't permit the user to truncate hugetlbfs files to sizes which are not
> > >   a multiple of HPAGE_SIZE.
> > > - We don't support expanding in ftruncate(), so remove that code.
> > 
> > erm, IIRC ftruncate() was the only way to expand the things;
> 
> Expanding ftruncate would be nice, but the current way of performing
> the page instantiation at mmap() time seems sufficient.

Having an expanding/shrinking ftruncate will trivially allow posix shared
memory semantics.   

I am trying to digest the idea of a mmap that grows a file.  There isn't
anything else that works that way is there?

It looks like you are removing the limit checking from hugetlbfs, by
removing the expansion code from ftruncate.  And given the fact that
nothing else grows in mmap, I suspect the code will be much easier to
write and maintain if the growth is constrained to happen in ftruncate.

mmap growing a file just sounds totally non-intuitive.  Though I do
agree, allocating that page at the time of growth sounds reasonable.

I may be missing something but it looks like there is not code present
to prevent multiple page allocations at the same time conflicting
when i_size is grown. 

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
