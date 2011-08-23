Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ADA3190013D
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 05:20:59 -0400 (EDT)
Date: Tue, 23 Aug 2011 05:20:56 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 08/13] list: add a new LRU list type
Message-ID: <20110823092056.GE21492@infradead.org>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
 <1314089786-20535-9-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314089786-20535-9-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

On Tue, Aug 23, 2011 at 06:56:21PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Several subsystems use the same construct for LRU lists - a list
> head, a spin lock and and item count. They also use exactly the same
> code for adding and removing items from the LRU. Create a generic
> type for these LRU lists.
> 
> This is the beginning of generic, node aware LRUs for shrinkers to
> work with.

Why list_lru vs the more natural sounding lru_list?

> diff --git a/lib/Makefile b/lib/Makefile
> index d5d175c..a08212f 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -12,7 +12,8 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
>  	 idr.o int_sqrt.o extable.o prio_tree.o \
>  	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
>  	 proportions.o prio_heap.o ratelimit.o show_mem.o \
> -	 is_single_threaded.o plist.o decompress.o find_next_bit.o
> +	 is_single_threaded.o plist.o decompress.o find_next_bit.o \
> +	 list_lru.o

Di we finally fix the issues with lib-y objects beeing discarded despite
modules relying on the exports?

> +int
> +list_lru_add(
> +	struct list_lru	*lru,
> +	struct list_head *item)
> +{

What about some kerneldoc comments for the helpers?

> +		ret = isolate(item, &lru->lock, cb_arg);
> +		switch (ret) {
> +		case 0:	/* item removed from list */
> +			lru->nr_items--;
> +			removed++;
> +			break;
> +		case 1: /* item referenced, give another pass */
> +			list_move_tail(item, &lru->list);
> +			break;
> +		case 2: /* item cannot be locked, skip */
> +			break;
> +		case 3: /* item not freeable, lock dropped */
> +			goto restart;

I think the isolate callback returns shoud have symbolic names, i.e.
and enum lru_isolate or similar.

> +int
> +list_lru_init(
> +	struct list_lru	*lru)
> +{
> +	spin_lock_init(&lru->lock);
> +	INIT_LIST_HEAD(&lru->list);
> +	lru->nr_items = 0;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_init);

This one doesn't need a return value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
