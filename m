Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1CFAA6B0055
	for <linux-mm@kvack.org>; Fri, 22 May 2009 12:40:30 -0400 (EDT)
Date: Fri, 22 May 2009 17:41:02 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
	with hugepage shared memory segments attached
Message-ID: <20090522164101.GA9196@csn.ul.ie>
References: <1242831915.6194.15.camel@lts-notebook> <20090520154128.GD4409@csn.ul.ie> <20090521094057.63B8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090521094057.63B8.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, starlight@binnacle.cx, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>, riel@redhat.com, hugh.dickins@tiscali.co.uk, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Thu, May 21, 2009 at 09:41:46AM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > Basic and in this case, apparently the critical factor. This patch on
> > 2.6.27.7 makes the problem disappear as well by never setting VM_LOCKED on
> > hugetlb-backed VMAs. Obviously, it's a hachet job and almost certainly the
> > wrong fix but it indicates that the handling of VM_LOCKED && VM_HUGETLB
> > is wrong somewhere. Now I have a better idea now what to search for on
> > Friday. Thanks Lee.
> > 
> > --- mm/mlock.c	2009-05-20 16:36:08.000000000 +0100
> > +++ mm/mlock-new.c	2009-05-20 16:28:17.000000000 +0100
> > @@ -64,7 +64,8 @@
> >  	 * It's okay if try_to_unmap_one unmaps a page just after we
> >  	 * set VM_LOCKED, make_pages_present below will bring it back.
> >  	 */
> > -	vma->vm_flags = newflags;
> > +	if (!(vma->vm_flags & VM_HUGETLB))
> 
> this condition meaning isn't so obvious to me. could you please
> consider comment adding?
> 

I should have used the helper, but anyway, the check was to see if the VMA was
backed by hugetlbfs or not. This wasn't the right fix. It was only intended
to show that it was something to do with the VM_LOCKED flag.

The real problem has something to do with pagetable-sharing of hugetlb-backed
segments. After fork(), the VM_LOCKED gets cleared so when huge_pmd_share()
is called, some of the pagetables are shared and others are not. I believe
this is resulting in pagetables being freed prematurely. I'm cc'ing the
author and acks to the pagetable-sharing patch to see can they shed more
light on whether this is the right patch or not. Kenneth, Hugh?

==== CUT HERE ====
x86: Ignore VM_LOCKED when determining if hugetlb-backed page tables can be shared or not

On x86 and x86-64, it is possible that page tables are shared beween shared
mappings backed by hugetlbfs. As part of this, page_table_shareable() checks
a pair of vma->vm_flags and they must match if they are to be shared. All
VMA flags are taken into account, including VM_LOCKED.

The problem is that VM_LOCKED is cleared on fork(). When a process with a
shared memory segment forks() to exec() a helper, there will be shared VMAs
with different flags. The impact is that the shared segment is sometimes
considered shareable and other times not, depending on what process is
checking. A test process that forks and execs heavily can trigger a
number of "bad pmd" messages appearing in the kernel log and hugepages
being leaked.

I believe what happens is that the segment page tables are being shared but
the count is inaccurate depending on the ordering of events.

Strictly speaking, this affects mainline but the problem is masked by the
changes made for CONFIG_UNEVITABLE_LRU as the kernel now never has VM_LOCKED
set for hugetlbfs-backed mapping. This does affect the stable branch of
2.6.27 and distributions based on that kernel such as SLES 11.

This patch addresses the problem by comparing all flags but VM_LOCKED when
deciding if pagetables should be shared or not for hugetlbfs-backed mapping.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 arch/x86/mm/hugetlbpage.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 8f307d9..16e4bcc 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -26,12 +26,16 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
 	unsigned long sbase = saddr & PUD_MASK;
 	unsigned long s_end = sbase + PUD_SIZE;
 
+	/* Allow segments to share if only one is locked */
+	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
+	unsigned long svm_flags = vma->vm_flags & ~VM_LOCKED;
+
 	/*
 	 * match the virtual addresses, permission and the alignment of the
 	 * page table page.
 	 */
 	if (pmd_index(addr) != pmd_index(saddr) ||
-	    vma->vm_flags != svma->vm_flags ||
+	    vm_flags != svm_flags ||
 	    sbase < svma->vm_start || svma->vm_end < s_end)
 		return 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
