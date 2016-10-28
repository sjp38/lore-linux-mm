Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 262726B027A
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 04:08:54 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hm5so38937813pac.4
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 01:08:54 -0700 (PDT)
Received: from out0-147.mail.aliyun.com (out0-147.mail.aliyun.com. [140.205.0.147])
        by mx.google.com with ESMTP id he1si10231728pac.124.2016.10.28.01.08.52
        for <linux-mm@kvack.org>;
        Fri, 28 Oct 2016 01:08:53 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161028055608.1736-1-ying.huang@intel.com> <20161028055608.1736-7-ying.huang@intel.com>
In-Reply-To: <20161028055608.1736-7-ying.huang@intel.com>
Subject: Re: [PATCH -v4 RESEND 6/9] mm, THP, swap: Support to add/delete THP to/from swap cache
Date: Fri, 28 Oct 2016 16:08:46 +0800
Message-ID: <050a01d230f2$826f0b20$874d2160$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Huang, Ying'" <ying.huang@intel.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Hugh Dickins' <hughd@google.com>, 'Shaohua Li' <shli@kernel.org>, 'Minchan Kim' <minchan@kernel.org>, 'Rik van Riel' <riel@redhat.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>

On Friday, October 28, 2016 1:56 PM Huang, Ying wrote:
> 
> @@ -109,9 +118,16 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
>  		 * So add_to_swap_cache() doesn't returns -EEXIST.
>  		 */
>  		VM_BUG_ON(error == -EEXIST);
> -		set_page_private(page, 0UL);
>  		ClearPageSwapCache(page);
> -		put_page(page);
> +		set_page_private(cur_page, 0UL);
> +		while (i--) {
> +			cur_page--;
> +			cur_entry.val--;
> +			set_page_private(cur_page, 0UL);
> +			radix_tree_delete(&address_space->page_tree,
> +					  swp_offset(cur_entry));
> +		}

Pull pages out of radix tree with tree lock held?

> +		page_ref_sub(page, nr);
>  	}
> 
>  	return error;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
