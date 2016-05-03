Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 101DD6B0005
	for <linux-mm@kvack.org>; Mon,  2 May 2016 21:58:13 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id rd14so12865920obb.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 18:58:13 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id dy10si8997066igb.102.2016.05.02.18.58.11
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 18:58:12 -0700 (PDT)
Date: Tue, 3 May 2016 10:58:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 11/12] zsmalloc: page migration support
Message-ID: <20160503015810.GA3642@bbox>
References: <1461743305-19970-1-git-send-email-minchan@kernel.org>
 <1461743305-19970-12-git-send-email-minchan@kernel.org>
 <5727E3BC.8070308@samsung.com>
 <20160503004359.GA2272@bbox>
 <572801FA.4090304@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <572801FA.4090304@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, May 03, 2016 at 10:42:18AM +0900, Chulmin Kim wrote:
> On 2016e?? 05i?? 03i? 1/4  09:43, Minchan Kim wrote:
> >Good morning, Chulmin
> >
> >On Tue, May 03, 2016 at 08:33:16AM +0900, Chulmin Kim wrote:
> >>Hello, Minchan!
> >>
> >>On 2016e?? 04i?? 27i? 1/4  16:48, Minchan Kim wrote:
> >>>This patch introduces run-time migration feature for zspage.
> >>>
> >>>For migration, VM uses page.lru field so it would be better to not use
> >>>page.next field for own purpose. For that, firstly, we can get first
> >>>object offset of the page via runtime calculation instead of
> >>>page->index so we can use page->index as link for page chaining.
> >>>In case of huge object, it stores handle rather than page chaining.
> >>>To identify huge object, we uses PG_owner_priv_1 flag.
> >>>
> >>>For migration, it supports three functions
> >>>
> >>>* zs_page_isolate
> >>>
> >>>It isolates a zspage which includes a subpage VM want to migrate from
> >>>class so anyone cannot allocate new object from the zspage if it's first
> >>>isolation on subpages of zspage. Thus, further isolation on other
> >>>subpages cannot isolate zspage from class list.
> >>>
> >>>* zs_page_migrate
> >>>
> >>>First of all, it holds write-side zspage->lock to prevent migrate other
> >>>subpage in zspage. Then, lock all objects in the page VM want to migrate.
> >>>The reason we should lock all objects in the page is due to race between
> >>>zs_map_object and zs_page_migrate.
> >>>
> >>>zs_map_object				zs_page_migrate
> >>>
> >>>pin_tag(handle)
> >>>obj = handle_to_obj(handle)
> >>>obj_to_location(obj, &page, &obj_idx);
> >>>
> >>>					write_lock(&zspage->lock)
> >>>					if (!trypin_tag(handle))
> >>>						goto unpin_object
> >>>
> >>>zspage = get_zspage(page);
> >>>read_lock(&zspage->lock);
> >>>
> >>>If zs_page_migrate doesn't do trypin_tag, zs_map_object's page can
> >>>be stale so go crash.
> >>>
> >>>If it locks all of objects successfully, it copies content from old page
> >>>create new one, finally, create new page chain with new page.
> >>>If it's last isolated page in the zspage, put the zspage back to class.
> >>>
> >>>* zs_page_putback
> >>>
> >>>It returns isolated zspage to right fullness_group list if it fails to
> >>>migrate a page.
> >>>
> >>>Lastly, this patch introduces asynchronous zspage free. The reason
> >>>we need it is we need page_lock to clear PG_movable but unfortunately,
> >>>zs_free path should be atomic so the apporach is try to grab page_lock
> >>>with preemption disabled. If it got page_lock of all of pages
> >>>successfully, it can free zspage in the context. Otherwise, it queues
> >>>the free request and free zspage via workqueue in process context.
> >>>
> >>>Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> >>>Signed-off-by: Minchan Kim <minchan@kernel.org>
> >>>---
> >>>  include/uapi/linux/magic.h |   1 +
> >>>  mm/zsmalloc.c              | 552 +++++++++++++++++++++++++++++++++++++++------
> >>>  2 files changed, 487 insertions(+), 66 deletions(-)
> >>>
> >>>diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
> >>>index e1fbe72c39c0..93b1affe4801 100644
> >>>--- a/include/uapi/linux/magic.h
> >>>+++ b/include/uapi/linux/magic.h
> >>>@@ -79,5 +79,6 @@
> >>>  #define NSFS_MAGIC		0x6e736673
> >>>  #define BPF_FS_MAGIC		0xcafe4a11
> >>>  #define BALLOON_KVM_MAGIC	0x13661366
> >>>+#define ZSMALLOC_MAGIC		0x58295829
> >>>
> >>>  #endif /* __LINUX_MAGIC_H__ */
> >>>diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> >>>index 8d82e44c4644..042793015ecf 100644
> >>>--- a/mm/zsmalloc.c
> >>>+++ b/mm/zsmalloc.c
> >>>@@ -17,15 +17,14 @@
> >>>   *
> >>>   * Usage of struct page fields:
> >>>   *	page->private: points to zspage
> >>>- *	page->index: offset of the first object starting in this page.
> >>>- *		For the first page, this is always 0, so we use this field
> >>>- *		to store handle for huge object.
> >>>- *	page->next: links together all component pages of a zspage
> >>>+ *	page->freelist: links together all component pages of a zspage
> >>>+ *		For the huge page, this is always 0, so we use this field
> >>>+ *		to store handle.
> >>>   *
> >>>   * Usage of struct page flags:
> >>>   *	PG_private: identifies the first component page
> >>>   *	PG_private2: identifies the last component page
> >>>- *
> >>>+ *	PG_owner_priv_1: indentifies the huge component page
> >>>   */
> >>>
> >>>  #include <linux/module.h>
> >>>@@ -47,6 +46,10 @@
> >>>  #include <linux/debugfs.h>
> >>>  #include <linux/zsmalloc.h>
> >>>  #include <linux/zpool.h>
> >>>+#include <linux/mount.h>
> >>>+#include <linux/migrate.h>
> >>>+
> >>>+#define ZSPAGE_MAGIC	0x58
> >>>
> >>>  /*
> >>>   * This must be power of 2 and greater than of equal to sizeof(link_free).
> >>>@@ -128,8 +131,33 @@
> >>>   *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
> >>>   *  (reason above)
> >>>   */
> >>>+
> >>>+/*
> >>>+ * A zspage's class index and fullness group
> >>>+ * are encoded in its (first)page->mapping
> >>>+ */
> >>>+#define FULLNESS_BITS	2
> >>>+#define CLASS_BITS	8
> >>>+#define ISOLATED_BITS	3
> >>>+#define MAGIC_VAL_BITS	8
> >>>+
> >>>+
> >>>  #define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> CLASS_BITS)
> >>>
> >>>+struct zspage {
> >>>+	struct {
> >>>+		unsigned int fullness:FULLNESS_BITS;
> >>>+		unsigned int class:CLASS_BITS;
> >>>+		unsigned int isolated:ISOLATED_BITS;
> >>>+		unsigned int magic:MAGIC_VAL_BITS;
> >>>+	};
> >>>+	unsigned int inuse;
> >>>+	unsigned int freeobj;
> >>>+	struct page *first_page;
> >>>+	struct list_head list; /* fullness list */
> >>>+	rwlock_t lock;
> >>>+};
> >>>+
> >>>  /*
> >>>   * We do not maintain any list for completely empty or full pages
> >>>   */
> >>>@@ -161,6 +189,8 @@ struct zs_size_stat {
> >>>  static struct dentry *zs_stat_root;
> >>>  #endif
> >>>
> >>>+static struct vfsmount *zsmalloc_mnt;
> >>>+
> >>>  /*
> >>>   * number of size_classes
> >>>   */
> >>>@@ -243,24 +273,10 @@ struct zs_pool {
> >>>  #ifdef CONFIG_ZSMALLOC_STAT
> >>>  	struct dentry *stat_dentry;
> >>>  #endif
> >>>-};
> >>>-
> >>>-/*
> >>>- * A zspage's class index and fullness group
> >>>- * are encoded in its (first)page->mapping
> >>>- */
> >>>-#define FULLNESS_BITS	2
> >>>-#define CLASS_BITS	8
> >>>-
> >>>-struct zspage {
> >>>-	struct {
> >>>-		unsigned int fullness:FULLNESS_BITS;
> >>>-		unsigned int class:CLASS_BITS;
> >>>-	};
> >>>-	unsigned int inuse;
> >>>-	unsigned int freeobj;
> >>>-	struct page *first_page;
> >>>-	struct list_head list; /* fullness list */
> >>>+	struct inode *inode;
> >>>+	spinlock_t free_lock;
> >>>+	struct work_struct free_work;
> >>>+	struct list_head free_zspage;
> >>>  };
> >>>
> >>>  struct mapping_area {
> >>>@@ -312,8 +328,11 @@ static struct zspage *cache_alloc_zspage(struct zs_pool *pool, gfp_t flags)
> >>>  	struct zspage *zspage;
> >>>
> >>>  	zspage = kmem_cache_alloc(pool->zspage_cachep, flags & ~__GFP_HIGHMEM);
> >>>-	if (zspage)
> >>>+	if (zspage) {
> >>>  		memset(zspage, 0, sizeof(struct zspage));
> >>>+		zspage->magic = ZSPAGE_MAGIC;
> >>>+		rwlock_init(&zspage->lock);
> >>
> >>+              INIT_LIST_HEAD(&zspage->list);
> >>
> >>If there is no special intention here,
> >>I think we need the list initialization.
> >
> >Intention was that I just watned to add unncessary instruction there
> >although it was not expensive. :)
> >
> >>
> >>There are some functions checking "list_empty(&zspage->list)".
> >>and they might be executed before the list initialization in rare cases.
> >
> >There are two places now.
> >
> >1. zspage_isolate
> >
> >It's okay because zs_page_isolate checks get_zspage_inuse under
> >class->lock while alloc_zspage adds newly created zspage to list
> >under class->lock with increasing used object count.
> >
> >2. free_zspage
> >
> >It's okay because every zspage passed free_zspage should
> >remove from list and remove_zspage has list_del_init and
> >the used object in the zspage should be zero so zs_page_isolate
> >cannot pick it up.
> >
> >>(AFAIK, the list initialization is being done by insert_zspage(),etc.)
> >>I guess, checking the uninitialized list is not intended at all.
> >
> >You have been great to spot something until now so you are saying
> >with some clue already and I might miss something. :)
> >
> >Do you have another scenario to make race problem?
> >Otherwise, I want to remain as it is because I want to reveal the
> >problem rather than hiding problems with safe-guard. :)
> 
> A weak clue, yes.
> my team saw the problem cases with zspage->list filled with 0.
> 
> I just found a scenario.
> 
> In case of huge page,
> the list initialization in remove_zspage() and insert_zspage()
> will not work as one zs_malloc will make the zspage to ZS_FULL.
> 
> I guess this is the cause of the problem I saw.

Good spot!

In that case, INIT_LIST_HEAD in alloc_zspage is not a solution.
If we do, we cannot migrate huge object because migration can
think object compactor already isolated the zspage so it return
false on zs_page_isolate.

I think it would be better to maintain ZS_FULL and ZS_EMPTY
in fullness_list. I will cook a patch.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
