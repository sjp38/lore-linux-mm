Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 81A296B00DF
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:52:34 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 30/33] autonuma: bugcheck page_autonuma fields on newly allocated pages
Date: Thu,  4 Oct 2012 01:51:12 +0200
Message-Id: <1349308275-2174-31-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Debug tweak.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma.h |   15 +++++++++++++++
 mm/page_alloc.c          |    3 ++-
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/include/linux/autonuma.h b/include/linux/autonuma.h
index 274c616..9cd94cc 100644
--- a/include/linux/autonuma.h
+++ b/include/linux/autonuma.h
@@ -18,6 +18,20 @@ static inline void autonuma_free_page(struct page *page)
 		lookup_page_autonuma(page)->autonuma_last_nid = -1;
 }
 
+static inline int autonuma_check_new_page(struct page *page)
+{
+	struct page_autonuma *page_autonuma;
+	int ret = 0;
+	if (autonuma_possible()) {
+		page_autonuma = lookup_page_autonuma(page);
+		if (unlikely(page_autonuma->autonuma_last_nid != -1)) {
+			ret = 1;
+			WARN_ON(1);
+		}
+	}
+	return ret;
+}
+
 #define autonuma_printk(format, args...) \
 	if (autonuma_debug()) printk(format, ##args)
 
@@ -29,6 +43,7 @@ static inline void autonuma_migrate_split_huge_page(struct page *page,
 						    struct page *page_tail) {}
 static inline void autonuma_setup_new_exec(struct task_struct *p) {}
 static inline void autonuma_free_page(struct page *page) {}
+static inline int autonuma_check_new_page(struct page *page) { return 0; }
 
 #endif /* CONFIG_AUTONUMA */
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8e6493a..ecb2f8d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -833,7 +833,8 @@ static inline int check_new_page(struct page *page)
 		(page->mapping != NULL)  |
 		(__page_count(page) != 0)  |
 		(page->flags & PAGE_FLAGS_CHECK_AT_PREP) |
-		(mem_cgroup_bad_page_check(page)))) {
+		(mem_cgroup_bad_page_check(page)) |
+		autonuma_check_new_page(page))) {
 		bad_page(page);
 		return 1;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
