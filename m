Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 87B0D6B0005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 00:03:26 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id xa7so1790990pbc.41
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 21:03:25 -0700 (PDT)
Message-ID: <515E4D05.5090807@gmail.com>
Date: Fri, 05 Apr 2013 12:03:17 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 11/30] thp, mm: handle tail pages in page_cache_get_speculative()
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-12-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Kirill,
On 03/15/2013 01:50 AM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> For tail page we call __get_page_tail(). It has the same semantics, but
> for tail page.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>   include/linux/pagemap.h |    4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 3521b0d..408c4e3 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -159,6 +159,9 @@ static inline int page_cache_get_speculative(struct page *page)

What's the different between page_cache_get_speculative and page_cache_get?

>   {
>   	VM_BUG_ON(in_interrupt());
>   
> +	if (unlikely(PageTail(page)))
> +		return __get_page_tail(page);
> +
>   #ifdef CONFIG_TINY_RCU
>   # ifdef CONFIG_PREEMPT_COUNT
>   	VM_BUG_ON(!in_atomic());
> @@ -185,7 +188,6 @@ static inline int page_cache_get_speculative(struct page *page)
>   		return 0;
>   	}
>   #endif
> -	VM_BUG_ON(PageTail(page));
>   
>   	return 1;
>   }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
