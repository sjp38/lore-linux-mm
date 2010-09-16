Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B50AE6B0078
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 17:36:05 -0400 (EDT)
Date: Thu, 16 Sep 2010 23:36:03 +0200
From: Peter Palfrader <peter@palfrader.org>
Subject: breaks 2.6.32.21+ (was: [PATCH] percpu: fix a memory leak in
	pcpu_extend_area_map())
Message-ID: <20100916213603.GW6447@anguilla.noreply.org>
References: <1281261197-8816-1-git-send-email-shijie8@gmail.com> <4C5EA651.7080009@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4C5EA651.7080009@kernel.org>
Sender: owner-linux-mm@kvack.org
To: stable@kernel.org
Cc: Tejun Heo <tj@kernel.org>, Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hey,

The patch quoted below seems to have made it into Greg's stable-queue
for 2.6.32.

I tried building a kernel based on 2.6.32.21 plus all the patches
currently in that queue.  The resulting kernel unfortunately didn't
boot for me, neither as a 32 nor as 64 bit x86 kernel.

I have put up a screenshot of a trace at
http://asteria.noreply.org/~weasel/volatile/2010-09-16-SrLl9JHtDTg/trace-64bit.png
since the kernel fortunately also died in kvm - unfortunately only the
last 60 lines are easily available.  If you need more I could try to set
up some serial console thing to catch more.

Bisecting led to this patch and reverting "percpu: fix a memory leak in
pcpu_extend_area_map()" makes the kernel boot for me again.

> From 206c53730b8b1707becca7a868ea8d14ebee24d2 Mon Sep 17 00:00:00 2001
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
> ---
> Patch applied to percpu#for-linus w/ some updates.  Thanks a lot for
> catching this.
> 
>  mm/percpu.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
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

Cheers,
Peter
-- 
                           |  .''`.  ** Debian GNU/Linux **
      Peter Palfrader      | : :' :      The  universal
 http://www.palfrader.org/ | `. `'      Operating System
                           |   `-    http://www.debian.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
