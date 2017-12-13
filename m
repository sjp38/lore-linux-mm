Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 788B96B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:20:38 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 80so1114306wmb.7
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:20:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v14sor1147612edc.43.2017.12.13.04.20.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 04:20:37 -0800 (PST)
Date: Wed, 13 Dec 2017 15:20:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 3/3] mm: unclutter THP migration
Message-ID: <20171213122035.av4kgn2lkbwk3ovn@node.shutemov.name>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208161559.27313-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, Dec 08, 2017 at 05:15:59PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> THP migration is hacked into the generic migration with rather
> surprising semantic. The migration allocation callback is supposed to
> check whether the THP can be migrated at once and if that is not the
> case then it allocates a simple page to migrate. unmap_and_move then
> fixes that up by spliting the THP into small pages while moving the
> head page to the newly allocated order-0 page. Remaning pages are moved
> to the LRU list by split_huge_page. The same happens if the THP
> allocation fails. This is really ugly and error prone [1].
> 
> I also believe that split_huge_page to the LRU lists is inherently
> wrong because all tail pages are not migrated. Some callers will just
> work around that by retrying (e.g. memory hotplug). There are other
> pfn walkers which are simply broken though. e.g. madvise_inject_error
> will migrate head and then advances next pfn by the huge page size.
> do_move_page_to_node_array, queue_pages_range (migrate_pages, mbind),
> will simply split the THP before migration if the THP migration is not
> supported then falls back to single page migration but it doesn't handle
> tail pages if the THP migration path is not able to allocate a fresh
> THP so we end up with ENOMEM and fail the whole migration which is
> a questionable behavior. Page compaction doesn't try to migrate large
> pages so it should be immune.
> 
> This patch tries to unclutter the situation by moving the special THP
> handling up to the migrate_pages layer where it actually belongs. We
> simply split the THP page into the existing list if unmap_and_move fails
> with ENOMEM and retry. So we will _always_ migrate all THP subpages and
> specific migrate_pages users do not have to deal with this case in a
> special way.
> 
> [1] http://lkml.kernel.org/r/20171121021855.50525-1-zi.yan@sent.com
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
