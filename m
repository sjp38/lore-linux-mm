Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2C90B6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:18:00 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so67171055wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:17:59 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id b4si20569711wic.119.2015.08.24.03.17.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 03:17:58 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so67170250wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:17:58 -0700 (PDT)
Date: Mon, 24 Aug 2015 13:17:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150824101755.GA2370@node.dhcp.inet.fi>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 19, 2015 at 12:21:45PM +0300, Kirill A. Shutemov wrote:
> Hugh has pointed that compound_head() call can be unsafe in some
> context. There's one example:
> 
> 	CPU0					CPU1
> 
> isolate_migratepages_block()
>   page_count()
>     compound_head()
>       !!PageTail() == true
> 					put_page()
> 					  tail->first_page = NULL
>       head = tail->first_page
> 					alloc_pages(__GFP_COMP)
> 					   prep_compound_page()
> 					     tail->first_page = head
> 					     __SetPageTail(p);
>       !!PageTail() == true
>     <head == NULL dereferencing>
> 
> The race is pure theoretical. I don't it's possible to trigger it in
> practice. But who knows.
> 
> We can fix the race by changing how encode PageTail() and compound_head()
> within struct page to be able to update them in one shot.
> 
> The patch introduces page->compound_head into third double word block in
> front of compound_dtor and compound_order. That means it shares storage
> space with:
> 
>  - page->lru.next;
>  - page->next;
>  - page->rcu_head.next;
>  - page->pmd_huge_pte;
> 
> That's too long list to be absolutely sure, but looks like nobody uses
> bit 0 of the word. It can be used to encode PageTail(). And if the bit
> set, rest of the word is pointer to head page.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>

If DEFERRED_STRUCT_PAGE_INIT=n, combining this patchset with my page-flags
patches causes oops in SetPageReserved() called from
reserve_bootmem_region().

It happens because we haven't yet initilized the word in struct page and
PageTail() inside SetPageReserved() can give false-positive, which leads
to bogus compound_head() result.

IIUC, we initialize the word only on first allocation of the page. It can
be too late: pfn scanner can see false-positive PageTail() from not yet
allocated pages too.

Here's fixlet for patch to address the issue.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 347724850665..d0e3fca830f8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -892,6 +892,8 @@ static void init_reserved_page(unsigned long pfn)
 #else
 static inline void init_reserved_page(unsigned long pfn)
 {
+	/* Avoid false-positive PageTail() */
+	INIT_LIST_HEAD(&pfn_to_page(pfn)->lru);
 }
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
