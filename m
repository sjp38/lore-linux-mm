Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 01E7D6B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 09:58:47 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p63so74327264wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 06:58:46 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id 186si30934253wms.43.2016.02.03.06.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 06:58:45 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id l66so167583541wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 06:58:45 -0800 (PST)
Date: Wed, 3 Feb 2016 15:58:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2 2/2] mm: downgrade VM_BUG in isolate_lru_page() to
 warning
Message-ID: <20160203145844.GJ6757@dhcp22.suse.cz>
References: <1454430061-116955-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1454430061-116955-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454430061-116955-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 02-02-16 19:21:01, Kirill A. Shutemov wrote:
> Calling isolate_lru_page() is wrong and shouldn't happen, but it not
> nessesary fatal: the page just will not be isolated if it's not on LRU.
> 
> Let's downgrade the VM_BUG_ON_PAGE() to WARN_RATELIMIT().

This will trigger for !CONFIG_DEBUG_VM as well which I am not sure is
necessary. I guess isolate_lru_page is not such a hot path so this would
be acceptable.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eb3dd37ccd7c..71b1c29948db 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1443,7 +1443,7 @@ int isolate_lru_page(struct page *page)
>  	int ret = -EBUSY;
>  
>  	VM_BUG_ON_PAGE(!page_count(page), page);
> -	VM_BUG_ON_PAGE(PageTail(page), page);
> +	WARN_RATELIMIT(PageTail(page), "trying to isolate tail page");
>  
>  	if (PageLRU(page)) {
>  		struct zone *zone = page_zone(page);
> -- 
> 2.7.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
