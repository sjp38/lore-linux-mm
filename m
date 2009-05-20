Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFAA6B0092
	for <linux-mm@kvack.org>; Wed, 20 May 2009 11:05:43 -0400 (EDT)
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
	with hugepage shared memory segments attached
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1242831218.6194.13.camel@lts-notebook>
References: <6.2.5.6.2.20090515145151.03a55298@binnacle.cx>
	 <20090520113525.GA4409@csn.ul.ie>  <1242831218.6194.13.camel@lts-notebook>
Content-Type: text/plain
Date: Wed, 20 May 2009 11:05:15 -0400
Message-Id: <1242831915.6194.15.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: starlight@binnacle.cx, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 2009-05-20 at 10:53 -0400, Lee Schermerhorn wrote:
> On Wed, 2009-05-20 at 12:35 +0100, Mel Gorman wrote:
> > On Fri, May 15, 2009 at 02:53:27PM -0400, starlight@binnacle.cx wrote:
> > > Here's another possible clue:
> > > 
> > > I tried the first 'tcbm' testcase on a 2.6.27.7
> > > kernel that was hanging around from a few months
> > > ago and it breaks it 100% of the time.
> > > 
> > > Completely hoses huge memory.  Enough "bad pmd"
> > > errors to fill the kernel log.
> > > 
> > 
> > So I investigated what's wrong with 2.6.27.7. The problem is a race between
> > exec() and the handling of mlock()ed VMAs but I can't see where. The normal
> > teardown of pages is applied to a shared memory segment as if VM_HUGETLB
> > was not set.
> > 
> > This was fixed between 2.6.27 and 2.6.28 but apparently by accident during the
> > introduction of CONFIG_UNEVITABLE_LRU. This patchset made a number of changes
> > to how mlock()ed are handled but I didn't spot which was the relevant change
> > that fixed the problem and reverse bisecting didn't help. I've added two people
> > that were working on the unevictable LRU patches to see if they spot something.
> 
> Hi, Mel:
> and still do.  With the unevictable lru, mlock()/mmap('LOCKED) now move
> the mlocked pages to the unevictable lru list and munlock, including at
> exit, must rescue them from the unevictable list.   Since hugepages are
> not maintained on the lru and don't get reclaimed, we don't want to move
> them to the unevictable list,  However, we still want to populate the
> page tables.  So, we still call [_]mlock_vma_pages_range() for hugepage
> vmas, but after making the pages present to preserve prior behavior, we
> remove the VM_LOCKED flag from the vma.

Wow!  that got garbled.  not sure how.  Message was intended to start
here:

> The basic change to handling of hugepage handling with the unevictable
> lru patches is that we no longer keep a huge page vma marked with
> VM_LOCKED.  So, at exit time, there is no record that this is a vmlocked
> vma.
> 
> A bit of context:  before the unevictable lru, mlock() or
> mmap(MAP_LOCKED) would just set the VM_LOCKED flag and
> "make_pages_present()" for all but a few vma types.  We've always
> excluded those that get_user_pages() can't handle and still do.  With
> the unevictable lru, mlock()/mmap('LOCKED) now move the mlocked pages to
> the unevictable lru list and munlock, including at exit, must rescue
> them from the unevictable list.   Since hugepages are not maintained on
> the lru and don't get reclaimed, we don't want to move them to the
> unevictable list,  However, we still want to populate the page tables.
> So, we still call [_]mlock_vma_pages_range() for hugepage vmas, but
> after making the pages present to preserve prior behavior, we remove the
> VM_LOCKED flag from the vma.
> 
> This may have resulted in the apparent fix to the subject problem in
> 2.6.28...
> 
> > 
> > For context, the two attached files are used to reproduce a problem
> > where bad pmd messages are scribbled all over the console on 2.6.27.7.
> > Do something like
> > 
> > echo 64 > /proc/sys/vm/nr_hugepages
> > mount -t hugetlbfs none /mnt
> > sh ./test-tcbm.sh
> > 
> > I did confirm that it didn't matter to 2.6.29.1 if CONFIG_UNEVITABLE_LRU is
> > set or not.  It's possible the race it still there but I don't know where
> > it is.
> > 
> > Any ideas where the race might be?
> 
> No, sorry.  Haven't had time to investigate this.
> 
> Lee
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
