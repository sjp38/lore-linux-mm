Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 8EF4D6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 16:57:28 -0500 (EST)
Date: Thu, 23 Feb 2012 22:57:23 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 1/2] mm: fix quadratic behaviour in
 get_unmapped_area_topdown
Message-ID: <20120223215723.GB1701@cmpxchg.org>
References: <20120223145417.261225fd@cuia.bos.redhat.com>
 <20120223145636.616bef1c@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120223145636.616bef1c@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, hughd@google.com

On Thu, Feb 23, 2012 at 02:56:36PM -0500, Rik van Riel wrote:
> When we look for a VMA smaller than the cached_hole_size, we set the
> starting search address to mm->mmap_base, to try and find our hole.
> 
> However, even in the case where we fall through and found nothing at
> the mm->free_area_cache, we still reset the search address to mm->mmap_base.
> This bug results in quadratic behaviour, with observed mmap times of 0.4
> seconds for processes that have very fragmented memory.
> 
> If there is no hole small enough for us to fit the VMA, and we have
> no good spot for us right at mm->free_area_cache, we are much better
> off continuing the search down from mm->free_area_cache, instead of
> all the way from the top.

Would it make sense to retain the restart for the case where we _know_
that the remaining address space can not fit the desired area?

	/* make sure it can fit in the remaining address space */
	if (addr > len) {
		vma = find_vma(mm, addr-len);
		if (!vma || addr <= vma->vm_start)
			/* remember the address as a hint for next time */
			return (mm->free_area_cache = addr-len);
	} else /* like this */
		addr = mm->mmap_base - len;

It would save one pointless find_vma() further down.  I don't feel too
strongly about it, though.  Either way:

> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
