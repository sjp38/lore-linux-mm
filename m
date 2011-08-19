Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 19CD16B016B
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:48:58 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p7J7mth1030576
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:55 -0700
Received: from gyg13 (gyg13.prod.google.com [10.243.50.141])
	by hpaq11.eem.corp.google.com with ESMTP id p7J7mn1J004910
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:54 -0700
Received: by gyg13 with SMTP id 13so2632091gyg.21
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:49 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/9] Use RCU to stabilize page counts
Date: Fri, 19 Aug 2011 00:48:22 -0700
Message-Id: <1313740111-27446-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

include/linux/pagemap.h describes the protocol one should use to get pages
from page cache - one can't know if the reference they get will be on the
desired page, so newly allocated pages might see elevated reference counts,
but using RCU this effect can be limited in time to one RCU grace period.

For this protocol to work, every call site of get_page_unless_zero() has to
participate, and this was not previously enforced.

Patches 1-3 convert some get_page_unless_zero() call sites to use the proper
RCU protocol as described in pagemap.h

Patches 4-5 convert some get_page_unless_zero() call sites to just call
get_page()

Patch 6 asserts that every remaining get_page_unless_zero() call site should
participate in the RCU protocol. Well, not actually all of them -
__isolate_rcu_page() is exempted because it holds the zone LRU lock which
would prevent the given page from getting entirely freed, and a few others
related to hwpoison, memory hotplug and memory failure are exempted because
I haven't been able to figure out what to do.

Patch 7 is a placeholder for an RCU API extension we have been talking about
with Paul McKenney. The idea is to record an initial time as an opaque cookie,
and to be able to determine later on if an rcu grace period has elapsed since
that initial time.

Patch 8 adds wrapper functions to store an RCU cookie into compound pages.

Patch 9 makes use of new RCU API, as well as the prior fixes from patches 1-6,
to ensure tail page counts are stable while we split THP pages. This fixes a
(rather theorical, not actually been observed) race condition where THP page
splitting could result in incorrect page counts if THP page allocation and
splitting both occur while another thread tries to run get_page_unless_zero
on a single page that got re-allocated as THP tail page.


The patches have received only a limited amount of testing; however I
believe patches 1-6 to be sane and I would like them to get more
exposure, maybe as part of andrew's -mm tree.


Besides that, this proposal is also to sync up with Paul regarding the RCU
functionality :)


Michel Lespinasse (9):
  mm: rcu read lock for getting reference on pages in
    migration_entry_wait()
  mm: avoid calling get_page_unless_zero() when charging cgroups
  mm: rcu read lock when getting from tail to head page
  mm: use get_page in deactivate_page()
  kvm: use get_page instead of get_page_unless_zero
  mm: assert that get_page_unless_zero() callers hold the rcu lock
  rcu: rcu_get_gp_cookie() / rcu_gp_cookie_elapsed() stand-ins
  mm: add API for setting a grace period cookie on compound pages
  mm: make sure tail page counts are stable before splitting THP pages

 arch/x86/kvm/mmu.c       |    3 +--
 include/linux/mm.h       |   38 +++++++++++++++++++++++++++++++++++++-
 include/linux/mm_types.h |    6 +++++-
 include/linux/pagemap.h  |    1 +
 include/linux/rcupdate.h |   35 +++++++++++++++++++++++++++++++++++
 mm/huge_memory.c         |   33 +++++++++++++++++++++++++++++----
 mm/hwpoison-inject.c     |    2 +-
 mm/ksm.c                 |    4 ++++
 mm/memcontrol.c          |   20 ++++++++++----------
 mm/memory-failure.c      |    6 +++---
 mm/memory_hotplug.c      |    2 +-
 mm/migrate.c             |    3 +++
 mm/page_alloc.c          |    1 +
 mm/swap.c                |   22 ++++++++++++++--------
 mm/vmscan.c              |    7 ++++++-
 15 files changed, 151 insertions(+), 32 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
