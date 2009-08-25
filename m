Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4657F6B00A4
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:16:21 -0400 (EDT)
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n7PKGPuF024418
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:16:25 -0400
Date: Tue, 25 Aug 2009 16:58:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 9/12] ksm: fix oom deadlock
Message-ID: <20090825145832.GP14722@random.random>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908031317190.16754@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 03, 2009 at 01:18:16PM +0100, Hugh Dickins wrote:
> tables which have been freed for reuse; and even do_anonymous_page
> and __do_fault need to check they're not being called by break_ksm
> to reinstate a pte after zap_pte_range has zapped that page table.

This deadlocks exit_mmap in an infinite loop when there's some region
locked. mlock calls gup and pretends to page fault successfully if
there's a vma existing on the region, but it doesn't page fault
anymore because of the mm_count being 0 already, so follow_page fails
and gup retries the page fault forever. And generally I don't like to
add those checks to page fault fast path.

Given we check mm_users == 0 (ksm_test_exit) after taking mmap_sem in
unmerge_and_remove_all_rmap_items, why do we actually need to care
that a page fault happens? We hold mmap_sem so we're guaranteed to see
mm_users == 0 and we won't ever break COW on that mm with mm_users ==
0 so I think those troublesome checks from page fault can be simply
removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
