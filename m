Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A5C4E6B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 21:40:51 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m2-v6so16123103plt.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:40:51 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id j1-v6si1175630pll.493.2018.07.11.18.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 18:40:50 -0700 (PDT)
Subject: Re: [PATCH] thp: fix data loss when splitting a file pmd
References: <alpine.LSU.2.11.1807111741430.1106@eggly.anvils>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <769d0c1d-120a-9a0b-28e3-477830b4606a@linux.alibaba.com>
Date: Wed, 11 Jul 2018 18:40:20 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1807111741430.1106@eggly.anvils>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ashwin Chaugule <ashwinch@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 7/11/18 5:48 PM, Hugh Dickins wrote:
> __split_huge_pmd_locked() must check if the cleared huge pmd was dirty,
> and propagate that to PageDirty: otherwise, data may be lost when a huge
> tmpfs page is modified then split then reclaimed.
>
> How has this taken so long to be noticed?  Because there was no problem
> when the huge page is written by a write system call (shmem_write_end()
> calls set_page_dirty()), nor when the page is allocated for a write fault
> (fault_dirty_shared_page() calls set_page_dirty()); but when allocated
> for a read fault (which MAP_POPULATE simulates), no set_page_dirty().

Sounds good to me. Reviewed-by: Yang Shi <yang.shi@linux.alibaba.com>

> Fixes: d21b9e57c74c ("thp: handle file pages in split_huge_pmd()")
> Reported-by: Ashwin Chaugule <ashwinch@google.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: "Huang, Ying" <ying.huang@intel.com>
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: <stable@vger.kernel.org> # v4.8+
> ---
>
>   mm/huge_memory.c |    2 ++
>   1 file changed, 2 insertions(+)
>
> --- 4.18-rc4/mm/huge_memory.c	2018-06-16 18:48:22.029173363 -0700
> +++ linux/mm/huge_memory.c	2018-07-10 20:11:29.991011603 -0700
> @@ -2084,6 +2084,8 @@ static void __split_huge_pmd_locked(stru
>   		if (vma_is_dax(vma))
>   			return;
>   		page = pmd_page(_pmd);
> +		if (!PageDirty(page) && pmd_dirty(_pmd))
> +			set_page_dirty(page);
>   		if (!PageReferenced(page) && pmd_young(_pmd))
>   			SetPageReferenced(page);
>   		page_remove_rmap(page, true);
