Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A31186B0203
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:56:20 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 67] Transparent Hugepage Support #18
Message-Id: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:50:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

Hello,

I merged memory compaction v7 from Mel, plus his latest incremental updates
into my tree.

Large order allocations without __GFP_WAIT were grinding the system to an
unusable state if run frequently and the VM was invoked frequently, but I
deferred looking into the VM until I combined it with memory compaction.
Memory compaction didn't solve the problem in fact (that would have been too
easy), so this time I tracked it down to lumpy reclaim which I nuked and now
direct reclaim with memory compaction in the page faults works fine and system
remains responsive and doesn't start swapping despite tons of cache freeable.

You can trace the memory compaction working with your workload with something
like this:

stap -ve 'probe kernel.function("try_to_compact_pages") { printf("x") } probe kernel.function("try_to_free_pages") { printf("y") }'
xxxxxxxxxxxxxxxxxxxxxxxxxxxyxxxyxxyxxxxxxyxxyxxxxyxxyxxxxxxxxyxxyxxxxxyxxxyxxyxxyxxyxxxxyxxxyxxxxxxyxxyxxxyxxxyxxxyxxxxxxyxxyxxxxxxxyxxxxyxxyxxyxxyxxyxxyxxxxyxxxxyxxyxxyxxyxxxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxxxyxxyxxxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxy
 xxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxxyxxyxxyxxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxxyxx^CyxxyxxyxxyxxyxxyxxyxxyxxyxPass
5: run completed in 0usr/30sys/29754real ms.

I also merged set_recommended_min_free_kbytes in kernel so nobody risks to
forget to run hugeadm. It won't be run if you boot with
transparent_hugepage=0. But it will be run later if you enable transparent
hugepage with "echo always >/sys/kernel/mm/transparent_hugepage/enabled".
(however running it later if there's already unmovable stuff fragmenting the
memory will be too late)

If there's any sluglishness and (I don't see it anymore after nuking lumpy
reclaim) you should try this:

	echo never >/sys/kernel/mm/transparent_hugepage/defrag

That way only khugepaged runs memory compaction (see
/sys/kernel/mm/transparent_hugepage/khugepaged/defrag).

Full list of changes:

1) set HUGETLB_PAGE when TRANSPARENT_HUGEPAGE is set
2) select COMPACTION when TRANSPARENT_HUGEPAGE is set
3) have TRANSPARENT_HUGEPAGE depend on MMU
4) fix a bug in migrate that didn't split the hugepages when invoked by kernel
   (through compaction for example) instead of moves_pages syscall
5) Add set_recommended_min_free_kbytes in kernel
6) Add GFP_IO_FS back to GFP_TRANSHUGE so when defrag sysfs control is enabled 
   compaction runs (removing it was a minor attempt to decrease the
   unusability created by lumpy reclaim, they never intended to be not set)
7) set defrag to always by default (previous default setting was "never")
8) Fix oops in memcg when migration is invoked on a signalled task
9) Fix lockdep error in memory compaction when trying to drain lru lists
   (migrate_prep is not mandatory so I commented it out for now)
10) removed lumpy reclaim
11) memory compaction
12) fix to memory compaction to remove an unnecessary optimization reading the
    page_order if page_buddy is set but outside of zone->lock which is
    racy and crashes.

It's not as well tested as #17 but after the last couple of fixes everything
seems fine.

This is the tree I recommend to use for benchmarking (note: I recommend to try
both with "echo never >/sys/kernel/mm/transparent_hugepage/defrag" and the
default "echo always >/sys/kernel/mm/transparent_hugepage/defrag"). The only
other tuning I suggest is to decrease the khugepaged/scan_sleep_millisecs.

To take full advantage of it in all apps, we also need to sort out how to make
glibc extend vma->vm_end of anonymous vmas in 2M aligned chunks to see the
exact speedup gcc gets from transparent hugepages on host without
virtualization on certain files that requires >200M of ram to build. A kernel
workaround is possible too but personally I like the current simpler kernel
code and to address it in userland which should be more efficient and much
simpler, but we'll see...

quilt:

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc3/transparent_hugepage-18/
	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc3/transparent_hugepage-18.gz

git: (note after the clone you've to run
"git fetch; git checkout origin/master" because it'll be rebased, and you
should check that "git diff a56565c0eb27da00bfdd46f54ad738cabdc05996" shows zero
difference to be sure)

	git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

(apparently right now I still get a slightly older tree for both quilt and git
that I've overwritten in quilt case and that I changed origin/master branch on
git, I assume it takes a bit to be available on git.kernel.org, which is why I
specified to check with git diff a56565c0eb27da00bfdd46f54ad738cabdc05996)

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
