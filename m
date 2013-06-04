Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 9677B6B003D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 01:07:45 -0400 (EDT)
Date: Tue, 4 Jun 2013 14:07:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [v5][PATCH 5/6] mm: vmscan: batch shrink_page_list() locking
 operations
Message-ID: <20130604050744.GD14719@blaptop>
References: <20130603200202.7F5FDE07@viggo.jf.intel.com>
 <20130603200208.6F71D31F@viggo.jf.intel.com>
 <CAJd=RBC563c64usU2oK40b62c7N0R15KD_4ihFExeT021wUTcw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBC563c64usU2oK40b62c7N0R15KD_4ihFExeT021wUTcw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On Tue, Jun 04, 2013 at 09:17:26AM +0800, Hillf Danton wrote:
> On Tue, Jun 4, 2013 at 4:02 AM, Dave Hansen <dave@sr71.net> wrote:
> > +/*
> > + * pages come in here (via remove_list) locked and leave unlocked
> > + * (on either ret_pages or free_pages)
> > + *
> > + * We do this batching so that we free batches of pages with a
> > + * single mapping->tree_lock acquisition/release.  This optimization
> > + * only makes sense when the pages on remove_list all share a
> > + * page_mapping().  If this is violated you will BUG_ON().
> > + */
> > +static int __remove_mapping_batch(struct list_head *remove_list,
> > +                                 struct list_head *ret_pages,
> > +                                 struct list_head *free_pages)
> > +{
> > +       int nr_reclaimed = 0;
> > +       struct address_space *mapping;
> > +       struct page *page;
> > +       LIST_HEAD(need_free_mapping);
> > +
> > +       if (list_empty(remove_list))
> > +               return 0;
> > +
> > +       mapping = page_mapping(lru_to_page(remove_list));
> > +       spin_lock_irq(&mapping->tree_lock);
> > +       while (!list_empty(remove_list)) {
> > +               page = lru_to_page(remove_list);
> > +               BUG_ON(!PageLocked(page));
> > +               BUG_ON(page_mapping(page) != mapping);
> > +               list_del(&page->lru);
> > +
> > +               if (!__remove_mapping(mapping, page)) {
> > +                       unlock_page(page);
> > +                       list_add(&page->lru, ret_pages);
> > +                       continue;
> > +               }
> > +               list_add(&page->lru, &need_free_mapping);
> > +       }
> > +       spin_unlock_irq(&mapping->tree_lock);
> > +
> While reclaiming pages, can we open ears upon IRQ controller,
> if the page list length is over 10, or even 20?

At the moment, it implicitly could be bounded by SWAP_CLUSTER_MAX and
it's the value used by isolate_migratepages_ranges to enable IRQ.
I have no idea it's proper value to give a chace to IRQ but at least,
Dave's code doesn't break the rule.
If we need a tune for that, it could be a another patch to investigate
all of places on vmscan.c in near future.


> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
