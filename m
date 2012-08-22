Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 9642C6B0074
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:09 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 30/36] autonuma: bugcheck page_autonuma fields on newly allocated pages
Date: Wed, 22 Aug 2012 16:59:14 +0200
Message-Id: <1345647560-30387-31-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Debug tweak.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma.h |   19 +++++++++++++++++++
 mm/page_alloc.c          |    3 ++-
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/include/linux/autonuma.h b/include/linux/autonuma.h
index 1d87ecc..8a779e0 100644
--- a/include/linux/autonuma.h
+++ b/include/linux/autonuma.h
@@ -29,6 +29,24 @@ static inline void autonuma_free_page(struct page *page)
 	}
 }
 
+static inline int autonuma_check_new_page(struct page *page)
+{
+	struct page_autonuma *page_autonuma;
+	int ret = 0;
+	if (autonuma_possible()) {
+		page_autonuma = lookup_page_autonuma(page);
+		if (unlikely(page_autonuma->autonuma_migrate_nid != -1)) {
+			ret = 1;
+			WARN_ON(1);
+		}
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
 
@@ -41,6 +59,7 @@ static inline void autonuma_migrate_split_huge_page(struct page *page,
 						    struct page *page_tail) {}
 static inline void autonuma_setup_new_exec(struct task_struct *p) {}
 static inline void autonuma_free_page(struct page *page) {}
+static inline int autonuma_check_new_page(struct page *page) { return 0; }
 
 #endif /* CONFIG_AUTONUMA */
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 74b73fa..87a4d5b 100644
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
