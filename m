Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D0F066B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 16:49:46 -0400 (EDT)
Message-ID: <1375994967.29639.4.camel@concerto>
Subject: Re: [PATCH 22/23] thp, mm: split huge page on mmap file page
From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Thu, 08 Aug 2013 14:49:27 -0600
In-Reply-To: <1375582645-29274-23-git-send-email-kirill.shutemov@linux.intel.com>
References: 
	<1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1375582645-29274-23-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill
 A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 2013-08-04 at 05:17 +0300, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> We are not ready to mmap file-backed tranparent huge pages. Let's split
> them on fault attempt.
> 
> Later we'll implement mmap() properly and this code path be used for
> fallback cases.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/filemap.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index ed65af5..f7857ef 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1743,6 +1743,8 @@ retry_find:
>  			goto no_cached_page;
>  	}
>  
> +	if (PageTransCompound(page))
> +		split_huge_page(compound_trans_head(page));

Since PageTransCompound(page) returns true for transparent huge pages as
well as hugetlbfs pages, could this code split hugetlbfs pages on an
mmap() on to hugetlbfs pages? hugetlbfs pages are not supposed to be
split, right?

>  	if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
>  		page_cache_release(page);
>  		return ret | VM_FAULT_RETRY;

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
