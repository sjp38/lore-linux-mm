Subject: Re: hugepage patches
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030202025546.2a29db61.akpm@digeo.com>
	<20030202195908.GD29981@holomorphy.com>
	<20030202124943.30ea43b7.akpm@digeo.com>
	<m1n0ld1jvv.fsf@frodo.biederman.org>
	<20030203132929.40f0d9c0.akpm@digeo.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 03 Feb 2003 22:37:51 -0700
In-Reply-To: <20030203132929.40f0d9c0.akpm@digeo.com>
Message-ID: <m1hebk1u8g.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: wli@holomorphy.com, davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> writes:

> ebiederm@xmission.com (Eric W. Biederman) wrote:
> >
> > > 
> > > Expanding ftruncate would be nice, but the current way of performing
> > > the page instantiation at mmap() time seems sufficient.
> > 
> > Having an expanding/shrinking ftruncate will trivially allow posix shared
> > memory semantics.   
> > 
> > I am trying to digest the idea of a mmap that grows a file.  There isn't
> > anything else that works that way is there?
> 
> Not that I can think of.
> 
> > It looks like you are removing the limit checking from hugetlbfs, by
> > removing the expansion code from ftruncate.
> 
> There was no expansion code.

inode->i_size was grown, but I admit no huge pages were allocated.
 
> The code I took out was vestigial.  We can put it all back if we decide to
> add a new expand-with-ftruncate feature to hugetlbfs.
> 
> >  And given the fact that
> > nothing else grows in mmap, I suspect the code will be much easier to
> > write and maintain if the growth is constrained to happen in ftruncate.
> 
> That would require a fault handler.  We don't have one of those for hugetlbs.
>  Probably not hard to add one though.

I don't see that ftruncate setting the size would require a fault
handler.  ftruncate just needs to be called before mmap.  But a fault
handler would certainly make the code more like the rest of the mmap
cases.  

With a fault handler I start getting dangerous thoughts of paging
hugetlbfs to swap, probably not a good idea.

> > I may be missing something but it looks like there is not code present
> > to prevent multiple page allocations at the same time conflicting
> > when i_size is grown. 
> 
> All the mmap code runs under down_write(current->mm->mmap_sem);

Last I looked i_size is commonly protected by inode->i_sem.

current->mm->mmap_sem really doesn't provide protection if there is
a shared area between mappings in two different mm's.  Not a problem
if the code is a private mapping but otherwise...

Does hugetlbfs support shared mappings?  If it is exclusively
for private mappings the code makes much more sense than I am
thinking.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
