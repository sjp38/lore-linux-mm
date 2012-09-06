Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 872E86B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 10:35:40 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH V2 0/2] Enable clients to schedule in mmu_notifier methods
Date: Thu,  6 Sep 2012 17:34:53 +0300
Message-Id: <1346942095-23927-1-git-send-email-haggaie@mellanox.com>
In-Reply-To: <20120904150737.a6774600.akpm@linux-foundation.org>
References: <20120904150737.a6774600.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>

> The following short patch series completes the support for allowing clients to
> sleep in mmu notifiers (specifically in invalidate_page and
> invalidate_range_start/end), adding on the work done by Andrea Arcangeli and
> Sagi Grimberg in http://marc.info/?l=linux-mm&m=133113297028676&w=3
>
> This patchset is a preliminary step towards on-demand paging design to be
> added to the Infiniband stack. Our goal is to avoid pinning pages in
> memory regions registered for IB communication, so we need to get
> notifications for invalidations on such memory regions, and stop the hardware
> from continuing its access to the invalidated pages. The hardware operation
> that flushes the page tables can block, so we need to sleep until the hardware
> is guaranteed not to access these pages anymore.
>
> The first patch moves the mentioned notifier functions out of the PTL, and the
> second patch changes the change_pte notification to stop calling
> invalidate_page as a default.

On Wed, 5 Sep 2012 01:07:42 +0300, Andrew Morton wrote:
> On Tue,  4 Sep 2012 11:41:20 +0300
> Haggai Eran <haggaie@mellanox.com> wrote:
>> @@ -1405,6 +1414,9 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>>  	if (!pmd_present(*pmd))
>>  		return ret;
>>  
>> +	start = address;
>> +	mmu_notifier_invalidate_range_start(mm, start, end);
> `end' is used uninitialised in this function.

I don't think it is. You might think so because the patch didn't initialize it
itself - it was already defined in this function. Anyway, to make it more clear
I've used your suggested convention with mmun_start/end in this function as
well as the others.

> I'm surprised that it didn't generate a warning(?) and I worry about
> the testing coverage?

I tried to test these patches by writing a small module that registered as an
mmu notifiers client. The module used might_sleep() in each notifier to verify
that it was called from a sleepable context. I then used a set of user space
tests that attempted to invoke various mmu notifiers. I had tests for:
* munmap
* fork and copy-on-write breaking (either with regular pages or huge pages)
* swapping out regular pages
* swapping out a nonlinear vma
* madvise with MADV_DONTNEED and with MADV_REMOVE
* KSM
* mremap
* mprotect
* transparent huge pages

The module exported the notifications to the user space programs, and it
checked that range invalidations came in matching pairs of begin and end,
but only after you wrote about the bug in V1 I noticed that I didn't have a
test for transparent huge pages COW breaking where the new huge page allocation
fails (do_huge_pmd_wp_page_fallback). Before sending V2 I've added a new test
for that, using fail_page_alloc.

Changes from V1:
- Add the motivation for on-demand paging in patch 1 changelog.

- Fix issues in patch 1 where invalidate_range_begin and invalidate_range_end
  are called with different arguments.

- Used the convention Andrew suggested in both patches to make it a little
  harder for such bugs to be introduced in the future.

- Dropped changes in patch 1 that moved calls to ptep_clear_flush_young_notify
  out of the PTL. The patch doesn't intend to make clear_flush_young
  notification sleepable, only invalidate_range_begin/end and invalidate_page.

Changes from V0:
- Fixed a bug in patch 1 that prevented compilation without MMU notifiers.
- Dropped the patches 2 and 3 that were moving tlb_gather_mmu calls.
- Added a patch to handle invalidate_page being called from change_pte.

Haggai Eran (1):
  mm: Wrap calls to set_pte_at_notify with invalidate_range_start and
    invalidate_range_end

Sagi Grimberg (1):
  mm: Move all mmu notifier invocations to be done outside the PT lock

 include/linux/mmu_notifier.h | 47 --------------------------------------------
 kernel/events/uprobes.c      |  5 +++++
 mm/filemap_xip.c             |  4 +++-
 mm/huge_memory.c             | 42 +++++++++++++++++++++++++++++++++------
 mm/hugetlb.c                 | 21 ++++++++++++--------
 mm/ksm.c                     | 21 ++++++++++++++++++--
 mm/memory.c                  | 25 ++++++++++++++++++-----
 mm/mmu_notifier.c            |  6 ------
 mm/mremap.c                  |  8 ++++++--
 mm/rmap.c                    | 18 ++++++++++++++---
 10 files changed, 117 insertions(+), 80 deletions(-)

-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
