Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 470916B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 13:47:40 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 23:14:22 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id A8BFFE0053
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 23:19:22 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AHlQZB66388008
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 23:17:27 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AHlUXb008698
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:47:31 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 06/25] powerpc: Reduce PTE table memory wastage
In-Reply-To: <87r4iiom8a.fsf@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1365055083-31956-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130410044611.GF8165@truffula.fritz.box> <8738uyq4om.fsf@linux.vnet.ibm.com> <20130410070403.GH8165@truffula.fritz.box> <87r4iiom8a.fsf@linux.vnet.ibm.com>
Date: Wed, 10 Apr 2013 23:17:30 +0530
Message-ID: <87eheinuq5.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> David Gibson <dwg@au1.ibm.com> writes:
>
>> On Wed, Apr 10, 2013 at 11:59:29AM +0530, Aneesh Kumar K.V wrote:
>>> David Gibson <dwg@au1.ibm.com> writes:
>>> > On Thu, Apr 04, 2013 at 11:27:44AM +0530, Aneesh Kumar K.V wrote:
>> [snip]
>>> >> @@ -97,13 +100,45 @@ void __destroy_context(int context_id)
>>> >>  }
>>> >>  EXPORT_SYMBOL_GPL(__destroy_context);
>>> >>  
>>> >> +#ifdef CONFIG_PPC_64K_PAGES
>>> >> +static void destroy_pagetable_page(struct mm_struct *mm)
>>> >> +{
>>> >> +	int count;
>>> >> +	struct page *page;
>>> >> +
>>> >> +	page = mm->context.pgtable_page;
>>> >> +	if (!page)
>>> >> +		return;
>>> >> +
>>> >> +	/* drop all the pending references */
>>> >> +	count = atomic_read(&page->_mapcount) + 1;
>>> >> +	/* We allow PTE_FRAG_NR(16) fragments from a PTE page */
>>> >> +	count = atomic_sub_return(16 - count, &page->_count);
>>> >
>>> > You should really move PTE_FRAG_NR to a header so you can actually use
>>> > it here rather than hard coding 16.
>>> >
>>> > It took me a fair while to convince myself that there is no race here
>>> > with something altering mapcount and count between the atomic_read()
>>> > and the atomic_sub_return().  It could do with a comment to explain
>>> > why that is safe.
>>> >
>>> > Re-using the mapcount field for your index also seems odd, and it took
>>> > me a while to convince myself that that's safe too.  Wouldn't it be
>>> > simpler to store a pointer to the next sub-page in the mm_context
>>> > instead? You can get from that to the struct page easily enough with a
>>> > shift and pfn_to_page().
>>> 
>>> I found using _mapcount simpler in this case. I was looking at it not
>>> as an index, but rather how may fragments are mapped/used already.
>>
>> Except that it's actually (#fragments - 1).  Using subpage pointer
>> makes the fragments calculation (very slightly) harder, but the
>> calculation of the table address easier.  More importantly it avoids
>> adding effectively an extra variable - which is then shoehorned into a
>> structure not really designed to hold it.
>
> Even with subpage pointer we would need mm->context.pgtable_page or
> something similar. We don't add any other extra variable right ?. Let me
> try what you are suggesting here and see if that make it simpler.


Here is what I ended up with. I will fold this in next update

diff --git a/arch/powerpc/include/asm/mmu-book3e.h b/arch/powerpc/include/asm/mmu-book3e.h
index affbd68..8bd560c 100644
--- a/arch/powerpc/include/asm/mmu-book3e.h
+++ b/arch/powerpc/include/asm/mmu-book3e.h
@@ -233,7 +233,7 @@ typedef struct {
 #endif
 #ifdef CONFIG_PPC_64K_PAGES
 	/* for 4K PTE fragment support */
-	struct page *pgtable_page;
+	void *pte_frag;
 #endif
 } mm_context_t;
 
diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include/asm/mmu-hash64.h
index f51ed83..af73f06 100644
--- a/arch/powerpc/include/asm/mmu-hash64.h
+++ b/arch/powerpc/include/asm/mmu-hash64.h
@@ -511,7 +511,7 @@ typedef struct {
 #endif /* CONFIG_PPC_ICSWX */
 #ifdef CONFIG_PPC_64K_PAGES
 	/* for 4K PTE fragment support */
-	struct page *pgtable_page;
+	void *pte_frag;
 #endif
 } mm_context_t;
 
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index 46c6ffa..7b7ac40 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -149,6 +149,16 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 }
 
 #else /* if CONFIG_PPC_64K_PAGES */
+/*
+ * we support 16 fragments per PTE page.
+ */
+#define PTE_FRAG_NR	16
+/*
+ * We use a 2K PTE page fragment and another 2K for storing
+ * real_pte_t hash index
+ */
+#define PTE_FRAG_SIZE_SHIFT  12
+#define PTE_FRAG_SIZE (2 * PTRS_PER_PTE * sizeof(pte_t))
 
 extern pte_t *page_table_alloc(struct mm_struct *, unsigned long, int);
 extern void page_table_free(struct mm_struct *, unsigned long *, int);
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 27432fe..e379d3f 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -584,7 +584,7 @@ void __init setup_arch(char **cmdline_p)
 	init_mm.end_data = (unsigned long) _edata;
 	init_mm.brk = klimit;
 #ifdef CONFIG_PPC_64K_PAGES
-	init_mm.context.pgtable_page = NULL;
+	init_mm.context.pte_frag = NULL;
 #endif
 	irqstack_early_init();
 	exc_lvl_early_init();
diff --git a/arch/powerpc/mm/mmu_context_hash64.c b/arch/powerpc/mm/mmu_context_hash64.c
index 87d96e5..8fe4bc9 100644
--- a/arch/powerpc/mm/mmu_context_hash64.c
+++ b/arch/powerpc/mm/mmu_context_hash64.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 
 #include <asm/mmu_context.h>
+#include <asm/pgalloc.h>
 
 #include "icswx.h"
 
@@ -86,7 +87,7 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 #endif /* CONFIG_PPC_ICSWX */
 
 #ifdef CONFIG_PPC_64K_PAGES
-	mm->context.pgtable_page = NULL;
+	mm->context.pte_frag = NULL;
 #endif
 	return 0;
 }
@@ -103,16 +104,19 @@ EXPORT_SYMBOL_GPL(__destroy_context);
 static void destroy_pagetable_page(struct mm_struct *mm)
 {
 	int count;
+	void *pte_frag;
 	struct page *page;
 
-	page = mm->context.pgtable_page;
-	if (!page)
+	pte_frag = mm->context.pte_frag;
+	if (!pte_frag)
 		return;
 
+	page = virt_to_page(pte_frag);
 	/* drop all the pending references */
-	count = atomic_read(&page->_mapcount) + 1;
-	/* We allow PTE_FRAG_NR(16) fragments from a PTE page */
-	count = atomic_sub_return(16 - count, &page->_count);
+	count = ((unsigned long )pte_frag &
+		 (PAGE_SIZE -1)) >> PTE_FRAG_SIZE_SHIFT;
+	/* We allow PTE_FRAG_NR fragments from a PTE page */
+	count = atomic_sub_return(PTE_FRAG_NR - count, &page->_count);
 	if (!count) {
 		pgtable_page_dtor(page);
 		page_mapcount_reset(page);
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 34bc11f..d776614 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -352,66 +352,50 @@ struct page *pmd_page(pmd_t pmd)
 }
 
 #ifdef CONFIG_PPC_64K_PAGES
-/*
- * we support 16 fragments per PTE page. This is limited by how many
- * bits we can pack in page->_mapcount. We use the first half for
- * tracking the usage for rcu page table free.
- */
-#define PTE_FRAG_NR	16
-/*
- * We use a 2K PTE page fragment and another 2K for storing
- * real_pte_t hash index
- */
-#define PTE_FRAG_SIZE (2 * PTRS_PER_PTE * sizeof(pte_t))
-
 static pte_t *get_from_cache(struct mm_struct *mm)
 {
-	int index;
-	pte_t *ret = NULL;
-	struct page *page;
+	void *ret = NULL;
 
 	spin_lock(&mm->page_table_lock);
-	page = mm->context.pgtable_page;
-	if (page) {
-		void *p = page_address(page);
-		index = atomic_add_return(1, &page->_mapcount);
-		ret = (pte_t *) (p + (index * PTE_FRAG_SIZE));
+	ret = mm->context.pte_frag;
+	if (ret) {
+		ret += PTE_FRAG_SIZE;
 		/*
 		 * If we have taken up all the fragments mark PTE page NULL
 		 */
-		if (index == PTE_FRAG_NR - 1)
-			mm->context.pgtable_page = NULL;
+		if (((unsigned long )ret & (PAGE_SIZE - 1)) == 0)
+			ret = NULL;
+		mm->context.pte_frag = ret;
 	}
 	spin_unlock(&mm->page_table_lock);
-	return ret;
+	return (pte_t *)ret;
 }
 
 static pte_t *__alloc_for_cache(struct mm_struct *mm, int kernel)
 {
-	pte_t *ret = NULL;
+	void *ret = NULL;
 	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK |
 				       __GFP_REPEAT | __GFP_ZERO);
 	if (!page)
 		return NULL;
 
+	ret = page_address(page);
 	spin_lock(&mm->page_table_lock);
 	/*
 	 * If we find pgtable_page set, we return
 	 * the allocated page with single fragement
 	 * count.
 	 */
-	if (likely(!mm->context.pgtable_page)) {
+	if (likely(!mm->context.pte_frag)) {
 		atomic_set(&page->_count, PTE_FRAG_NR);
-		atomic_set(&page->_mapcount, 0);
-		mm->context.pgtable_page = page;
+		mm->context.pte_frag = ret + PTE_FRAG_SIZE;
 	}
 	spin_unlock(&mm->page_table_lock);
 
-	ret = (unsigned long *)page_address(page);
 	if (!kernel)
 		pgtable_page_ctor(page);
 
-	return ret;
+	return (pte_t *)ret;
 }
 
 pte_t *page_table_alloc(struct mm_struct *mm, unsigned long vmaddr, int kernel)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
