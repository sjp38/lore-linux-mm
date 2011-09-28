Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CDABA9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:49:33 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p8S0nUa4003910
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:30 -0700
Received: from iarr31 (iarr31.prod.google.com [10.12.44.31])
	by hpaq14.eem.corp.google.com with ESMTP id p8S0nQRW013361
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:29 -0700
Received: by iarr31 with SMTP id r31so2489367iar.36
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:26 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/9] V2: idle page tracking / working set estimation
Date: Tue, 27 Sep 2011 17:48:58 -0700
Message-Id: <1317170947-17074-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

This is a followup to the prior version of this patchset, which I sent out
on September 16.

I have addressed most of the basic feedback I got so far:

- Renamed struct pr_info -> struct page_referenced_info

- Config option now depends on 64BIT, as we may not have sufficient
  free page flags in 32-bit builds

- Renamed mem -> memcg in kstaled code within memcontrol.c

- Uninlined kstaled_scan_page

- Replaced strict_strtoul -> kstrtoul

- Report PG_stale in /proc/kpageflags

- Fix accounting of THP pages. Sorry for forgeting to do this in the
  V1 patchset - to detail the change here, what I had to do was make sure
  page_referenced() reports THP pages as dirty (as they always are - the
  dirty bit in the pmd is currently meaningless) and update the minimalistic
  implementation change to count THP pages as equivalent to 512 small pages.

- The ugliest parts of patch 6 (rate limit pages scanned per second) have
  been reworked. If the scanning thread gets delayed, it tries to catch up
  so as to minimize jitter. If it can't catch up, it would probably be a
  good idea to increase the scanning interval, but this is left up
  to userspace.

Michel Lespinasse (9):
  page_referenced: replace vm_flags parameter with struct page_referenced_info
  kstaled: documentation and config option.
  kstaled: page_referenced_kstaled() and supporting infrastructure.
  kstaled: minimalistic implementation.
  kstaled: skip non-RAM regions.
  kstaled: rate limit pages scanned per second.
  kstaled: add histogram sampling functionality
  kstaled: add incrementally updating stale page count
  kstaled: export PG_stale in /proc/kpageflags

 Documentation/cgroups/memory.txt  |  103 ++++++++-
 arch/x86/include/asm/page_types.h |    8 +
 arch/x86/kernel/e820.c            |   45 ++++
 fs/proc/page.c                    |    4 +
 include/linux/kernel-page-flags.h |    2 +
 include/linux/ksm.h               |    9 +-
 include/linux/mmzone.h            |   11 +
 include/linux/page-flags.h        |   50 ++++
 include/linux/pagemap.h           |   11 +-
 include/linux/rmap.h              |   82 ++++++-
 mm/Kconfig                        |   10 +
 mm/internal.h                     |    1 +
 mm/ksm.c                          |   15 +-
 mm/memcontrol.c                   |  479 +++++++++++++++++++++++++++++++++++++
 mm/memory_hotplug.c               |    6 +
 mm/mlock.c                        |    1 +
 mm/rmap.c                         |  138 ++++++-----
 mm/swap.c                         |    1 +
 mm/vmscan.c                       |   20 +-
 19 files changed, 899 insertions(+), 97 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
