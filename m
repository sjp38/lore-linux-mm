Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
In-Reply-To: Your message of "Fri, 30 May 2008 10:45:15 +0900"
	<20080530104515.9afefdbb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080530104515.9afefdbb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080602021540.5C6705A0D@siro.lan>
Date: Mon,  2 Jun 2008 11:15:40 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, menage@google.com, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

> @@ -135,13 +138,118 @@ ssize_t res_counter_write(struct res_cou
>  		if (*end != '\0')
>  			goto out_free;
>  	}
> -	spin_lock_irqsave(&counter->lock, flags);
> -	val = res_counter_member(counter, member);
> -	*val = tmp;
> -	spin_unlock_irqrestore(&counter->lock, flags);
> -	ret = nbytes;
> +	if (member != RES_LIMIT || !callback) {

is there any reason to check member != RES_LIMIT here,
rather than in callers?

> +/*
> + * Move resource to its parent.
> + *   child->limit -= val.
> + *   parent->usage -= val.
> + *   parent->limit -= val.

s/limit/for_children/

> + */
> +
> +int res_counter_repay_resource(struct res_counter *child,
> +				struct res_counter *parent,
> +				unsigned long long val,
> +				res_shrink_callback_t callback, int retry)

can you reduce gratuitous differences between
res_counter_borrow_resource and res_counter_repay_resource?
eg. 'success' vs 'done', how to decrement 'retry'.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
