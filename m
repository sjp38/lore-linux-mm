Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 49AF06B0036
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:07:40 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id q58so885584wes.32
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 09:07:39 -0700 (PDT)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id e6si16269791wix.75.2014.07.15.09.07.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 09:07:38 -0700 (PDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so5807215wgh.15
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 09:07:38 -0700 (PDT)
Date: Tue, 15 Jul 2014 18:07:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140715160735.GB29269@dhcp22.suse.cz>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715155537.GA19454@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715155537.GA19454@nhori.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 15-07-14 11:55:37, Naoya Horiguchi wrote:
> On Wed, Jun 18, 2014 at 04:40:45PM -0400, Johannes Weiner wrote:
> ...
> > diff --git a/mm/swap.c b/mm/swap.c
> > index a98f48626359..3074210f245d 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -62,6 +62,7 @@ static void __page_cache_release(struct page *page)
> >  		del_page_from_lru_list(page, lruvec, page_off_lru(page));
> >  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> >  	}
> > +	mem_cgroup_uncharge(page);
> >  }
> >  
> >  static void __put_single_page(struct page *page)
> 
> This seems to cause a list breakage in hstate->hugepage_activelist
> when freeing a hugetlbfs page.

This looks like a fall out from
http://marc.info/?l=linux-mm&m=140475936311294&w=2

I didn't get to review this one but the easiest fix seems to be check
HugePage and do not call uncharge.

> For hugetlbfs, we uncharge in free_huge_page() which is called after
> __page_cache_release(), so I think that we don't have to uncharge here.
> 
> In my testing, moving mem_cgroup_uncharge() inside if (PageLRU) block
> fixed the problem, so if that works for you, could you fold the change
> into your patch?
> 
> Thanks,
> Naoya Horiguchi
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
