Date: Sat, 23 Feb 2008 00:06:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 17/28] netvm: hook skb allocation to reserves
Message-Id: <20080223000613.123c57b6.akpm@linux-foundation.org>
In-Reply-To: <20080220150307.507134000@chello.nl>
References: <20080220144610.548202000@chello.nl>
	<20080220150307.507134000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 15:46:27 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Change the skb allocation api to indicate RX usage and use this to fall back to
> the reserve when needed. SKBs allocated from the reserve are tagged in
> skb->emergency.
> 
> Teach all other skb ops about emergency skbs and the reserve accounting.
> 
> Use the (new) packet split API to allocate and track fragment pages from the
> emergency reserve. Do this using an atomic counter in page->index. This is
> needed because the fragments have a different sharing semantic than that
> indicated by skb_shinfo()->dataref. 
> 
> Note that the decision to distinguish between regular and emergency SKBs allows
> the accounting overhead to be limited to the later kind.
> 
> ...
>
> +static inline void skb_get_page(struct sk_buff *skb, struct page *page)
> +{
> +	get_page(page);
> +	if (skb_emergency(skb))
> +		atomic_inc(&page->frag_count);
> +}
> +
> +static inline void skb_put_page(struct sk_buff *skb, struct page *page)
> +{
> +	if (skb_emergency(skb) && atomic_dec_and_test(&page->frag_count))
> +		rx_emergency_put(PAGE_SIZE);
> +	put_page(page);
> +}

I'm thinking we should do `#define slowcall inline' then use that in the future.

>  static void skb_release_data(struct sk_buff *skb)
>  {
>  	if (!skb->cloned ||
>  	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
>  			       &skb_shinfo(skb)->dataref)) {
> +		int size;
> +
> +#ifdef NET_SKBUFF_DATA_USES_OFFSET
> +		size = skb->end;
> +#else
> +		size = skb->end - skb->head;
> +#endif

The patch adds rather a lot of ifdefs.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
