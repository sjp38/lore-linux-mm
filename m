Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 6A2176B0044
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 04:05:52 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: thp: fix pmd_bad() triggering in code paths holding mmap_sem read mode
Date: Fri, 16 Mar 2012 04:05:38 -0400
Message-Id: <1331885138-11171-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120315162711.0870c27b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu, Mar 15, 2012 at 04:27:11PM -0700, Andrew Morton wrote:
> On Fri, 16 Mar 2012 00:15:56 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > On Thu, Mar 15, 2012 at 03:45:04PM -0700, Andrew Morton wrote:
> > > Or do we still need pdm_trans_unstable() checking in
> > > mem_cgroup_count_precharge_pte_range() and
> > > mem_cgroup_move_charge_pte_range()?
> > 
> > I think we need a pmd_trans_unstable check before the
> > pte_offset_map_lock in both places.
> >
> > Otherwise with only the mmap_sem
> > hold for reading, the pmd may have been transhuge,
> > mem_cgroup_move_charge_pte_range could be called, and then
> > MADV_DONTNEED would transform the pmd to none from another thread just
> > before pmd_trans_huge_lock runs, and we would end up doing
> > pmd_offset_map_lock on a none pmd (or a transhuge pmd if it becomes
> > huge again before we get there).
>
> page_table_lock doesn't prevent the race?  pmd_trans_huge_lock()
> rechecks after taking that lock...

I'm afraid not.
We hold and unhold page_table_lock inside pmd_trans_huge_lock(), so this
lock does not prevent page fault after pmd_trans_huge_lock(), which means
that there still exists the race window before and pmd_offset_map_lock()
without putting pmd_trans_unstable()s to make sure the race does not happen.

> > Only if pmd_trans_unstable is false, the pmd can't change from under
> > us, so we can proceed safely with the pte level walk (and it just need
> > to be checked with a compiler barrier, as the real pmd changes freely
> > from under us).
> > 
> > pmd_trans_unstable will never actually trigger unless we're hitting
> > the race, if the pmd was none when we started the walk we'd abort at
> > the higher level (method not called), if the pmd was transhuge we'd
> > stop at the pmd_trans_huge_lock() == 1 branch. So the only way to run
> > pmd_trans_unstable is when the result is undefined, i.e. the pmd was
> > not none initially but it become none or transhuge or none again at
> > some point, so we can just simply consider it still none and skip for
> > the undefined case.
> 
> Naoya, could you please take a look into this?

I read the patch and description, and agree that this tricky exclusion
without any explicit locking does work.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
