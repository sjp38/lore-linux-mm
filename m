Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC7D828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 12:28:33 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id n127so60362572vkb.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:28:33 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t186si408427vkg.205.2016.06.23.09.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 09:28:32 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: clear compound_mapcount when freeing gigantic
 pages
References: <1466612719-5642-1-git-send-email-gerald.schaefer@de.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6a371d8e-748c-d6cf-e563-7515b3a1c318@oracle.com>
Date: Thu, 23 Jun 2016 09:28:18 -0700
MIME-Version: 1.0
In-Reply-To: <1466612719-5642-1-git-send-email-gerald.schaefer@de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On 06/22/2016 09:25 AM, Gerald Schaefer wrote:
> While working on s390 support for gigantic hugepages I ran into the following
> "Bad page state" warning when freeing gigantic pages:
> 
> BUG: Bad page state in process bash  pfn:580001
> page:000003d116000040 count:0 mapcount:0 mapping:ffffffff00000000 index:0x0
> flags: 0x7fffc0000000000()
> page dumped because: non-NULL mapping
> 
> This is because page->compound_mapcount, which is part of a union with
> page->mapping, is initialized with -1 in prep_compound_gigantic_page(), and
> not cleared again during destroy_compound_gigantic_page(). Fix this by
> clearing the compound_mapcount in destroy_compound_gigantic_page() before
> clearing compound_head.
> 
> Interestingly enough, the warning will not show up on x86_64, although this
> should not be architecture specific. Apparently there is an endianness issue,
> combined with the fact that the union contains both a 64 bit ->mapping
> pointer and a 32 bit atomic_t ->compound_mapcount as members. The resulting
> bogus page->mapping on x86_64 therefore contains 00000000ffffffff instead
> of ffffffff00000000 on s390, which will falsely trigger the PageAnon() check
> in free_pages_prepare() because page->mapping & PAGE_MAPPING_ANON is true
> on little-endian architectures like x86_64 in this case (the page is not
> compound anymore, ->compound_head was already cleared before). As a result,
> page->mapping will be cleared before doing the checks in free_pages_check().
> 
> Not sure if the bogus "PageAnon() returning true" on x86_64 for the first
> tail page of a gigantic page (at this stage) has other theoretical
> implications, but they would also be fixed with this patch.
> 
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

Thanks Gerald, I agree with your fix.
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

However, like you I was wondering if this had any other implications.  I've
been examining code and can not find other places where this could be an
issue.  I did not find any issues, and in general since this is/was a huge
page, nobody should be doing PageAnon() on the tail pages except in a tear
down operation like this.

It would be great if someone with more page counting experience could
comment on this.

-- 
Mike Kravetz

> ---
>  mm/hugetlb.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e197cd7..b64f8b7 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1030,6 +1030,7 @@ static void destroy_compound_gigantic_page(struct page *page,
>  	int nr_pages = 1 << order;
>  	struct page *p = page + 1;
>  
> +	atomic_set(compound_mapcount_ptr(page), 0);
>  	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
>  		clear_compound_head(p);
>  		set_page_refcounted(p);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
