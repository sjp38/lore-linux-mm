Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 3850E6B005D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 08:48:48 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 0/6] Avoid cache trashing on clearing huge/gigantic page
Date: Fri, 20 Jul 2012 15:50:16 +0300
Message-Id: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Clearing a 2MB huge page will typically blow away several levels of CPU
caches.  To avoid this only cache clear the 4K area around the fault
address and use a cache avoiding clears for the rest of the 2MB area.

It would be nice to test the patchset with more workloads. Especially if
you see performance regression with THP.

Any feedback is appreciated.

Andi Kleen (6):
  THP: Use real address for NUMA policy
  mm: make clear_huge_page tolerate non aligned address
  THP: Pass real, not rounded, address to clear_huge_page
  x86: Add clear_page_nocache
  mm: make clear_huge_page cache clear only around the fault address
  x86: switch the 64bit uncached page clear to SSE/AVX v2

 arch/x86/include/asm/page.h          |    2 +
 arch/x86/include/asm/string_32.h     |    5 ++
 arch/x86/include/asm/string_64.h     |    5 ++
 arch/x86/lib/Makefile                |    1 +
 arch/x86/lib/clear_page_nocache_32.S |   30 +++++++++++
 arch/x86/lib/clear_page_nocache_64.S |   92 ++++++++++++++++++++++++++++++++++
 arch/x86/mm/fault.c                  |    7 +++
 mm/huge_memory.c                     |   17 +++---
 mm/memory.c                          |   29 ++++++++++-
 9 files changed, 178 insertions(+), 10 deletions(-)
 create mode 100644 arch/x86/lib/clear_page_nocache_32.S
 create mode 100644 arch/x86/lib/clear_page_nocache_64.S

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
