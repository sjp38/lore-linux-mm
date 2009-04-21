Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0F5A56B005D
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 23:44:59 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L3jeru017620
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Apr 2009 12:45:40 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 50B5145DE55
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 12:45:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E56445DE4F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 12:45:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EC041DB8046
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 12:45:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CEDDE1DB8037
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 12:45:39 +0900 (JST)
Date: Tue, 21 Apr 2009 12:44:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 1/3] mm: fix pageref leak in do_swap_page()
Message-Id: <20090421124407.0f8587dc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
References: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Apr 2009 22:24:43 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> By the time the memory cgroup code is notified about a swapin we
> already hold a reference on the fault page.
> 
> If the cgroup callback fails make sure to unlock AND release the page
> or we leak the reference.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>

Wow, thanks.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/memory.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 366dab5..db126b6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2536,8 +2536,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr)) {
>  		ret = VM_FAULT_OOM;
> -		unlock_page(page);
> -		goto out;
> +		goto out_page;
>  	}
>  
>  	/*
> @@ -2599,6 +2598,7 @@ out:
>  out_nomap:
>  	mem_cgroup_cancel_charge_swapin(ptr);
>  	pte_unmap_unlock(page_table, ptl);
> +out_page:
>  	unlock_page(page);
>  	page_cache_release(page);
>  	return ret;
> -- 
> 1.6.2.1.135.gde769
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
