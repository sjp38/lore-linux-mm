Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 217CA6B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 11:56:26 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id gq1so7230539obb.17
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 08:56:25 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id ns8si13950926obc.35.2013.12.11.08.56.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 08:56:25 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 09:56:24 -0700
Received: from b03cxnp07027.gho.boulder.ibm.com (b03cxnp07027.gho.boulder.ibm.com [9.17.130.14])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id BA6B83E4003F
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:56:21 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBBEsDRi8257934
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 15:54:13 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rBBGxNUi006792
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:59:23 -0700
Date: Wed, 11 Dec 2013 08:56:20 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: numa: Guarantee that tlb_flush_pending updates are
 visible before page table updates
Message-ID: <20131211165620.GU4208@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
 <20131211132109.GB24125@suse.de>
 <20131211144446.GP4208@linux.vnet.ibm.com>
 <20131211164052.GB11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131211164052.GB11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 11, 2013 at 04:40:52PM +0000, Mel Gorman wrote:
> On Wed, Dec 11, 2013 at 06:44:47AM -0800, Paul E. McKenney wrote:
> > On Wed, Dec 11, 2013 at 01:21:09PM +0000, Mel Gorman wrote:
> > > According to documentation on barriers, stores issued before a LOCK can
> > > complete after the lock implying that it's possible tlb_flush_pending can
> > > be visible after a page table update. As per revised documentation, this patch
> > > adds a smp_mb__before_spinlock to guarantee the correct ordering.
> > > 
> > > Cc: stable@vger.kernel.org
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > 
> > Assuming that there is a lock acquisition after calls to
> > set_tlb_flush_pending():
> > 
> > Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > 
> > (I don't see set_tlb_flush_pending() in mainline.)
> > 
> 
> It's introduced by a patch flight that is currently sitting in Andrew's
> tree. In the case where we care about the value of tlb_flush_pending, a
> spinlock will be taken. PMD or PTE split spinlocks or the mm->page_table_lock
> depending on whether it is 3.13 or 3.12-stable and earlier kernels. I
> pushed the relevant patches to this tree and branch
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git numab-instrument-serialise-v5r1
> 
> There is no guarantee the lock will be taken if there are no pages populated
> in the region but we also do not care about flushing the TLB in that case
> either. Does it matter that there is no guarantee a lock will be taken
> after smp_mb__before_spinlock, just very likely that it will be?

If you do smp_mb__before_spinlock() without a lock acquisition, no harm
will be done, other than possibly a bit of performance loss.  So you
should be OK.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
