Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id A149A6B0069
	for <linux-mm@kvack.org>; Tue, 21 May 2013 16:54:47 -0400 (EDT)
Message-ID: <519BDF15.4080301@sr71.net>
Date: Tue, 21 May 2013 13:54:45 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 18/39] thp, mm: add event counters for huge page alloc
 on write to a file
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-19-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index d4b7a18..584c71c 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -71,6 +71,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		THP_FAULT_FALLBACK,
>  		THP_COLLAPSE_ALLOC,
>  		THP_COLLAPSE_ALLOC_FAILED,
> +		THP_WRITE_ALLOC,
> +		THP_WRITE_ALLOC_FAILED,
>  		THP_SPLIT,
>  		THP_ZERO_PAGE_ALLOC,
>  		THP_ZERO_PAGE_ALLOC_FAILED,
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7945285..df8dcda 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -821,6 +821,8 @@ const char * const vmstat_text[] = {
>  	"thp_fault_fallback",
>  	"thp_collapse_alloc",
>  	"thp_collapse_alloc_failed",
> +	"thp_write_alloc",
> +	"thp_write_alloc_failed",
>  	"thp_split",
>  	"thp_zero_page_alloc",
>  	"thp_zero_page_alloc_failed",

I guess these new counters are _consistent_ with all the others.  But,
why do we need a separate "_failed" for each one of these?  While I'm
nitpicking, does "thp_write_alloc" mean allocs or _successful_ allocs?
I had to look at the code to tell.

I thihk it's probably safe to combine this patch with the next one.
Breaking them apart just makes it harder to review.  If _anything_,
this, plus the use of the counters should go in to a different patch
from the true code changes in "mm: allocate huge pages in
grab_cache_page_write_begin()".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
