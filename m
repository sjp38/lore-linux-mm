Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 926226B0256
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 05:10:09 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so15981856pab.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:10:09 -0700 (PDT)
Received: from us-alimail-mta2.hst.scl.en.alidc.net (mail113-249.mail.alibaba.com. [205.204.113.249])
        by mx.google.com with ESMTP id fd1si3720726pad.44.2015.10.13.02.10.07
        for <linux-mm@kvack.org>;
        Tue, 13 Oct 2015 02:10:08 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <004b01d10596$60e7eae0$22b7c0a0$@alibaba-inc.com>
In-Reply-To: <004b01d10596$60e7eae0$22b7c0a0$@alibaba-inc.com>
Subject: Re: [PATCH] hugetlb: clear PG_reserved before setting PG_head on gigantic pages
Date: Tue, 13 Oct 2015 17:09:52 +0800
Message-ID: <004e01d10596$eba6de70$c2f49b50$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> PF_NO_COMPOUND for PG_reserved assumes we don't use PG_reserved for
> compound pages. And we generally don't. But during allocation of
> gigantic pages we set PG_head before clearing PG_reserved and
> __ClearPageReserved() steps on the VM_BUG_ON_PAGE().
> 
> The fix is trivial: set PG_head after PG_reserved.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> 
> Andrew, this patch can be folded into "page-flags: define PG_reserved behavior on compound pages".
> 
> ---
>  mm/hugetlb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6ecf61ffa65d..bd3f3e20313b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1258,8 +1258,8 @@ static void prep_compound_gigantic_page(struct page *page, unsigned int order)
> 
>  	/* we rely on prep_new_huge_page to set the destructor */
>  	set_compound_order(page, order);
> -	__SetPageHead(page);
>  	__ClearPageReserved(page);
> +	__SetPageHead(page);
>  	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
>  		/*
>  		 * For gigantic hugepages allocated through bootmem at
> --
> 2.5.3
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
