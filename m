Date: Wed, 20 Aug 2008 19:08:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH -mm 7/7] memcg: add page_cgroup.h header file
Message-Id: <20080820190849.ca472102.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, ryov@valinux.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Experimental...I wonder whether this is enough for potential users.
==

page_cgroup is a struct for accounting each page under memory resource
controller. Currently, it's only used under memcontrol.h but there 
is possible user of this struct (now).
(*) Because page_cgroup is an extended/on-demand mem_map by nature,
    there are people who want to use this for recording information.

If no users, this patch is not necessary.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/page_cgroup.h |  100 ++++++++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c             |   82 ------------------------------------
 2 files changed, 101 insertions(+), 81 deletions(-)

Index: mmtom-2.6.27-rc3+/include/linux/page_cgroup.h
===================================================================
--- /dev/null
+++ mmtom-2.6.27-rc3+/include/linux/page_cgroup.h
@@ -0,0 +1,100 @@
+#ifndef __LINUX_PAGE_CGROUP_H
+#define __LINUX_PAGE_CGROUP_H
+
+/*
+ * A page_cgroup page is associated with every page descriptor. The
+ * page_cgroup helps us identify information about the cgroup.
+ *
+ * This is pointed from struct page by page->page_cgroup pointer.
+ * This pointer is safe under RCU. If a page_cgroup is marked as
+ * Obsolete, don't access it.
+ *
+ * Typical way to access page_cgroup is following.
+ *
+ * rcu_read_lock();
+ * pc = page_get_page_cgroup(page);
+ * if (pc && !PcgObsolete(pc)) {
+ *         ......
+ * }
+ * rcu_read_unlock();
+ *
+ */
+struct page_cgroup {
+	struct list_head lru;		/* per zone/memcg LRU list */
+	struct page *page;		/* the page this accounts for */
+	struct mem_cgroup *mem_cgroup;  /* belongs to this mem_cgroup */
+	unsigned long flags;
+	struct page_cgroup *next;
+};
+
+enum {
+	/* flags for mem_cgroup */
+	Pcg_CACHE, /* charged as cache */
+	Pcg_OBSOLETE,	/* this page cgroup is invalid (unused) */
+	/* flags for LRU placement */
+	Pcg_ACTIVE, /* page is active in this cgroup */
+	Pcg_FILE, /* page is file system backed */
+	Pcg_UNEVICTABLE, /* page is unevictableable */
+};
+
+#define TESTPCGFLAG(uname, lname)			\
+static inline int Pcg##uname(struct page_cgroup *pc)	\
+	{ return test_bit(Pcg_##lname, &pc->flags); }
+
+#define SETPCGFLAG(uname, lname)			\
+static inline void SetPcg##uname(struct page_cgroup *pc)\
+	{ set_bit(Pcg_##lname, &pc->flags);  }
+
+#define CLEARPCGFLAG(uname, lname)			\
+static inline void ClearPcg##uname(struct page_cgroup *pc)	\
+	{ clear_bit(Pcg_##lname, &pc->flags);  }
+
+#define __SETPCGFLAG(uname, lname)			\
+static inline void __SetPcg##uname(struct page_cgroup *pc)\
+	{ __set_bit(Pcg_##lname, &pc->flags);  }
+
+#define __CLEARPCGFLAG(uname, lname)			\
+static inline void __ClearPcg##uname(struct page_cgroup *pc)	\
+	{ __clear_bit(Pcg_##lname, &pc->flags);  }
+
+/* Cache flag is set only once (at allocation) */
+TESTPCGFLAG(Cache, CACHE)
+__SETPCGFLAG(Cache, CACHE)
+
+/* No "Clear" routine for OBSOLETE flag */
+TESTPCGFLAG(Obsolete, OBSOLETE);
+SETPCGFLAG(Obsolete, OBSOLETE);
+
+/* LRU management flags (from global-lru definition) */
+TESTPCGFLAG(File, FILE)
+SETPCGFLAG(File, FILE)
+__SETPCGFLAG(File, FILE)
+CLEARPCGFLAG(File, FILE)
+
+TESTPCGFLAG(Active, ACTIVE)
+SETPCGFLAG(Active, ACTIVE)
+__SETPCGFLAG(Active, ACTIVE)
+CLEARPCGFLAG(Active, ACTIVE)
+
+TESTPCGFLAG(Unevictable, UNEVICTABLE)
+SETPCGFLAG(Unevictable, UNEVICTABLE)
+CLEARPCGFLAG(Unevictable, UNEVICTABLE)
+
+
+static int page_cgroup_nid(struct page_cgroup *pc)
+{
+	return page_to_nid(pc->page);
+}
+
+static enum zone_type page_cgroup_zid(struct page_cgroup *pc)
+{
+	return page_zonenum(pc->page);
+}
+
+struct page_cgroup *page_get_page_cgroup(struct page *page)
+{
+	return rcu_dereference(page->page_cgroup);
+}
+
+
+#endif
Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -33,7 +33,7 @@
 #include <linux/seq_file.h>
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
-
+#include <linux/page_cgroup.h>
 #include <asm/uaccess.h>
 
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
@@ -136,81 +136,6 @@ struct mem_cgroup {
 };
 static struct mem_cgroup init_mem_cgroup;
 
-/*
- * A page_cgroup page is associated with every page descriptor. The
- * page_cgroup helps us identify information about the cgroup
- */
-struct page_cgroup {
-	struct list_head lru;		/* per cgroup LRU list */
-	struct page *page;
-	struct mem_cgroup *mem_cgroup;
-	unsigned long flags;
-	struct page_cgroup *next;
-};
-
-enum {
-	/* flags for mem_cgroup */
-	Pcg_CACHE, /* charged as cache */
-	Pcg_OBSOLETE,	/* this page cgroup is invalid (unused) */
-	/* flags for LRU placement */
-	Pcg_ACTIVE, /* page is active in this cgroup */
-	Pcg_FILE, /* page is file system backed */
-	Pcg_UNEVICTABLE, /* page is unevictableable */
-};
-
-#define TESTPCGFLAG(uname, lname)			\
-static inline int Pcg##uname(struct page_cgroup *pc)	\
-	{ return test_bit(Pcg_##lname, &pc->flags); }
-
-#define SETPCGFLAG(uname, lname)			\
-static inline void SetPcg##uname(struct page_cgroup *pc)\
-	{ set_bit(Pcg_##lname, &pc->flags);  }
-
-#define CLEARPCGFLAG(uname, lname)			\
-static inline void ClearPcg##uname(struct page_cgroup *pc)	\
-	{ clear_bit(Pcg_##lname, &pc->flags);  }
-
-#define __SETPCGFLAG(uname, lname)			\
-static inline void __SetPcg##uname(struct page_cgroup *pc)\
-	{ __set_bit(Pcg_##lname, &pc->flags);  }
-
-#define __CLEARPCGFLAG(uname, lname)			\
-static inline void __ClearPcg##uname(struct page_cgroup *pc)	\
-	{ __clear_bit(Pcg_##lname, &pc->flags);  }
-
-/* Cache flag is set only once (at allocation) */
-TESTPCGFLAG(Cache, CACHE)
-__SETPCGFLAG(Cache, CACHE)
-
-/* No "Clear" routine for OBSOLETE flag */
-TESTPCGFLAG(Obsolete, OBSOLETE);
-SETPCGFLAG(Obsolete, OBSOLETE);
-
-/* LRU management flags (from global-lru definition) */
-TESTPCGFLAG(File, FILE)
-SETPCGFLAG(File, FILE)
-__SETPCGFLAG(File, FILE)
-CLEARPCGFLAG(File, FILE)
-
-TESTPCGFLAG(Active, ACTIVE)
-SETPCGFLAG(Active, ACTIVE)
-__SETPCGFLAG(Active, ACTIVE)
-CLEARPCGFLAG(Active, ACTIVE)
-
-TESTPCGFLAG(Unevictable, UNEVICTABLE)
-SETPCGFLAG(Unevictable, UNEVICTABLE)
-CLEARPCGFLAG(Unevictable, UNEVICTABLE)
-
-
-static int page_cgroup_nid(struct page_cgroup *pc)
-{
-	return page_to_nid(pc->page);
-}
-
-static enum zone_type page_cgroup_zid(struct page_cgroup *pc)
-{
-	return page_zonenum(pc->page);
-}
 
 /*
  * per-cpu slot for freeing page_cgroup in lazy manner.
@@ -303,11 +228,6 @@ static void page_assign_page_cgroup(stru
 	rcu_assign_pointer(page->page_cgroup, pc);
 }
 
-struct page_cgroup *page_get_page_cgroup(struct page *page)
-{
-	return rcu_dereference(page->page_cgroup);
-}
-
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
 			struct page_cgroup *pc)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
