Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 07B8E6B005D
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 11:31:14 -0400 (EDT)
Date: Tue, 16 Oct 2012 15:31:13 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v5 07/14] mm: Allocate kernel pages to the right memcg
In-Reply-To: <1350382611-20579-8-git-send-email-glommer@parallels.com>
Message-ID: <0000013a6a333867-52b0d904-5ca2-4095-8c46-5a4dfc021cde-000000@email.amazonses.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-8-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Tue, 16 Oct 2012, Glauber Costa wrote:

> To avoid adding markers to the page - and a kmem flag that would
> necessarily follow, as much as doing page_cgroup lookups for no reason,
> whoever is marking its allocations with __GFP_KMEMCG flag is responsible
> for telling the page allocator that this is such an allocation at
> free_pages() time. This is done by the invocation of
> __free_accounted_pages() and free_accounted_pages().

Hmmm... The code paths to free pages are often shared between multiple
subsystems. Are you sure that this is actually working and accurately
tracks the MEMCG pages?

> +/*
> + * __free_accounted_pages and free_accounted_pages will free pages allocated
> + * with __GFP_KMEMCG.
> + *
> + * Those pages are accounted to a particular memcg, embedded in the
> + * corresponding page_cgroup. To avoid adding a hit in the allocator to search
> + * for that information only to find out that it is NULL for users who have no
> + * interest in that whatsoever, we provide these functions.
> + *
> + * The caller knows better which flags it relies on.
> + */
> +void __free_accounted_pages(struct page *page, unsigned int order)
> +{
> +	memcg_kmem_uncharge_page(page, order);
> +	__free_pages(page, order);
> +}

If we already are introducing such an API: Could it not be made more
general so that it can also be used in the future to communicate other
characteristics of a page on free?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
