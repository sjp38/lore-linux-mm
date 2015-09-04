Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 56D656B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 09:43:57 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so25048704pac.3
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 06:43:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id qh9si4396750pac.204.2015.09.04.06.43.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 06:43:56 -0700 (PDT)
Date: Fri, 4 Sep 2015 15:43:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCHv5 0/7] Fix compound_head() race
Message-ID: <20150904134353.GD31717@redhat.com>
References: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 03, 2015 at 03:35:51PM +0300, Kirill A. Shutemov wrote:
> Kirill A. Shutemov (7):
>   mm: drop page->slab_page
>   slub: use page->rcu_head instead of page->lru plus cast
>   zsmalloc: use page->private instead of page->first_page
>   mm: pack compound_dtor and compound_order into one word in struct page
>   mm: make compound_head() robust
>   mm: use 'unsigned int' for page order
>   mm: use 'unsigned int' for compound_dtor/compound_order on 64BIT

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

The only other alternative solution that doesn't require finding a bit
zero at the LSB in a field unused in tail pages, is to drop both
PG_head and PG_tail, and reserve 4 bits from page->flags.

This means a net loss of 2 bits from page->flags (and loss of 3 bits
if !CONFIG_PAGEFLAGS_EXTENDED), but then everything becomes simple and
there's no need of finding a LSB field that is guaranteed zero at all
times.

With those 4 bits, you clear them for not compound pages. When you
create a compound page you encode the compound_order in those 4 bits
of page->flags, equal for for all head and tail
pages. compound_order() then becomes atomically available for tail
pages too and compound_order goes away from struct page along with
first_page (and there's no need to add a compound_head).

In PageCompound you read the 4 bits, if they're not all zero it's
compound, otherwise it's not.

In PageHead/Tail, if the 4 bits are all zero it's not head/tail,
otherwise you do the math on the page_to_pfn(page). If the pfn is
naturally aligned against the order encoded in the 4 bits "!(pfn &
(1<<order)-1)" it's a head, otherwise it's a tail.

If it's a tail, for the compound_head then it's just a matter of doing
"return page - (pfn & ((1<<order)-1)" (no need of pfn_to_page).

This leverages the physical natural alignment of compound pages for
all orders. It'd cover up to CONFIG_FORCE_MAX_ZONEORDER == 16
(128MBytes of order 15 with PAGE_SIZE 4kb).

page_to_pfn can actually be replaced with
(&NODE_DATA(page_to_nid(page))->node_mem_map-page) which is faster as
page_to_nid only need to accesses page->flags which is already in
L1. So then it costs only one cacheline access in the pgdat and a sub.

Because of the two (or three) additional bits taken out of page->flags
I doubt it's viable on 32bit, but I thought I'd mention it just in case.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
