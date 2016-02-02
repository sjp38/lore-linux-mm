Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id A16596B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 17:51:01 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id r129so140039680wmr.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 14:51:01 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id h62si8006184wmh.51.2016.02.02.14.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 14:51:00 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id p63so140085568wmp.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 14:51:00 -0800 (PST)
Date: Wed, 3 Feb 2016 00:50:58 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/hugetlb: fix gigantic page initialization/allocation
Message-ID: <20160202225058.GA8309@node.shutemov.name>
References: <1454452420-25007-1-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454452420-25007-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jerome Marchand <jmarchan@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>

On Tue, Feb 02, 2016 at 02:33:40PM -0800, Mike Kravetz wrote:
> Attempting to preallocate 1G gigantic huge pages at boot time with
> "hugepagesz=1G hugepages=1" on the kernel command line will prevent
> booting with the following:
> 
> kernel BUG at mm/hugetlb.c:1218!
> 
> When mapcount accounting was reworked, the setting of compound_mapcount_ptr
> in prep_compound_gigantic_page was overlooked.  As a result, the validation
> of mapcount in free_huge_page fails.

Oops. Soory for that.

> 
> The "BUG_ON" checks in free_huge_page were also changed to "VM_BUG_ON_PAGE"
> to assist with debugging.
> 
> Fixes: af5642a8af ("mm: rework mapcount accounting to enable 4k mapping of THPs")
> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> ---
>  mm/hugetlb.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 12908dc..d7a8024 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1214,8 +1214,8 @@ void free_huge_page(struct page *page)
>  
>  	set_page_private(page, 0);
>  	page->mapping = NULL;
> -	BUG_ON(page_count(page));
> -	BUG_ON(page_mapcount(page));
> +	VM_BUG_ON_PAGE(page_count(page), page);
> +	VM_BUG_ON_PAGE(page_mapcount(page), page);
>  	restore_reserve = PagePrivate(page);
>  	ClearPagePrivate(page);
>  
> @@ -1286,6 +1286,7 @@ static void prep_compound_gigantic_page(struct page *page, unsigned int order)
>  		set_page_count(p, 0);
>  		set_compound_head(p, page);
>  	}
> +	atomic_set(compound_mapcount_ptr(page), -1);
>  }
>  
>  /*
> -- 
> 2.4.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
