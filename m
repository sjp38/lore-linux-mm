Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2B2CF6B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 01:31:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5B5Wso5015673
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Jun 2009 14:32:54 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DCD645DE55
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 14:32:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2712845DE51
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 14:32:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EDB3E1DB8040
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 14:32:53 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1F331DB803F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 14:32:53 +0900 (JST)
Date: Thu, 11 Jun 2009 14:31:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-Id: <20090611143122.108468f1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090609190128.GA1785@cmpxchg.org>
References: <20090609190128.GA1785@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.org.uk>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jun 2009 21:01:28 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:
> [resend with lists cc'd, sorry]
> 
> +static int swap_readahead_ptes(struct mm_struct *mm,
> +			unsigned long addr, pmd_t *pmd,
> +			swp_entry_t *entries,
> +			unsigned long cluster)
> +{
> +	unsigned long window, min, max, limit;
> +	spinlock_t *ptl;
> +	pte_t *ptep;
> +	int i, nr;
> +
> +	window = cluster << PAGE_SHIFT;
> +	min = addr & ~(window - 1);
> +	max = min + cluster;

Johannes, I wonder there is no reason to use "alignment".
I think we just need to read "nearby" pages. Then, this function's
scan range should be

	[addr - window/2, addr + window/2)
or some.

And here, too
> +	if (!entries)	/* XXX: shmem case */
> +		return swapin_readahead_phys(entry, gfp_mask, vma, addr);
> +	pmin = swp_offset(entry) & ~(cluster - 1);
> +	pmax = pmin + cluster;

pmin = swp_offset(entry) - cluster/2.
pmax = swp_offset(entry) + cluster/2.

I'm sorry if I miss a reason for using "alignment".

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
