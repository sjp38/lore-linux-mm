Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id BA5E96B00B3
	for <linux-mm@kvack.org>; Tue, 19 May 2015 09:54:49 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so18891205wgb.3
        for <linux-mm@kvack.org>; Tue, 19 May 2015 06:54:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eh5si23599964wjd.174.2015.05.19.06.54.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 06:54:48 -0700 (PDT)
Message-ID: <555B40A4.8000109@suse.cz>
Date: Tue, 19 May 2015 15:54:44 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 26/28] thp: introduce deferred_split_huge_page()
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-27-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-27-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:04 PM, Kirill A. Shutemov wrote:
> Currently we don't split huge page on partial unmap. It's not an ideal
> situation. It can lead to memory overhead.
>
> Furtunately, we can detect partial unmap on page_remove_rmap(). But we
> cannot call split_huge_page() from there due to locking context.
>
> It's also counterproductive to do directly from munmap() codepath: in
> many cases we will hit this from exit(2) and splitting the huge page
> just to free it up in small pages is not what we really want.
>
> The patch introduce deferred_split_huge_page() which put the huge page
> into queue for splitting. The splitting itself will happen when we get
> memory pressure via shrinker interface. The page will be dropped from
> list on freeing through compound page destructor.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> @@ -715,6 +726,12 @@ static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
>   	return entry;
>   }
>
> +void prep_transhuge_page(struct page *page)
> +{
> +	INIT_LIST_HEAD(&page[2].lru);

Wouldn't hurt to mention that you use page[2] because lru in page 1 
would collide with the dtor (right?).

> +	set_compound_page_dtor(page, free_transhuge_page);
> +}
> +
>   static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>   					struct vm_area_struct *vma,
>   					unsigned long haddr, pmd_t *pmd,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
