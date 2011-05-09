Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6BA6B0025
	for <linux-mm@kvack.org>; Mon,  9 May 2011 17:44:32 -0400 (EDT)
Date: Mon, 9 May 2011 14:43:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap
 chain locking
Message-Id: <20110509144324.8e79654a.akpm@linux-foundation.org>
In-Reply-To: <1304623972-9159-2-git-send-email-andi@firstfloor.org>
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org>
	<1304623972-9159-2-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie, Andi Kleen <ak@linux.intel.com>

On Thu,  5 May 2011 12:32:49 -0700
Andi Kleen <andi@firstfloor.org> wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> In fork and exit it's quite common to take same rmap chain locks
> again and again when the whole address space is processed  for a
> address space that has a lot of sharing. Also since the locking
> has changed to always lock the root anon_vma this can be very
> contended.
> 
> This patch adds a simple wrapper to batch these lock acquisitions
> and only reaquire the lock when another is needed. The main
> advantage is that when multiple processes are doing this in
> parallel they will avoid a lot of communication overhead
> on the lock cache line.
> 
> I added a simple lock break (100 locks) for paranoia reason,
> but it's unclear if that's needed or not.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  include/linux/rmap.h |   38 ++++++++++++++++++++++++++++++++++++++
>  1 files changed, 38 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 830e65d..d5bb9f8 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -113,6 +113,44 @@ static inline void anon_vma_unlock(struct anon_vma *anon_vma)
>  	spin_unlock(&anon_vma->root->lock);
>  }
>  
> +/* 
> + * Batched locking for anon VMA chains to avoid too much cache line 
> + * bouncing.
> + */
> +
> +#define AVL_LOCKBREAK 500
> +
> +struct anon_vma_lock_state {
> +	struct anon_vma *root_anon_vma;
> +	int counter;
> +};
> +
> +static inline void init_anon_vma_lock_batch(struct anon_vma_lock_state *avs)
> +{
> +	avs->root_anon_vma = NULL;
> +	avs->counter = 0;
> +}

This should be called anon_vma_lock_batch_init().

> +static inline void anon_vma_lock_batch(struct anon_vma *anon_vma,
> +				       struct anon_vma_lock_state *state)
> +{
> +	if (state->root_anon_vma == anon_vma->root &&
> +	    state->counter++ < AVL_LOCKBREAK)
> +		return;
> +	if (state->root_anon_vma) {
> +		state->counter = 0;
> +		spin_unlock(&state->root_anon_vma->lock);
> +	}
> +	state->root_anon_vma = anon_vma->root;
> +	spin_lock(&state->root_anon_vma->lock);
> +}

hm, that's a bit large for inlining.

> +static inline void anon_vma_unlock_batch(struct anon_vma_lock_state *avs)
> +{
> +	if (avs->root_anon_vma)
> +		spin_unlock(&avs->root_anon_vma->lock);
> +}
> +
>  /*
>   * anon_vma helper functions.
>   */

The code doesn't build - the patchset forgot to add `spinlock_t lock'
to the anon_vma.

After fixing that and doing an allnoconfig x86_64 build, the patchset
takes rmap.o's .text from 6167 bytes to 6551.  This is likely to be a
regression for uniprocessor machines.  What can we do about this?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
