Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 7EDE76B0068
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 02:09:55 -0400 (EDT)
Message-ID: <51AD84BA.4090106@sr71.net>
Date: Mon, 03 Jun 2013 23:10:02 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [v5][PATCH 5/6] mm: vmscan: batch shrink_page_list() locking
 operations
References: <20130603200202.7F5FDE07@viggo.jf.intel.com> <20130603200208.6F71D31F@viggo.jf.intel.com> <20130604050103.GC14719@blaptop>
In-Reply-To: <20130604050103.GC14719@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On 06/03/2013 10:01 PM, Minchan Kim wrote:
>> > +static int __remove_mapping_batch(struct list_head *remove_list,
>> > +				  struct list_head *ret_pages,
>> > +				  struct list_head *free_pages)
>> > +{
>> > +	int nr_reclaimed = 0;
>> > +	struct address_space *mapping;
>> > +	struct page *page;
>> > +	LIST_HEAD(need_free_mapping);
>> > +
>> > +	while (!list_empty(remove_list)) {
...
>> > +		if (!__remove_mapping(mapping, page)) {
>> > +			unlock_page(page);
>> > +			list_add(&page->lru, ret_pages);
>> > +			continue;
>> > +		}
>> > +		list_add(&page->lru, &need_free_mapping);
...
> +	spin_unlock_irq(&mapping->tree_lock);
> +	while (!list_empty(&need_free_mapping)) {...
> +		list_move(&page->list, free_pages);
> +		mapping_release_page(mapping, page);
> +	}
> Why do we need new lru list instead of using @free_pages?

I actually tried using @free_pages at first.  The problem is that we
need to call mapping_release_page() without the radix tree lock held so
we can not do it in the first while() loop.

'free_pages' is a list created up in shrink_page_list().  There can be
several calls to __remove_mapping_batch() for each call to
shrink_page_list().

'need_free_mapping' lets us temporarily differentiate the pages that we
need to call mapping_release_page()/unlock_page() on versus the ones on
'free_pages' which have already had that done.

We could theoretically delay _all_ of the
release_mapping_page()/unlock_page() operations until the _entire_
shrink_page_list() operation is done, but doing this really helps with
lock_page() latency.

Does that make sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
