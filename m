Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC2796B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:04:59 -0500 (EST)
Received: by wmpp66 with SMTP id p66so57743482wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:04:59 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id mn10si45446692wjc.177.2015.12.14.04.04.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 04:04:58 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id p66so58668645wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:04:58 -0800 (PST)
Date: Mon, 14 Dec 2015 14:04:56 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: isolate_lru_page on !head pages
Message-ID: <20151214120456.GA4201@node.shutemov.name>
References: <20151209130204.GD30907@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209130204.GD30907@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 09, 2015 at 02:02:05PM +0100, Michal Hocko wrote:
> Hi Kirill,

[ sorry for late reply, just back from vacation. ]

> while looking at the issue reported by Minchan [1] I have noticed that
> there is nothing to prevent from "isolating" a tail page from LRU because
> isolate_lru_page checks PageLRU which is
> PAGEFLAG(LRU, lru, PF_HEAD)
> so it is checked on the head page rather than the given page directly
> but the rest of the operation is done on the given (tail) page.

Looks like most (all?) callers already exclude PTE-mapped THP already one
way or another.
Probably, VM_BUG_ON_PAGE(PageTail(page), page) in isolate_lru_page() would
be appropriate.

> This is really subtle because this expects that every caller of this
> function checks for the tail page otherwise we would clobber statistics
> and who knows what else (I haven't checked that in detail) as the page
> cannot be on the LRU list and the operation makes sense only on the head
> page.
> 
> Would it make more sense to make PageLRU PF_ANY? That would return
> false for PageLRU on any tail page and so it would be ignored by
> isolate_lru_page.

I don't think this is right way to go. What we put on LRU is compound
page, not 4k subpages. PageLRU() should return true if the compound page
is on LRU regardless if you ask for head or tail page.

False-negatives PageLRU() can be as bad as bug Minchan reported, but
perhaps more silent.

> I haven't checked other flags but there might be a similar situation. I
> am wondering whether it is really a good idea to perform a flag check on
> a different page then the operation which depends on the result of the
> test in general. It sounds like a maintenance horror to me.
> 
> [1] http://lkml.kernel.org/r/20151201133455.GB27574@bbox
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
