Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id AEE126B007E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 09:24:39 -0400 (EDT)
Message-ID: <4F86D733.50809@parallels.com>
Date: Thu, 12 Apr 2012 10:22:59 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] res_counter: add a function res_counter_move_parent().
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BA66.2010503@jp.fujitsu.com>
In-Reply-To: <4F86BA66.2010503@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Frederic
 Weisbecker <fweisbec@gmail.com>

On 04/12/2012 08:20 AM, KAMEZAWA Hiroyuki wrote:
> 
> This function is used for moving accounting information to its
> parent in the hierarchy of res_counter.
>
> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>

Frederic has a patch in his fork cgroup series, that allows you to
uncharge a counter until you reach a specific ancestor.
You pass the parent as a parameter, and then only you gets uncharged.

I think that is a much better interface than this you are proposing.
We should probably merge that patch and use it.

> ---
>   include/linux/res_counter.h |    3 +++
>   kernel/res_counter.c        |   13 +++++++++++++
>   2 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index da81af0..8919d3c 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -135,6 +135,9 @@ int __must_check res_counter_charge_nofail(struct res_counter *counter,
>   void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
>   void res_counter_uncharge(struct res_counter *counter, unsigned long val);
> 
> +/* move resource to parent counter...i.e. just forget accounting in a child */
> +void res_counter_move_parent(struct res_counter *counter, unsigned long val);
> +
>   /**
>    * res_counter_margin - calculate chargeable space of a counter
>    * @cnt: the counter
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index d508363..fafebf0 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -113,6 +113,19 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
>   	local_irq_restore(flags);
>   }
> 
> +/*
> + * In hierarchical accounting, child's usage is accounted into ancestors.
> + * To move local usage to its parent, just forget current level usage.
> + */
> +void res_counter_move_parent(struct res_counter *counter, unsigned long val)
> +{
> +	unsigned long flags;
> +
> +	BUG_ON(!counter->parent);
> +	spin_lock_irqsave(&counter->lock, flags);
> +	res_counter_uncharge_locked(counter, val);
> +	spin_unlock_irqrestore(&counter->lock, flags);
> +}
> 
>   static inline unsigned long long *
>   res_counter_member(struct res_counter *counter, int member)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
