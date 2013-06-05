Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 569746B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 03:28:28 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id m6so851980oag.16
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 00:28:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130604050744.GD14719@blaptop>
References: <20130603200202.7F5FDE07@viggo.jf.intel.com>
	<20130603200208.6F71D31F@viggo.jf.intel.com>
	<CAJd=RBC563c64usU2oK40b62c7N0R15KD_4ihFExeT021wUTcw@mail.gmail.com>
	<20130604050744.GD14719@blaptop>
Date: Wed, 5 Jun 2013 15:28:27 +0800
Message-ID: <CAJd=RBAt9eSx3_FB79J93e19bv15sFry-mU6hkUYH80isULszw@mail.gmail.com>
Subject: Re: [v5][PATCH 5/6] mm: vmscan: batch shrink_page_list() locking operations
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On Tue, Jun 4, 2013 at 1:07 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Tue, Jun 04, 2013 at 09:17:26AM +0800, Hillf Danton wrote:
>> On Tue, Jun 4, 2013 at 4:02 AM, Dave Hansen <dave@sr71.net> wrote:
>> > +/*
>> > + * pages come in here (via remove_list) locked and leave unlocked
>> > + * (on either ret_pages or free_pages)
>> > + *
>> > + * We do this batching so that we free batches of pages with a
>> > + * single mapping->tree_lock acquisition/release.  This optimization
>> > + * only makes sense when the pages on remove_list all share a
>> > + * page_mapping().  If this is violated you will BUG_ON().
>> > + */
>> > +static int __remove_mapping_batch(struct list_head *remove_list,
>> > +                                 struct list_head *ret_pages,
>> > +                                 struct list_head *free_pages)
>> > +{
>> > +       int nr_reclaimed = 0;
>> > +       struct address_space *mapping;
>> > +       struct page *page;
>> > +       LIST_HEAD(need_free_mapping);
>> > +
>> > +       if (list_empty(remove_list))
>> > +               return 0;
>> > +
>> > +       mapping = page_mapping(lru_to_page(remove_list));
>> > +       spin_lock_irq(&mapping->tree_lock);
>> > +       while (!list_empty(remove_list)) {
>> > +               page = lru_to_page(remove_list);
>> > +               BUG_ON(!PageLocked(page));
>> > +               BUG_ON(page_mapping(page) != mapping);
>> > +               list_del(&page->lru);
>> > +
>> > +               if (!__remove_mapping(mapping, page)) {
>> > +                       unlock_page(page);
>> > +                       list_add(&page->lru, ret_pages);
>> > +                       continue;
>> > +               }
>> > +               list_add(&page->lru, &need_free_mapping);
>> > +       }
>> > +       spin_unlock_irq(&mapping->tree_lock);
>> > +
>> While reclaiming pages, can we open ears upon IRQ controller,
>> if the page list length is over 10, or even 20?
>
> At the moment, it implicitly could be bounded by SWAP_CLUSTER_MAX and

Could we reclaim a THP currently?

> it's the value used by isolate_migratepages_ranges to enable IRQ.
> I have no idea it's proper value to give a chace to IRQ but at least,
> Dave's code doesn't break the rule.
> If we need a tune for that, it could be a another patch to investigate
> all of places on vmscan.c in near future.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
