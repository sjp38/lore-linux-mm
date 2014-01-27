Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 827236B0037
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:03:08 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id e9so9095758qcy.1
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 13:03:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v1si4202029qcl.79.2014.01.27.13.03.07
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 13:03:07 -0800 (PST)
Date: Mon, 27 Jan 2014 16:02:56 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1390856576-ud1qp3fm-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1390794746-16755-4-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
 <1390794746-16755-4-git-send-email-davidlohr@hp.com>
Subject: Re: [PATCH 3/8] mm, hugetlb: fix race in region tracking
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 26, 2014 at 07:52:21PM -0800, Davidlohr Bueso wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> There is a race condition if we map a same file on different processes.
> Region tracking is protected by mmap_sem and hugetlb_instantiation_mutex.
> When we do mmap, we don't grab a hugetlb_instantiation_mutex, but only the,
> mmap_sem (exclusively). This doesn't prevent other tasks from modifying the
> region structure, so it can be modified by two processes concurrently.
> 
> To solve this, introduce a spinlock to resv_map and make region manipulation
> function grab it before they do actual work.
> 
> Acked-by: David Gibson <david@gibson.dropbear.id.au>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> [Updated changelog]
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
...
> @@ -203,15 +200,23 @@ static long region_chg(struct resv_map *resv, long f, long t)
>  	 * Subtle, allocate a new region at the position but make it zero
>  	 * size such that we can guarantee to record the reservation. */
>  	if (&rg->link == head || t < rg->from) {
> -		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> -		if (!nrg)
> -			return -ENOMEM;
> +		if (!nrg) {
> +			spin_unlock(&resv->lock);

I think that doing kmalloc() inside the lock is simpler.
Why do you unlock and retry here?

Thanks,
Naoya Horiguchi

> +			nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> +			if (!nrg)
> +				return -ENOMEM;
> +
> +			goto retry;
> +		}
> +
>  		nrg->from = f;
>  		nrg->to   = f;
>  		INIT_LIST_HEAD(&nrg->link);
>  		list_add(&nrg->link, rg->link.prev);
> +		nrg = NULL;
>  
> -		return t - f;
> +		chg = t - f;
> +		goto out_locked;
>  	}
>  
>  	/* Round our left edge to the current segment if it encloses us. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
