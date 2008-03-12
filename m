Subject: Re: [PATCH 2/2] Make res_counter hierarchical
In-Reply-To: Your message of "Fri, 07 Mar 2008 18:32:20 +0300"
	<47D16004.7050204@openvz.org>
References: <47D16004.7050204@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080312230541.CB9021E703D@siro.lan>
Date: Thu, 13 Mar 2008 08:05:41 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: xemul@openvz.org
Cc: balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, containers@lists.osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> @@ -36,10 +37,26 @@ int res_counter_charge(struct res_counter *counter, unsigned long val)
>  {
>  	int ret;
>  	unsigned long flags;
> +	struct res_counter *c, *unroll_c;
> +
> +	local_irq_save(flags);
> +	for (c = counter; c != NULL; c = c->parent) {
> +		spin_lock(&c->lock);
> +		ret = res_counter_charge_locked(c, val);
> +		spin_unlock(&c->lock);
> +		if (ret < 0)
> +			goto unroll;
> +	}
> +	local_irq_restore(flags);
> +	return 0;
>  
> -	spin_lock_irqsave(&counter->lock, flags);
> -	ret = res_counter_charge_locked(counter, val);
> -	spin_unlock_irqrestore(&counter->lock, flags);
> +unroll:
> +	for (unroll_c = counter; unroll_c != c; unroll_c = unroll_c->parent) {
> +		spin_lock(&unroll_c->lock);
> +		res_counter_uncharge_locked(unroll_c, val);
> +		spin_unlock(&unroll_c->lock);
> +	}
> +	local_irq_restore(flags);
>  	return ret;
>  }

what prevents the topology (in particular, ->parent pointers) from
changing behind us?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
