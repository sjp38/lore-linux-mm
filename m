Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 1E4A26B0078
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 17:29:58 -0400 (EDT)
Received: by iakh37 with SMTP id h37so1591385iak.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2012 14:29:57 -0700 (PDT)
Date: Wed, 3 Oct 2012 14:29:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch -mm] mm, thp: fix mlock statistics fix
In-Reply-To: <alpine.DEB.2.00.1210031403270.4352@chino.kir.corp.google.com>
Message-ID: <alpine.LSU.2.00.1210031418410.14458@eggly.anvils>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com> <alpine.LSU.2.00.1209192021270.28543@eggly.anvils> <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com> <alpine.DEB.2.00.1209261929270.8567@chino.kir.corp.google.com>
 <alpine.LSU.2.00.1209271814340.2107@eggly.anvils> <20121003131012.f88b0d66.akpm@linux-foundation.org> <alpine.DEB.2.00.1210031403270.4352@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 3 Oct 2012, David Rientjes wrote:
> On Wed, 3 Oct 2012, Andrew Morton wrote:
> 
> > The free_page_mlock() hunk gets dropped because free_page_mlock() is
> > removed.  And clear_page_mlock() doesn't need this treatment.  But
> > please check my handiwork.
> > 
> 
> I reviewed what was merged into -mm and clear_page_mlock() does need this 
> fix as well.  It's an easy fix, there's no need to pass "anon" into 
> clear_page_mlock() since PageHuge() is already checked in its only caller.
> 
> 
> mm, thp: fix mlock statistics fix
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Hugh Dickins <hughd@google.com>

Thanks for providing that, David, I was just on the point of building
and working out a test, suspecting that what you've added is necessary.

Probably some equivalent always was missing, but between the THP Mlock
counting issue that you're fixing, and the Mlock counting issue that
I'm fixing by moving the clear_page_mlock, it's hard to say just where.

While clear_page_mlock was being called from truncate.c, we knew that
it couldn't happen on a THP.  But now that it's from page_remove_rmap,
yes, we do want to add in this additional fix.

Hugh

> ---
>  mm/mlock.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -56,7 +56,8 @@ void clear_page_mlock(struct page *page)
>  	if (!TestClearPageMlocked(page))
>  		return;
>  
> -	dec_zone_page_state(page, NR_MLOCK);
> +	mod_zone_page_state(page_zone(page), NR_MLOCK,
> +			    -hpage_nr_pages(page));
>  	count_vm_event(UNEVICTABLE_PGCLEARED);
>  	if (!isolate_lru_page(page)) {
>  		putback_lru_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
