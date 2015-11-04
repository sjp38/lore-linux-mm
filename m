Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 777176B0254
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 04:20:48 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so23578870pac.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 01:20:48 -0800 (PST)
Received: from out21.biz.mail.alibaba.com (out114-136.biz.mail.alibaba.com. [205.204.114.136])
        by mx.google.com with ESMTP id gn6si814968pbc.40.2015.11.04.01.20.44
        for <linux-mm@kvack.org>;
        Wed, 04 Nov 2015 01:20:47 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <052401d116e0$c3ac0110$4b040330$@alibaba-inc.com>
In-Reply-To: <052401d116e0$c3ac0110$4b040330$@alibaba-inc.com>
Subject: Re: [PATCH 3/4] thp: fix split vs. unmap race
Date: Wed, 04 Nov 2015 17:20:15 +0800
Message-ID: <052701d116e2$0437a2b0$0ca6e810$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 'Minchan Kim' <minchan@kernel.org>

> @@ -1135,20 +1135,12 @@ void do_page_add_anon_rmap(struct page *page,
>  	bool compound = flags & RMAP_COMPOUND;
>  	bool first;
> 
> -	if (PageTransCompound(page)) {
> +	if (compound) {
> +		atomic_t *mapcount;
>  		VM_BUG_ON_PAGE(!PageLocked(page), page);
> -		if (compound) {
> -			atomic_t *mapcount;
> -
> -			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> -			mapcount = compound_mapcount_ptr(page);
> -			first = atomic_inc_and_test(mapcount);
> -		} else {
> -			/* Anon THP always mapped first with PMD */
> -			first = 0;
> -			VM_BUG_ON_PAGE(!page_mapcount(page), page);
> -			atomic_inc(&page->_mapcount);
> -		}
> +		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> +		mapcount = compound_mapcount_ptr(page);
> +		first = atomic_inc_and_test(mapcount);
>  	} else {
>  		VM_BUG_ON_PAGE(compound, page);

Then this debug info is no longer needed.
>  		first = atomic_inc_and_test(&page->_mapcount);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
