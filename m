Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id ADA516B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 17:21:04 -0500 (EST)
Received: by iacb35 with SMTP id b35so29154411iac.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 14:21:04 -0800 (PST)
Date: Thu, 29 Dec 2011 14:20:47 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
In-Reply-To: <4EFC4C74.9010705@openvz.org>
Message-ID: <alpine.LSU.2.00.1112291408180.4781@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282037000.1362@eggly.anvils> <4EFC4C74.9010705@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 29 Dec 2011, Konstantin Khlebnikov wrote:
> 
> Nice patch
> 
> Reviewed-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Thanks.

> As I see, this patch is on top "memcg naturalization" patchset,
> it does not apply clearly against Linus tree.

Right, it's certainly not intended as a last-minute "fix" to 3.2,
but as a patch for mmotm and linux-next then 3.3.  Linus doesn't
even have your free_hot_cold_page_list() yet.

> 
> > +		if (put_page_testzero(page)) {
> > +			__ClearPageLRU(page);
> > +			__ClearPageActive(page);
> > +			del_page_from_lru_list(zone, page, lru);
> > +
> > +			if (unlikely(PageCompound(page))) {
> > +				spin_unlock_irq(&zone->lru_lock);
> 
> There is good place for VM_BUG_ON(!PageHead(page));

Well, my inertia wanted to find a reason to disagree with you on that,
and indeed I found one!  If this were a tail page, the preceding
put_page_testzero() should already have hit its
	VM_BUG_ON(atomic_read(&page->_count) == 0);
(since Andrea changed the THP refcounting to respect get_page_unless_zero).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
