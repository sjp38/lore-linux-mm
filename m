Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id D386F6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:29:25 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so79958212wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:29:25 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id mn10si33767902wjc.72.2015.08.24.11.29.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 11:29:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 3C428992A4
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:29:23 +0000 (UTC)
Date: Mon, 24 Aug 2015 19:29:21 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 07/12] mm, page_alloc: Distinguish between being unable
 to sleep, unwilling to sleep and avoiding waking kswapd
Message-ID: <20150824182921.GL12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 24, 2015 at 01:09:46PM +0100, Mel Gorman wrote:
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index f9ebe1c82060..c3775ee46cd6 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -188,7 +188,7 @@ radix_tree_node_alloc(struct radix_tree_root *root)
>  	 * preloading in the interrupt anyway as all the allocations have to
>  	 * be atomic. So just do normal allocation when in interrupt.
>  	 */
> -	if (!(gfp_mask & __GFP_WAIT) && !in_interrupt()) {
> +	if (!gfpflags_allow_blocking(gfp_mask) && !in_interrupt()) {
>  		struct radix_tree_preload *rtp;
>  
>  		/*
> @@ -249,7 +249,7 @@ radix_tree_node_free(struct radix_tree_node *node)
>   * with preemption not disabled.
>   *
>   * To make use of this facility, the radix tree must be initialised without
> - * __GFP_WAIT being passed to INIT_RADIX_TREE().
> + * __GFP_DIRECT_RECLAIM being passed to INIT_RADIX_TREE().
>   */
>  static int __radix_tree_preload(gfp_t gfp_mask)
>  {
> @@ -286,12 +286,12 @@ static int __radix_tree_preload(gfp_t gfp_mask)
>   * with preemption not disabled.
>   *
>   * To make use of this facility, the radix tree must be initialised without
> - * __GFP_WAIT being passed to INIT_RADIX_TREE().
> + * __GFP_DIRECT_RECLAIM being passed to INIT_RADIX_TREE().
>   */
>  int radix_tree_preload(gfp_t gfp_mask)
>  {
>  	/* Warn on non-sensical use... */
> -	WARN_ON_ONCE(!(gfp_mask & __GFP_WAIT));
> +	WARN_ON_ONCE(gfpflags_allow_blocking(gfp_mask));
>  	return __radix_tree_preload(gfp_mask);
>  }
>  EXPORT_SYMBOL(radix_tree_preload);

This was a last minute conversion related to fixing up direct usages of
__GFP_DIRECT_RECLAIM that is obviously wrong. It needs a

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index c3775ee46cd6..fcf5d98574ce 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -291,7 +291,7 @@ static int __radix_tree_preload(gfp_t gfp_mask)
 int radix_tree_preload(gfp_t gfp_mask)
 {
 	/* Warn on non-sensical use... */
-	WARN_ON_ONCE(gfpflags_allow_blocking(gfp_mask));
+	WARN_ON_ONCE(!gfpflags_allow_blocking(gfp_mask));
 	return __radix_tree_preload(gfp_mask);
 }
 EXPORT_SYMBOL(radix_tree_preload);

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
