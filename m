Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 67ACE6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 05:52:34 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so72049204wib.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 02:52:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h9si17406728wix.59.2015.06.15.02.52.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Jun 2015 02:52:28 -0700 (PDT)
Message-ID: <557EA05B.3040405@suse.cz>
Date: Mon, 15 Jun 2015 11:52:27 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH RFC v0 0/6] mm: proof-of-concept memory compaction without
 isolation
References: <20150615073926.18112.59207.stgit@zurg>
In-Reply-To: <20150615073926.18112.59207.stgit@zurg>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org

On 06/15/2015 09:50 AM, Konstantin Khlebnikov wrote:
> This is incomplete implementation of non-isolating memory migration and
> compaction. It's alive!
>
> The main reason -- it can preserve lru order during compaction.

That's nice, and there's also another benefit - no lru_lock taken during 
migration scanner.

So I think it's worth pursuing. But after brief checking, I'm not sure 
it can work as it is (but maybe I just overlooked something). What 
prevents somebody else to isolate the old page from the lru while you 
are migrating it? Especially in Patch 6, it appears that a PageLRU() is 
tested without any lock and only then insert_lru_page() takes the 
lru_lock to do something. This seems racy to me.

>
> Also it makes implementation of migration for various types of pages: zram,
> balloon, ptes, kernel stacks [ Why not? I've already migrated them accidentally
> and kernel have crashed in very funny places ] much easier: owner just have to
> set page->mappingw with valid method a_ops->migratepage.
>
> ---
>
> Konstantin Khlebnikov (6):
>        pagevec: segmented page vectors
>        mm/migrate: move putback of old page out of unmap_and_move
>        mm/cma: repalce reclaim_clean_pages_from_list with try_to_reclaim_page
>        mm/migrate: page migration without page isolation
>        mm/compaction: use migration without isolation
>        mm/migrate: preserve lru order if possible
>
>
>   include/linux/migrate.h           |    4 +
>   include/linux/mm.h                |    1
>   include/linux/pagevec.h           |   48 ++++++++-
>   include/trace/events/compaction.h |   12 +-
>   mm/compaction.c                   |  205 +++++++++++++++++++++----------------
>   mm/filemap.c                      |   20 ++++
>   mm/internal.h                     |   12 +-
>   mm/migrate.c                      |  141 +++++++++++++++++++++----
>   mm/page_alloc.c                   |   35 ++++--
>   mm/swap.c                         |   69 ++++++++++++
>   mm/vmscan.c                       |   42 +-------
>   11 files changed, 410 insertions(+), 179 deletions(-)
>
> --
> Konstantin
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
