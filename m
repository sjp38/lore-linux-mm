Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B74536B00B4
	for <linux-mm@kvack.org>; Wed, 27 May 2009 19:18:23 -0400 (EDT)
Date: Thu, 28 May 2009 01:18:03 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] x86: Ignore VM_LOCKED when determining if
	hugetlb-backed page tables can be shared or not
Message-ID: <20090527231803.GA30002@elte.hu>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie> <1243422749-6256-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1243422749-6256-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, starlight@binnacle.cx, Eric B Munson <ebmunson@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, wli@movementarian.org
List-ID: <linux-mm.kvack.org>


* Mel Gorman <mel@csn.ul.ie> wrote:

> On x86 and x86-64, it is possible that page tables are shared 
> beween shared mappings backed by hugetlbfs. As part of this, 
> page_table_shareable() checks a pair of vma->vm_flags and they 
> must match if they are to be shared. All VMA flags are taken into 
> account, including VM_LOCKED.
> 
> The problem is that VM_LOCKED is cleared on fork(). When a process 
> with a shared memory segment forks() to exec() a helper, there 
> will be shared VMAs with different flags. The impact is that the 
> shared segment is sometimes considered shareable and other times 
> not, depending on what process is checking.
> 
> What happens is that the segment page tables are being shared but 
> the count is inaccurate depending on the ordering of events. As 
> the page tables are freed with put_page(), bad pmd's are found 
> when some of the children exit. The hugepage counters also get 
> corrupted and the Total and Free count will no longer match even 
> when all the hugepage-backed regions are freed. This requires a 
> reboot of the machine to "fix".
> 
> This patch addresses the problem by comparing all flags except 
> VM_LOCKED when deciding if pagetables should be shared or not for 
> hugetlbfs-backed mapping.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>  arch/x86/mm/hugetlbpage.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)

i suspect it would be best to do this due -mm, due to the (larger) 
mm/hugetlb.c cross section, right?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
