Date: Tue, 9 Dec 2008 11:31:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v2][PATCH]page_fault retry with NOPAGE_RETRY
Message-Id: <20081209113115.2af0172e.akpm@linux-foundation.org>
In-Reply-To: <604427e00812051140s67b2a89dm35806c3ee3b6ed7a@mail.gmail.com>
References: <604427e00812051140s67b2a89dm35806c3ee3b6ed7a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, mikew@google.com, rientjes@google.com, rohitseth@google.com, hugh@veritas.com, a.p.zijlstra@chello.nl, hpa@zytor.com, edwintorok@gmail.com, lee.schermerhorn@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 5 Dec 2008 11:40:19 -0800
Ying Han <yinghan@google.com> wrote:

> changelog[v2]:
> - reduce the runtime overhead by extending the 'write' flag of
>   handle_mm_fault() to indicate the retry hint.
> - add another two branches in filemap_fault with retry logic.
> - replace find_lock_page with find_lock_page_retry to make the code
>   cleaner.
> 
> todo:
> - there is potential a starvation hole with the retry. By the time the
>   retry returns, the pages might be released. we can make change by holding
>   page reference as well as remembering what the page "was"(in case the
>   file was truncated). any suggestion here are welcomed.
> 
> I also made patches for all other arch. I am posting x86_64 here first and
> i will post others by the time everyone feels comfortable of this patch.
> 
> Edwin, please test this patch with your testcase and check if you get any
> performance improvement of mmap over read. I added another two more places
> in filemap_fault with retry logic which you might hit in your privous
> experiment.
> 
> 
> page fault retry with NOPAGE_RETRY
> Allow major faults to drop the mmap_sem read lock while waiting for
> synchronous disk read. This allows another thread which wishes to grab
> down_write(mmap_sem) to proceed while the current is waiting the disk IO.
> 
> The patch extend the 'write' flag of handle_mm_fault() to FAULT_FLAG_RETRY
> as identify that the caller can tolerate the retry in the filemap_fault call
> patch.
> 
> This patch helps a lot in cases we have writer which is waitting behind all
> readers, so it could execute much faster.
> 
> 
>  Signed-off-by: Mike Waychison <mikew@google.com>
>  Signed-off-by: Ying Han <yinghan@google.com>
> 

It would be useful if the changelog were to describe the performance
benefits of the patch.  I mean, the whole point of the patch is to
improve throughpuyt/latency/etc, but we see no evidence here that it
_does_ this?

> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 31e8730..5cf5eff 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -591,6 +591,7 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigne
>  #ifdef CONFIG_X86_64
>  	unsigned long flags;
>  #endif
> +	unsigned int retry_flag = FAULT_FLAG_RETRY;
> 
>  	tsk = current;
>  	mm = tsk->mm;
> @@ -689,6 +690,7 @@ again:
>  		down_read(&mm->mmap_sem);
>  	}
> 
> +retry:
>  	vma = find_vma(mm, address);
>  	if (!vma)
>  		goto bad_area;
> @@ -715,6 +717,7 @@ again:
>  good_area:
>  	si_code = SEGV_ACCERR;
>  	write = 0;
> +	write |= retry_flag;
>  	switch (error_code & (PF_PROT|PF_WRITE)) {
>  	default:	/* 3: write, present */
>  		/* fall through */
> @@ -743,6 +746,15 @@ good_area:
>  			goto do_sigbus;
>  		BUG();
>  	}
> +
> +	if (fault & VM_FAULT_RETRY) {
> +		if (write & FAULT_FLAG_RETRY) {
> +			retry_flag &= ~FAULT_FLAG_RETRY;

What are we doing here?  We appear to be retrying the fault once, then
we switch to synchronous mode?  There is no description of this in the
changelog and there is no comment explaining the reasons for this
design.  There is no way in which readers of this code will be able to
understand why it is implemented in this fashion.

And a *lot* of people will want to know why this was done this way. 
Starting with about twenty arch maintainers!

Please add a comment which completely describes this code section.


> +			goto retry;
> +		}
> +		BUG();
> +	}
> +
>  	if (fault & VM_FAULT_MAJOR)
>  		tsk->maj_flt++;
>  	else
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ffee2f7..9cc65a5 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -144,7 +144,7 @@ extern pgprot_t protection_map[16];
> 
>  #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
>  #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
> -
> +#define FAULT_FLAG_RETRY	0x04	/* Retry majoy fault */
> 
>  /*
>   * vm_fault is filled by the the pagefault handler and passed to the vma's
> @@ -694,6 +694,7 @@ static inline int page_mapped(struct page *page)
>  #define VM_FAULT_SIGBUS	0x0002
>  #define VM_FAULT_MAJOR	0x0004
>  #define VM_FAULT_WRITE	0x0008	/* Special case for get_user_pages */
> +#define VM_FAULT_RETRY	0x0010
> 
>  #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page
>  #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
> diff --git a/mm/filemap.c b/mm/filemap.c
> index f3e5f89..aab4a08 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -714,6 +714,56 @@ repeat:
>  EXPORT_SYMBOL(find_lock_page);
> 
>  /**
> + * find_lock_page_retry - locate, pin and lock a pagecache page, if retry
> + * flag is on, and page is already locked by someone else, return a hint of
> + * retry.

kerneldoc does not support linewrapping in this context.  It has to be
done on a single line.  Please see the appended patch.

> + * @mapping: the address_space to search
> + * @offset: the page index
> + * @vma: vma in which the fault was taken
> + * @page: zero if page not present, otherwise point to the page in
> + * pagecache.

Ditto here.

> + * @retry: 1 indicate caller tolerate a retry.
> + *
> + * Return *page==NULL if page is not in pagecache. Otherwise return *page
> + * points to the page in the pagecache with ret=VM_FAULT_RETRY indicate a
> + * hint to caller for retry, or ret=0 which means page is succefully
> + * locked.
> + */
> +unsigned find_lock_page_retry(struct address_space *mapping, pgoff_t offset,
> +				struct vm_area_struct *vma, struct page **page,
> +				int retry)
> +{
> +	unsigned int ret = 0;
> +
> +repeat:
> +	*page = find_get_page(mapping, offset);
> +	if (*page) {
> +		if (!retry)
> +			lock_page(*page);
> +		else {
> +			if (!trylock_page(*page)) {
> +				struct mm_struct *mm = vma->vm_mm;
> +
> +				up_read(&mm->mmap_sem);
> +				wait_on_page_locked(*page);
> +				down_read(&mm->mmap_sem);
> +
> +				page_cache_release(*page);
> +				return VM_FAULT_RETRY;
> +			}
> +		}
> +		if (unlikely((*page)->mapping != mapping)) {
> +			unlock_page(*page);
> +			page_cache_release(*page);
> +			goto repeat;
> +		}
> +		VM_BUG_ON((*page)->index != offset);
> +	}
> +	return ret;
> +}
> +EXPORT_SYMBOL(find_lock_page_retry);

The patch adds no declaration for find_lock_page_retry() in any header
file.  See appended patch.

The frequent dereferencing of `page' is a bit ungainly, and adds risk
that gcc will generate poor code (my version of gcc does manage to do
the right thing, however).  I do think the code woukld look better if
we added a local for this.  See appended patch.

MM developers expect a variable called `page' to have type `struct page
*'.  This function violates that by adding `struct page **page'.  See
appended patch.


> +/**
>   * find_or_create_page - locate or add a pagecache page
>   * @mapping: the page's address_space
>   * @index: the page's index into the mapping
> @@ -1444,6 +1494,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_
>  	pgoff_t size;
>  	int did_readaround = 0;
>  	int ret = 0;
> +	int retry_flag = vmf->flags & FAULT_FLAG_RETRY;
> +	int retry_ret;
> 
>  	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
>  	if (vmf->pgoff >= size)
> @@ -1458,6 +1510,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_
>  	 */
>  retry_find:
>  	page = find_lock_page(mapping, vmf->pgoff);
> +
> +retry_find_nopage:
>  	/*
>  	 * For sequential accesses, we use the generic readahead logic.
>  	 */
> @@ -1465,9 +1519,12 @@ retry_find:
>  		if (!page) {
>  			page_cache_sync_readahead(mapping, ra, file,
>  							   vmf->pgoff, 1);
> -			page = find_lock_page(mapping, vmf->pgoff);
> +			retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
> +						vma, &page, retry_flag);
>  			if (!page)
>  				goto no_cached_page;
> +			if (retry_ret == VM_FAULT_RETRY)
> +				return retry_ret;
>  		}
>  		if (PageReadahead(page)) {
>  			page_cache_async_readahead(mapping, ra, file, page,
> @@ -1504,14 +1561,18 @@ retry_find:
>  				start = vmf->pgoff - ra_pages / 2;
>  			do_page_cache_readahead(mapping, file, start, ra_pages);
>  		}
> -		page = find_lock_page(mapping, vmf->pgoff);
> +		retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
> +				vma, &page, retry_flag);
>  		if (!page)
>  			goto no_cached_page;
> +		if (retry_ret == VM_FAULT_RETRY)
> +			return retry_ret;
>  	}
> 
>  	if (!did_readaround)
>  		ra->mmap_miss--;
> 
> +retry_page_update:
>  	/*
>  	 * We have a locked page in the page cache, now we need to check
>  	 * that it's up-to-date. If not, it is going to be due to an error.
> @@ -1547,8 +1608,23 @@ no_cached_page:
>  	 * In the unlikely event that someone removed it in the
>  	 * meantime, we'll just come back here and read it again.
>  	 */
> -	if (error >= 0)
> -		goto retry_find;
> +	if (error >= 0) {
> +		/*
> +		 * If caller cannot tolerate a retry in the ->fault path
> +		 * go back to check the page again.
> +		 */
> +		if (!retry_flag)
> +			goto retry_find;
> +
> +		retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
> +					vma, &page, retry_flag);
> +		if (!page)
> +			goto retry_find_nopage;
> +		else if (retry_ret == VM_FAULT_RETRY)
> +			return retry_ret;
> +		else
> +			goto retry_page_update;
> +	}
> 
>  	/*
>  	 * An error return from page_cache_read can result if the
> diff --git a/mm/memory.c b/mm/memory.c
> index 164951c..1ff37f7 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2467,6 +2467,13 @@ static int __do_fault(struct mm_struct *mm, struct vm_a
>  	vmf.page = NULL;
> 
>  	ret = vma->vm_ops->fault(vma, &vmf);
> +
> +	/* page may be available, but we have to restart the process
> +	 * because mmap_sem was dropped during the ->fault
> +	 */
> +	if (ret == VM_FAULT_RETRY)
> +		return ret;

Shouldn't this be

	if (ret & VM_FAULT_RETRY)

?

It may not make any difference in practice with present ->fault
implementations, but that's through sheer luck.

>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
>  		return ret;
> 
> @@ -2613,6 +2620,7 @@ static int do_linear_fault(struct mm_struct *mm, struct
>  			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
>  	unsigned int flags = (write_access ? FAULT_FLAG_WRITE : 0);
> 
> +	flags |= (write_access & FAULT_FLAG_RETRY);
>  	pte_unmap(page_table);
>  	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
>  }


 include/linux/pagemap.h |    3 +++
 mm/filemap.c            |   38 ++++++++++++++++++++------------------
 2 files changed, 23 insertions(+), 18 deletions(-)

diff -puN arch/x86/mm/fault.c~page_fault-retry-with-nopage_retry-fix arch/x86/mm/fault.c
diff -puN include/linux/mm.h~page_fault-retry-with-nopage_retry-fix include/linux/mm.h
diff -puN mm/filemap.c~page_fault-retry-with-nopage_retry-fix mm/filemap.c
--- a/mm/filemap.c~page_fault-retry-with-nopage_retry-fix
+++ a/mm/filemap.c
@@ -714,51 +714,53 @@ repeat:
 EXPORT_SYMBOL(find_lock_page);
 
 /**
- * find_lock_page_retry - locate, pin and lock a pagecache page, if retry
- * flag is on, and page is already locked by someone else, return a hint of
- * retry.
+ * find_lock_page_retry - locate, pin and lock a pagecache page
  * @mapping: the address_space to search
  * @offset: the page index
  * @vma: vma in which the fault was taken
- * @page: zero if page not present, otherwise point to the page in
- * pagecache.
+ * @ppage: zero if page not present, otherwise point to the page in pagecache.
  * @retry: 1 indicate caller tolerate a retry.
  *
- * Return *page==NULL if page is not in pagecache. Otherwise return *page
+ * If retry flag is on, and page is already locked by someone else, return a
+ * hint of retry.
+ *
+ * Return *ppage==NULL if page is not in pagecache. Otherwise return *ppage
  * points to the page in the pagecache with ret=VM_FAULT_RETRY indicate a
- * hint to caller for retry, or ret=0 which means page is succefully
+ * hint to caller for retry, or ret=0 which means page is successfully
  * locked.
  */
 unsigned find_lock_page_retry(struct address_space *mapping, pgoff_t offset,
-				struct vm_area_struct *vma, struct page **page,
+				struct vm_area_struct *vma, struct page **ppage,
 				int retry)
 {
 	unsigned int ret = 0;
+	struct page *page;
 
 repeat:
-	*page = find_get_page(mapping, offset);
-	if (*page) {
+	page = find_get_page(mapping, offset);
+	if (page) {
 		if (!retry)
-			lock_page(*page);
+			lock_page(page);
 		else {
-			if (!trylock_page(*page)) {
+			if (!trylock_page(page)) {
 				struct mm_struct *mm = vma->vm_mm;
 
 				up_read(&mm->mmap_sem);
-				wait_on_page_locked(*page);
+				wait_on_page_locked(page);
 				down_read(&mm->mmap_sem);
 
-				page_cache_release(*page);
+				page_cache_release(page);
 				return VM_FAULT_RETRY;
 			}
 		}
-		if (unlikely((*page)->mapping != mapping)) {
-			unlock_page(*page);
-			page_cache_release(*page);
+		if (unlikely(page->mapping != mapping)) {
+			unlock_page(page);
+			page_cache_release(page);
 			goto repeat;
 		}
-		VM_BUG_ON((*page)->index != offset);
+		VM_BUG_ON(page->index != offset);
 	}
+	*ppage = page;
 	return ret;
 }
 EXPORT_SYMBOL(find_lock_page_retry);
diff -puN mm/memory.c~page_fault-retry-with-nopage_retry-fix mm/memory.c
diff -puN include/linux/pagemap.h~page_fault-retry-with-nopage_retry-fix include/linux/pagemap.h
--- a/include/linux/pagemap.h~page_fault-retry-with-nopage_retry-fix
+++ a/include/linux/pagemap.h
@@ -232,6 +232,9 @@ extern struct page * find_get_page(struc
 				pgoff_t index);
 extern struct page * find_lock_page(struct address_space *mapping,
 				pgoff_t index);
+extern unsigned find_lock_page_retry(struct address_space *mapping,
+			pgoff_t offset, struct vm_area_struct *vma,
+			struct page **ppage, int retry)
 extern struct page * find_or_create_page(struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
