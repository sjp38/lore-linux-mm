Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1C3C56B0085
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 21:49:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8O1nL1w012518
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 24 Sep 2009 10:49:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E75BB45DE4E
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:49:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C555845DD70
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:49:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A796E38001
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:49:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EDE7E38009
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:49:20 +0900 (JST)
Date: Thu, 24 Sep 2009 10:47:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC 1/2] Add notifiers for various swap events
Message-Id: <20090924104708.4f54ce4e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1253540040-24860-1-git-send-email-ngupta@vflare.org>
References: <1253540040-24860-1-git-send-email-ngupta@vflare.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Sep 2009 19:03:59 +0530
Nitin Gupta <ngupta@vflare.org> wrote:

> Add notifiers for following swap events:
>  - Swapon
>  - Swapoff
>  - When a swap slot is freed
> 
> This is required for ramzswap module which implements RAM based block
> devices to be used as swap disks. These devices require a notification
> on these events to function properly (as shown in patch 2/2).
> 
> Currently, I'm not sure if any of these event notifiers have any other
> users. However, adding ramzswap specific hooks instead of this generic
> approach resulted in a bad/hacky code.
> 
Hmm ? if it's not necessary to make ramzswap as module, for-ramzswap-only
code is much easier to read..



> For SWAP_EVENT_SLOT_FREE, callbacks are made under swap_lock. Currently, this
> is not a problem since ramzswap is the only user and the callback it registers
> can be safely made under this lock. However, if this event finds more users,
> we might have to work on reducing contention on this lock.
> 
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> 

In general, notifier chain codes allowed to return NOTIFY_BAD.
But this patch just assumes all chains should return NOTIFY_OK or
just ignore return code.

That's not good as generic interface, I think.

Thanks,
-Kame


> ---
>  include/linux/swap.h |   12 +++++++++
>  mm/swapfile.c        |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 79 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 7c15334..2873aad 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -127,6 +127,12 @@ enum {
>  	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
>  };
>  
> +enum swap_event {
> +	SWAP_EVENT_SWAPON,
> +	SWAP_EVENT_SWAPOFF,
> +	SWAP_EVENT_SLOT_FREE,
> +};
> +
>  #define SWAP_CLUSTER_MAX 32
>  
>  #define SWAP_MAP_MAX	0x7ffe
> @@ -155,6 +161,7 @@ struct swap_info_struct {
>  	unsigned int max;
>  	unsigned int inuse_pages;
>  	unsigned int old_block_size;
> +	struct atomic_notifier_head slot_free_notify_list;
>  };
>  
>  struct swap_list_t {
> @@ -295,8 +302,13 @@ extern sector_t swapdev_block(int, pgoff_t);
>  extern struct swap_info_struct *get_swap_info_struct(unsigned);
>  extern int reuse_swap_page(struct page *);
>  extern int try_to_free_swap(struct page *);
> +extern int register_swap_event_notifier(struct notifier_block *nb,
> +                                enum swap_event event, unsigned long val);
> +extern int unregister_swap_event_notifier(struct notifier_block *nb,
> +                                enum swap_event event, unsigned long val);
>  struct backing_dev_info;
>  
> +
>  /* linux/mm/thrash.c */
>  extern struct mm_struct *swap_token_mm;
>  extern void grab_swap_token(struct mm_struct *);
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 74f1102..f63643c 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -52,6 +52,9 @@ static struct swap_list_t swap_list = {-1, -1};
>  static struct swap_info_struct swap_info[MAX_SWAPFILES];
>  
>  static DEFINE_MUTEX(swapon_mutex);
> +static BLOCKING_NOTIFIER_HEAD(swapon_notify_list);
> +static BLOCKING_NOTIFIER_HEAD(swapoff_notify_list);
> +
>  
>  /* For reference count accounting in swap_map */
>  /* enum for swap_map[] handling. internal use only */
> @@ -585,6 +588,8 @@ static int swap_entry_free(struct swap_info_struct *p,
>  			swap_list.next = p - swap_info;
>  		nr_swap_pages++;
>  		p->inuse_pages--;
> +		atomic_notifier_call_chain(&p->slot_free_notify_list,
> +					offset, p->swap_file);
>  	}
>  	if (!swap_count(count))
>  		mem_cgroup_uncharge_swap(ent);
> @@ -1626,6 +1631,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	p->swap_map = NULL;
>  	p->flags = 0;
>  	spin_unlock(&swap_lock);
> +	blocking_notifier_call_chain(&swapoff_notify_list, type, swap_file);
>  	mutex_unlock(&swapon_mutex);
>  	vfree(swap_map);
>  	/* Destroy swap account informatin */
> @@ -2014,7 +2020,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	} else {
>  		swap_info[prev].next = p - swap_info;
>  	}
> +	ATOMIC_INIT_NOTIFIER_HEAD(&p->slot_free_notify_list);
>  	spin_unlock(&swap_lock);
> +	blocking_notifier_call_chain(&swapon_notify_list, type, swap_file);
>  	mutex_unlock(&swapon_mutex);
>  	error = 0;
>  	goto out;
> @@ -2216,3 +2224,62 @@ int valid_swaphandles(swp_entry_t entry, unsigned long *offset)
>  	*offset = ++toff;
>  	return nr_pages? ++nr_pages: 0;
>  }
> +
> +int register_swap_event_notifier(struct notifier_block *nb,
> +				enum swap_event event, unsigned long val)
> +{
> +	switch (event) {
> +	case SWAP_EVENT_SWAPON:
> +		return blocking_notifier_chain_register(
> +					&swapon_notify_list, nb);
> +	case SWAP_EVENT_SWAPOFF:
> +		return blocking_notifier_chain_register(
> +					&swapoff_notify_list, nb);
> +	case SWAP_EVENT_SLOT_FREE:
> +		{
> +		struct swap_info_struct *sis;
> +
> +		if (val > nr_swapfiles)
> +			goto out;
> +		sis = get_swap_info_struct(val);
> +		return atomic_notifier_chain_register(
> +				&sis->slot_free_notify_list, nb);
> +		}
> +	default:
> +		pr_err("Invalid swap event: %d\n", event);
> +	};
> +
> +out:
> +	return -EINVAL;
> +}
> +EXPORT_SYMBOL_GPL(register_swap_event_notifier);
> +
> +int unregister_swap_event_notifier(struct notifier_block *nb,
> +				enum swap_event event, unsigned long val)
> +{
> +	switch (event) {
> +	case SWAP_EVENT_SWAPON:
> +		return blocking_notifier_chain_unregister(
> +					&swapon_notify_list, nb);
> +	case SWAP_EVENT_SWAPOFF:
> +		return blocking_notifier_chain_unregister(
> +					&swapoff_notify_list, nb);
> +	case SWAP_EVENT_SLOT_FREE:
> +		{
> +		struct swap_info_struct *sis;
> +
> +		if (val > nr_swapfiles)
> +			goto out;
> +		sis = get_swap_info_struct(val);
> +		return atomic_notifier_chain_unregister(
> +				&sis->slot_free_notify_list, nb);
> +		}
> +	default:
> +		pr_err("Invalid swap event: %d\n", event);
> +	};
> +
> +out:
> +	return -EINVAL;
> +}
> +EXPORT_SYMBOL_GPL(unregister_swap_event_notifier);
> +
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
