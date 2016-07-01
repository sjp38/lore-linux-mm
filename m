Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AFA276B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 04:30:40 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id f6so26904514ith.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 01:30:40 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id l133si2432048ioa.213.2016.07.01.01.30.38
        for <linux-mm@kvack.org>;
        Fri, 01 Jul 2016 01:30:39 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <016001d1d36e$ef1db5a0$cd5920e0$@alibaba-inc.com>
In-Reply-To: <016001d1d36e$ef1db5a0$cd5920e0$@alibaba-inc.com>
Subject: Re: [PATCH 4/6] mm: move flush in madvise_free_pte_range()
Date: Fri, 01 Jul 2016 16:30:23 +0800
Message-ID: <016101d1d372$d0317650$709462f0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dave Hansen' <dave@sr71.net>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> I think this code is OK and does not *need* to be patched.  We
> are just rewriting the PTE without the Accessed and Dirty bits.
> The hardware could come along and set them at any time with or
> without the erratum that this series addresses
> 
> But this does make the ptep_get_and_clear_full() and
> tlb_remove_tlb_entry() calls here more consistent with the other
> places they are used together and look *obviously* the same
> between call-sites.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> ---
> 
>  b/mm/madvise.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN mm/madvise.c~knl-leak-40-madvise_free_pte_range-move-flush mm/madvise.c
> --- a/mm/madvise.c~knl-leak-40-madvise_free_pte_range-move-flush	2016-06-30 17:10:42.557246755 -0700
> +++ b/mm/madvise.c	2016-06-30 17:10:42.561246936 -0700
> @@ -369,13 +369,13 @@ static int madvise_free_pte_range(pmd_t
>  			 */
>  			ptent = ptep_get_and_clear_full(mm, addr, pte,
>  							tlb->fullmm);
> +			tlb_remove_tlb_entry(tlb, pte, addr);
> 

Then the current comment has to be updated, no?-/

thanks
Hillf
>  			ptent = pte_mkold(ptent);
>  			ptent = pte_mkclean(ptent);
>  			set_pte_at(mm, addr, pte, ptent);
>  			if (PageActive(page))
>  				deactivate_page(page);
> -			tlb_remove_tlb_entry(tlb, pte, addr);
>  		}
>  	}
>  out:
> _
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
