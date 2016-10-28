Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C34F66B027A
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 06:20:27 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rf5so40371701pab.3
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 03:20:27 -0700 (PDT)
Received: from out0-154.mail.aliyun.com (out0-154.mail.aliyun.com. [140.205.0.154])
        by mx.google.com with ESMTP id qb2si1061448pac.132.2016.10.28.03.20.26
        for <linux-mm@kvack.org>;
        Fri, 28 Oct 2016 03:20:26 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161028055608.1736-1-ying.huang@intel.com> <20161028055608.1736-9-ying.huang@intel.com>
In-Reply-To: <20161028055608.1736-9-ying.huang@intel.com>
Subject: Re: [PATCH -v4 RESEND 8/9] mm, THP, swap: Support to split THP in swap cache
Date: Fri, 28 Oct 2016 18:18:34 +0800
Message-ID: <052901d23104$a6473380$f2d59a80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Huang, Ying'" <ying.huang@intel.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Andrea Arcangeli' <aarcange@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, 'Ebru Akagunduz' <ebru.akagunduz@gmail.com>

On Friday, October 28, 2016 1:56 PM Huang, Ying wrote: 
> @@ -2016,10 +2021,12 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
>  /* Racy check whether the huge page can be split */
>  bool can_split_huge_page(struct page *page)
>  {
> -	int extra_pins = 0;
> +	int extra_pins;
> 
>  	/* Additional pins from radix tree */
> -	if (!PageAnon(page))
> +	if (PageAnon(page))
> +		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
> +	else
>  		extra_pins = HPAGE_PMD_NR;

extra_pins is computed in this newly added helper.

>  	return total_mapcount(page) == page_count(page) - extra_pins - 1;
>  }
> @@ -2072,7 +2079,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  			ret = -EBUSY;
>  			goto out;
>  		}
> -		extra_pins = 0;
> +		extra_pins = PageSwapCache(head) ? HPAGE_PMD_NR : 0;

It is also computed at the call site, so can we fold them into one?

>  		mapping = NULL;
>  		anon_vma_lock_write(anon_vma);
>  	} else {
> --
> 2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
