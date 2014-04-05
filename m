Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 98DB36B0031
	for <linux-mm@kvack.org>; Sat,  5 Apr 2014 05:06:05 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id md12so4542668pbc.9
        for <linux-mm@kvack.org>; Sat, 05 Apr 2014 02:06:05 -0700 (PDT)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id tm7si5650651pac.106.2014.04.05.02.06.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 05 Apr 2014 02:06:04 -0700 (PDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so4545023pbb.33
        for <linux-mm@kvack.org>; Sat, 05 Apr 2014 02:06:04 -0700 (PDT)
Date: Sat, 5 Apr 2014 02:04:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: rmap: don't try to add an unevictable page to lru
 list
In-Reply-To: <1396235259-2394-1-git-send-email-bob.liu@oracle.com>
Message-ID: <alpine.LSU.2.11.1404042358030.12542@eggly.anvils>
References: <1396235259-2394-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org, riel@redhat.com, sasha.levin@oracle.com, Bob Liu <bob.liu@oracle.com>

On Mon, 31 Mar 2014, Bob Liu wrote:

> VM_BUG_ON_PAGE(PageActive(page) && PageUnevictable(page), page) in
> lru_cache_add() was triggered during migrate_misplaced_transhuge_page.
> 
> kernel BUG at mm/swap.c:609!
> [<ffffffff8127f311>] lru_cache_add+0x21/0x60
> [<ffffffff812adaec>] page_add_new_anon_rmap+0x1ec/0x210
> [<ffffffff812db8ec>] migrate_misplaced_transhuge_page+0x55c/0x830
> 
> The root cause is the checking mlocked_vma_newpage() in
> page_add_new_anon_rmap() is not enough to decide whether a page is unevictable.
> 
> migrate_misplaced_transhuge_page():
> 	=> migrate_page_copy()
> 		=> SetPageUnevictable(newpage)
> 
> 	=> page_add_new_anon_rmap(newpage)
> 		=> mlocked_vma_newpage(vma, newpage) <--This check is not enough
> 			=> SetPageActive(newpage)
> 			=> lru_cache_add(newpage)
> 				=> VM_BUG_ON_PAGE()
> 
> From vmscan.c:
>  * Reasons page might not be evictable:
>  * (1) page's mapping marked unevictable
>  * (2) page is part of an mlocked VMA
> 
> But page_add_new_anon_rmap() only checks reason (2), we may hit this
> VM_BUG_ON_PAGE() if PageUnevictable(old_page) was originally set by reason (1).

But (1) always reports evictable on an anon page, doesn't it?

> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>

I can't quite assert NAK, but I suspect this is not the proper fix.

Initially I was uncomfortable with it for largely aesthetic reasons.
page_add_new_anon_rmap() is a cut-some-corners fast-path collection of
rmap and lru stuff for the common case, the first time a page is added.

If what it does is not suitable for the unusual case of page migration,
then we should not clutter it up with additional tests, but adjust
migration to use the slower page_add_anon_rmap() instead.

Or, if there turns out to be some really good reason to stick with
page_add_new_anon_rmap(), add an inline comment to explain why this
additional !PageUnevictable test (never needed before) is needed now.

Note that the call from migrate_misplaced_transhuge_page() is the
only use of page_add_new_anon_rmap() in mm/migrate.c: I think it's a
mistake, and should use page_add_anon_rmap() plus putback_lru_page()
like elsewhere in migrate.c.

Beware, I've not written, let alone tested, a patch to do so: maybe
more is needed.  In particular, it's unclear whether Mel intended the
SetPageActive that comes bundled up in page_add_new_anon_rmap(), when
normally migration just transfers PageActive state from old to new.

I went through a phase of thinking your patch is downright wrong,
that in the racy case it puts a recently-become-evictable page back
to the unevictable lru.  Currently I believe I was wrong about that,
the page lock (on old page) or mmap_sem preventing that possibility.

(Yet now I'm wavering again: if down_write mmap_sem is needed to
munlock() the vma, and migrate_misplaced_transhuge_page() is only
migrating a singly-mapped THP under down_read mmap_sem, how could
VM_LOCKED have changed during the migration?  I've lost sight of
how we got to hit the BUG altogether, maybe I'm just too tired.)

Even so, I'd be much more comfortable with a page_add_anon_rmap()
plus putback_lru_page() approach; but we probably need Mel to
explain why he chose not to do it that way (my guess is it just
seemed simpler this way, relying on the singly-mapped aspect),
and someone to explain again how we hit the BUG.

Hugh

> ---
>  mm/rmap.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 43d429b..39458c5 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1024,7 +1024,7 @@ void page_add_new_anon_rmap(struct page *page,
>  	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
>  			hpage_nr_pages(page));
>  	__page_set_anon_rmap(page, vma, address, 1);
> -	if (!mlocked_vma_newpage(vma, page)) {
> +	if (!mlocked_vma_newpage(vma, page) && !PageUnevictable(page)) {
>  		SetPageActive(page);
>  		lru_cache_add(page);
>  	} else
> --
> 1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
