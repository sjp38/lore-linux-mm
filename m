Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 31E8C6B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 06:46:55 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o89Aki03010747
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 06:46:44 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o89Aknux1773806
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 06:46:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o89Akmkw004811
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 07:46:49 -0300
Date: Thu, 9 Sep 2010 16:16:30 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Transparent Hugepage Support #30
Message-ID: <20100909104630.GO4443@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100901190859.GA20316@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100901190859.GA20316@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

* Andrea Arcangeli <aarcange@redhat.com> [2010-09-01 21:08:59]:

> http://www.linux-kvm.org/wiki/images/9/9e/2010-forum-thp.pdf
> 
> http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog
> 
> first: git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
> or first: git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
> later: git fetch; git checkout -f origin/master
> 
> The tree is rebased and git pull won't work.
> 
> http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.36-rc3/transparent_hugepage-30/
> http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.36-rc3/transparent_hugepage-30.gz
> 
> Diff #29 -> #30:
> 
>  b/compaction-migration-warning               |   25 +++
> 
> Avoid MIGRATION config warning when COMPACTION is selected but numa
> and memhotplug aren't.
> 
>  do_swap_page-VM_FAULT_WRITE                  |   21 --
>  kvm-huge-spte-wrprotect                      |   48 ------
>  kvm-mmu-notifier-huge-spte                   |   29 ---
>  root_anon_vma-anon_vma_lock                  |  208 ---------------------------
>  root_anon_vma-avoid-ksm-hang                 |   30 ---
>  root_anon_vma-bugchecks                      |   37 ----
>  root_anon_vma-in_vma                         |   27 ---
>  root_anon_vma-ksm_refcount                   |  169 ---------------------
>  root_anon_vma-lock_root                      |  127 ----------------
>  root_anon_vma-memory-compaction              |   36 ----
>  root_anon_vma-mm_take_all_locks              |   81 ----------
>  root_anon_vma-oldest_root                    |   81 ----------
>  root_anon_vma-refcount                       |   29 ---
>  root_anon_vma-swapin                         |   91 -----------
>  root_anon_vma-use-root                       |   66 --------
>  root_anon_vma-vma_lock_anon_vma              |   94 ------------
> 
> merged upstream.
> 
>  b/memcg_compound                             |  166 ++++++++++-----------
>  b/memcg_compound_tail                        |   31 +---
>  b/memcg_consume_stock                        |   31 ++--
>  memcg_check_room                             |   88 -----------
>  memcg_oom                                    |   34 ----
> 
> These had heavy rejects, the last two patches and other bits got
> removed. memcg code is rewritten so fast it's hard to justify to keep
> up with it. It's simpler and less time consuming to fix it just once
> than over and over again. Likely memcg in this release isn't too
> stable with THP on (it'll definitely work fine if you disable THP at
> compile time or at boot time with the kernel parameter). Especially
> all get_css/put_css will have to be re-audited after these new
> changes. For now it builds just fine and the basics to support THP and
> to show the direction are in. Nevertheless I welcome patches to fix
> this up.
> 
> btw, memcg developers could already support THP inside memcg even if
> THP is not included yet without any sort of problem, so it's also

Could you elaborate by what you mean here?

> partly up to them to want to support THP in memcg, but it's also
> perfectly ok to catch up with memcg externally, but it'd be also nice
> to know when memcg reaches a milestone and so when it's time to
> re-audit it all for THP.
>

We try not to change too drastically, but several of the current
changes are fixes, we are currently contemplating some more changes to
support the I/O control. Some of the recent changes have been driven
by tracing. We will pay closer attention to THP changes, thanks for
bring your concern to our notice.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
