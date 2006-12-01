Date: Fri, 1 Dec 2006 11:44:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
Message-Id: <20061201114414.0c90f649.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830611301548y66e5e66eo2f61df940a66711a@mail.gmail.com>
References: <20061129030655.941148000@menage.corp.google.com>
	<Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
	<6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
	<Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
	<6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
	<Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
	<6599ad830611301207q4e4ab485lb0d3c99680db5a2a@mail.gmail.com>
	<Pine.LNX.4.64.0611301211270.24331@schroedinger.engr.sgi.com>
	<6599ad830611301333v48f2da03g747c088ed3b4ad60@mail.gmail.com>
	<Pine.LNX.4.64.0611301540390.13297@schroedinger.engr.sgi.com>
	<6599ad830611301548y66e5e66eo2f61df940a66711a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: clameter@sgi.com, hugh@veritas.com, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006 15:48:28 -0800
"Paul Menage" <menage@google.com> wrote:

> On 11/30/06, Christoph Lameter <clameter@sgi.com> wrote:
> > I think you initial suggestion of adding a counter to the anon_vma may
> > work. Here is a patch that may allow us to keep the anon_vma around
> > without holding mmap_sem. Seems to be simple.
> 
> Don't we need to bump the mapcount? If we don't, then the page gets
> unmapped by the migration prep, and if we race with anyone trying to
> map it they may allocate a new anon_vma and replace it.

I don't think add *dummy* mapccount to a page is good.

One way I can think of now is to make use of RCU routine for anon_vma_free() and
take RCU readlock while unmap->map an anon page. This can prevent a freed anon_vma 
struct from being used by someone immediately.

But Christoph-san's patch just uses 4bytes(int) for delayed freeing. 
This adds 2 pointers to each anon_vma struct, but doesn't uses any special things.

This is a patch. not tested at all, just idea level.
(seems a period of taking rcu_read_lock() is a bit long..)

-Kame

==
For moving page-migration to the next step, we have to fix
anon_vma problem.

migration code temporally makes page->mapcount to 0. This means
page->mapping is not trustful. AFAIK, anon_vma can be freed while
migration if mm->sem is not taken.

To make use of migration without mm->sem, we need to delay freeing
of anon_vma. This patch uses RCU for delayed freeing of anon_vma.


Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/rmap.h |   10 +++++++++-
 mm/migrate.c         |    2 ++
 mm/rmap.c            |    6 ++++++
 3 files changed, 17 insertions(+), 1 deletion(-)

Index: linux-2.6.19/include/linux/rmap.h
===================================================================
--- linux-2.6.19.orig/include/linux/rmap.h
+++ linux-2.6.19/include/linux/rmap.h
@@ -26,6 +26,7 @@
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
+	struct rcu_head rcu;	/* for delayed RCU freeing */
 };
 
 #ifdef CONFIG_MMU
@@ -37,11 +38,18 @@ static inline struct anon_vma *anon_vma_
 	return kmem_cache_alloc(anon_vma_cachep, SLAB_KERNEL);
 }
 
+/*
+ * Because page->mapping(which points to anon-vma) is not cleared
+ * even if page is removed from anon_vma, we use delayed freeing
+ * of anon_vma. This makes migration safer.
+ */
+extern void delayed_anon_vma_free(struct rcu_head *head);
 static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
-	kmem_cache_free(anon_vma_cachep, anon_vma);
+	call_rcu(&anon_vma->rcu, delayed_anon_vma_free);
 }
 
+
 static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
Index: linux-2.6.19/mm/migrate.c
===================================================================
--- linux-2.6.19.orig/mm/migrate.c
+++ linux-2.6.19/mm/migrate.c
@@ -618,12 +618,14 @@ static int unmap_and_move(new_page_t get
 	/*
 	 * Establish migration ptes or remove ptes
 	 */
+	rcu_read_lock();
 	try_to_unmap(page, 1);
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
 	if (rc)
 		remove_migration_ptes(page, page);
+	rcu_read_unlock();
 
 unlock:
 	unlock_page(page);
Index: linux-2.6.19/mm/rmap.c
===================================================================
--- linux-2.6.19.orig/mm/rmap.c
+++ linux-2.6.19/mm/rmap.c
@@ -70,6 +70,12 @@ static inline void validate_anon_vma(str
 #endif
 }
 
+void delayed_anon_vma_free(struct rcu_head *head)
+{
+	struct anon_vma *anon_vma = container_of(head, struct anon_vma, rcu);
+	kmem_cache_free(anon_vma_cachep, anon_vma);
+}
+
 /* This must be called under the mmap_sem. */
 int anon_vma_prepare(struct vm_area_struct *vma)
 {




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
