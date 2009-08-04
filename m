Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 811856B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 17:49:50 -0400 (EDT)
Date: Tue, 4 Aug 2009 14:49:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/12] ksm: pages_unshared and pages_volatile
Message-Id: <20090804144920.bfc6a44f.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0908031311061.16754@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
	<Pine.LNX.4.64.0908031311061.16754@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: ieidus@redhat.com, aarcange@redhat.com, riel@redhat.com, chrisw@redhat.com, nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 2009 13:11:53 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> The pages_shared and pages_sharing counts give a good picture of how
> successful KSM is at sharing; but no clue to how much wasted work it's
> doing to get there.  Add pages_unshared (count of unique pages waiting
> in the unstable tree, hoping to find a mate) and pages_volatile.
> 
> pages_volatile is harder to define.  It includes those pages changing
> too fast to get into the unstable tree, but also whatever other edge
> conditions prevent a page getting into the trees: a high value may
> deserve investigation.  Don't try to calculate it from the various
> conditions: it's the total of rmap_items less those accounted for.
> 
> Also show full_scans: the number of completed scans of everything
> registered in the mm list.
> 
> The locking for all these counts is simply ksm_thread_mutex.
> 
> ...
>
>  static inline struct rmap_item *alloc_rmap_item(void)
>  {
> -	return kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
> +	struct rmap_item *rmap_item;
> +
> +	rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
> +	if (rmap_item)
> +		ksm_rmap_items++;
> +	return rmap_item;
>  }

ksm_rmap_items was already available via /proc/slabinfo.  I guess that
wasn't a particularly nice user interface ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
