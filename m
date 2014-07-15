Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 262206B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 13:34:55 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id bs8so4778031wib.3
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 10:34:54 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id n4si16628952wiw.34.2014.07.15.10.34.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 10:34:53 -0700 (PDT)
Date: Tue, 15 Jul 2014 13:34:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140715173439.GU29639@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715155537.GA19454@nhori.bos.redhat.com>
 <20140715160735.GB29269@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715160735.GB29269@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 15, 2014 at 06:07:35PM +0200, Michal Hocko wrote:
> On Tue 15-07-14 11:55:37, Naoya Horiguchi wrote:
> > On Wed, Jun 18, 2014 at 04:40:45PM -0400, Johannes Weiner wrote:
> > ...
> > > diff --git a/mm/swap.c b/mm/swap.c
> > > index a98f48626359..3074210f245d 100644
> > > --- a/mm/swap.c
> > > +++ b/mm/swap.c
> > > @@ -62,6 +62,7 @@ static void __page_cache_release(struct page *page)
> > >  		del_page_from_lru_list(page, lruvec, page_off_lru(page));
> > >  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> > >  	}
> > > +	mem_cgroup_uncharge(page);
> > >  }
> > >  
> > >  static void __put_single_page(struct page *page)
> > 
> > This seems to cause a list breakage in hstate->hugepage_activelist
> > when freeing a hugetlbfs page.
> 
> This looks like a fall out from
> http://marc.info/?l=linux-mm&m=140475936311294&w=2
> 
> I didn't get to review this one but the easiest fix seems to be check
> HugePage and do not call uncharge.

Yes, that makes sense.  I'm also moving the uncharge call into
__put_single_page() and __put_compound_page() so that PageHuge(), a
function call, only needs to be checked for compound pages.

> > For hugetlbfs, we uncharge in free_huge_page() which is called after
> > __page_cache_release(), so I think that we don't have to uncharge here.
> > 
> > In my testing, moving mem_cgroup_uncharge() inside if (PageLRU) block
> > fixed the problem, so if that works for you, could you fold the change
> > into your patch?

Memcg pages that *do* need uncharging might not necessarily be on the
LRU list.

Does the following work for you?

Thanks!

---

diff --git a/mm/swap.c b/mm/swap.c
index 3461f2f5be20..af5c8ad830d1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -62,12 +62,12 @@ static void __page_cache_release(struct page *page)
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
-	mem_cgroup_uncharge(page);
 }
 
 static void __put_single_page(struct page *page)
 {
 	__page_cache_release(page);
+	mem_cgroup_uncharge(page);
 	free_hot_cold_page(page, false);
 }
 
@@ -76,6 +76,8 @@ static void __put_compound_page(struct page *page)
 	compound_page_dtor *dtor;
 
 	__page_cache_release(page);
+	if (!PageHuge(page))
+		mem_cgroup_uncharge(page);
 	dtor = get_compound_page_dtor(page);
 	(*dtor)(page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
