Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 440AA6B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:05:11 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so5908575wgh.3
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:05:09 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id k8si4099870wib.17.2014.07.15.12.05.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 12:05:08 -0700 (PDT)
Date: Tue, 15 Jul 2014 15:04:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140715190454.GW29639@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715155537.GA19454@nhori.bos.redhat.com>
 <20140715160735.GB29269@dhcp22.suse.cz>
 <20140715173439.GU29639@cmpxchg.org>
 <20140715184358.GA31550@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715184358.GA31550@nhori.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 15, 2014 at 02:43:58PM -0400, Naoya Horiguchi wrote:
> On Tue, Jul 15, 2014 at 01:34:39PM -0400, Johannes Weiner wrote:
> > On Tue, Jul 15, 2014 at 06:07:35PM +0200, Michal Hocko wrote:
> > > On Tue 15-07-14 11:55:37, Naoya Horiguchi wrote:
> > > > On Wed, Jun 18, 2014 at 04:40:45PM -0400, Johannes Weiner wrote:
> > > > ...
> > > > > diff --git a/mm/swap.c b/mm/swap.c
> > > > > index a98f48626359..3074210f245d 100644
> > > > > --- a/mm/swap.c
> > > > > +++ b/mm/swap.c
> > > > > @@ -62,6 +62,7 @@ static void __page_cache_release(struct page *page)
> > > > >  		del_page_from_lru_list(page, lruvec, page_off_lru(page));
> > > > >  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> > > > >  	}
> > > > > +	mem_cgroup_uncharge(page);
> > > > >  }
> > > > >  
> > > > >  static void __put_single_page(struct page *page)
> > > > 
> > > > This seems to cause a list breakage in hstate->hugepage_activelist
> > > > when freeing a hugetlbfs page.
> > > 
> > > This looks like a fall out from
> > > http://marc.info/?l=linux-mm&m=140475936311294&w=2
> > > 
> > > I didn't get to review this one but the easiest fix seems to be check
> > > HugePage and do not call uncharge.
> > 
> > Yes, that makes sense.  I'm also moving the uncharge call into
> > __put_single_page() and __put_compound_page() so that PageHuge(), a
> > function call, only needs to be checked for compound pages.
> > 
> > > > For hugetlbfs, we uncharge in free_huge_page() which is called after
> > > > __page_cache_release(), so I think that we don't have to uncharge here.
> > > > 
> > > > In my testing, moving mem_cgroup_uncharge() inside if (PageLRU) block
> > > > fixed the problem, so if that works for you, could you fold the change
> > > > into your patch?
> > 
> > Memcg pages that *do* need uncharging might not necessarily be on the
> > LRU list.
> 
> OK.
> 
> > Does the following work for you?
> 
> Unfortunately, with this change I saw the following bug message when
> stressing with hugepage migration.
> move_to_new_page() is called by unmap_and_move_huge_page() too, so
> we need some hugetlb related code around mem_cgroup_migrate().

Can we just move hugetlb_cgroup_migrate() into move_to_new_page()?  It
doesn't seem to be dependent of any page-specific state.

diff --git a/mm/migrate.c b/mm/migrate.c
index 7f5a42403fae..219da52d2f43 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -781,7 +781,10 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		if (!PageAnon(newpage))
 			newpage->mapping = NULL;
 	} else {
-		mem_cgroup_migrate(page, newpage, false);
+		if (PageHuge(page))
+			hugetlb_cgroup_migrate(hpage, new_hpage);
+		else
+			mem_cgroup_migrate(page, newpage, false);
 		if (remap_swapcache)
 			remove_migration_ptes(page, newpage);
 		if (!PageAnon(page))
@@ -1064,9 +1067,6 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	if (anon_vma)
 		put_anon_vma(anon_vma);
 
-	if (rc == MIGRATEPAGE_SUCCESS)
-		hugetlb_cgroup_migrate(hpage, new_hpage);
-
 	unlock_page(hpage);
 out:
 	if (rc != -EAGAIN)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
