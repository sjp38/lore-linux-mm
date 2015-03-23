Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC296B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 23:01:17 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so172957889pdb.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 20:01:17 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id p3si20041319pdo.8.2015.03.22.20.01.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 20:01:16 -0700 (PDT)
Received: by pdbop1 with SMTP id op1so172957521pdb.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 20:01:16 -0700 (PDT)
Date: Sun, 22 Mar 2015 20:01:13 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 03/24] mm: use __SetPageSwapBacked and don't
 ClearPageSwapBacked
In-Reply-To: <20150225105315.GK23372@suse.de>
Message-ID: <alpine.LSU.2.11.1503221944530.4290@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils> <alpine.LSU.2.11.1502201954100.14414@eggly.anvils> <20150225105315.GK23372@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Feb 2015, Mel Gorman wrote:
> On Fri, Feb 20, 2015 at 07:56:15PM -0800, Hugh Dickins wrote:
> > Commit 07a427884348 ("mm: shmem: avoid atomic operation during
> > shmem_getpage_gfp") rightly replaced one instance of SetPageSwapBacked
> > by __SetPageSwapBacked, pointing out that the newly allocated page is
> > not yet visible to other users (except speculative get_page_unless_zero-
> > ers, who may not update page flags before their further checks).
> > 
> > That was part of a series in which Mel was focused on tmpfs profiles:
> > but almost all SetPageSwapBacked uses can be so optimized, with the
> > same justification.  And remove the ClearPageSwapBacked from
> > read_swap_cache_async()'s and zswap_get_swap_cache_page()'s error
> > paths: it's not an error to free a page with PG_swapbacked set.
> > 
> > (There's probably scope for further __SetPageFlags in other places,
> > but SwapBacked is the one I'm interested in at the moment.)
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > ---
> >  mm/migrate.c    |    6 +++---
> >  mm/rmap.c       |    2 +-
> >  mm/shmem.c      |    4 ++--
> >  mm/swap_state.c |    3 +--
> >  mm/zswap.c      |    3 +--
> >  5 files changed, 8 insertions(+), 10 deletions(-)
> > 
> > <SNIP>
> > --- thpfs.orig/mm/shmem.c	2015-02-08 18:54:22.000000000 -0800
> > +++ thpfs/mm/shmem.c	2015-02-20 19:33:35.676074594 -0800
> > @@ -987,8 +987,8 @@ static int shmem_replace_page(struct pag
> >  	flush_dcache_page(newpage);
> >  
> >  	__set_page_locked(newpage);
> > +	__SetPageSwapBacked(newpage);
> >  	SetPageUptodate(newpage);
> > -	SetPageSwapBacked(newpage);
> >  	set_page_private(newpage, swap_index);
> >  	SetPageSwapCache(newpage);
> >  
> 
> It's clear why you did this but ...
> 
> > @@ -1177,8 +1177,8 @@ repeat:
> >  			goto decused;
> >  		}
> >  
> > -		__SetPageSwapBacked(page);
> >  		__set_page_locked(page);
> > +		__SetPageSwapBacked(page);
> >  		if (sgp == SGP_WRITE)
> >  			__SetPageReferenced(page);
> >  
> 
> It's less clear why this was necessary.

I don't think the reordering was necessary in either case
(though perhaps the first hunk makes a subsequent patch smaller).
I just get irritated by seeing the same lines of code permuted
in different ways for no reason, and thought I'd tidy them up
to establish one familiar sequence, that's all.

> I don't think it causes any problems though so
> 
> Reviewed-by: Mel Gorman <mgorman@suse.de>

Thanks!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
