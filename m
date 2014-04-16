Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id D7AC66B004D
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 10:48:01 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so10981091pbb.15
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 07:48:01 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id wh4si12847567pbc.348.2014.04.16.07.48.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 07:48:00 -0700 (PDT)
Message-ID: <534E97D7.4060903@oracle.com>
Date: Wed, 16 Apr 2014 10:46:47 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] thp: close race between split and zap huge pages
References: <1397598515-25017-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1397598515-25017-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Dave Jones <davej@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 04/15/2014 05:48 PM, Kirill A. Shutemov wrote:
> Sasha Levin has reported two THP BUGs[1][2]. I believe both of them have
> the same root cause. Let's look to them one by one.
> 
> The first bug[1] is "kernel BUG at mm/huge_memory.c:1829!".
> It's BUG_ON(mapcount != page_mapcount(page)) in __split_huge_page().
> From my testing I see that page_mapcount() is higher than mapcount here.
> 
> I think it happens due to race between zap_huge_pmd() and
> page_check_address_pmd(). page_check_address_pmd() misses PMD
> which is under zap:
> 
> 	CPU0						CPU1
> 						zap_huge_pmd()
> 						  pmdp_get_and_clear()
> __split_huge_page()
>   anon_vma_interval_tree_foreach()
>     __split_huge_page_splitting()
>       page_check_address_pmd()
>         mm_find_pmd()
> 	  /*
> 	   * We check if PMD present without taking ptl: no
> 	   * serialization against zap_huge_pmd(). We miss this PMD,
> 	   * it's not accounted to 'mapcount' in __split_huge_page().
> 	   */
> 	  pmd_present(pmd) == 0
> 
>   BUG_ON(mapcount != page_mapcount(page)) // CRASH!!!
> 
> 						  page_remove_rmap(page)
> 						    atomic_add_negative(-1, &page->_mapcount)
> 
> The second bug[2] is "kernel BUG at mm/huge_memory.c:1371!".
> It's VM_BUG_ON_PAGE(!PageHead(page), page) in zap_huge_pmd().
> 
> This happens in similar way:
> 
> 	CPU0						CPU1
> 						zap_huge_pmd()
> 						  pmdp_get_and_clear()
> 						  page_remove_rmap(page)
> 						    atomic_add_negative(-1, &page->_mapcount)
> __split_huge_page()
>   anon_vma_interval_tree_foreach()
>     __split_huge_page_splitting()
>       page_check_address_pmd()
>         mm_find_pmd()
> 	  pmd_present(pmd) == 0	/* The same comment as above */
>   /*
>    * No crash this time since we already decremented page->_mapcount in
>    * zap_huge_pmd().
>    */
>   BUG_ON(mapcount != page_mapcount(page))
> 
>   /*
>    * We split the compound page here into small pages without
>    * serialization against zap_huge_pmd()
>    */
>   __split_huge_page_refcount()
> 						VM_BUG_ON_PAGE(!PageHead(page), page); // CRASH!!!
> 
> So my understanding the problem is pmd_present() check in mm_find_pmd()
> without taking page table lock.
> 
> The bug was introduced by me commit with commit 117b0791ac42. Sorry for
> that. :(
> 
> Let's open code mm_find_pmd() in page_check_address_pmd() and do the
> check under page table lock.
> 
> Note that __page_check_address() does the same for PTE entires
> if sync != 0.
> 
> I've stress tested split and zap code paths for 36+ hours by now and
> don't see crashes with the patch applied. Before it took <20 min to
> trigger the first bug and few hours for second one (if we ignore
> first).
> 
> [1] https://lkml.kernel.org/g/<53440991.9090001@oracle.com>
> [2] https://lkml.kernel.org/g/<5310C56C.60709@oracle.com>
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: <stable@vger.kernel.org> #3.13+

Seems to work for me, thanks!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
