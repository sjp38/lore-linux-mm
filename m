Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 3ADBF6B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 23:26:16 -0500 (EST)
Received: by mail-da0-f48.google.com with SMTP id w4so149793dam.21
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 20:26:15 -0800 (PST)
Message-ID: <5126F360.1060507@gmail.com>
Date: Fri, 22 Feb 2013 12:26:08 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] ksm: add some comments
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <alpine.LNX.2.00.1302210018100.17843@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1302210018100.17843@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/21/2013 04:19 PM, Hugh Dickins wrote:
> Added slightly more detail to the Documentation of merge_across_nodes,
> a few comments in areas indicated by review, and renamed get_ksm_page()'s
> argument from "locked" to "lock_it".  No functional change.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>   Documentation/vm/ksm.txt |   16 ++++++++++++----
>   mm/ksm.c                 |   18 ++++++++++++++----
>   2 files changed, 26 insertions(+), 8 deletions(-)
>
> --- mmotm.orig/Documentation/vm/ksm.txt	2013-02-20 22:28:09.456001057 -0800
> +++ mmotm/Documentation/vm/ksm.txt	2013-02-20 22:28:23.580001392 -0800
> @@ -60,10 +60,18 @@ sleep_millisecs  - how many milliseconds
>   
>   merge_across_nodes - specifies if pages from different numa nodes can be merged.
>                      When set to 0, ksm merges only pages which physically
> -                   reside in the memory area of same NUMA node. It brings
> -                   lower latency to access to shared page. Value can be
> -                   changed only when there is no ksm shared pages in system.
> -                   Default: 1
> +                   reside in the memory area of same NUMA node. That brings
> +                   lower latency to access of shared pages. Systems with more
> +                   nodes, at significant NUMA distances, are likely to benefit
> +                   from the lower latency of setting 0. Smaller systems, which
> +                   need to minimize memory usage, are likely to benefit from
> +                   the greater sharing of setting 1 (default). You may wish to
> +                   compare how your system performs under each setting, before
> +                   deciding on which to use. merge_across_nodes setting can be
> +                   changed only when there are no ksm shared pages in system:
> +                   set run 2 to unmerge pages first, then to 1 after changing
> +                   merge_across_nodes, to remerge according to the new setting.

What's the root reason merge_across_nodes setting just can be changed 
only when there are no ksm shared pages in system? Can they be unmerged 
and merged again during ksmd scan?

> +                   Default: 1 (merging across nodes as in earlier releases)
>   
>   run              - set 0 to stop ksmd from running but keep merged pages,
>                      set 1 to run ksmd e.g. "echo 1 > /sys/kernel/mm/ksm/run",
> --- mmotm.orig/mm/ksm.c	2013-02-20 22:28:09.456001057 -0800
> +++ mmotm/mm/ksm.c	2013-02-20 22:28:23.584001392 -0800
> @@ -87,6 +87,9 @@
>    *    take 10 attempts to find a page in the unstable tree, once it is found,
>    *    it is secured in the stable tree.  (When we scan a new page, we first
>    *    compare it against the stable tree, and then against the unstable tree.)
> + *
> + * If the merge_across_nodes tunable is unset, then KSM maintains multiple
> + * stable trees and multiple unstable trees: one of each for each NUMA node.
>    */
>   
>   /**
> @@ -524,7 +527,7 @@ static void remove_node_from_stable_tree
>    * a page to put something that might look like our key in page->mapping.
>    * is on its way to being freed; but it is an anomaly to bear in mind.
>    */
> -static struct page *get_ksm_page(struct stable_node *stable_node, bool locked)
> +static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>   {
>   	struct page *page;
>   	void *expected_mapping;
> @@ -573,7 +576,7 @@ again:
>   		goto stale;
>   	}
>   
> -	if (locked) {
> +	if (lock_it) {
>   		lock_page(page);
>   		if (ACCESS_ONCE(page->mapping) != expected_mapping) {
>   			unlock_page(page);
> @@ -703,10 +706,17 @@ static int remove_stable_node(struct sta
>   		return 0;
>   	}
>   
> -	if (WARN_ON_ONCE(page_mapped(page)))
> +	if (WARN_ON_ONCE(page_mapped(page))) {
> +		/*
> +		 * This should not happen: but if it does, just refuse to let
> +		 * merge_across_nodes be switched - there is no need to panic.
> +		 */
>   		err = -EBUSY;
> -	else {
> +	} else {
>   		/*
> +		 * The stable node did not yet appear stale to get_ksm_page(),
> +		 * since that allows for an unmapped ksm page to be recognized
> +		 * right up until it is freed; but the node is safe to remove.
>   		 * This page might be in a pagevec waiting to be freed,
>   		 * or it might be PageSwapCache (perhaps under writeback),
>   		 * or it might have been removed from swapcache a moment ago.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
