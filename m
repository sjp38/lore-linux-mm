Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00EF26B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:06:37 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w105so2065209wrc.20
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 01:06:36 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id a3si2947490edd.224.2017.10.18.01.06.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 01:06:35 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 8918C98E30
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 08:06:35 +0000 (UTC)
Date: Wed, 18 Oct 2017 09:06:31 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: simplify hot/cold page handling in
 rmqueue_bulk()
Message-ID: <20171018080631.7ebimdlwek4inits@techsingularity.net>
References: <20171018073528.30982-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171018073528.30982-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Wed, Oct 18, 2017 at 09:35:28AM +0200, Vlastimil Babka wrote:
> The rmqueue_bulk() function fills an empty pcplist with pages from the free
> list. It tries to preserve increasing order by pfn to the caller, because it
> leads to better performance with some I/O controllers, as explained in
> e084b2d95e48 ("page-allocator: preserve PFN ordering when __GFP_COLD is set").
> For callers requesting cold pages, which are obtained from the tail of
> pcplists, it means the pcplist has to be filled in reverse order from the free
> lists (the hot/cold property only applies when pages are recycled on the
> pcplists, not when refilled from free lists).
> 
> The related comment in rmqueue_bulk() wasn't clear to me without reading the
> log of the commit mentioned above, so try to clarify it.
> 
> The code for filling the pcplists in order determined by the cold flag also
> seems unnecessarily hard to follow. It's sufficient to either use list_add()
> or list_add_tail(), but the current code also updates the list head pointer
> in each step to the last added page, which then counterintuitively requires
> to switch the usage of list_add() and list_add_tail() to achieve the desired
> order, with no apparent benefit. This patch simplifies the code.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

The "cold" treatment is dubious because almost everything that frees
considers the page "hot" which limits the usefulness of hot/cold in the
allocator. While I do not see a problem with your patch as such, please
take a look at "mm: Remove __GFP_COLD" in particular. The last 4 patches
in that series make a number of observations on how "cold" is treated in
the allocator.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
