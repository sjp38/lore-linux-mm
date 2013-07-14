From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [v5][PATCH 5/6] mm: vmscan: batch shrink_page_list() locking
 operations
Date: Mon, 15 Jul 2013 07:50:28 +0800
Message-ID: <36159.2620415196$1373845848@news.gmane.org>
References: <20130603200202.7F5FDE07@viggo.jf.intel.com>
 <20130603200208.6F71D31F@viggo.jf.intel.com>
 <20130604050103.GC14719@blaptop>
 <51AD84BA.4090106@sr71.net>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UyW3o-0006Tl-M1
	for glkm-linux-mm-2@m.gmane.org; Mon, 15 Jul 2013 01:50:36 +0200
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id BF2F76B005C
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 19:50:34 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 15 Jul 2013 05:15:00 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 9C8BAE0053
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:20:21 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6ENpAAL31326364
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:21:10 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6ENoTmH006271
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 09:50:29 +1000
Content-Disposition: inline
In-Reply-To: <51AD84BA.4090106@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, minchan@kernel.org, Dave Hansen <dave@sr71.net>

On Mon, Jun 03, 2013 at 11:10:02PM -0700, Dave Hansen wrote:
>On 06/03/2013 10:01 PM, Minchan Kim wrote:
>>> > +static int __remove_mapping_batch(struct list_head *remove_list,
>>> > +				  struct list_head *ret_pages,
>>> > +				  struct list_head *free_pages)
>>> > +{
>>> > +	int nr_reclaimed = 0;
>>> > +	struct address_space *mapping;
>>> > +	struct page *page;
>>> > +	LIST_HEAD(need_free_mapping);
>>> > +
>>> > +	while (!list_empty(remove_list)) {
>...
>>> > +		if (!__remove_mapping(mapping, page)) {
>>> > +			unlock_page(page);
>>> > +			list_add(&page->lru, ret_pages);
>>> > +			continue;
>>> > +		}
>>> > +		list_add(&page->lru, &need_free_mapping);
>...
>> +	spin_unlock_irq(&mapping->tree_lock);
>> +	while (!list_empty(&need_free_mapping)) {...
>> +		list_move(&page->list, free_pages);
>> +		mapping_release_page(mapping, page);
>> +	}
>> Why do we need new lru list instead of using @free_pages?
>
>I actually tried using @free_pages at first.  The problem is that we
>need to call mapping_release_page() without the radix tree lock held so
>we can not do it in the first while() loop.
>
>'free_pages' is a list created up in shrink_page_list().  There can be
>several calls to __remove_mapping_batch() for each call to
>shrink_page_list().
>
>'need_free_mapping' lets us temporarily differentiate the pages that we
>need to call mapping_release_page()/unlock_page() on versus the ones on
>'free_pages' which have already had that done.
>
>We could theoretically delay _all_ of the
>release_mapping_page()/unlock_page() operations until the _entire_
>shrink_page_list() operation is done, but doing this really helps with
>lock_page() latency.
>
>Does that make sense?

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
