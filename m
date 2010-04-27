Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2738B6B01EE
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 20:31:13 -0400 (EDT)
Message-ID: <4BD63031.6050105@redhat.com>
Date: Mon, 26 Apr 2010 20:30:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie> <1272321478-28481-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1272321478-28481-3-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/26/2010 06:37 PM, Mel Gorman wrote:

> diff --git a/mm/rmap.c b/mm/rmap.c
> index 85f203e..bc313a6 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1368,15 +1368,31 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
>   	 * are holding mmap_sem. Users without mmap_sem are required to
>   	 * take a reference count to prevent the anon_vma disappearing
>   	 */
> +retry:
>   	anon_vma = page_anon_vma(page);
>   	if (!anon_vma)
>   		return ret;
>   	spin_lock(&anon_vma->lock);
>   	list_for_each_entry(avc,&anon_vma->head, same_anon_vma) {
>   		struct vm_area_struct *vma = avc->vma;
> -		unsigned long address = vma_address(page, vma);
> -		if (address == -EFAULT)
> -			continue;
> +		unsigned long address;
> +
> +		/*
> +		 * Guard against deadlocks by not spinning against
> +		 * vma->anon_vma->lock. If contention is found, release our
> +		 * lock and try again until VMA list can be traversed without
> +		 * contention.
> +		 */
> +		if (anon_vma != vma->anon_vma) {
> +			if (!spin_trylock(&vma->anon_vma->lock)) {
> +				spin_unlock(&anon_vma->lock);
> +				goto retry;
> +			}
> +		}

If you're part way down the list, surely you'll need to
unlock multiple anon_vmas here before going to retry?

Otherwise you could forget to unlock one that you already
locked, and live-lock here.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
