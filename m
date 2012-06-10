Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id C60766B005C
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 22:19:15 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4811198dak.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 19:19:15 -0700 (PDT)
Date: Sat, 9 Jun 2012 19:19:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5] slab/mempolicy: always use local policy from interrupt
 context
In-Reply-To: <1339234803-21106-1-git-send-email-tdmackey@twitter.com>
Message-ID: <alpine.DEB.2.00.1206091917580.7832@chino.kir.corp.google.com>
References: <1338438844-5022-1-git-send-email-andi@firstfloor.org> <1339234803-21106-1-git-send-email-tdmackey@twitter.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Mackey <tdmackey@twitter.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, penberg@kernel.org, cl@linux.com

On Sat, 9 Jun 2012, David Mackey wrote:

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f15c1b2..cb0b230 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1602,8 +1602,14 @@ static unsigned interleave_nodes(struct mempolicy *policy)
>   * task can change it's policy.  The system default policy requires no
>   * such protection.
>   */
> -unsigned slab_node(struct mempolicy *policy)
> +unsigned slab_node(void)
>  {
> +	struct mempolicy *policy;
> +
> +	if (in_interrupt())
> +		return numa_node_id();
> +
> +	policy = current->mempolicy;
>  	if (!policy || policy->flags & MPOL_F_LOCAL)
>  		return numa_node_id();
>  

Should probably be numa_mem_id() in both these cases for 
CONFIG_HAVE_MEMORYLESS_NODES, but it won't cause a problem in this form 
either.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
