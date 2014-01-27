Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 46F0D6B0036
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 18:32:12 -0500 (EST)
Received: by mail-vc0-f171.google.com with SMTP id le5so3945591vcb.30
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 15:32:12 -0800 (PST)
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
        by mx.google.com with ESMTPS id yb7si5706846vec.77.2014.01.27.15.32.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 15:32:11 -0800 (PST)
Received: by mail-ve0-f171.google.com with SMTP id pa12so3987047veb.30
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 15:31:35 -0800 (PST)
Date: Mon, 27 Jan 2014 15:31:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.14] mm, mempolicy: fix mempolicy printing in
 numa_maps
In-Reply-To: <20140127110330.GH4963@suse.de>
Message-ID: <alpine.DEB.2.02.1401271526010.17114@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1401251902180.3140@chino.kir.corp.google.com> <20140127110330.GH4963@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 27 Jan 2014, Mel Gorman wrote:

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index c2ccec0..c1a2573 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -120,6 +120,14 @@ static struct mempolicy default_policy = {
>  
>  static struct mempolicy preferred_node_policy[MAX_NUMNODES];
>  
> +/* Returns true if the policy is the default policy */
> +static bool mpol_is_default(struct mempolicy *pol)
> +{
> +	return !pol ||
> +		pol == &default_policy ||
> +		pol == &preferred_node_policy[numa_node_id()];
> +}
> +
>  static struct mempolicy *get_task_policy(struct task_struct *p)
>  {
>  	struct mempolicy *pol = p->mempolicy;

I was trying to avoid doing this because numa_node_id() of process A 
reading numa_maps for process B has nothing to do with the policy of the 
process A and I thought MPOL_F_MORON's purpose was exactly for what it is 
used for today.  It works today since you initialize preferred_node_policy 
for all nodes, but could this ever change to only be valid for N_MEMORY 
node states, for example?

I'm not sure what the harm in updating mpol_to_str() would be if 
MPOL_F_MORON is to change in the future?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
