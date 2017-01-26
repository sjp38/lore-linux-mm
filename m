Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 22FC86B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 01:56:40 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f5so300284100pgi.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 22:56:40 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id r22si585449pfi.273.2017.01.25.22.56.37
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 22:56:39 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com> <20170125182538.86249-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170125182538.86249-6-kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 05/12] mm, rmap: check all VMAs that PTE-mapped THP can be part of
Date: Thu, 26 Jan 2017 14:56:20 +0800
Message-ID: <008a01d277a1$4d7021c0$e8506540$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Hugh Dickins' <hughd@google.com>, 'Rik van Riel' <riel@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


On January 26, 2017 2:26 AM Kirill A. Shutemov wrote: 
> @@ -333,12 +333,15 @@ __vma_address(struct page *page, struct vm_area_struct *vma)
>  static inline unsigned long
>  vma_address(struct page *page, struct vm_area_struct *vma)
>  {
> -	unsigned long address = __vma_address(page, vma);
> +	unsigned long start, end;
> +
> +	start = __vma_address(page, vma);
> +	end = start + PAGE_SIZE * (hpage_nr_pages(page) - 1);
> 
>  	/* page should be within @vma mapping range */
> -	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
> +	VM_BUG_ON_VMA(end < vma->vm_start || start >= vma->vm_end, vma);
> 
> -	return address;
> +	return max(start, vma->vm_start);
>  }
Nit: currently it's buggy if page is not within the mapping range.
In this work fix is added for start if unlikely it goes outside range, and 
its currently relevant debugging is cut off.

Other than that,
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
