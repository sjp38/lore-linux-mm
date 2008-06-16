Message-ID: <48560A7C.9050501@openvz.org>
Date: Mon, 16 Jun 2008 10:38:52 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] res_counter:  handle limit change
References: <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com> <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Add a support to shrink_usage_at_limit_change feature to res_counter.
> memcg will use this to drop pages.
> 
> Change log: xxx -> v4 (new file.)
>  - cut out the limit-change part from hierarchy patch set.
>  - add "retry_count" arguments to shrink_usage(). This allows that we don't
>    have to set the default retry loop count.
>  - res_counter_check_under_val() is added to support subsystem.
>  - res_counter_init() is res_counter_init_ops(cnt, NULL)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  Documentation/controllers/resource_counter.txt |   19 +++++-
>  include/linux/res_counter.h                    |   33 ++++++++++-
>  kernel/res_counter.c                           |   74 ++++++++++++++++++++++++-
>  3 files changed, 121 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.26-rc5-mm3/include/linux/res_counter.h
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/include/linux/res_counter.h
> +++ linux-2.6.26-rc5-mm3/include/linux/res_counter.h
> @@ -21,6 +21,13 @@
>   * the helpers described beyond
>   */
>  
> +struct res_counter;
> +struct res_counter_ops {
> +	/* called when the subsystem has to reduce the usage. */
> +	int (*shrink_usage)(struct res_counter *cnt, unsigned long long val,
> +			    int retry_count);
> +};
> +
>  struct res_counter {
>  	/*
>  	 * the current resource consumption level
> @@ -39,6 +46,10 @@ struct res_counter {
>  	 */
>  	unsigned long long failcnt;
>  	/*
> +	 * registered callbacks etc...for res_counter.
> +	 */
> +	struct res_counter_ops ops;
> +	/*

Why would we need such? All res_counter.limit update comes via the appropiate
cgroup's files, so it can do whatever it needs w/o any callbacks?

And (if we definitely need one) isn't it better to make it a
	struct res_counter_ops *ops;
pointer?

>  	 * the lock to protect all of the above.
>  	 * the routines below consider this to be IRQ-safe
>  	 */
> @@ -82,7 +93,13 @@ enum {
>   * helpers for accounting
>   */
>  
> -void res_counter_init(struct res_counter *counter);
> +void res_counter_init_ops(struct res_counter *counter,
> +				struct res_counter_ops *ops);
> +
> +static inline void res_counter_init(struct res_counter *counter)
> +{
> +	res_counter_init_ops(counter, NULL);
> +}
>  
>  /*
>   * charge - try to consume more resource.
> @@ -136,6 +153,20 @@ static inline bool res_counter_check_und
>  	return ret;
>  }
>  
> +static inline bool res_counter_check_under_val(struct res_counter *cnt,
> +					unsigned long long val)
> +{
> +	bool ret = false;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	if (cnt->usage <= val)
> +		ret = true;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +
> +	return ret;
> +}
> +
>  static inline void res_counter_reset_max(struct res_counter *cnt)
>  {
>  	unsigned long flags;
> Index: linux-2.6.26-rc5-mm3/kernel/res_counter.c
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/kernel/res_counter.c
> +++ linux-2.6.26-rc5-mm3/kernel/res_counter.c
> @@ -14,10 +14,22 @@
>  #include <linux/res_counter.h>
>  #include <linux/uaccess.h>
>  
> -void res_counter_init(struct res_counter *counter)
> +/**
> + * res_counter_init_ops -- initialize res_counter.
> + * @counter: the res_counter to be initialized
> + * @ops: the res_counter_ops for this res_counter. This argument can be NULL
> + *        and is copied.
> + *
> + * init spinlock and set limit to be very very big value.
> + */
> +
> +void res_counter_init_ops(struct res_counter *counter,
> +				struct res_counter_ops *ops)
>  {
>  	spin_lock_init(&counter->lock);
>  	counter->limit = (unsigned long long)LLONG_MAX;
> +	if (ops)
> +		counter->ops = *ops;
>  }
>  
>  int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
> @@ -102,6 +114,46 @@ u64 res_counter_read_u64(struct res_coun
>  	return *res_counter_member(counter, member);
>  }
>  
> +/*
> + * Called when the limit changes if res_counter has ops->shrink_usage.
> + * This function uses shrink usage to below new limit. returns 0 at success.
> + */
> +
> +static int res_counter_resize_limit(struct res_counter *cnt,
> +			unsigned long long val)
> +{
> +	int retry_count = 0;
> +	int ret = -EBUSY;
> +	unsigned long flags;
> +
> +	BUG_ON(!cnt->ops.shrink_usage);
> +	while (1) {
> +		spin_lock_irqsave(&cnt->lock, flags);
> +		if (cnt->usage <= val) {
> +			cnt->limit = val;
> +			ret = 0;
> +			spin_unlock_irqrestore(&cnt->lock, flags);
> +			break;
> +		}
> +		BUG_ON(val > cnt->limit);
> +		spin_unlock_irqrestore(&cnt->lock, flags);
> +
> +		/*
> +		 * Rest before calling callback().... rest after callback
> +		 * tends to add difference between the result of callback and
> +		 * the check in next loop.
> +		 */
> +		cond_resched();
> +
> +		ret = cnt->ops.shrink_usage(cnt, val, retry_count);
> +		if (!ret)
> +			break;
> +		retry_count++;
> +	}
> +	return ret;
> +}
> +
> +
>  ssize_t res_counter_write(struct res_counter *counter, int member,
>  		const char __user *userbuf, size_t nbytes, loff_t *pos,
>  		int (*write_strategy)(char *st_buf, unsigned long long *val))
> @@ -133,11 +185,29 @@ ssize_t res_counter_write(struct res_cou
>  		if (*end != '\0')
>  			goto out_free;
>  	}
> +	switch (member) {
> +	case RES_LIMIT:
> +		if (counter->ops.shrink_usage) {
> +			ret = res_counter_resize_limit(counter, tmp);
> +			goto done;
> +		}
> +		break;
> +	default:
> +		/*
> +		 * Considering future implementation, we'll have to handle
> +		 * other members and "fallback" will not work well. So, we
> +		 * avoid to make use of "default" here.
> +		 */
> +		break;
> +	}
>  	spin_lock_irqsave(&counter->lock, flags);
>  	val = res_counter_member(counter, member);
>  	*val = tmp;
>  	spin_unlock_irqrestore(&counter->lock, flags);
> -	ret = nbytes;
> +	ret = 0;
> +done:
> +	if (!ret)
> +		ret = nbytes;
>  out_free:
>  	kfree(buf);
>  out:
> Index: linux-2.6.26-rc5-mm3/Documentation/controllers/resource_counter.txt
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/Documentation/controllers/resource_counter.txt
> +++ linux-2.6.26-rc5-mm3/Documentation/controllers/resource_counter.txt
> @@ -39,7 +39,11 @@ to work with it.
>   	The failcnt stands for "failures counter". This is the number of
>  	resource allocation attempts that failed.
>  
> - c. spinlock_t lock
> + e. res_counter_ops.
> +	Callbacks for helping resource_counter per each subsystem.
> +	- shrink_usage() .... called at limit change (decrease).
> +
> + f. spinlock_t lock
>  
>   	Protects changes of the above values.
>  
> @@ -141,8 +145,19 @@ counter fields. They are recommended to 
>  	failcnt		reset to zero
>  
>  
> +5. res_counter_ops (Callbacks)
>  
> -5. Usage example
> +   res_counter_ops is for implementing feedback control from res_counter
> +   to subsystem. Each one has each own purpose and the subsystem doesn't
> +   necessary to provide all callbacks. Just implement necessary ones.
> +
> +   - shrink_usage(res_counter, newlimit, retry)
> +     Called for reducing usage to newlimit, retry is incremented per
> +     loop. (See memory resource controller as example.)
> +     Returns 0 at success. Any error code is acceptable but -EBUSY will be
> +     suitable to show "the kernel can't shrink usage."
> +
> +6. Usage example
>  
>   a. Declare a task group (take a look at cgroups subsystem for this) and
>      fold a res_counter into it
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
