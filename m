Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7486B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 04:08:13 -0500 (EST)
Date: Wed, 26 Jan 2011 09:07:45 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] hugepage: Protect region tracking lists with its
	own spinlock
Message-ID: <20110126090744.GQ18984@csn.ul.ie>
References: <20110125143226.37532ea2@kryten>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110125143226.37532ea2@kryten>
Sender: owner-linux-mm@kvack.org
To: Anton Blanchard <anton@samba.org>
Cc: dwg@au1.ibm.com, akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 25, 2011 at 02:32:26PM +1100, Anton Blanchard wrote:
> 
> In preparation for creating a hash of spinlocks to replace the global
> hugetlb_instantiation_mutex, protect the region tracking code with
> its own spinlock.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org> 
> ---
> 
> The old code locked it with either:
> 
> 	down_write(&mm->mmap_sem);
> or
> 	down_read(&mm->mmap_sem);
> 	mutex_lock(&hugetlb_instantiation_mutex);
> 
> I chose to keep things simple and wrap everything with a single lock.
> Do we need the parallelism the old code had in the down_write case?
> 
> 
> Index: powerpc.git/mm/hugetlb.c
> ===================================================================
> --- powerpc.git.orig/mm/hugetlb.c	2011-01-07 12:50:52.090440484 +1100
> +++ powerpc.git/mm/hugetlb.c	2011-01-07 12:52:03.922704453 +1100
> @@ -56,16 +56,6 @@ static DEFINE_SPINLOCK(hugetlb_lock);
>  /*
>   * Region tracking -- allows tracking of reservations and instantiated pages
>   *                    across the pages in a mapping.
> - *
> - * The region data structures are protected by a combination of the mmap_sem
> - * and the hugetlb_instantion_mutex.  To access or modify a region the caller
> - * must either hold the mmap_sem for write, or the mmap_sem for read and
> - * the hugetlb_instantiation mutex:
> - *
> - * 	down_write(&mm->mmap_sem);
> - * or
> - * 	down_read(&mm->mmap_sem);
> - * 	mutex_lock(&hugetlb_instantiation_mutex);
>   */
>  struct file_region {
>  	struct list_head link;

A new comment is needed to explain how region_lock is protecting the
region lists.

Otherwise, nothing jumps out as being bad. It does not appear functionality
or locking has really changed.  The mutex + mmap_sem is still in place
so the spinlock is redundant for protecting the region lists presumably
until the next patch.

> @@ -73,10 +63,14 @@ struct file_region {
>  	long to;
>  };
>  
> +static DEFINE_SPINLOCK(region_lock);
> +
>  static long region_add(struct list_head *head, long f, long t)
>  {
>  	struct file_region *rg, *nrg, *trg;
>  
> +	spin_lock(&region_lock);
> +
>  	/* Locate the region we are either in or before. */
>  	list_for_each_entry(rg, head, link)
>  		if (f <= rg->to)
> @@ -106,6 +100,7 @@ static long region_add(struct list_head
>  	}
>  	nrg->from = f;
>  	nrg->to = t;
> +	spin_unlock(&region_lock);
>  	return 0;
>  }
>  
> @@ -114,6 +109,8 @@ static long region_chg(struct list_head
>  	struct file_region *rg, *nrg;
>  	long chg = 0;
>  
> +	spin_lock(&region_lock);
> +
>  	/* Locate the region we are before or in. */
>  	list_for_each_entry(rg, head, link)
>  		if (f <= rg->to)
> @@ -124,14 +121,17 @@ static long region_chg(struct list_head
>  	 * size such that we can guarantee to record the reservation. */
>  	if (&rg->link == head || t < rg->from) {
>  		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> -		if (!nrg)
> -			return -ENOMEM;
> +		if (!nrg) {
> +			chg = -ENOMEM;
> +			goto out;
> +		}
>  		nrg->from = f;
>  		nrg->to   = f;
>  		INIT_LIST_HEAD(&nrg->link);
>  		list_add(&nrg->link, rg->link.prev);
>  
> -		return t - f;
> +		chg = t - f;
> +		goto out;
>  	}
>  
>  	/* Round our left edge to the current segment if it encloses us. */
> @@ -144,7 +144,7 @@ static long region_chg(struct list_head
>  		if (&rg->link == head)
>  			break;
>  		if (rg->from > t)
> -			return chg;
> +			goto out;
>  
>  		/* We overlap with this area, if it extends futher than
>  		 * us then we must extend ourselves.  Account for its
> @@ -155,6 +155,9 @@ static long region_chg(struct list_head
>  		}
>  		chg -= rg->to - rg->from;
>  	}
> +out:
> +
> +	spin_unlock(&region_lock);
>  	return chg;
>  }
>  
> @@ -163,12 +166,16 @@ static long region_truncate(struct list_
>  	struct file_region *rg, *trg;
>  	long chg = 0;
>  
> +	spin_lock(&region_lock);
> +
>  	/* Locate the region we are either in or before. */
>  	list_for_each_entry(rg, head, link)
>  		if (end <= rg->to)
>  			break;
> -	if (&rg->link == head)
> -		return 0;
> +	if (&rg->link == head) {
> +		chg = 0;
> +		goto out;
> +	}
>  
>  	/* If we are in the middle of a region then adjust it. */
>  	if (end > rg->from) {
> @@ -185,6 +192,9 @@ static long region_truncate(struct list_
>  		list_del(&rg->link);
>  		kfree(rg);
>  	}
> +
> +out:
> +	spin_unlock(&region_lock);
>  	return chg;
>  }
>  
> @@ -193,6 +203,8 @@ static long region_count(struct list_hea
>  	struct file_region *rg;
>  	long chg = 0;
>  
> +	spin_lock(&region_lock);
> +
>  	/* Locate each segment we overlap with, and count that overlap. */
>  	list_for_each_entry(rg, head, link) {
>  		int seg_from;
> @@ -209,6 +221,7 @@ static long region_count(struct list_hea
>  		chg += seg_to - seg_from;
>  	}
>  
> +	spin_unlock(&region_lock);
>  	return chg;
>  }
>  
> 

-- 
Mel Gorman
Linux Technology Center
IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
