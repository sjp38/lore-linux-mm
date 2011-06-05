Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 38E756B0109
	for <linux-mm@kvack.org>; Sun,  5 Jun 2011 09:43:20 -0400 (EDT)
Date: Sun, 5 Jun 2011 14:43:17 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: ENOSPC returned by handle_mm_fault()
Message-ID: <20110605134317.GF11521@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org

	When alloc_huge_page() runs afoul of quota, it returns ERR_PTR(-ENOSPC).
Callers do not expect that - hugetlb_cow() returns ENOSPC if it gets that
and so does hugetlb_no_page().  Eventually the thing propagates back to
hugetlb_fault() and is returned by it.

	Callers of hugetlb_fault() clearly expect a bitmap of VM_... and
not something from errno.h: one place is 
                        ret = hugetlb_fault(mm, vma, vaddr,
                                (flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
                        spin_lock(&mm->page_table_lock);
                        if (!(ret & VM_FAULT_ERROR))
                                continue;
and another is handle_mm_fault(), which ends up returning ENOSPC and *its*
callers are definitely not ready to deal with that.

ENOSPC is 28, i.e. VM_FAULT_MAJOR | VM_FAULT_WRITE | VM_FAULT_HWPOISON;
it's also theoretically possible to get ENOMEM if region_chg() ends up
hitting
                nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
                if (!nrg)
                        return -ENOMEM;
region_chg() <- vma_needs_reservation() <- alloc_huge_page() and from that
point as with ENOSPC.  ENOMEM is 12, i.e. VM_FAULT_MAJOR | VM_FAULT_WRITE...

Am I right assuming that we want VM_FAULT_OOM in both cases?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
