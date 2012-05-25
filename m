Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E25726B0102
	for <linux-mm@kvack.org>; Fri, 25 May 2012 13:03:21 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 30/35] autonuma: reset autonuma page data when pages are freed
Date: Fri, 25 May 2012 19:02:34 +0200
Message-Id: <1337965359-29725-31-git-send-email-aarcange@redhat.com>
In-Reply-To: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

When pages are freed abort any pending migration. If knuma_migrated
arrives first it will notice because get_page_unless_zero would fail.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/page_alloc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3d1ee70..1d3163f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -614,6 +614,10 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page);
 		return 1;
 	}
+	autonuma_migrate_page_remove(page);
+#ifdef CONFIG_AUTONUMA
+	ACCESS_ONCE(page->autonuma_last_nid) = -1;
+#endif
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
