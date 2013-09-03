Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 651D96B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 02:39:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AB7243EE0C3
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 15:39:06 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EE0F45DE54
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 15:39:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8276B45DE5E
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 15:39:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 757D11DB8040
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 15:39:06 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F1E3BE08001
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 15:39:05 +0900 (JST)
Message-ID: <522583DE.709@jp.fujitsu.com>
Date: Tue, 3 Sep 2013 15:38:22 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 09/35] mm: Track the freepage migratetype of pages
 accurately
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com> <20130830131635.4947.81565.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131635.4947.81565.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2013/08/30 22:16), Srivatsa S. Bhat wrote:
> Due to the region-wise ordering of the pages in the buddy allocator's
> free lists, whenever we want to delete a free pageblock from a free list
> (for ex: when moving blocks of pages from one list to the other), we need
> to be able to tell the buddy allocator exactly which migratetype it belongs
> to. For that purpose, we can use the page's freepage migratetype (which is
> maintained in the page's ->index field).
>
> So, while splitting up higher order pages into smaller ones as part of buddy
> operations, keep the new head pages updated with the correct freepage
> migratetype information (because we depend on tracking this info accurately,
> as outlined above).
>
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---
>
>   mm/page_alloc.c |    7 +++++++
>   1 file changed, 7 insertions(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 398b62c..b4b1275 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -947,6 +947,13 @@ static inline void expand(struct zone *zone, struct page *page,
>   		add_to_freelist(&page[size], &area->free_list[migratetype]);
>   		area->nr_free++;
>   		set_page_order(&page[size], high);
> +
> +		/*
> +		 * Freepage migratetype is tracked using the index field of the
> +		 * first page of the block. So we need to update the new first
> +		 * page, when changing the page order.
> +		 */
> +		set_freepage_migratetype(&page[size], migratetype);
>   	}
>   }
>
>

It this patch a bug fix patch?
If so, I want you to split the patch from the patch-set.

Thanks,
Yasuaki Ishimatsu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
