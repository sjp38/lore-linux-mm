Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B10A26B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 02:59:33 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id kq3so76031959wjc.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 23:59:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b41si23819903wrb.307.2017.01.31.23.59.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Jan 2017 23:59:32 -0800 (PST)
Date: Wed, 1 Feb 2017 08:59:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 1/4] mm/migration: make isolate_movable_page() return
 int type
Message-ID: <20170201075924.GB5977@dhcp22.suse.cz>
References: <1485867981-16037-1-git-send-email-ysxie@foxmail.com>
 <1485867981-16037-2-git-send-email-ysxie@foxmail.com>
 <20170201064821.GA10342@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170201064821.GA10342@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: ysxie@foxmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, arbab@linux.vnet.ibm.com, vkuznets@redhat.com, ak@linux.intel.com, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed 01-02-17 15:48:21, Minchan Kim wrote:
> Hi Yisheng,
> 
> On Tue, Jan 31, 2017 at 09:06:18PM +0800, ysxie@foxmail.com wrote:
> > From: Yisheng Xie <xieyisheng1@huawei.com>
> > 
> > This patch changes the return type of isolate_movable_page()
> > from bool to int. It will return 0 when isolate movable page
> > successfully, return -EINVAL when the page is not a non-lru movable
> > page, and for other cases it will return -EBUSY.
> > 
> > There is no functional change within this patch but prepare
> > for later patch.
> > 
> > Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> > Suggested-by: Michal Hocko <mhocko@kernel.org>
> 
> Sorry for missing this one you guys were discussing.
> I don't understand the patch's goal although I read later patches.

The point is that the failed isolation has to propagate error up the
call chain to the userspace which has initiated the migration.

> isolate_movable_pages returns success/fail so that's why I selected
> bool rather than int but it seems you guys want to propagate more
> detailed error to the user so added -EBUSY and -EINVAL.
> 
> But the question is why isolate_lru_pages doesn't have -EINVAL?

It doesn't have to same as isolate_movable_pages. We should just return
EBUSY when the page is no longer movable.

> Secondly, madvise man page should update?

Why?

> Thirdly, if a driver fail isolation due to -ENOMEM, it should be
> propagated, too?

Yes

> if we want to propagte detailed error to user, driver's isolate_page
> function should return right error.

Yes

> I don't feel this all changes should be done now. What's the problem
> if we change isolate_lru_page from int to bool? it returns just binary
> value so it should be right place to use bool. If it fails, error val
> is just -EBUSY.

We really want to propagate the reason why the offline operation has
failed. Why would we want to postpone that?

> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > CC: Vlastimil Babka <vbabka@suse.cz>
> > ---
> >  include/linux/migrate.h |  2 +-
> >  mm/compaction.c         |  2 +-
> >  mm/migrate.c            | 11 +++++++----
> >  3 files changed, 9 insertions(+), 6 deletions(-)
> > 
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index ae8d475..43d5deb 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -37,7 +37,7 @@ extern int migrate_page(struct address_space *,
> >  			struct page *, struct page *, enum migrate_mode);
> >  extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
> >  		unsigned long private, enum migrate_mode mode, int reason);
> > -extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
> > +extern int isolate_movable_page(struct page *page, isolate_mode_t mode);
> >  extern void putback_movable_page(struct page *page);
> >  
> >  extern int migrate_prep(void);
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 949198d..1d89147 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -802,7 +802,7 @@ static bool too_many_isolated(struct zone *zone)
> >  					locked = false;
> >  				}
> >  
> > -				if (isolate_movable_page(page, isolate_mode))
> > +				if (!isolate_movable_page(page, isolate_mode))
> >  					goto isolate_success;
> >  			}
> >  
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 87f4d0f..bbbd170 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -74,8 +74,9 @@ int migrate_prep_local(void)
> >  	return 0;
> >  }
> >  
> > -bool isolate_movable_page(struct page *page, isolate_mode_t mode)
> > +int isolate_movable_page(struct page *page, isolate_mode_t mode)
> >  {
> > +	int ret = -EBUSY;
> >  	struct address_space *mapping;
> >  
> >  	/*
> > @@ -95,8 +96,10 @@ bool isolate_movable_page(struct page *page, isolate_mode_t mode)
> >  	 * assumes anybody doesn't touch PG_lock of newly allocated page
> >  	 * so unconditionally grapping the lock ruins page's owner side.
> >  	 */
> > -	if (unlikely(!__PageMovable(page)))
> > +	if (unlikely(!__PageMovable(page))) {
> > +		ret = -EINVAL;
> >  		goto out_putpage;
> > +	}
> >  	/*
> >  	 * As movable pages are not isolated from LRU lists, concurrent
> >  	 * compaction threads can race against page migration functions
> > @@ -125,14 +128,14 @@ bool isolate_movable_page(struct page *page, isolate_mode_t mode)
> >  	__SetPageIsolated(page);
> >  	unlock_page(page);
> >  
> > -	return true;
> > +	return 0;
> >  
> >  out_no_isolated:
> >  	unlock_page(page);
> >  out_putpage:
> >  	put_page(page);
> >  out:
> > -	return false;
> > +	return ret;
> >  }
> >  
> >  /* It should be called on page which is PG_movable */
> > -- 
> > 1.9.1
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
