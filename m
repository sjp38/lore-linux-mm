Subject: Re: [patch 3/9] radix-tree: gang slot lookups
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20070412103223.5564.13412.sendpatchset@linux.site>
References: <20070412103151.5564.16127.sendpatchset@linux.site>
	 <20070412103223.5564.13412.sendpatchset@linux.site>
Content-Type: text/plain
Date: Fri, 01 Jun 2007 12:31:18 +0200
Message-Id: <1180693878.7348.119.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-12 at 14:45 +0200, Nick Piggin wrote:

> @@ -825,13 +889,21 @@ radix_tree_gang_lookup_tag(struct radix_
>  
>  	ret = 0;
>  	while (ret < max_items) {
> -		unsigned int nr_found;
> +		unsigned int slots_found, nr_found, i;
>  		unsigned long next_index;	/* Index of next search */
>  
>  		if (cur_index > max_index)
>  			break;
> -		nr_found = __lookup_tag(node, results + ret, cur_index,
> -					max_items - ret, &next_index, tag);
> +		slots_found = __lookup_tag(node, (void ***)results + ret,
> +				cur_index, max_items - ret, &next_index, tag);
> +		nr_found = 0;
> +		for (i = 0; i < slots_found; i++) {
> +			node = *((void ***)results)[ret + i];
> +			if (!node)
> +				continue;
> +			results[ret + nr_found] = rcu_dereference(node);

I think this should read (as you correctly did in
radix_tree_gang_lookup):

			struct radix_tree_node *slot;
			slot = *((void ***)results)[ret + i];
			if (!slot)
				continue;
			results[ret + nr_found] = rcu_dereference(slot);

by overwriting node, a subsequent __lookup_tag() will do the darnest
things.


> +			nr_found++;
> +		}
>  		ret += nr_found;
>  		if (next_index == 0)
>  			break;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
