Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 18CBB6B003C
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 17:15:59 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so11468632pad.1
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 14:15:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xy8si13363108pab.365.2014.04.16.14.15.57
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 14:15:58 -0700 (PDT)
Date: Wed, 16 Apr 2014 14:15:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/mempool: warn about __GFP_ZERO usage
Message-Id: <20140416141556.d50eef60d955d724ba1b02de@linux-foundation.org>
In-Reply-To: <alpine.LFD.2.11.1404141918170.1561@denkbrett>
References: <alpine.LFD.2.11.1404141918170.1561@denkbrett>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Apr 2014 19:23:34 +0200 (CEST) Sebastian Ott <sebott@linux.vnet.ibm.com> wrote:

> Memory obtained via mempool_alloc is not always zeroed even when
> called with __GFP_ZERO. Add a note and VM_BUG_ON statement to make
> that clear.
> 
> ..
>
> @@ -200,6 +201,7 @@ void * mempool_alloc(mempool_t *pool, gf
>  	wait_queue_t wait;
>  	gfp_t gfp_temp;
>  
> +	VM_BUG_ON(gfp_mask & __GFP_ZERO);
>  	might_sleep_if(gfp_mask & __GFP_WAIT);
>  
>  	gfp_mask |= __GFP_NOMEMALLOC;	/* don't allocate emergency reserves */

hm, BUG is a bit harsh.  How about

--- a/mm/mempool.c~mm-mempool-warn-about-__gfp_zero-usage-fix
+++ a/mm/mempool.c
@@ -201,7 +201,9 @@ void * mempool_alloc(mempool_t *pool, gf
 	wait_queue_t wait;
 	gfp_t gfp_temp;
 
-	VM_BUG_ON(gfp_mask & __GFP_ZERO);
+#ifdef CONFIG_DEBUG_VM
+	WARN_ON_ONCE(gfp_mask & __GFP_ZERO);	/* Where's VM_WARN_ON_ONCE()? */
+#endif
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 
 	gfp_mask |= __GFP_NOMEMALLOC;	/* don't allocate emergency reserves */

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
