Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 0C0516B0010
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 12:12:42 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/6] mm: numa: Handle side-effects in count_vm_numa_events() for !CONFIG_NUMA_BALANCING
Date: Tue, 22 Jan 2013 17:12:39 +0000
Message-Id: <1358874762-19717-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1358874762-19717-1-git-send-email-mgorman@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The current definitions for count_vm_numa_events() is wrong for
!CONFIG_NUMA_BALANCING as the following would miss the side-effect.

	count_vm_numa_events(NUMA_FOO, bar++);

There are no such users of count_vm_numa_events() but it is a potential
pitfall. This patch fixes it and converts count_vm_numa_event() so that
the definitions look similar.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/vmstat.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index a13291f..5fd71a7 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -85,7 +85,7 @@ static inline void vm_events_fold_cpu(int cpu)
 #define count_vm_numa_events(x, y) count_vm_events(x, y)
 #else
 #define count_vm_numa_event(x) do {} while (0)
-#define count_vm_numa_events(x, y) do {} while (0)
+#define count_vm_numa_events(x, y) do { (void)(y); } while (0)
 #endif /* CONFIG_NUMA_BALANCING */
 
 #define __count_zone_vm_events(item, zone, delta) \
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
