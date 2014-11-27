Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1096B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 04:40:11 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id z12so5982768wgg.29
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 01:40:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pn8si10969580wjb.151.2014.11.27.01.40.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Nov 2014 01:40:10 -0800 (PST)
Date: Thu, 27 Nov 2014 10:40:06 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [rfc patch] mm: protect set_page_dirty() from ongoing truncation
Message-ID: <20141127094006.GC30152@quack.suse.cz>
References: <1416944921-14164-1-git-send-email-hannes@cmpxchg.org>
 <20141126140006.d6f71f447b69cd4fadc42c26@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141126140006.d6f71f447b69cd4fadc42c26@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 26-11-14 14:00:06, Andrew Morton wrote:
> On Tue, 25 Nov 2014 14:48:41 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Tejun, while reviewing the code, spotted the following race condition
> > between the dirtying and truncation of a page:
> > 
> > __set_page_dirty_nobuffers()       __delete_from_page_cache()
> >   if (TestSetPageDirty(page))
> >                                      page->mapping = NULL
> > 				     if (PageDirty())
> > 				       dec_zone_page_state(page, NR_FILE_DIRTY);
> > 				       dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> >     if (page->mapping)
> >       account_page_dirtied(page)
> >         __inc_zone_page_state(page, NR_FILE_DIRTY);
> > 	__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> > 
> > which results in an imbalance of NR_FILE_DIRTY and BDI_RECLAIMABLE.
> > 
> > Dirtiers usually lock out truncation, either by holding the page lock
> > directly, or in case of zap_pte_range(), by pinning the mapcount with
> > the page table lock held.  The notable exception to this rule, though,
> > is do_wp_page(), for which this race exists.  However, do_wp_page()
> > already waits for a locked page to unlock before setting the dirty
> > bit, in order to prevent a race where clear_page_dirty() misses the
> > page bit in the presence of dirty ptes.  Upgrade that wait to a fully
> > locked set_page_dirty() to also cover the situation explained above.
> > 
> > Afterwards, the code in set_page_dirty() dealing with a truncation
> > race is no longer needed.  Remove it.
> > 
> > Reported-by: Tejun Heo <tj@kernel.org>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/memory.c         | 11 ++---------
> >  mm/page-writeback.c | 33 ++++++++++++---------------------
> >  2 files changed, 14 insertions(+), 30 deletions(-)
> > 
> > It is unfortunate to hold the page lock while balancing dirty pages,
> > but I don't see what else would protect mapping at that point.
> 
> Yes.
> 
> I'm a bit surprised that calling balance_dirty_pages() under
> lock_page() doesn't just go and deadlock.  Memory fails me.
> 
> And yes, often the only thing which protects the address_space is
> lock_page().
> 
> set_page_dirty_balance() and balance_dirty_pages() don't actually need
> the address_space - they just use it to get at the backing_dev_info. 
> So perhaps what we could do here is the change those functions to take
> a bdi directly, then change do_wp_page() to do something like
> 
> 	lock_page(dirty_page);
> 	bdi = page->mapping->backing_dev_info;
> 	need_balance = set_page_dirty2(bdi);
> 	unlock_page(page);
> 	if (need_balance)
> 		balance_dirty_pages_ratelimited2(bdi);
  Yes, please! Holding lock_page() over balance dirty pages definitely has
a potential for deadlock (e.g. flusher might block on lock_page() in
WB_SYNC_ALL pass and then there'd be no one to clean pages and thus release
process from balance_dirty_pages()).

> so we no longer require that the address_space be stabilized after
> lock_page().  Of course something needs to protect the bdi and I'm not
> sure what that is, but we're talking about umount and that quiesces and
> evicts lots of things before proceeding, so surely there's something in
> there which will save us ;)
  In do_wp_page() the process doing the fault and ending in
balance_dirty_pages() has to have the page mapped, thus it has to have the
file open => no umount.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
