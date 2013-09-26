Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id DDF4F6B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:16:41 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so1720296pbc.18
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 15:16:41 -0700 (PDT)
Message-ID: <5244B22C.9020503@sr71.net>
Date: Thu, 26 Sep 2013 15:16:12 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v4 06/40] mm: Demarcate and maintain pageblocks in
 region-order in the zones' freelists
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <20130925231454.26184.19783.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231454.26184.19783.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/25/2013 04:14 PM, Srivatsa S. Bhat wrote:
> @@ -605,16 +713,22 @@ static inline void __free_one_page(struct page *page,
>  		buddy_idx = __find_buddy_index(combined_idx, order + 1);
>  		higher_buddy = higher_page + (buddy_idx - combined_idx);
>  		if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
> -			list_add_tail(&page->lru,
> -				&zone->free_area[order].free_list[migratetype].list);
> +
> +			/*
> +			 * Implementing an add_to_freelist_tail() won't be
> +			 * very useful because both of them (almost) add to
> +			 * the tail within the region. So we could potentially
> +			 * switch off this entire "is next-higher buddy free?"
> +			 * logic when memory regions are used.
> +			 */
> +			add_to_freelist(page, &area->free_list[migratetype]);
>  			goto out;
>  		}
>  	}

Commit 6dda9d55b says that this had some discrete performance gains.
It's a bummer that this deoptimizes it, and I think that (expected)
performance degredation at least needs to be referenced _somewhere_.

I also find it very hard to take code seriously which stuff like this:

> +#ifdef CONFIG_DEBUG_PAGEALLOC
> +		WARN(region->nr_free == 0, "%s: nr_free messed up\n", __func__);
> +#endif

nine times.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
