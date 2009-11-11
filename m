Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 238896B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 02:56:33 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB7uU3F007049
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Nov 2009 16:56:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 155CD45DE4E
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 16:56:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D0B2B45DE55
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 16:56:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B91521DB8040
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 16:56:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EC80E18009
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 16:56:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] mm: mlocking in try_to_unmap_one
In-Reply-To: <Pine.LNX.4.64.0911102151500.2816@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils> <Pine.LNX.4.64.0911102151500.2816@sister.anvils>
Message-Id: <20091111102400.FD36.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Nov 2009 16:56:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh

> @@ -1081,45 +1053,23 @@ static int try_to_unmap_file(struct page
>  	unsigned long max_nl_cursor = 0;
>  	unsigned long max_nl_size = 0;
>  	unsigned int mapcount;
> -	unsigned int mlocked = 0;
> -	int unlock = TTU_ACTION(flags) == TTU_MUNLOCK;
> -
> -	if (MLOCK_PAGES && unlikely(unlock))
> -		ret = SWAP_SUCCESS;	/* default for try_to_munlock() */
>  
>  	spin_lock(&mapping->i_mmap_lock);
>  	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
> -		if (MLOCK_PAGES && unlikely(unlock)) {
> -			if (!((vma->vm_flags & VM_LOCKED) &&
> -						page_mapped_in_vma(page, vma)))
> -				continue;	/* must visit all vmas */
> -			ret = SWAP_MLOCK;
> -		} else {
> -			ret = try_to_unmap_one(page, vma, flags);
> -			if (ret == SWAP_FAIL || !page_mapped(page))
> -				goto out;
> -		}
> -		if (ret == SWAP_MLOCK) {
> -			mlocked = try_to_mlock_page(page, vma);
> -			if (mlocked)
> -				break;  /* stop if actually mlocked page */
> -		}
> +		ret = try_to_unmap_one(page, vma, flags);
> +		if (ret != SWAP_AGAIN || !page_mapped(page))
> +			goto out;
>  	}
>  
> -	if (mlocked)
> +	if (list_empty(&mapping->i_mmap_nonlinear))
>  		goto out;
>
> -	if (list_empty(&mapping->i_mmap_nonlinear))
> +	/* We don't bother to try to find the munlocked page in nonlinears */
> +	if (MLOCK_PAGES && TTU_ACTION(flags) == TTU_MUNLOCK)
>  		goto out;

I have dumb question.
Does this shortcut exiting code makes any behavior change?




>  
>  	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
>  						shared.vm_set.list) {
> -		if (MLOCK_PAGES && unlikely(unlock)) {
> -			if (!(vma->vm_flags & VM_LOCKED))
> -				continue;	/* must visit all vmas */
> -			ret = SWAP_MLOCK;	/* leave mlocked == 0 */
> -			goto out;		/* no need to look further */
> -		}
>  		if (!MLOCK_PAGES && !(flags & TTU_IGNORE_MLOCK) &&
>  			(vma->vm_flags & VM_LOCKED))
>  			continue;
> @@ -1161,10 +1111,9 @@ static int try_to_unmap_file(struct page
>  			cursor = (unsigned long) vma->vm_private_data;
>  			while ( cursor < max_nl_cursor &&
>  				cursor < vma->vm_end - vma->vm_start) {
> -				ret = try_to_unmap_cluster(cursor, &mapcount,
> -								vma, page);
> -				if (ret == SWAP_MLOCK)
> -					mlocked = 2;	/* to return below */
> +				if (try_to_unmap_cluster(cursor, &mapcount,
> +						vma, page) == SWAP_MLOCK)
> +					ret = SWAP_MLOCK;
>  				cursor += CLUSTER_SIZE;
>  				vma->vm_private_data = (void *) cursor;
>  				if ((int)mapcount <= 0)
> @@ -1185,10 +1134,6 @@ static int try_to_unmap_file(struct page
>  		vma->vm_private_data = NULL;
>  out:
>  	spin_unlock(&mapping->i_mmap_lock);
> -	if (mlocked)
> -		ret = SWAP_MLOCK;	/* actually mlocked the page */
> -	else if (ret == SWAP_MLOCK)
> -		ret = SWAP_AGAIN;	/* saw VM_LOCKED vma */
>  	return ret;
>  }
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
