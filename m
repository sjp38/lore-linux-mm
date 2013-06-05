Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id D21166B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 10:24:37 -0400 (EDT)
Message-ID: <51AF4A24.2020606@sr71.net>
Date: Wed, 05 Jun 2013 07:24:36 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [v5][PATCH 5/6] mm: vmscan: batch shrink_page_list() locking
 operations
References: <20130603200202.7F5FDE07@viggo.jf.intel.com> <20130603200208.6F71D31F@viggo.jf.intel.com> <CAJd=RBC563c64usU2oK40b62c7N0R15KD_4ihFExeT021wUTcw@mail.gmail.com> <20130604050744.GD14719@blaptop> <CAJd=RBAt9eSx3_FB79J93e19bv15sFry-mU6hkUYH80isULszw@mail.gmail.com>
In-Reply-To: <CAJd=RBAt9eSx3_FB79J93e19bv15sFry-mU6hkUYH80isULszw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On 06/05/2013 12:28 AM, Hillf Danton wrote:
>>>> >> > +       mapping = page_mapping(lru_to_page(remove_list));
>>>> >> > +       spin_lock_irq(&mapping->tree_lock);
>>>> >> > +       while (!list_empty(remove_list)) {
>>>> >> > +               page = lru_to_page(remove_list);
>>>> >> > +               BUG_ON(!PageLocked(page));
>>>> >> > +               BUG_ON(page_mapping(page) != mapping);
>>>> >> > +               list_del(&page->lru);
>>>> >> > +
>>>> >> > +               if (!__remove_mapping(mapping, page)) {
>>>> >> > +                       unlock_page(page);
>>>> >> > +                       list_add(&page->lru, ret_pages);
>>>> >> > +                       continue;
>>>> >> > +               }
>>>> >> > +               list_add(&page->lru, &need_free_mapping);
>>>> >> > +       }
>>>> >> > +       spin_unlock_irq(&mapping->tree_lock);
>>>> >> > +
>>> >> While reclaiming pages, can we open ears upon IRQ controller,
>>> >> if the page list length is over 10, or even 20?
>> >
>> > At the moment, it implicitly could be bounded by SWAP_CLUSTER_MAX and
> Could we reclaim a THP currently?

No, it would be split first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
