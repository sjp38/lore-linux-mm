Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A966B6B02C3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:46:39 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o9so11488348iod.13
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:46:39 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id l92si8964225ioi.260.2017.08.07.11.46.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:46:38 -0700 (PDT)
Date: Mon, 7 Aug 2017 13:46:37 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] mm: Clear to access sub-page last when clearing huge
 page
In-Reply-To: <20170807072131.8343-1-ying.huang@intel.com>
Message-ID: <alpine.DEB.2.20.1708071343030.19915@nuc-kabylake>
References: <20170807072131.8343-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>

On Mon, 7 Aug 2017, Huang, Ying wrote:

> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4374,9 +4374,31 @@ void clear_huge_page(struct page *page,
>  	}
>
>  	might_sleep();
> -	for (i = 0; i < pages_per_huge_page; i++) {
> +	VM_BUG_ON(clamp(addr_hint, addr, addr +
> +			(pages_per_huge_page << PAGE_SHIFT)) != addr_hint);
> +	n = (addr_hint - addr) / PAGE_SIZE;
> +	if (2 * n <= pages_per_huge_page) {
> +		base = 0;
> +		l = n;
> +		for (i = pages_per_huge_page - 1; i >= 2 * n; i--) {
> +			cond_resched();
> +			clear_user_highpage(page + i, addr + i * PAGE_SIZE);
> +		}

I really like the idea behind the patch but this is not clearing from last
to first byte of the huge page.

What seems to be happening here is clearing from the last page to the
first page and I would think that within each page the clearing is from
first byte to last byte. Maybe more gains can be had by really clearing
from last to first byte of the huge page instead of this jumping over 4k
addresses?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
