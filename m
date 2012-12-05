Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 0C8406B006C
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 05:00:43 -0500 (EST)
Date: Wed, 5 Dec 2012 09:52:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] tmpfs: fix shared mempolicy leak
Message-ID: <20121205095221.GB2489@suse.de>
References: <1349801921-16598-1-git-send-email-mgorman@suse.de>
 <1349801921-16598-6-git-send-email-mgorman@suse.de>
 <CA+ydwtqQ7iK_1E+7ctLxYe8JZY+SzMfuRagjyHJ12OYsxbMcaA@mail.gmail.com>
 <20121204141501.GA2797@suse.de>
 <alpine.LNX.2.00.1212042042130.13895@eggly.anvils>
 <alpine.LNX.2.00.1212042211340.892@eggly.anvils>
 <alpine.LNX.2.00.1212042320050.19453@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1212042320050.19453@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Tommi Rantala <tt.rantala@gmail.com>, Stable <stable@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Dec 04, 2012 at 11:24:30PM -0800, Hugh Dickins wrote:
> From: Mel Gorman <mgorman@suse.de>
> 
> Commit 00442ad04a5e ("mempolicy: fix a memory corruption by refcount
> imbalance in alloc_pages_vma()") changed get_vma_policy() to raise the
> refcount on a shmem shared mempolicy; whereas shmem_alloc_page() went
> on expecting alloc_page_vma() to drop the refcount it had acquired.
> This deserves a rework: but for now fix the leak in shmem_alloc_page().
> 
> Hugh: shmem_swapin() did not need a fix, but surely it's clearer to use
> the same refcounting there as in shmem_alloc_page(), delete its onstack
> mempolicy, and the strange mpol_cond_copy() and __mpol_cond_copy() -
> those were invented to let swapin_readahead() make an unknown number of
> calls to alloc_pages_vma() with one mempolicy; but since 00442ad04a5e,
> alloc_pages_vma() has kept refcount in balance, so now no problem.
> 

Agreed. Anything that reduces the complexity of the mempolicy ref counting
is worthwhile even if it's only by a small bit.

> Reported-by: Tommi Rantala <tt.rantala@gmail.com>
> Awaiting-signed-off-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org

Thanks Hugh for turning gibber into a patch!

Signed-off-by: Mel Gorman <mgorman@suse.de>

Tommi, just in case, can you confirm this fixes the problem for you please?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
