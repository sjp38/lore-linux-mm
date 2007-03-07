Date: Wed, 7 Mar 2007 11:30:18 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 7/6] mm: merge page_mkwrite
Message-ID: <20070307103018.GC5555@wotan.suse.de>
References: <20070307082755.GA25733@elte.hu> <E1HOrfO-0008AW-00@dorka.pomaz.szeredi.hu> <20070307004709.432ddf97.akpm@linux-foundation.org> <E1HOrsL-0008Dv-00@dorka.pomaz.szeredi.hu> <20070307010756.b31c8190.akpm@linux-foundation.org> <1173259942.6374.125.camel@twins> <20070307094503.GD8609@wotan.suse.de> <20070307100430.GA5080@wotan.suse.de> <1173262002.6374.128.camel@twins> <E1HOt96-0008V6-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1HOt96-0008V6-00@dorka.pomaz.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Now that I'm making some progress on merging the basic stuff, I'd
like to get opinions about merging page_mkwrite functionality into
->fault().

I still don't see any callers in the tree, but I see no reason why
this won't work (or why it isn't better).

--
Like everything else in life, page_mkwrite()ing is just a primitive,
degenerate form of fault()ing.

Having FAULT_FLAG_WRITE in the fault operation allows us to just get
rid of the page_mkwrite call in do_fault, because filesystems can check
for that flag bit, and do the page_mkwrite thing before returning the
page (this will improve efficiency for everyone).

Then, we introduce another fault flag to signal that the fault is
an event notification for a page, rather than a request for a pgoff.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -176,6 +176,7 @@ extern unsigned int kobjsize(const void 
 					 * return with the page locked.
 					 */
 #define VM_CAN_NONLINEAR 0x10000000	/* Has ->fault & does nonlinear pages */
+#define VM_NOTIFY_MKWRITE 0x20000000	/* Has ->fault & wants page writable notification */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
@@ -201,6 +202,7 @@ extern pgprot_t protection_map[16];
 
 #define FAULT_FLAG_WRITE	0x01
 #define FAULT_FLAG_NONLINEAR	0x02
+#define FAULT_FLAG_NOTIFY	0x04	/* fault_data.page contains page */
 
 /*
  * fault_data is filled in the the pagefault handler and passed to the
@@ -213,7 +215,10 @@ extern pgprot_t protection_map[16];
  * nonlinear mapping support.
  */
 struct fault_data {
-	unsigned long address;
+	union {
+		unsigned long address;
+		struct page *page;
+	};
 	pgoff_t pgoff;
 	unsigned int flags;
 
@@ -230,9 +235,6 @@ struct vm_operations_struct {
 	void (*close)(struct vm_area_struct * area);
 	struct page * (*fault)(struct vm_area_struct *vma, struct fault_data * fdata);
 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int *type);
-	/* notification that a previously read-only page is about to become
-	 * writable, if an error is returned it will cause a SIGBUS */
-	int (*page_mkwrite)(struct vm_area_struct *vma, struct page *page);
 #ifdef CONFIG_NUMA
 	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
@@ -831,7 +833,7 @@ extern struct shrinker *set_shrinker(int
 extern void remove_shrinker(struct shrinker *shrinker);
 
 /*
- * Some shared mappigns will want the pages marked read-only
+ * Some shared mappings will want the pages marked read-only
  * to track write events. If so, we'll downgrade vm_page_prot
  * to the private version (using protection_map[] without the
  * VM_SHARED bit).
@@ -845,7 +847,7 @@ static inline int vma_wants_writenotify(
 		return 0;
 
 	/* The backer wishes to know when pages are first written to? */
-	if (vma->vm_ops && vma->vm_ops->page_mkwrite)
+	if (vma->vm_flags & VM_NOTIFY_MKWRITE)
 		return 1;
 
 	/* The open routine did something to the protections already? */
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1566,7 +1566,8 @@ static int do_wp_page(struct mm_struct *
 		 * read-only shared pages can get COWed by
 		 * get_user_pages(.write=1, .force=1).
 		 */
-		if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
+		if (unlikely(vma->vm_flags & VM_NOTIFY_MKWRITE)) {
+			struct fault_data fdata;
 			/*
 			 * Notify the address space that the page is about to
 			 * become writable so that it can prohibit this or wait
@@ -1578,8 +1579,14 @@ static int do_wp_page(struct mm_struct *
 			page_cache_get(old_page);
 			pte_unmap_unlock(page_table, ptl);
 
-			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0)
-				goto unwritable_page;
+			fdata.flags = FAULT_FLAG_NOTIFY|FAULT_FLAG_WRITE;
+			fdata.page = old_page;
+			fdata.type = -1;
+			old_page = vma->vm_ops->fault(vma, &fdata);
+			WARN_ON(fdata.type == -1);
+			ret = fdata.type;
+			if (!old_page)
+				return ret;
 
 			/*
 			 * Since we dropped the lock we need to revalidate
@@ -1677,10 +1684,6 @@ oom:
 	if (old_page)
 		page_cache_release(old_page);
 	return VM_FAULT_OOM;
-
-unwritable_page:
-	page_cache_release(old_page);
-	return VM_FAULT_SIGBUS;
 }
 
 /*
@@ -2254,18 +2257,6 @@ static int __do_fault(struct mm_struct *
 				goto out;
 			}
 			copy_user_highpage(page, faulted_page, address, vma);
-		} else {
-			/*
-			 * If the page will be shareable, see if the backing
-			 * address space wants to know that the page is about
-			 * to become writable
-			 */
-			if (vma->vm_ops->page_mkwrite &&
-			    vma->vm_ops->page_mkwrite(vma, page) < 0) {
-				fdata.type = VM_FAULT_SIGBUS;
-				anon = 1; /* no anon but release faulted_page */
-				goto out;
-			}
 		}
 
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
