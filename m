Subject: [RFC][PATCH 5/5] RSS accounting at the page level
Message-Id: <20070205132846.6E1911B676@openx4.frec.bull.fr>
Date: Mon, 5 Feb 2007 14:28:46 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, menage@google.com
List-ID: <linux-mm.kvack.org>

Add accounting at the page level.

Signed-off-by: Patrick Le Dot <Patrick.Le-Dot@bull.net>
---

 include/linux/mm_types.h   |   12 +++++
 kernel/res_group/memctlr.c |   98 +++++++++++++++++++++++++++++++++++----------
 2 files changed, 90 insertions(+), 20 deletions(-)

diff -puN a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h	2006-12-12 13:39:19.000000000 +0100
+++ b/include/linux/mm_types.h	2006-12-11 10:47:22.000000000 +0100
@@ -6,6 +6,14 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 
+#ifdef CONFIG_RES_GROUPS_MEMORY
+struct rg_shared_pg_cnt {
+	unsigned long rg_bit_id;	/* rgroup id */
+	atomic_t count;			/* 1 counter per shared page per rgroup */
+	struct rg_shared_pg_cnt *next;	/* another rgroup use the page */
+};
+#endif /* CONFIG_RES_GROUPS_MEMORY */
+
 struct address_space;
 
 /*
@@ -62,6 +70,10 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
+#ifdef CONFIG_RES_GROUPS_MEMORY
+	unsigned long rg_bitmap;		/* 1 bit per rgroup using this page */
+	struct rg_shared_pg_cnt *shared_count;	/* and 1 counter per rgroup */
+#endif /* CONFIG_RES_GROUPS_MEMORY */
 };
 
 #endif /* _LINUX_MM_TYPES_H */
diff -puN a/kernel/res_group/memctlr.c b/kernel/res_group/memctlr.c
--- a/kernel/res_group/memctlr.c	2006-12-12 13:20:24.000000000 +0100
+++ b/kernel/res_group/memctlr.c	2006-12-12 12:57:30.000000000 +0100
@@ -42,6 +42,12 @@ static const char res_ctlr_name[] = "mem
 static struct resource_group *root_rgroup;
 static const char version[] = "0.01";
 static struct memctlr *memctlr_root;
+static unsigned long rg_bitmap_shift_index = 0;
+
+/*
+ * first implementation : use a global lock
+ */
+static spinlock_t memctlr_lock;
 
 /*
  * this struct is used in mm_struct
@@ -56,6 +62,7 @@ struct mem_counter {
 struct memctlr {
 	struct res_shares shares;	/* My shares		  */
 	struct mem_counter counter;	/* Accounting information */
+	unsigned long bit_id;		/* rgroup_id bitmap : only 1 bit on  */
 	spinlock_t lock;
 };
 
@@ -120,10 +127,17 @@ static inline struct memctlr *get_task_m
 	return res;
 }
 
+void memctlr_inc_rss(struct page *page)
+{
+	struct mm_struct *mm = current->mm;
+
+	memctlr_inc_rss_mm(page, mm);
+}
 
 void memctlr_inc_rss_mm(struct page *page, struct mm_struct *mm)
 {
 	struct memctlr *res;
+	struct rg_shared_pg_cnt *shared_pg_cnt;
 
 	res = get_task_memctlr(current);
 	if (!res) {
@@ -131,32 +145,44 @@ void memctlr_inc_rss_mm(struct page *pag
 		return;
 	}
 
-	spin_lock(&res->lock);
-	atomic_long_inc(&current->mm->counter->rss);
-	atomic_long_inc(&res->counter.rss);
-	spin_unlock(&res->lock);
-}
-
-void memctlr_inc_rss(struct page *page)
-{
-	struct memctlr *res;
-	struct mm_struct *mm = current->mm;
+	spin_lock(&memctlr_lock);
 
-	res = get_task_memctlr(current);
-	if (!res) {
-		printk(KERN_INFO "inc_rss no res set *---*\n");
-		return;
+	if ((page->rg_bitmap & res->bit_id) != 0) {
+		/* search the counter for this rgroup */
+		shared_pg_cnt = page->shared_count;
+		while (shared_pg_cnt != NULL) {
+			if (shared_pg_cnt->rg_bit_id == res->bit_id) {
+				atomic_inc(&shared_pg_cnt->count);
+				spin_unlock(&memctlr_lock);
+				return;
+			}
+			shared_pg_cnt = shared_pg_cnt->next;
+		}
+		/* should never get here */
+		BUG();
 	}
 
-	spin_lock(&res->lock);
+	/* first mapping for this rgroup : add a new counter */
+	shared_pg_cnt = kzalloc(sizeof(struct rg_shared_pg_cnt), GFP_ATOMIC);
+	shared_pg_cnt->rg_bit_id = res->bit_id;
+	atomic_set(&shared_pg_cnt->count, 1);
+
+	shared_pg_cnt->next = page->shared_count;
+	page->shared_count = shared_pg_cnt;
+
+	page->rg_bitmap = (page->rg_bitmap ^ res->bit_id);
+
 	atomic_long_inc(&mm->counter->rss);
 	atomic_long_inc(&res->counter.rss);
-	spin_unlock(&res->lock);
+
+	spin_unlock(&memctlr_lock);
 }
 
 void memctlr_dec_rss_mm(struct page *page, struct mm_struct *mm)
 {
 	struct memctlr *res;
+	struct rg_shared_pg_cnt *shared_pg_cnt;
+	struct rg_shared_pg_cnt *previous = NULL;
 
 	res = get_task_memctlr(current);
 	if (!res) {
@@ -164,10 +190,36 @@ void memctlr_dec_rss_mm(struct page *pag
 		return;
 	}
 
-	spin_lock(&res->lock);
-	atomic_long_dec(&res->counter.rss);
-	atomic_long_dec(&mm->counter->rss);
-	spin_unlock(&res->lock);
+	spin_lock(&memctlr_lock);
+	shared_pg_cnt = page->shared_count;
+
+	while (shared_pg_cnt != NULL) {
+		if (shared_pg_cnt->rg_bit_id == res->bit_id) {
+			atomic_dec(&shared_pg_cnt->count);
+
+			if (atomic_read(&shared_pg_cnt->count) == 0) {
+				/* this group don't use this page anymore */
+				/* remove the rg_shared_pg_cnt struct from the list */
+				if (previous != NULL)
+					previous->next = shared_pg_cnt->next;
+				else
+					page->shared_count = NULL;
+				/* and free it */
+				kfree(shared_pg_cnt);
+				/* remove the rgroup from the page bitmap */
+				page->rg_bitmap = (page->rg_bitmap & ~res->bit_id);
+
+				atomic_long_dec(&res->counter.rss);
+				atomic_long_dec(&mm->counter->rss);
+			}
+			spin_unlock(&memctlr_lock);
+			return;
+		}
+		previous = shared_pg_cnt;
+		shared_pg_cnt = shared_pg_cnt->next;
+	}
+	/* should never get here */
+	BUG();
 }
 
 static void memctlr_init_new(struct memctlr *res)
@@ -176,6 +228,7 @@ static void memctlr_init_new(struct memc
 	res->shares.max_shares = SHARE_DONT_CARE;
 	res->shares.child_shares_divisor = SHARE_DEFAULT_DIVISOR;
 	res->shares.unused_min_shares = SHARE_DEFAULT_DIVISOR;
+	res->bit_id = (1 << rg_bitmap_shift_index);
 
 	memctlr_init_mem_counter(&res->counter);
 	spin_lock_init(&res->lock);
@@ -189,6 +242,7 @@ static struct res_shares *memctlr_alloc_
 	if (!res)
 		return NULL;
 	memctlr_init_new(res);
+	rg_bitmap_shift_index++;	/* overflow TBC */
 	if (is_res_group_root(rgroup)) {
 		root_rgroup = rgroup;
 		memctlr_root = res;
@@ -386,6 +440,9 @@ static void memctlr_move_task(struct tas
	if (p->pid != p->tgid)
		return;

+	printk("memctlr_move_task not yet available \n");
+	return;
+
	oldres = get_memctlr_from_shares(old);
	newres = get_memctlr_from_shares(new);

@@ -414,6 +471,7 @@ int __init memctlr_init(void)
 {
 	if (memctlr_rg.ctlr_id != NO_RES_ID)
 		return -EBUSY;	/* already registered */
+	spin_lock_init(&memctlr_lock);
 	return register_controller(&memctlr_rg);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
