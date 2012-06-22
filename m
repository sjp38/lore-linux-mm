Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id EF8526B014D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 03:42:02 -0400 (EDT)
Received: by wgbds1 with SMTP id ds1so476548wgb.2
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 00:42:00 -0700 (PDT)
Date: Fri, 22 Jun 2012 09:41:56 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [patch 3.5-rc3] mm, mempolicy: fix mbind() to do synchronous
 migration
Message-ID: <20120622074156.GA23682@gmail.com>
References: <alpine.DEB.2.00.1206201758500.3068@chino.kir.corp.google.com>
 <20120621164606.4ae1a71d.akpm@linux-foundation.org>
 <CA+55aFzPXMD3N3Oy-om6utDCQYmrBDnDgdqpVC5cgKe-v6uZ3w@mail.gmail.com>
 <20120621184536.6dd97746.akpm@linux-foundation.org>
 <20120622071243.GB22167@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120622071243.GB22167@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>


* Ingo Molnar <mingo@kernel.org> wrote:

> > I do still ask what the plans are for that patchset..
> 
> Somewhat off topic, but the main sched/numa objections were 
> over the mbind/etc. syscalls and the extra configuration space 
> - we dropped those bits and just turned it all into an 
> improved NUMA scheduling feature, as suggested by Peter and me 
> in the original discussion.
> 
> There were no objections to that approach so the reworked NUMA 
> scheduling/balancing scheme is now in the scheduler tree 
> (tip:sched/core).
> 
> The mbind/etc. syscall changes and all the related cleanups, 
> speedups and reorganization of the MM code are still in limbo.
> 
> I dropped them with the rest of tip:sched/numa as nobody from 
> the MM side expressed much interest in them and I wanted to 
> keep things simple and not carry objected-to commits.

>From your mail it appears that you weren't aware that this was 
all queued up (clearly our fault) - so here's a quick status 
dump, please let us know what you think and whether we can keep 
them.

The ones with mm/ effect that we kept are these, which are 
needed for scheduler directed opportunistic/lazy memory 
migration between nodes:

 e9941dae8708 mm/mpol: Lazy migrate a process/vma
 a9ea2f1e496e mm/mpol: Make mempolicy home-node aware
 5dca4a911980 mm/mpol: Split and explose some mempolicy functions
 f1b39afe3e55 mm/mpol: Introduce vma_put_policy()
 9fc52f506a4e mm/mpol: Introduce vma_dup_policy()
 6494a5f2cb89 mm/mpol: Simplify do_mbind()
 65699050e8aa mm: Handle misplaced anon pages
 4783af477d3d mm: Migrate misplaced page
 147c5c460202 mm/mpol: Check for misplaced page
 84f1e3478238 mm/mpol: Add MPOL_MF_NOOP
 68d9661d42bf mm/mpol: Add MPOL_MF_LAZY ...
 03ed7b538ca0 mm/mpol: Make MPOL_LOCAL a real policy
 e975d6ac08f3 mm/mpol: Remove NUMA_INTERLEAVE_HIT
 8c41549ed1b3 mm/mpol: Re-implement check_*_range() using walk_page_range()
 2ab41dd59922 mm: Optimize put_mems_allowed() usage

Or with diffstats:

e9941dae8708 mm/mpol: Lazy migrate a process/vma
 mm/mempolicy.c |   84 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 84 insertions(+)

a9ea2f1e496e mm/mpol: Make mempolicy home-node aware
 mm/mempolicy.c |   29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

5dca4a911980 mm/mpol: Split and explose some mempolicy functions
 mm/mempolicy.c |  111 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 63 insertions(+), 48 deletions(-)

f1b39afe3e55 mm/mpol: Introduce vma_put_policy()
 mm/mempolicy.c |    5 +++++
 mm/mmap.c      |    8 ++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

9fc52f506a4e mm/mpol: Introduce vma_dup_policy()
 mm/mempolicy.c |   11 +++++++++++
 mm/mmap.c      |   17 +++++------------
 2 files changed, 16 insertions(+), 12 deletions(-)

6494a5f2cb89 mm/mpol: Simplify do_mbind()
 mm/mempolicy.c |   73 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 38 insertions(+), 35 deletions(-)

65699050e8aa mm: Handle misplaced anon pages
 mm/memory.c   |   17 +++++++++++++++++
 mm/swapfile.c |   13 +++++++++++++
 2 files changed, 30 insertions(+)

4783af477d3d mm: Migrate misplaced page
 mm/mempolicy.c |   19 +++++++++
 mm/migrate.c   |  130 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 148 insertions(+), 1 deletion(-)

147c5c460202 mm/mpol: Check for misplaced page
 mm/mempolicy.c |   79 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 79 insertions(+)

84f1e3478238 mm/mpol: Add MPOL_MF_NOOP
 mm/mempolicy.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

68d9661d42bf mm/mpol: Add MPOL_MF_LAZY ...
 mm/mempolicy.c |   20 +++++++-----
 mm/migrate.c   |   96 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 mm/rmap.c      |    6 ++--
 3 files changed, 109 insertions(+), 13 deletions(-)

03ed7b538ca0 mm/mpol: Make MPOL_LOCAL a real policy
 mm/mempolicy.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

e975d6ac08f3 mm/mpol: Remove NUMA_INTERLEAVE_HIT
 mm/mempolicy.c |   68 +++++++++++++++++---------------------------------------
 1 file changed, 21 insertions(+), 47 deletions(-)

8c41549ed1b3 mm/mpol: Re-implement check_*_range() using walk_page_range()
 mm/mempolicy.c |  141 ++++++++++++++++++--------------------------------------
 1 file changed, 45 insertions(+), 96 deletions(-)

2ab41dd59922 mm: Optimize put_mems_allowed() usage
 mm/filemap.c    |    4 ++--
 mm/hugetlb.c    |    4 ++--
 mm/mempolicy.c  |   14 +++++++-------
 mm/page_alloc.c |    8 ++++----
 mm/slab.c       |    4 ++--
 mm/slub.c       |   16 +++-------------
 6 files changed, 20 insertions(+), 30 deletions(-)

These are mostly lazy migration facility enablers. On a second 
note, should we internalize MPOL_MF_LAZY as well, to not expose 
it to user-space?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
