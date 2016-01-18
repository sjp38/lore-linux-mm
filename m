Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 49E4D6B0009
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 18:03:27 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l65so117239934wmf.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 15:03:27 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id 5si28562714wmx.6.2016.01.18.15.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 15:03:26 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id b14so144836355wmb.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 15:03:26 -0800 (PST)
Date: Tue, 19 Jan 2016 01:03:24 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: avoid uninitialized variable in tracepoint
Message-ID: <20160118230324.GF14531@node.shutemov.name>
References: <4117363.Ys1FTDH7Wz@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4117363.Ys1FTDH7Wz@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, dan.carpenter@oracle.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, Jan 18, 2016 at 09:50:26PM +0100, Arnd Bergmann wrote:
> A newly added tracepoint in the hugepage code uses a variable in the
> error handling that is not initialized at that point:
> 
> include/trace/events/huge_memory.h:81:230: error: 'isolated' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> The result is relatively harmless, as the trace data will in rare
> cases contain incorrect data.
> 
> This works around the problem by adding an explicit initialization.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 7d2eba0557c1 ("mm: add tracepoint for scanning pages")

There's the same patch in mm tree, but it got lost on the way to Linus'
tree:

https://ozlabs.org/~akpm/mmots/broken-out/mm-make-optimistic-check-for-swapin-readahead-fix.patch

Andrew?

> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index b2db98136af9..bb3b763b1829 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2320,7 +2320,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	pgtable_t pgtable;
>  	struct page *new_page;
>  	spinlock_t *pmd_ptl, *pte_ptl;
> -	int isolated, result = 0;
> +	int isolated = 0, result = 0;
>  	unsigned long hstart, hend;
>  	struct mem_cgroup *memcg;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
