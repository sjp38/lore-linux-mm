Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2E4D6B0007
	for <linux-mm@kvack.org>; Sun, 24 Jun 2018 15:57:57 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id w21-v6so80836ljj.7
        for <linux-mm@kvack.org>; Sun, 24 Jun 2018 12:57:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q24-v6sor233743lfi.25.2018.06.24.12.57.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Jun 2018 12:57:56 -0700 (PDT)
Date: Sun, 24 Jun 2018 22:57:53 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 2/3] mm: workingset: make shadow_lru_isolate() use
 locking suffix
Message-ID: <20180624195753.2e277k5xhujypwre@esperanza>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
 <20180622151221.28167-3-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622151221.28167-3-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 22, 2018 at 05:12:20PM +0200, Sebastian Andrzej Siewior wrote:
> shadow_lru_isolate() disables interrupts and acquires a lock. It could
> use spin_lock_irq() instead. It also uses local_irq_enable() while it
> could use spin_unlock_irq()/xa_unlock_irq().
> 
> Use proper suffix for lock/unlock in order to enable/disable interrupts
> during release/acquire of a lock.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

I don't like when a spin lock is locked with local_irq_disabled +
spin_lock and unlocked with spin_unlock_irq - it looks asymmetric.
IMHO the code is pretty easy to follow as it is - local_irq_disable in
scan_shadow_nodes matches local_irq_enable in shadow_lru_isolate.

> ---
>  mm/workingset.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/workingset.c b/mm/workingset.c
> index ed8151180899..529480c21f93 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -431,7 +431,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
>  
>  	/* Coming from the list, invert the lock order */
>  	if (!xa_trylock(&mapping->i_pages)) {
> -		spin_unlock(lru_lock);
> +		spin_unlock_irq(lru_lock);
>  		ret = LRU_RETRY;
>  		goto out;
>  	}
> @@ -469,13 +469,11 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
>  				 workingset_lookup_update(mapping));
>  
>  out_invalid:
> -	xa_unlock(&mapping->i_pages);
> +	xa_unlock_irq(&mapping->i_pages);
>  	ret = LRU_REMOVED_RETRY;
>  out:
> -	local_irq_enable();
>  	cond_resched();
> -	local_irq_disable();
> -	spin_lock(lru_lock);
> +	spin_lock_irq(lru_lock);
>  	return ret;
>  }
