Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 4B8426B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 05:03:36 -0400 (EDT)
Date: Fri, 16 Aug 2013 12:04:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] Fix aio performance regression for database caused
 by THP
Message-ID: <20130816090425.GA2162@shutemov.name>
References: <1376590389.24607.33.camel@concerto>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376590389.24607.33.camel@concerto>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 15, 2013 at 12:13:09PM -0600, Khalid Aziz wrote:
> I am working with a tool that simulates oracle database I/O workload.
> This tool (orion to be specific -
> <http://docs.oracle.com/cd/E11882_01/server.112/e16638/iodesign.htm#autoId24>) allocates hugetlbfs pages using shmget() with SHM_HUGETLB flag. It then does aio into these pages from flash disks using various common block sizes used by database. I am looking at performance with two of the most common block sizes - 1M and 64K. aio performance with these two block sizes plunged after Transparent HugePages was introduced in the kernel. Here are performance numbers:
> 
> 		pre-THP		2.6.39		3.11-rc5
> 1M read		8384 MB/s	5629 MB/s	6501 MB/s
> 64K read	7867 MB/s	4576 MB/s	4251 MB/s
> 
> I have narrowed the performance impact down to the overheads introduced
> by THP in __get_page_tail() and put_compound_page() routines. perf top
> shows >40% of cycles being spent in these two routines. Every time
> direct I/O to hugetlbfs pages starts, kernel calls get_page() to grab a
> reference to the pages and calls put_page() when I/O completes to put
> the reference away. THP introduced significant amount of locking
> overhead to get_page() and put_page() when dealing with compound pages
> because hugepages can be split underneath get_page() and put_page(). It
> added this overhead irrespective of whether it is dealing with hugetlbfs
> pages or transparent hugepages. This resulted in 20%-45% drop in aio
> performance when using hugetlbfs pages.
> 
> Since hugetlbfs pages can not be split, there is no reason to go through
> all the locking overhead for these pages from what I can see. I added
> code to __get_page_tail() and put_compound_page() to bypass all the
> locking code when working with hugetlbfs pages. This improved
> performance significantly. Performance numbers with this patch:
> 
> 		pre-THP		3.11-rc5	3.11-rc5 + Patch
> 1M read		8384 MB/s	6501 MB/s	8371 MB/s
> 64K read	7867 MB/s	4251 MB/s	6510 MB/s
> 
> Performance with 64K read is still lower than what it was before THP,
> but still a 53% improvement. It does mean there is more work to be done
> but I will take a 53% improvement for now.
> 
> Please take a look at the following patch and let me know if it looks
> reasonable.
> 
> 
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> ---
>  mm/swap.c |   77 +++++++++++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 52 insertions(+), 25 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 62b78a6..cc8326f 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -31,6 +31,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/gfp.h>
>  #include <linux/uio.h>
> +#include <linux/hugetlb.h>
>  
>  #include "internal.h"
>  
> @@ -81,6 +82,19 @@ static void __put_compound_page(struct page *page)
>  
>  static void put_compound_page(struct page *page)
>  {
> +	/*
> +	 * hugetlbfs pages can not be split from under us. If this
> +	 * is a hugetlbfs page, check refcount on head page and release
> +	 * the page if refcount is zero.
> +	 */
> +	if (PageHuge(page)) {
> +		page = compound_head(page);
> +		if (put_page_testzero(page))
> +			__put_compound_page(page);
> +
> +		return;
> +	}
> +
>  	if (unlikely(PageTail(page))) {
>  		/* __split_huge_page_refcount can run under us */
>  		struct page *page_head = compound_trans_head(page);
> @@ -184,38 +198,51 @@ bool __get_page_tail(struct page *page)
>  	 * proper PT lock that already serializes against
>  	 * split_huge_page().
>  	 */
> -	unsigned long flags;
>  	bool got = false;
> -	struct page *page_head = compound_trans_head(page);
> +	struct page *page_head;
>  
> -	if (likely(page != page_head && get_page_unless_zero(page_head))) {
> +	/*
> +	 * If this is a hugetlbfs page, it can not be split under
> +	 * us. Simply increment refcount for head page
> +	 */
> +	if (PageHuge(page)) {
> +		page_head = compound_head(page);
> +		atomic_inc(&page_head->_count);
> +		got = true;

Why not just return here and don't increase indentantion level for rest of
the function?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
