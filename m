Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 53A8A6B0031
	for <linux-mm@kvack.org>; Sun,  1 Jun 2014 15:32:43 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x12so4141687wgg.21
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 12:32:42 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id yx7si21910741wjc.120.2014.06.01.12.32.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jun 2014 12:32:41 -0700 (PDT)
Date: Sun, 1 Jun 2014 21:32:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: sleeping function warning from __put_anon_vma
Message-ID: <20140601193240.GF16155@laptop.programming.kicks-ass.net>
References: <20140530000944.GA29942@redhat.com>
 <alpine.LSU.2.11.1405311321340.10272@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1405311321340.10272@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, May 31, 2014 at 01:33:13PM -0700, Hugh Dickins wrote:
> [PATCH] mm: fix sleeping function warning from __put_anon_vma
> 
> Trinity reports BUG:
> sleeping function called from invalid context at kernel/locking/rwsem.c:47
> in_atomic(): 0, irqs_disabled(): 0, pid: 5787, name: trinity-c27
> __might_sleep < down_write < __put_anon_vma < page_get_anon_vma <
> migrate_pages < compact_zone < compact_zone_order < try_to_compact_pages ..
> 
> Right, since conversion to mutex then rwsem, we should not put_anon_vma()
> from inside an rcu_read_lock()ed section: fix the two places that did so.
> 
> Fixes: 88c22088bf23 ("mm: optimize page_lock_anon_vma() fast-path")
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Needs-Ack-from: Peter Zijlstra <peterz@infradead.org>
> ---
> 
>  mm/rmap.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> --- 3.15-rc7/mm/rmap.c	2014-04-13 17:24:36.680507189 -0700
> +++ linux/mm/rmap.c	2014-05-31 12:02:08.496088637 -0700
> @@ -426,12 +426,14 @@ struct anon_vma *page_get_anon_vma(struc
>  	 * above cannot corrupt).
>  	 */
>  	if (!page_mapped(page)) {
> +		rcu_read_unlock();
>  		put_anon_vma(anon_vma);
>  		anon_vma = NULL;
> +		goto outer;
>  	}
>  out:
>  	rcu_read_unlock();
> -
> +outer:
>  	return anon_vma;
>  }

I think we can do that without the goto if we write something like:

	if (!page_mapped(page)) {
		rcu_read_unlock();
		put_anon_vma(anon_vma);
		return NULL;
	}

> @@ -477,9 +479,10 @@ struct anon_vma *page_lock_anon_vma_read
>  	}
>  
>  	if (!page_mapped(page)) {
> +		rcu_read_unlock();
>  		put_anon_vma(anon_vma);
>  		anon_vma = NULL;
> -		goto out;
> +		goto outer;
>  	}
>  
>  	/* we pinned the anon_vma, its safe to sleep */
> @@ -501,6 +504,7 @@ struct anon_vma *page_lock_anon_vma_read
>  
>  out:
>  	rcu_read_unlock();
> +outer:
>  	return anon_vma;
>  }

Same here too, I suppose.

Interesting that we never managed to hit this one; it might also make
sense to put a might_sleep() in anon_vma_free().

Other than that, I don't see anything really odd, then again, its sunday
evening and my thinking cap isn't exactly on proper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
