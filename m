Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0A508828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 05:54:07 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id b14so116844798wmb.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 02:54:07 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id h79si18992755wme.86.2016.01.07.02.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 02:54:05 -0800 (PST)
Received: by mail-wm0-f53.google.com with SMTP id l65so91890921wmf.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 02:54:05 -0800 (PST)
Date: Thu, 7 Jan 2016 11:54:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 12/14] mm, page_owner: track and print last migrate
 reason
Message-ID: <20160107105404.GJ27868@dhcp22.suse.cz>
References: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
 <1450429406-7081-13-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450429406-7081-13-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Fri 18-12-15 10:03:24, Vlastimil Babka wrote:
> During migration, page_owner info is now copied with the rest of the page, so
> the stacktrace leading to free page allocation during migration is overwritten.
> For debugging purposes, it might be however useful to know that the page has
> been migrated since its initial allocation. This might happen many times during
> the lifetime for different reasons and fully tracking this, especially with
> stacktraces would incur extra memory costs. As a compromise, store and print
> the migrate_reason of the last migration that occurred to the page. This is
> enough to distinguish compaction, numa balancing etc.

So you know that the page has been migrated because of compaction the
last time. You do not know anything about the previous migrations
though. How would you use that information during debugging? Wouldn't it
be sufficient to know that the page has been migrated (or count how many
times) instead? That would lead to less code and it might be sufficient
for practical use.

> Example page_owner entry after the patch:
> 
> Page allocated via order 0, mask 0x24213ca(GFP_HIGHUSER_MOVABLE|GFP_COLD|GFP_NOWARN|GFP_NORETRY)
> PFN 674308 type Movable Block 1317 type Movable Flags 0x1fffff80010068(uptodate|lru|active|mappedtodisk)
>  [<ffffffff81164e9a>] __alloc_pages_nodemask+0x15a/0xa30
>  [<ffffffff811ab938>] alloc_pages_current+0x88/0x120
>  [<ffffffff8115bc46>] __page_cache_alloc+0xe6/0x120
>  [<ffffffff81168b9b>] __do_page_cache_readahead+0xdb/0x200
>  [<ffffffff81168df5>] ondemand_readahead+0x135/0x260
>  [<ffffffff81168f8c>] page_cache_async_readahead+0x6c/0x70
>  [<ffffffff8115d5f8>] generic_file_read_iter+0x378/0x590
>  [<ffffffff811d12a7>] __vfs_read+0xa7/0xd0
> Page has been migrated, last migrate reason: compaction
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> ---
>  include/linux/migrate.h    |  6 +++++-
>  include/linux/page_ext.h   |  1 +
>  include/linux/page_owner.h |  9 +++++++++
>  mm/debug.c                 | 11 +++++++++++
>  mm/migrate.c               | 10 +++++++---
>  mm/page_owner.c            | 17 +++++++++++++++++
>  6 files changed, 50 insertions(+), 4 deletions(-)
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
