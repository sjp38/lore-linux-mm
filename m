Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 3F8AB6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 17:34:58 -0400 (EDT)
Received: by mail-da0-f44.google.com with SMTP id z20so551834dae.17
        for <linux-mm@kvack.org>; Tue, 19 Mar 2013 14:34:57 -0700 (PDT)
Date: Tue, 19 Mar 2013 14:34:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 2/4 v3]swap: __swap_duplicate check bad swap entry
In-Reply-To: <20130221021738.GB32580@kernel.org>
Message-ID: <alpine.LNX.2.00.1303191352320.5966@eggly.anvils>
References: <20130221021738.GB32580@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, linux-mm@kvack.org

On Thu, 21 Feb 2013, Shaohua Li wrote:

> In swapin_readahead(), read_swap_cache_async() can read a bad swap entry,
> because we don't check if readahead swap entry is bad. This doesn't break
> anything but such swapin page is wasteful and can only be freed at page
> reclaim. We avoid read such swap entry.
> 
> And next patch will mark a swap entry bad temporarily for discard. Without this
> patch, swap entry count will be messed.
> 
> Thanks Hugh to inspire swapin_readahead could use bad swap entry.
> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Acked-by: Hugh Dickins <hughd@google.com>

Personally, I'd have merged this one into the next, or added it just
after the next - it can be easier to explain a bug once it's already
there, and okay to fix up after, just so long as it's very unlikely to
interfere with anybody's future bisection.  But maybe you and I just
prefer to tell stories in a different way: no need for you to reorder.

I applied your v3 series shortly before 3.9-rc1, and ran it under load
for a week.  With this addition to your previous, I no longer saw any
"Unused swap" or VM_BUG_ON(error == -EEXIST) issues, it all ran fine.

With one exception: swapoff occasionally failed, and it was another
such SWAP_MAP_BAD issue.  At the bottom I've appended the patch I was
using to fix that (which of course only makes sense after your next).

Maybe you'd like to merge that into this 2/4, and exchange 2/4 and 3/4,
or maybe you'd just like to merge it into your 3/4, or maybe you'd
prefer to keep it as a separate fixup following 3/4: up to you, I'm
not hung up the the ownership of it.  (I never experimented without
the SWP_WRITEOK part of it: I'm not sure how necessary that part is,
but I feel safer with it in.)

> ---
>  mm/swapfile.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> Index: linux/mm/swapfile.c
> ===================================================================
> --- linux.orig/mm/swapfile.c	2013-02-18 15:21:09.285317914 +0800
> +++ linux/mm/swapfile.c	2013-02-18 15:21:34.545004083 +0800
> @@ -2374,6 +2374,11 @@ static int __swap_duplicate(swp_entry_t
>  		goto unlock_out;
>  
>  	count = p->swap_map[offset];
> +	if (unlikely(swap_count(count) == SWAP_MAP_BAD)) {
> +		err = -ENOENT;
> +		goto unlock_out;
> +	}
> +
>  	has_cache = count & SWAP_HAS_CACHE;
>  	count &= ~SWAP_HAS_CACHE;
>  	err = 0;

[PATCH] swap: fix swapoff ENOMEMs from discard

swapoff was sometimes failing with "Cannot allocate memory", coming
from try_to_unuse()'s -ENOMEM: it needs to allow for swap_duplicate()
failing on a free entry temporarily SWAP_MAP_BAD while being discarded.

We should use ACCESS_ONCE() there, and whenever accessing swap_map
locklessly; but rather than peppering it throughout try_to_unuse(),
just declare *swap_map with volatile.

try_to_unuse() is accustomed to *swap_map going down racily, but not
necessarily to it jumping up from 0 to SWAP_MAP_BAD: we'll be safer to
prevent that transition once SWP_WRITEOK is switched off, when it's a
waste of time to issue discards anyway (swapon can do a whole discard).

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/swapfile.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

--- 3.9-rc1+shli/mm/swapfile.c	2013-02-24 12:14:25.799160751 -0800
+++ linux/mm/swapfile.c	2013-02-25 21:43:04.112050626 -0800
@@ -199,8 +199,8 @@ static void discard_swap_cluster(struct
 static int swap_cluster_check_discard(struct swap_info_struct *si,
 		unsigned int idx)
 {
-
-	if (!(si->flags & SWP_DISCARDABLE))
+	if ((si->flags & (SWP_WRITEOK | SWP_DISCARDABLE)) !=
+			 (SWP_WRITEOK | SWP_DISCARDABLE))
 		return 0;
 	/*
 	 * If scan_swap_map() can't find a free cluster, it will check
@@ -1223,7 +1223,7 @@ static unsigned int find_next_to_unuse(s
 			else
 				continue;
 		}
-		count = si->swap_map[i];
+		count = ACCESS_ONCE(si->swap_map[i]);
 		if (count && swap_count(count) != SWAP_MAP_BAD)
 			break;
 	}
@@ -1243,7 +1243,7 @@ int try_to_unuse(unsigned int type, bool
 {
 	struct swap_info_struct *si = swap_info[type];
 	struct mm_struct *start_mm;
-	unsigned char *swap_map;
+	volatile unsigned char *swap_map;	/* ACCESS_ONCE throughout */
 	unsigned char swcount;
 	struct page *page;
 	swp_entry_t entry;
@@ -1294,7 +1294,8 @@ int try_to_unuse(unsigned int type, bool
 			 * reused since sys_swapoff() already disabled
 			 * allocation from here, or alloc_page() failed.
 			 */
-			if (!*swap_map)
+			swcount = *swap_map;
+			if (!swcount || swcount == SWAP_MAP_BAD)
 				continue;
 			retval = -ENOMEM;
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
