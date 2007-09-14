Date: Fri, 14 Sep 2007 10:15:23 +0100
Subject: Re: [PATCH 1/5] hugetlb: Account for hugepages as locked_vm
Message-ID: <20070914091522.GB30407@skynet.ie>
References: <20070913175855.27074.27030.stgit@kernel> <20070913175905.27074.92434.stgit@kernel> <b040c32a0709132241t7d464a2x68d1194887cd8e93@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <b040c32a0709132241t7d464a2x68d1194887cd8e93@mail.gmail.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Bill Irwin <bill.irwin@oracle.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

On (13/09/07 22:41), Ken Chen didst pronounce:
> On 9/13/07, Adam Litke <agl@us.ibm.com> wrote:
> > Hugepages allocated to a process are pinned into memory and are not
> > reclaimable.  Currently they do not contribute towards the process' locked
> > memory.  This patch includes those pages in the process' 'locked_vm' pages.
> 
> On x86_64, hugetlb can share page table entry if multiple processes
> have their virtual addresses all lined up perfectly.  Because of that,
> mm->locked_vm can go negative with this patch depending on the order
> of which process fault in hugetlb pages and which one unmaps it last.
> 

hmmm, on close inspection you are right. The worst case is where two processes
share a PMD and fault half of the hugepages in that region each. Whichever
of them unmaps last will get bad values.

> Have you checked all user of mm->locked_vm that a negative number
> won't trigger unpleasant result?
> 

This, if it can occur is bad. It's looks stupid if absolutly nothing
else. Besides, locked_vm is an unsigned long. Wrapping negative would
actually be a huge positive so it's possible that a hostile process A
could cause a situation where innocent process B gets a large locked_vm
value and cannot dynamically resize the hugepage pool any more.

The choices for a fix I can think of are;

a) Do not use locked_vm at all. Instead use filesystem quotas to prevent the
pool growing in an unbounded fashion (this is Adam and Andy Whitcrofts idea,
not mine but it makes sense in light of this problem with locked_vm). I
liked the idea of being able to limit additional hugepage usage with
RLIMIT_LOCKED but maybe that is not such a great plan.

b) Double-count locked_vm. i.e. when pagetables are shared, the process
about to share increments it's locked_vm based on the pages already
faulted. On fault, all mm's sharing get their locked_vm increased and
unmap acts as it does. This would require the taking of many
page_table_locks to update locked_vm which would be very expensive.

Anyone got better suggestions than this? Mr. McCracken, how did you
handle the mlocked case in your pagetable sharing patches back when you
were working on them? I am assuming the problem is somewhat similar.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
