Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 4E6356B007E
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:27:31 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 12/39] autonuma: add page structure fields
Date: Mon, 26 Mar 2012 19:45:59 +0200
Message-Id: <1332783986-24195-13-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On 64bit archs, 20 bytes are used for async memory migration (specific
to the knuma_migrated per-node threads), and 4 bytes are used for the
thread NUMA false sharing detection logic.

This is a bad implementation due lack of time to do a proper one.

These AutoNUMA new fields must be moved to the pgdat like memcg
does. So that they're only allocated at boot time if the kernel is
booted on NUMA hardware. And so that they're not allocated even if
booted on NUMA hardware if "noautonuma" is passed as boot parameter to
the kernel.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm_types.h |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2567798..0a163bd 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -125,6 +125,31 @@ struct page {
 		struct page *first_page;	/* Compound tail pages */
 	};
 
+#ifdef CONFIG_AUTONUMA
+	/*
+	 * FIXME: move to pgdat section along with the memcg and allocate
+	 * at runtime only in presence of a numa system.
+	 */
+	/*
+	 * To modify autonuma_last_nid lockless the architecture,
+	 * needs SMP atomic granularity < sizeof(long), not all archs
+	 * have that, notably some alpha. Archs without that requires
+	 * autonuma_last_nid to be a long.
+	 */
+#if BITS_PER_LONG > 32
+	int autonuma_migrate_nid;
+	int autonuma_last_nid;
+#else
+#if MAX_NUMNODES >= 32768
+#error "too many nodes"
+#endif
+	/* FIXME: remember to check the updates are atomic */
+	short autonuma_migrate_nid;
+	short autonuma_last_nid;
+#endif
+	struct list_head autonuma_migrate_node;
+#endif
+
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
