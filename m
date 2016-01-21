Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id B93F46B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 20:22:42 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id 6so21063223qgy.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 17:22:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 75si46766648qkz.111.2016.01.20.17.22.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 17:22:41 -0800 (PST)
Date: Thu, 21 Jan 2016 02:22:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCHv12 34/37] thp: introduce deferred_split_huge_page()
Message-ID: <20160121012237.GE7119@redhat.com>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-35-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444145044-72349-35-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Kirill,

On Tue, Oct 06, 2015 at 06:24:01PM +0300, Kirill A. Shutemov wrote:
> +static unsigned long deferred_split_scan(struct shrinker *shrink,
> +		struct shrink_control *sc)
> +{
> +	unsigned long flags;
> +	LIST_HEAD(list), *pos, *next;
> +	struct page *page;
> +	int split = 0;
> +
> +	spin_lock_irqsave(&split_queue_lock, flags);
> +	list_splice_init(&split_queue, &list);
> +
> +	/* Take pin on all head pages to avoid freeing them under us */
> +	list_for_each_safe(pos, next, &list) {
> +		page = list_entry((void *)pos, struct page, mapping);
> +		page = compound_head(page);
> +		/* race with put_compound_page() */
> +		if (!get_page_unless_zero(page)) {
> +			list_del_init(page_deferred_list(page));
> +			split_queue_len--;
> +		}
> +	}
> +	spin_unlock_irqrestore(&split_queue_lock, flags);

While rebasing I noticed this loop looks a bit too heavy. There's no
lockbreak and no cap on the list size, and million of THP pages could
have been partially unmapped but not be entirely freed yet, and sit
there for a while (there are other scenarios but this is the one that
could more realistically happen with certain allocators). Then as
result of random memory pressure we'd be calling millions of
get_page_unless_zero across multiple NUMA nodes thrashing cachelines
at every list entry, with irq disabled too for the whole period.

I haven't verified it, but I guess that in some large NUMA (i.e. 4TiB)
system that could take down a CPU for a second or more with irq
disabled.

I think it needs to isolate a certain number of pages, not splice
(userland programs can invoke the shrinker through direct reclaim too
and they can't stuck there for too long) and perhaps use
sc->nr_to_scan to achieve that.

The split_queue can also be moved from global to the "struct
pglist_data" and then you can do NODE_DATA(sc->nid)->split_queue, same
for the spinlock. That will make it more scalable for the lock and
more efficient in freeing memory so we don't split THP from nodes
reclaim isn't currently interested about (reclaim will later try again
on the zones in the other nodes by itself if needed).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
