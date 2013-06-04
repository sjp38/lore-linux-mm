Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id DFE386B0031
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 21:17:27 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id wc20so8491362obb.18
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 18:17:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130603200208.6F71D31F@viggo.jf.intel.com>
References: <20130603200202.7F5FDE07@viggo.jf.intel.com>
	<20130603200208.6F71D31F@viggo.jf.intel.com>
Date: Tue, 4 Jun 2013 09:17:26 +0800
Message-ID: <CAJd=RBC563c64usU2oK40b62c7N0R15KD_4ihFExeT021wUTcw@mail.gmail.com>
Subject: Re: [v5][PATCH 5/6] mm: vmscan: batch shrink_page_list() locking operations
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, minchan@kernel.org

On Tue, Jun 4, 2013 at 4:02 AM, Dave Hansen <dave@sr71.net> wrote:
> +/*
> + * pages come in here (via remove_list) locked and leave unlocked
> + * (on either ret_pages or free_pages)
> + *
> + * We do this batching so that we free batches of pages with a
> + * single mapping->tree_lock acquisition/release.  This optimization
> + * only makes sense when the pages on remove_list all share a
> + * page_mapping().  If this is violated you will BUG_ON().
> + */
> +static int __remove_mapping_batch(struct list_head *remove_list,
> +                                 struct list_head *ret_pages,
> +                                 struct list_head *free_pages)
> +{
> +       int nr_reclaimed = 0;
> +       struct address_space *mapping;
> +       struct page *page;
> +       LIST_HEAD(need_free_mapping);
> +
> +       if (list_empty(remove_list))
> +               return 0;
> +
> +       mapping = page_mapping(lru_to_page(remove_list));
> +       spin_lock_irq(&mapping->tree_lock);
> +       while (!list_empty(remove_list)) {
> +               page = lru_to_page(remove_list);
> +               BUG_ON(!PageLocked(page));
> +               BUG_ON(page_mapping(page) != mapping);
> +               list_del(&page->lru);
> +
> +               if (!__remove_mapping(mapping, page)) {
> +                       unlock_page(page);
> +                       list_add(&page->lru, ret_pages);
> +                       continue;
> +               }
> +               list_add(&page->lru, &need_free_mapping);
> +       }
> +       spin_unlock_irq(&mapping->tree_lock);
> +
While reclaiming pages, can we open ears upon IRQ controller,
if the page list length is over 10, or even 20?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
