Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6BE16B0388
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 14:36:37 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 68so13637769ioh.4
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 11:36:37 -0800 (PST)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id v99si1406028ioi.163.2017.03.07.11.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 11:36:36 -0800 (PST)
Received: by mail-io0-x242.google.com with SMTP id n76so1624607ioe.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 11:36:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbJpbD=dLwAWCuu+o-1phEA1eVNLOJb62fj-RvkJPR0+fA@mail.gmail.com>
References: <20161216120009.20064-1-vbabka@suse.cz> <20161216120009.20064-2-vbabka@suse.cz>
 <CA+8MBbJpbD=dLwAWCuu+o-1phEA1eVNLOJb62fj-RvkJPR0+fA@mail.gmail.com>
From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 7 Mar 2017 11:36:36 -0800
Message-ID: <CA+8MBbJNWT5LmekxdLz96_L62qHRJF3_PztjYVBikgv5goorbA@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] mm, page_alloc: avoid page_to_pfn() when merging buddies
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Mar 7, 2017 at 10:40 AM, Tony Luck <tony.luck@gmail.com> wrote:
> The commit messages talks about the "only caller" of page_is_buddy().
> But grep shows two call sites:
>
> mm/page_alloc.c:816:            if (!page_is_buddy(page, buddy, order))
> mm/page_alloc.c:876:            if (page_is_buddy(higher_page,

and it looks like the second one is the problem:

        if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)) {
                struct page *higher_page, *higher_buddy;
                combined_pfn = buddy_pfn & pfn;
                higher_page = page + (combined_pfn - pfn);
                buddy_pfn = __find_buddy_pfn(combined_pfn, order + 1);
                higher_buddy = higher_page + (buddy_pfn - combined_pfn);
                if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
                        list_add_tail(&page->lru,
                                &zone->free_area[order].free_list[migratetype]);
                        goto out;
                }
        }

Although outer "if" checked for pfn_valid_within(buddy_pfn),
we actually pass "higher_buddy" to this call of page_is_buddy().

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
