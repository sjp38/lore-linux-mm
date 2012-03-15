Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 243446B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 19:27:14 -0400 (EDT)
Date: Thu, 15 Mar 2012 16:27:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: thp: fix pmd_bad() triggering in code paths holding
 mmap_sem read mode
Message-Id: <20120315162711.0870c27b.akpm@linux-foundation.org>
In-Reply-To: <20120315231556.GA24602@redhat.com>
References: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
	<20120315154504.0fe15f95.akpm@linux-foundation.org>
	<20120315231556.GA24602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, 16 Mar 2012 00:15:56 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Thu, Mar 15, 2012 at 03:45:04PM -0700, Andrew Morton wrote:
> > Or do we still need pdm_trans_unstable() checking in
> > mem_cgroup_count_precharge_pte_range() and
> > mem_cgroup_move_charge_pte_range()?
> 
> I think we need a pmd_trans_unstable check before the
> pte_offset_map_lock in both places. Otherwise with only the mmap_sem
> hold for reading, the pmd may have been transhuge,
> mem_cgroup_move_charge_pte_range could be called, and then
> MADV_DONTNEED would transform the pmd to none from another thread just
> before pmd_trans_huge_lock runs, and we would end up doing
> pmd_offset_map_lock on a none pmd (or a transhuge pmd if it becomes
> huge again before we get there).

page_table_lock doesn't prevent the race?  pmd_trans_huge_lock()
rechecks after taking that lock...

> Only if pmd_trans_unstable is false, the pmd can't change from under
> us, so we can proceed safely with the pte level walk (and it just need
> to be checked with a compiler barrier, as the real pmd changes freely
> from under us).
> 
> pmd_trans_unstable will never actually trigger unless we're hitting
> the race, if the pmd was none when we started the walk we'd abort at
> the higher level (method not called), if the pmd was transhuge we'd
> stop at the pmd_trans_huge_lock() == 1 branch. So the only way to run
> pmd_trans_unstable is when the result is undefined, i.e. the pmd was
> not none initially but it become none or transhuge or none again at
> some point, so we can just simply consider it still none and skip for
> the undefined case.

Naoya, could you please take a look into this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
