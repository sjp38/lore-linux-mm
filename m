Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 905CF6B00A8
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 16:09:32 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so5331009pbb.7
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 13:09:32 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ot7si31816881pbc.164.2014.06.09.13.09.31
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 13:09:31 -0700 (PDT)
Message-ID: <53961338.4050309@intel.com>
Date: Mon, 09 Jun 2014 13:04:08 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm/pagewalk: move pmd_trans_huge_lock() from callbacks
 to common code
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1402095520-10109-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402095520-10109-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On 06/06/2014 03:58 PM, Naoya Horiguchi wrote:
> @@ -6723,14 +6723,9 @@ static int mem_cgroup_count_precharge_pmd(pmd_t *pmd,
>  					struct mm_walk *walk)
>  {
>  	struct vm_area_struct *vma = walk->vma;
> -	spinlock_t *ptl;
>  
> -	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
> -		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
> -			mc.precharge += HPAGE_PMD_NR;
> -		spin_unlock(ptl);
> -	} else
> -		skip->control = PTWALK_DOWN;
> +	if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
> +		mc.precharge += HPAGE_PMD_NR;
>  	return 0;
>  }

I guess my series did two things:
1. move page table walking to the walk_page_range() code
2. make new walk handler that can take arbitrarily-sizes ptes

This does (1) quite nicely and has some nice code savings.  I still
think (2) has some value, and like my approach, but this is definitely a
step in the right direction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
