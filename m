Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9BC9A6B01BC
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 12:56:47 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 41] Transparent Hugepage Support #15
Message-Id: <patchbomb.1269622081@v2.random>
Date: Fri, 26 Mar 2010 17:48:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Hello,

this fixes a potential issue with regard to simultaneous 4k and 2M TLB entries
in split_huge_page (at pratically zero cost, so I didn't need to add a fake
feature flag and it's a lot safer to do it this way just in case).
split_large_page in change_page_attr has the same issue too, but I've no idea
how to fix it there because the pmd cannot be marked non present at any given
time as change_page_attr may be running on ram below 640k and that is the same
pmd where the kernel .text resides. However I doubt it'll ever be a practical
problem. Other cpus also has a lot of warnings and risks in allowing
simultaneous TLB entries of different size.

Johannes also sent a cute optimization to split split_huge_page_vma/mm he
converted those in a single split_huge_page_pmd and in addition he also sent
native support for hugepages in both mincore and mprotect. Which shows how
deep he already understands the whole huge_memory.c and its usage in the
callers.  Seeing significant contributions like this I think further confirms
this is the way to go. Thanks a lot Johannes.

The ability to bisect before the mincore and mprotect native implementations
is one of the huge benefits of this approach. The hardest of all will be to
add swap native support to 2M pages later (as it involves to make the
swapcache 2M capable and that in turn means it expodes all over the
pagecache code) but I think first we've other priorities:

1) merge memory compaction
2) 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
