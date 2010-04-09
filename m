Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BF2AD6B0216
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 01:41:48 -0400 (EDT)
Date: Fri, 9 Apr 2010 04:05:21 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Transparent Hugepage Support #19
Message-ID: <20100409020521.GA5740@random.random>
References: <patchbomb.1270691443@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <patchbomb.1270691443@v2.random>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Hello,

I'm not patchbombing further due the size of the patchset (71 patches
now).

git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc3/transparent_hugepage-19/
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc3/transparent_hugepage-19.gz

Differences from #18:

1) backout mainline anon-vma changes, I had one bugcheck trigger that
   seems could be caused by bugs in the anon-vma changes. Those bugs
   are much more noticeable and severe with transparent hugepage
   support enabled. I tried the patches available but named wouldn't
   start anymore with futex returning sigbus. Note the commentary
   added here about it:

   http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc3/transparent_hugepage-19/split_huge_page-anon_vma

2) don't compact already compcat transparent hugepages (thanks to Avi,
   Mel and Johannes for the help). Avi you may want to re-test the
   sort workload with kernel build in parallel, memory compaction
   won't split hugepages anymore.

   http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc3/transparent_hugepage-19/transhuge-isolate_migratepages

3) include AnonHugePages into AnonPages in /proc/meminfo as suggested
   by Avi

   http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc3/transparent_hugepage-19/transparent_hugepage_vmstat

4) fix some issue in move_pages syscall (using a suggestion from
   Christoph to have follow_page split them internally, adding
   FOLL_SPLIT). Otherwise only the second run of move_pages would
   succeed. This is one of the special user of gup that like futex is
   doing more than just DMA or obtaining physical address of the page
   to setup a secondary MMU on the virtual memory.

   http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc3/transparent_hugepage-19/pmd_trans_huge_migrate

Let's see if this makes it rock solid..... I loaded it in enough
places that we'll know in a couple of days. I recommend to use this
tree for the benchmarking.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
