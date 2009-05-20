Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 711C16B0089
	for <linux-mm@kvack.org>; Wed, 20 May 2009 11:40:55 -0400 (EDT)
Date: Wed, 20 May 2009 16:41:29 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
	with hugepage shared memory segments attached
Message-ID: <20090520154128.GD4409@csn.ul.ie>
References: <6.2.5.6.2.20090515145151.03a55298@binnacle.cx> <20090520113525.GA4409@csn.ul.ie> <1242831218.6194.13.camel@lts-notebook> <1242831915.6194.15.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1242831915.6194.15.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: starlight@binnacle.cx, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, May 20, 2009 at 11:05:15AM -0400, Lee Schermerhorn wrote:
> On Wed, 2009-05-20 at 10:53 -0400, Lee Schermerhorn wrote:
> > On Wed, 2009-05-20 at 12:35 +0100, Mel Gorman wrote:
> > > On Fri, May 15, 2009 at 02:53:27PM -0400, starlight@binnacle.cx wrote:
> > > > Here's another possible clue:
> > > > 
> > > > I tried the first 'tcbm' testcase on a 2.6.27.7
> > > > kernel that was hanging around from a few months
> > > > ago and it breaks it 100% of the time.
> > > > 
> > > > Completely hoses huge memory.  Enough "bad pmd"
> > > > errors to fill the kernel log.
> > > > 
> > > 
> > > So I investigated what's wrong with 2.6.27.7. The problem is a race between
> > > exec() and the handling of mlock()ed VMAs but I can't see where. The normal
> > > teardown of pages is applied to a shared memory segment as if VM_HUGETLB
> > > was not set.
> > > 
> > > This was fixed between 2.6.27 and 2.6.28 but apparently by accident during the
> > > introduction of CONFIG_UNEVITABLE_LRU. This patchset made a number of changes
> > > to how mlock()ed are handled but I didn't spot which was the relevant change
> > > that fixed the problem and reverse bisecting didn't help. I've added two people
> > > that were working on the unevictable LRU patches to see if they spot something.
> > 
> > Hi, Mel:
> > and still do.  With the unevictable lru, mlock()/mmap('LOCKED) now move
> > the mlocked pages to the unevictable lru list and munlock, including at
> > exit, must rescue them from the unevictable list.   Since hugepages are
> > not maintained on the lru and don't get reclaimed, we don't want to move
> > them to the unevictable list,  However, we still want to populate the
> > page tables.  So, we still call [_]mlock_vma_pages_range() for hugepage
> > vmas, but after making the pages present to preserve prior behavior, we
> > remove the VM_LOCKED flag from the vma.
> 
> Wow!  that got garbled.  not sure how.  Message was intended to start
> here:
> 
> > The basic change to handling of hugepage handling with the unevictable
> > lru patches is that we no longer keep a huge page vma marked with
> > VM_LOCKED.  So, at exit time, there is no record that this is a vmlocked
> > vma.
> > 

Basic and in this case, apparently the critical factor. This patch on
2.6.27.7 makes the problem disappear as well by never setting VM_LOCKED on
hugetlb-backed VMAs. Obviously, it's a hachet job and almost certainly the
wrong fix but it indicates that the handling of VM_LOCKED && VM_HUGETLB
is wrong somewhere. Now I have a better idea now what to search for on
Friday. Thanks Lee.

--- mm/mlock.c	2009-05-20 16:36:08.000000000 +0100
+++ mm/mlock-new.c	2009-05-20 16:28:17.000000000 +0100
@@ -64,7 +64,8 @@
 	 * It's okay if try_to_unmap_one unmaps a page just after we
 	 * set VM_LOCKED, make_pages_present below will bring it back.
 	 */
-	vma->vm_flags = newflags;
+	if (!(vma->vm_flags & VM_HUGETLB))
+		vma->vm_flags = newflags;
 
 	/*
 	 * Keep track of amount of locked VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
