Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 57B006B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 19:03:53 -0400 (EDT)
Date: Thu, 12 Mar 2009 15:59:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] Memory controller soft limit interface (v5)
Message-Id: <20090312155905.81a3415a.akpm@linux-foundation.org>
In-Reply-To: <20090312175620.17890.69177.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
	<20090312175620.17890.69177.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 23:26:20 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +/**
> + * Get the difference between the usage and the soft limit
> + * @cnt: The counter
> + *
> + * Returns 0 if usage is less than or equal to soft limit
> + * The difference between usage and soft limit, otherwise.
> + */
> +static inline unsigned long long
> +res_counter_soft_limit_excess(struct res_counter *cnt)
> +{
> +	unsigned long long excess;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	if (cnt->usage <= cnt->soft_limit)
> +		excess = 0;
> +	else
> +		excess = cnt->usage - cnt->soft_limit;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return excess;
> +}
>
> ...
>  
> +static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
> +{
> +	bool ret;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	ret = res_counter_soft_limit_check_locked(cnt);
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return ret;
> +}
>
> ...
>
> +static inline int
> +res_counter_set_soft_limit(struct res_counter *cnt,
> +				unsigned long long soft_limit)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	cnt->soft_limit = soft_limit;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return 0;
> +}

These functions look too large to be inlined?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
