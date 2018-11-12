Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC3E6B027C
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 06:54:03 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x98-v6so4648719ede.0
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 03:54:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j15-v6si3024218edl.319.2018.11.12.03.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 03:54:01 -0800 (PST)
Date: Mon, 12 Nov 2018 12:54:00 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: cleancache: fix corruption on missed inode
 invalidation
Message-ID: <20181112115400.GE7175@quack2.suse.cz>
References: <20181112095734.17979-1-ptikhomirov@virtuozzo.com>
 <20181112113153.GC7175@quack2.suse.cz>
 <2abdb97e-0fed-0fb5-6941-e7afcc9e0209@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2abdb97e-0fed-0fb5-6941-e7afcc9e0209@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Jan Kara <jack@suse.cz>, Pavel Tikhomirov <ptikhomirov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Vasily Averin <vvs@virtuozzo.com>, Konstantin Khorenko <khorenko@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 12-11-18 14:40:06, Andrey Ryabinin wrote:
> 
> 
> On 11/12/18 2:31 PM, Jan Kara wrote:
> > On Mon 12-11-18 12:57:34, Pavel Tikhomirov wrote:
> >> If all pages are deleted from the mapping by memory reclaim and also
> >> moved to the cleancache:
> >>
> >> __delete_from_page_cache
> >>   (no shadow case)
> >>   unaccount_page_cache_page
> >>     cleancache_put_page
> >>   page_cache_delete
> >>     mapping->nrpages -= nr
> >>     (nrpages becomes 0)
> >>
> >> We don't clean the cleancache for an inode after final file truncation
> >> (removal).
> >>
> >> truncate_inode_pages_final
> >>   check (nrpages || nrexceptional) is false
> >>     no truncate_inode_pages
> >>       no cleancache_invalidate_inode(mapping)
> >>
> >> These way when reading the new file created with same inode we may get
> >> these trash leftover pages from cleancache and see wrong data instead of
> >> the contents of the new file.
> >>
> >> Fix it by always doing truncate_inode_pages which is already ready for
> >> nrpages == 0 && nrexceptional == 0 case and just invalidates inode.
> >>
> >> Fixes: commit 91b0abe36a7b ("mm + fs: store shadow entries in page cache")
> >> To: Andrew Morton <akpm@linux-foundation.org>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Mel Gorman <mgorman@techsingularity.net>
> >> Cc: Jan Kara <jack@suse.cz>
> >> Cc: Matthew Wilcox <willy@infradead.org>
> >> Cc: Andi Kleen <ak@linux.intel.com>
> >> Cc: linux-mm@kvack.org
> >> Cc: linux-kernel@vger.kernel.org
> >> Reviewed-by: Vasily Averin <vvs@virtuozzo.com>
> >> Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> >> Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
> >> ---
> >>  mm/truncate.c | 4 ++--
> >>  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > The patch looks good but can you add a short comment before the
> > truncate_inode_pages() call explaining why it needs to be called always?
> > Something like:
> > 
> > 	 /*
> > 	  * Cleancache needs notification even if there are no pages or
> > 	  * shadow entries...
> > 	  */
> 
> Or we can just call cleancache_invalidate_inode(mapping) on else branch,
> so the code would be more self-explanatory, and also avoid
> function call in no-cleancache setups, which should the most of setups.

That is workable for me as well although I'd be somewhat worried that if we
have calls to inform cleancache about final inode teardown in two different
places, they can get out of sync easily. So I somewhat prefer the current
solution + comment.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
