Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 510636B003D
	for <linux-mm@kvack.org>; Tue, 21 May 2013 16:17:35 -0400 (EDT)
Message-ID: <519BD65C.1050709@sr71.net>
Date: Tue, 21 May 2013 13:17:32 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 15/39] thp, mm: trigger bug in replace_page_cache_page()
 on THP
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-16-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> replace_page_cache_page() is only used by FUSE. It's unlikely that we
> will support THP in FUSE page cache any soon.
> 
> Let's pospone implemetation of THP handling in replace_page_cache_page()
> until any will use it.
...
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 657ce82..3a03426 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -428,6 +428,8 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  {
>  	int error;
>  
> +	VM_BUG_ON(PageTransHuge(old));
> +	VM_BUG_ON(PageTransHuge(new));
>  	VM_BUG_ON(!PageLocked(old));
>  	VM_BUG_ON(!PageLocked(new));
>  	VM_BUG_ON(new->mapping);

The code calling replace_page_cache_page() has a bunch of fallback and
error returning code.  It seems a little bit silly to bring the whole
machine down when you could just WARN_ONCE() and return an error code
like fuse already does:

>         /*
>          * This is a new and locked page, it shouldn't be mapped or
>          * have any special flags on it
>          */
>         if (WARN_ON(page_mapped(oldpage)))
>                 goto out_fallback_unlock;
>         if (WARN_ON(page_has_private(oldpage)))
>                 goto out_fallback_unlock;
>         if (WARN_ON(PageDirty(oldpage) || PageWriteback(oldpage)))
>                 goto out_fallback_unlock;
>         if (WARN_ON(PageMlocked(oldpage)))
>                 goto out_fallback_unlock;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
