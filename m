Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C52696B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 18:10:43 -0400 (EDT)
Date: Thu, 26 Aug 2010 15:10:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] percpu: fix a memory leak in pcpu_extend_area_map()
Message-Id: <20100826151017.63b20d2e.akpm@linux-foundation.org>
In-Reply-To: <4C5EA651.7080009@kernel.org>
References: <1281261197-8816-1-git-send-email-shijie8@gmail.com>
	<4C5EA651.7080009@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Huang Shijie <shijie8@gmail.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 08 Aug 2010 14:42:57 +0200
Tejun Heo <tj@kernel.org> wrote:

> >From 206c53730b8b1707becca7a868ea8d14ebee24d2 Mon Sep 17 00:00:00 2001
> From: Huang Shijie <shijie8@gmail.com>
> Date: Sun, 8 Aug 2010 14:39:07 +0200
> 
> The original code did not free the old map.  This patch fixes it.
> 
> tj: use @old as memcpy source instead of @chunk->map, and indentation
>     and description update
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> Signed-off-by: Tejun Heo <tj@kernel.org>

Should have had a cc:stable in the changelog, IMO.

> ---
> Patch applied to percpu#for-linus w/ some updates.  Thanks a lot for
> catching this.
> 

This patch appears to have been lost?

> diff --git a/mm/percpu.c b/mm/percpu.c
> index e61dc2c..a1830d8 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -393,7 +393,9 @@ static int pcpu_extend_area_map(struct pcpu_chunk *chunk, int new_alloc)
>  		goto out_unlock;
> 
>  	old_size = chunk->map_alloc * sizeof(chunk->map[0]);
> -	memcpy(new, chunk->map, old_size);
> +	old = chunk->map;
> +
> +	memcpy(new, old, old_size);
> 
>  	chunk->map_alloc = new_alloc;
>  	chunk->map = new;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
