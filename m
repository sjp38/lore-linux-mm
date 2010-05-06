Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DDBDD6B0265
	for <linux-mm@kvack.org>; Wed,  5 May 2010 20:44:33 -0400 (EDT)
Date: Wed, 5 May 2010 17:42:19 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
In-Reply-To: <20100506002255.GY20979@csn.ul.ie>
Message-ID: <alpine.LFD.2.00.1005051737290.901@i5.linux-foundation.org>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
 <20100505175311.GU20979@csn.ul.ie> <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org> <20100506002255.GY20979@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>



On Thu, 6 May 2010, Mel Gorman wrote:
> +	/*
> +	 * Get the root anon_vma on the list by depending on the ordering
> +	 * of the same_vma list setup by __page_set_anon_rmap. Basically
> +	 * we are doing
> +	 *
> +	 * local anon_vma -> local vma -> deepest vma -> anon_vma
> +	 */
> +	avc = list_first_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
> +	vma = avc->vma;
> +	root_avc = list_entry(vma->anon_vma_chain.prev, struct anon_vma_chain, same_vma);
> +	root_anon_vma = root_avc->anon_vma;
> +	if (!root_anon_vma) {
> +		/* XXX: Can this happen? Don't think so but get confirmation */
> +		WARN_ON_ONCE(1);
> +		return anon_vma;
> +	}

No, that can't happen. If you find an avc struct, it _will_ have a 
anon_vma pointer. So there's no point in testing for NULL. If some bug 
happens, you're much better off with the oops than with the warning.

> +	/* Get the lock of the root anon_vma */
> +	if (anon_vma != root_anon_vma) {
> +		/*
> +		 * XXX: This doesn't seem safe. What prevents root_anon_vma
> +		 * getting freed from underneath us? Not much but if
> +		 * we take the second lock first, there is a deadlock
> +		 * possibility if there are multiple callers of rmap_walk
> +		 */
> +		spin_unlock(&anon_vma->lock);
> +		spin_lock(&root_anon_vma->lock);
> +	}

What makes this ok is the fact that it must be running under the RCU read 
lock, and anon_vma's thus cannot be released. My version of the code made 
that explicit. Yours does not, and doesn't even have comments about the 
fact that it needs to be called RCU read-locked. Tssk, tssk.

Please don't just assume locking. Either lock it, or say "this must be 
called with so-and-so held". Not just a silent "this would be buggy if 
anybody ever called it without the RCU lock".

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
