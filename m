Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BF408620001
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:25:36 -0500 (EST)
Date: Sun, 31 Jan 2010 21:24:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25 of 31] transparent hugepage core
Message-ID: <20100131202436.GA12034@random.random>
References: <patchbomb.1264689194@v2.random>
 <ac9bbf9e2c95840eb237.1264689219@v2.random>
 <20100128175753.GF7139@csn.ul.ie>
 <20100128223653.GL1217@random.random>
 <20100129152939.GI7139@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100129152939.GI7139@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 29, 2010 at 03:29:39PM +0000, Mel Gorman wrote:
> Unfortunately, I don't have a i915 but I'll be testing the patchset on
> the laptop over the weekend.

never mind it's fixed. It was only cosmetical. It triggered on vesa
too, it just needed a large enough framebuffer. In short I didn't
interrupt the scan of the vma at vm_end & HPAGE_PMD_MASK. So I started
scanning a pmd that wasn't fully included in the current vma, but
passing the current vma to the pmd scanning like if the whole pmd
belonged it. The real vma mapping of the framebuffer was fine.

The reason this was going away with "echo never
>transparent_hugepage/enabled" while leaving khugepaged enabled in
readonly mode, is that mm_slot isn't allocated and khugepaged doesn't
track vmas that don't ask for hugepages so the registration logic of
mm is the same for madvise and always... of course.

This was the fix, and I'll submit #9 with it.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1657,9 +1657,14 @@ static unsigned int khugepaged_scan_mm_s
 		}
 		if (khugepaged_scan.address < hstart)
 			khugepaged_scan.address = hstart;
+		if (khugepaged_scan.address > hend) {
+			khugepaged_scan.address = hend + HPAGE_PMD_SIZE;
+			progress++;
+			continue;
+		}
 		BUG_ON(khugepaged_scan.address & ~HPAGE_PMD_MASK);
 
-		while (khugepaged_scan.address < vma->vm_end) {
+		while (khugepaged_scan.address < hend) {
 			int ret;
 			cond_resched();
 			if (unlikely(khugepaged_test_exit(mm)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
