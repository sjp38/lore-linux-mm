Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDC76B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 18:57:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d4-v6so26032144pfn.9
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 15:57:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 80-v6si29537966pgf.604.2018.07.16.15.57.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 15:57:18 -0700 (PDT)
Date: Mon, 16 Jul 2018 15:57:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] bdi: Use refcount_t for reference counting instead
 atomic_t
Message-Id: <20180716155716.1f7ac43d211133a8cb476637@linux-foundation.org>
In-Reply-To: <20180703200141.28415-4-bigeasy@linutronix.de>
References: <20180703200141.28415-1-bigeasy@linutronix.de>
	<20180703200141.28415-4-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>

On Tue,  3 Jul 2018 22:01:38 +0200 Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> refcount_t type and corresponding API should be used instead of atomic_t when
> the variable is used as a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free situations.
> 
> ...
>
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -438,10 +438,10 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
>  	if (new_congested) {
>  		/* !found and storage for new one already allocated, insert */
>  		congested = new_congested;
> -		new_congested = NULL;
>  		rb_link_node(&congested->rb_node, parent, node);
>  		rb_insert_color(&congested->rb_node, &bdi->cgwb_congested_tree);
> -		goto found;
> +		spin_unlock_irqrestore(&cgwb_lock, flags);
> +		return congested;
>  	}
>  
>  	spin_unlock_irqrestore(&cgwb_lock, flags);
> @@ -451,13 +451,13 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
>  	if (!new_congested)
>  		return NULL;
>  
> -	atomic_set(&new_congested->refcnt, 0);
> +	refcount_set(&new_congested->refcnt, 1);
>  	new_congested->__bdi = bdi;
>  	new_congested->blkcg_id = blkcg_id;
>  	goto retry;
>  
>  found:
> -	atomic_inc(&congested->refcnt);
> +	refcount_inc(&congested->refcnt);
>  	spin_unlock_irqrestore(&cgwb_lock, flags);
>  	kfree(new_congested);
>  	return congested;
>
> ...
>

I'm not sure that the restructuring of wb_congested_get_create() was
desirable and it does make the patch harder to review.  But it looks
OK to me.
