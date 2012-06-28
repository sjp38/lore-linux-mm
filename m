Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 60B5A6B0083
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:57:04 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 39/40] autonuma: bugcheck page_autonuma fields on newly allocated pages
Date: Thu, 28 Jun 2012 14:56:19 +0200
Message-Id: <1340888180-15355-40-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Debug tweak.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma.h |   11 +++++++++++
 mm/page_alloc.c          |    1 +
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/autonuma.h b/include/linux/autonuma.h
index 67af86a..05bd8c1 100644
--- a/include/linux/autonuma.h
+++ b/include/linux/autonuma.h
@@ -29,6 +29,16 @@ static inline void autonuma_free_page(struct page *page)
 	}
 }
 
+static inline void autonuma_check_new_page(struct page *page)
+{
+	struct page_autonuma *page_autonuma;
+	if (!autonuma_impossible()) {
+		page_autonuma = lookup_page_autonuma(page);
+		BUG_ON(page_autonuma->autonuma_migrate_nid != -1);
+		BUG_ON(page_autonuma->autonuma_last_nid != -1);
+	}
+}
+
 #define autonuma_printk(format, args...) \
 	if (autonuma_debug()) printk(format, ##args)
 
@@ -41,6 +51,7 @@ static inline void autonuma_migrate_split_huge_page(struct page *page,
 						    struct page *page_tail) {}
 static inline void autonuma_setup_new_exec(struct task_struct *p) {}
 static inline void autonuma_free_page(struct page *page) {}
+static inline void autonuma_check_new_page(struct page *page) {}
 
 #endif /* CONFIG_AUTONUMA */
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2d53a1f..5943ed2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -833,6 +833,7 @@ static inline int check_new_page(struct page *page)
 		bad_page(page);
 		return 1;
 	}
+	autonuma_check_new_page(page);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
