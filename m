Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id A5F786B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 11:22:15 -0400 (EDT)
Message-ID: <51AE061F.5060900@sr71.net>
Date: Tue, 04 Jun 2013 08:22:07 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [v5][PATCH 5/6] mm: vmscan: batch shrink_page_list() locking
 operations
References: <20130603200202.7F5FDE07@viggo.jf.intel.com> <20130603200208.6F71D31F@viggo.jf.intel.com> <CAJd=RBC563c64usU2oK40b62c7N0R15KD_4ihFExeT021wUTcw@mail.gmail.com> <20130604050744.GD14719@blaptop>
In-Reply-To: <20130604050744.GD14719@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On 06/03/2013 10:07 PM, Minchan Kim wrote:
>>> > > +       while (!list_empty(remove_list)) {
>>> > > +               page = lru_to_page(remove_list);
>>> > > +               BUG_ON(!PageLocked(page));
>>> > > +               BUG_ON(page_mapping(page) != mapping);
>>> > > +               list_del(&page->lru);
>>> > > +
>>> > > +               if (!__remove_mapping(mapping, page)) {
>>> > > +                       unlock_page(page);
>>> > > +                       list_add(&page->lru, ret_pages);
>>> > > +                       continue;
>>> > > +               }
>>> > > +               list_add(&page->lru, &need_free_mapping);
>>> > > +       }
>>> > > +       spin_unlock_irq(&mapping->tree_lock);
>>> > > +
>> > While reclaiming pages, can we open ears upon IRQ controller,
>> > if the page list length is over 10, or even 20?
> At the moment, it implicitly could be bounded by SWAP_CLUSTER_MAX and
> it's the value used by isolate_migratepages_ranges to enable IRQ.
> I have no idea it's proper value to give a chace to IRQ but at least,
> Dave's code doesn't break the rule.
> If we need a tune for that, it could be a another patch to investigate

I also wouldn't exactly call this "reclaiming pages".   As Minchan
mentions, this is already bounded and it's a relatively cheap set of
operations.  *WAY* cheaper than actually reclaiming a page.

Honestly, this whole patch series is about trading latency for increased
bandwidth reclaiming pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
