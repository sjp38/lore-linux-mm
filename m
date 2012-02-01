Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 5B98E6B13F1
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 17:43:54 -0500 (EST)
Date: Wed, 1 Feb 2012 14:43:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/5] hugetlb: try to search again if it is really needed
Message-Id: <20120201144353.7c75b5b6.akpm@linux-foundation.org>
In-Reply-To: <4F101969.8050601@linux.vnet.ibm.com>
References: <4F101904.8090405@linux.vnet.ibm.com>
	<4F101969.8050601@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 13 Jan 2012 19:45:45 +0800
Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com> wrote:

> Search again only if some holes may be skipped in the first time
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> ---
>  arch/x86/mm/hugetlbpage.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index e12debc..6bf5735 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -309,9 +309,8 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
>  	struct hstate *h = hstate_file(file);
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma;
> -	unsigned long base = mm->mmap_base, addr = addr0;
> +	unsigned long base = mm->mmap_base, addr = addr0, start_addr;

grr.  The multiple-definitions-per-line thing is ugly, makes for more
patch conflicts and reduces opportunities to add useful comments.

--- a/arch/x86/mm/hugetlbpage.c~hugetlb-try-to-search-again-if-it-is-really-needed-fix
+++ a/arch/x86/mm/hugetlbpage.c
@@ -309,7 +309,9 @@ static unsigned long hugetlb_get_unmappe
 	struct hstate *h = hstate_file(file);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
-	unsigned long base = mm->mmap_base, addr = addr0, start_addr;
+	unsigned long base = mm->mmap_base;
+	unsigned long addr = addr0;
+	unsigned long start_addr;
 	unsigned long largest_hole = mm->cached_hole_size;
 
 	/* don't allow allocations above current base */
_


>  	unsigned long largest_hole = mm->cached_hole_size;
> -	int first_time = 1;
> 
>  	/* don't allow allocations above current base */
>  	if (mm->free_area_cache > base)
> @@ -322,6 +321,8 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
>  		mm->free_area_cache  = base;
>  	}
>  try_again:
> +	start_addr = mm->free_area_cache;
> +
>  	/* make sure it can fit in the remaining address space */
>  	if (mm->free_area_cache < len)
>  		goto fail;
> @@ -357,10 +358,9 @@ fail:
>  	 * if hint left us with no space for the requested
>  	 * mapping then try again:
>  	 */
> -	if (first_time) {
> +	if (start_addr != base) {
>  		mm->free_area_cache = base;
>  		largest_hole = 0;
> -		first_time = 0;
>  		goto try_again;

The code used to retry a single time.  With this change the retrying is
potentially infinite.  What is the reason for this change?  What is the
potential for causing a lockup?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
