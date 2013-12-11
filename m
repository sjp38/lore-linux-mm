Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5D03A6B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 11:40:55 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so2991116eek.15
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 08:40:54 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id r9si19886175eeo.65.2013.12.11.08.40.54
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 08:40:54 -0800 (PST)
Date: Wed, 11 Dec 2013 16:40:52 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: numa: Guarantee that tlb_flush_pending updates are
 visible before page table updates
Message-ID: <20131211164052.GB11295@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
 <20131211132109.GB24125@suse.de>
 <20131211144446.GP4208@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131211144446.GP4208@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 11, 2013 at 06:44:47AM -0800, Paul E. McKenney wrote:
> On Wed, Dec 11, 2013 at 01:21:09PM +0000, Mel Gorman wrote:
> > According to documentation on barriers, stores issued before a LOCK can
> > complete after the lock implying that it's possible tlb_flush_pending can
> > be visible after a page table update. As per revised documentation, this patch
> > adds a smp_mb__before_spinlock to guarantee the correct ordering.
> > 
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Assuming that there is a lock acquisition after calls to
> set_tlb_flush_pending():
> 
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> (I don't see set_tlb_flush_pending() in mainline.)
> 

It's introduced by a patch flight that is currently sitting in Andrew's
tree. In the case where we care about the value of tlb_flush_pending, a
spinlock will be taken. PMD or PTE split spinlocks or the mm->page_table_lock
depending on whether it is 3.13 or 3.12-stable and earlier kernels. I
pushed the relevant patches to this tree and branch

git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git numab-instrument-serialise-v5r1

There is no guarantee the lock will be taken if there are no pages populated
in the region but we also do not care about flushing the TLB in that case
either. Does it matter that there is no guarantee a lock will be taken
after smp_mb__before_spinlock, just very likely that it will be?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
