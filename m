Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9656B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 07:42:54 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id w62so5572930wes.36
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 04:42:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lk7si2800085wic.68.2014.08.08.04.42.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 04:42:52 -0700 (PDT)
Date: Fri, 8 Aug 2014 13:42:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm: memcontrol: rewrite uncharge API
Message-ID: <20140808114250.GJ4004@dhcp22.suse.cz>
References: <20140806135914.9fca00159f6e3298c24a4ab3@linux-foundation.org>
 <20140806140011.692985b45f8844706b17098e@linux-foundation.org>
 <20140806140055.40a48055f8797e159a894a68@linux-foundation.org>
 <20140806140235.f8fb69e76454af2ce935dc5b@linux-foundation.org>
 <20140807073825.GA12779@dhcp22.suse.cz>
 <20140807162507.GF14734@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140807162507.GF14734@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu 07-08-14 12:25:07, Johannes Weiner wrote:
> On Thu, Aug 07, 2014 at 09:38:26AM +0200, Michal Hocko wrote:
> > On Wed 06-08-14 14:02:35, Andrew Morton wrote:
> > > On Wed, 6 Aug 2014 14:00:55 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> > > 
> > > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > > Subject: mm: memcontrol: rewrite uncharge API
> > > > 
> > > 
> > > Nope, sorry, that was missing
> > > mm-memcontrol-rewrite-uncharge-api-fix-clear-page-mapping-in-migration.patch.
> > > 
> > > This time:
> > > 
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > Subject: mm: memcontrol: rewrite uncharge API
> > > 
> > > The memcg uncharging code that is involved towards the end of a page's
> > > lifetime - truncation, reclaim, swapout, migration - is impressively
> > > complicated and fragile.
> > > 
> > > Because anonymous and file pages were always charged before they had their
> > > page->mapping established, uncharges had to happen when the page type
> > > could still be known from the context; as in unmap for anonymous, page
> > > cache removal for file and shmem pages, and swap cache truncation for swap
> > > pages.  However, these operations happen well before the page is actually
> > > freed, and so a lot of synchronization is necessary:
> > > 
> > > - Charging, uncharging, page migration, and charge migration all need
> > >   to take a per-page bit spinlock as they could race with uncharging.
> > > 
> > > - Swap cache truncation happens during both swap-in and swap-out, and
> > >   possibly repeatedly before the page is actually freed.  This means
> > >   that the memcg swapout code is called from many contexts that make
> > >   no sense and it has to figure out the direction from page state to
> > >   make sure memory and memory+swap are always correctly charged.
> > > 
> > > - On page migration, the old page might be unmapped but then reused,
> > >   so memcg code has to prevent untimely uncharging in that case.
> > >   Because this code - which should be a simple charge transfer - is so
> > >   special-cased, it is not reusable for replace_page_cache().
> > > 
> > > But now that charged pages always have a page->mapping, introduce
> > > mem_cgroup_uncharge(), which is called after the final put_page(), when we
> > > know for sure that nobody is looking at the page anymore.
> > > 
> > > For page migration, introduce mem_cgroup_migrate(), which is called after
> > > the migration is successful and the new page is fully rmapped.  Because
> > > the old page is no longer uncharged after migration, prevent double
> > > charges by decoupling the page's memcg association (PCG_USED and
> > > pc->mem_cgroup) from the page holding an actual charge.  The new bits
> > > PCG_MEM and PCG_MEMSW represent the respective charges and are transferred
> > > to the new page during migration.
> > > 
> > > mem_cgroup_migrate() is suitable for replace_page_cache() as well, which
> > > gets rid of mem_cgroup_replace_page_cache().
> > > 
> > > Swap accounting is massively simplified: because the page is no longer
> > > uncharged as early as swap cache deletion, a new mem_cgroup_swapout() can
> > > transfer the page's memory+swap charge (PCG_MEMSW) to the swap entry
> > > before the final put_page() in page reclaim.
> > > 
> > > Finally, page_cgroup changes are now protected by whatever protection the
> > > page itself offers: anonymous pages are charged under the page table lock,
> > > whereas page cache insertions, swapin, and migration hold the page lock. 
> > > Uncharging happens under full exclusion with no outstanding references. 
> > > Charging and uncharging also ensure that the page is off-LRU, which
> > > serializes against charge migration.  Remove the very costly page_cgroup
> > > lock and set pc->flags non-atomically.
> > 
> > I see some point in squashing all the fixups into the single patch but I
> > am afraid we have lost some interesting details from fix ups this time.
> > I think that at least
> > mm-memcontrol-rewrite-uncharge-api-fix-page-cache-migration.patch and
> > mm-memcontrol-rewrite-uncharge-api-fix-page-cache-migration-2.patch
> > would be good to go on their own _or_ their changelogs added here. The
> > whole page cache replace path is obscure and we should rather have that
> > documented so we do not have to google for details or go through painful
> > code inspection next time.
> 
> I agree, we would lose something there.  There is a paragraph in the
> changelog that says:
> 
> mem_cgroup_migrate() is suitable for replace_page_cache() as well,
> which gets rid of mem_cgroup_replace_page_cache().
> 
> Could you please update it to say:
> 
> mem_cgroup_migrate() is suitable for replace_page_cache() as well,
> which gets rid of mem_cgroup_replace_page_cache().  However, care
> needs to be taken because both the source and the target page can
> already be charged and on the LRU when fuse is splicing: grab the page
> lock on the charge moving side to prevent changing pc->mem_cgroup of a
> page under migration.  Also, the lruvecs of both pages change as we
> uncharge the old and charge the new during migration, and putback may
> race with us, so grab the lru lock and isolate the pages iff on LRU to
> prevent races and ensure the pages are on the right lruvec afterward.

Thanks! This is much better.

> > > [vdavydov@parallels.com: fix flags definition]
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Tejun Heo <tj@kernel.org>
> > > Cc: Vladimir Davydov <vdavydov@parallels.com>
> > > Tested-by: Jet Chen <jet.chen@intel.com>
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > If this comes from the above change then is should be probably removed.
> > You can replace it by my Acked-by. I have acked all the follow up fixes
> > but forgot to ack the initial patch.
> 
> Thanks!
> 
> > > Tested-by: Felipe Balbi <balbi@ti.com>
> > 
> > this tested-by came from the same preempt_{en,dis}able patch AFAICS.
> 
> Yeah it might be a bit overreaching to apply this to the full change.
> 
> On a different note, Michal, I just scrolled through the 2000 lines
> that follow to see if you had any more comments, but there was only
> your signature at the bottom.  Please think about the quote context
> after you inserted your inline comments and then trim accordingly.

Sure I usually trim emails a lot. Forgot this time, sorry about that!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
