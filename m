Date: Thu, 9 Mar 2006 19:54:19 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] optimize follow_hugetlb_page
Message-Id: <20060309195419.251925c6.akpm@osdl.org>
In-Reply-To: <200603091126.k29BQlg19037@unix-os.sc.intel.com>
References: <200603091126.k29BQlg19037@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: wli@holomorphy.com, linux-mm@kvack.org, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
>
>  follow_hugetlb_page walks a range of user virtual address and then
>  fills in list of struct page * into an array that is passed from
>  the argument list.  It also gets a reference count via get_page().
>  For compound page, get_page() actually traverse back to head page
>  via page_private() macro and then adds a reference count to the
>  head page.  Since we are doing a virt to pte look up, kernel already
>  has a struct page pointer into the head page.  So instead of traverse
>  into the small unit page struct and then follow a link back to the
>  head page, optimize that with incrementing the reference count
>  directly on the head page.
> 
>  The benefit is that we don't take a cache miss on accessing page
>  struct for the corresponding user address and more importantly, not
>  to pollute the cache with a "not very useful" round trip of pointer
>  chasing.  This adds a moderate performance gain on an I/O intensive
>  database transaction workload.
> 
> 
>  Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> 
>  --- ./mm/hugetlb.c.orig	2006-02-22 18:57:37.218102659 -0800
>  +++ ./mm/hugetlb.c	2006-02-22 20:49:33.008059453 -0800
>  @@ -521,10 +521,9 @@ int follow_hugetlb_page(struct mm_struct
>   			struct page **pages, struct vm_area_struct **vmas,
>   			unsigned long *position, int *length, int i)
>   {
>  -	unsigned long vpfn, vaddr = *position;
>  +	unsigned long pidx, vaddr = *position;

So I spent some time trying to divine what "pidx" means, and ended up
deciding that it doesn't.  So I renamed it to pfn_offset and, being a kind
soul, I added a comment to help out the next guy.

The patch assumes that all pageframes which represent a compound page are
contiguously laid out in mem_map[].  Which is reasonable, I guess.


--- devel/mm/hugetlb.c~optimize-follow_hugetlb_page	2006-03-09 19:46:04.000000000 -0800
+++ devel-akpm/mm/hugetlb.c	2006-03-09 19:51:34.000000000 -0800
@@ -661,10 +661,10 @@ int follow_hugetlb_page(struct mm_struct
 			struct page **pages, struct vm_area_struct **vmas,
 			unsigned long *position, int *length, int i)
 {
-	unsigned long vpfn, vaddr = *position;
+	unsigned long pfn_offset;
+	unsigned long vaddr = *position;
 	int remainder = *length;
 
-	vpfn = vaddr/PAGE_SIZE;
 	spin_lock(&mm->page_table_lock);
 	while (vaddr < vma->vm_end && remainder) {
 		pte_t *pte;
@@ -692,19 +692,28 @@ int follow_hugetlb_page(struct mm_struct
 			break;
 		}
 
-		if (pages) {
-			page = &pte_page(*pte)[vpfn % (HPAGE_SIZE/PAGE_SIZE)];
-			get_page(page);
-			pages[i] = page;
-		}
+		pfn_offset = (vaddr & ~HPAGE_MASK) >> PAGE_SHIFT;
+		page = pte_page(*pte);
+same_page:
+		get_page(page);
+		if (pages)
+			pages[i] = page + pfn_offset;
 
 		if (vmas)
 			vmas[i] = vma;
 
 		vaddr += PAGE_SIZE;
-		++vpfn;
+		++pfn_offset;
 		--remainder;
 		++i;
+		if (vaddr < vma->vm_end && remainder &&
+				pfn_offset < HPAGE_SIZE/PAGE_SIZE) {
+			/*
+			 * We use pfn_offset to avoid touching the pageframes
+			 * of this compound page.
+			 */
+			goto same_page;
+		}
 	}
 	spin_unlock(&mm->page_table_lock);
 	*length = remainder;
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
