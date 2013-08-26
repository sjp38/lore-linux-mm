Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 339D16B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 01:33:27 -0400 (EDT)
Message-ID: <521AE884.6090605@redhat.com>
Date: Mon, 26 Aug 2013 01:32:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier related
 damage v3
References: <20120307180852.GE17697@suse.de> <20130823130332.GY31370@twins.programming.kicks-ass.net> <20130823181546.GA31370@twins.programming.kicks-ass.net>
In-Reply-To: <20130823181546.GA31370@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/23/2013 02:15 PM, Peter Zijlstra wrote:

> So I guess the quick and ugly solution is something like the below. 

This still crashes :)

> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1762,19 +1762,21 @@ unsigned slab_node(void)
>  static unsigned offset_il_node(struct mempolicy *pol,
>  		struct vm_area_struct *vma, unsigned long off)
>  {
> -	unsigned nnodes = nodes_weight(pol->v.nodes);
> -	unsigned target;
> -	int c;
> -	int nid = -1;
> +	unsigned nnodes, target;
> +	int c, nid;
>  
> +again:
> +	nnodes = nodes_weight(pol->v.nodes);
>  	if (!nnodes)
>  		return numa_node_id();
> +
>  	target = (unsigned int)off % nnodes;
> -	c = 0;
> -	do {
> +	for (c = 0, nid = -1; c <= target; c++)
>  		nid = next_node(nid, pol->v.nodes);
> -		c++;
> -	} while (c <= target);
> +
> +	if (unlikely((unsigned)nid >= MAX_NUMNODES))
> +		goto again;

I'll go kick off a compile that replaces the conditional above with:

	if (unlikely(!node_online(nid)))
		goto again;

>  	return nid;
>  }


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
