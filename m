Date: Fri, 20 Jun 2008 09:13:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Question : memrlimit cgroup's task_move (2.6.26-rc5-mm3)
Message-Id: <20080620091316.80771d14.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080619182556.GA10461@balbir.in.ibm.com>
References: <20080619121435.f868c110.kamezawa.hiroyu@jp.fujitsu.com>
	<20080619182556.GA10461@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jun 2008 23:55:56 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-06-19 12:14:35]:
> 
> > I used memrlimit cgroup at the first time.
> > 
> > May I ask a question about memrlimit cgroup ?
> >
> 
> Hi, Kamezawa-San,
> 
> Could you please review/test the patch below to see if it solves your
> problem? If it does, I'll push it up to Andrew
> 

At quick glance,
> +	/*
> +	 * NOTE: Even though we do the necessary checks in can_attach(),
> +	 * by the time we come here, there is a chance that we still
> +	 * fail (the memrlimit cgroup has grown its usage, and the
> +	 * addition of total_vm will no longer fit into its limit)
> +	 */
I don't like this kind of holes. Considering tests which are usually done
by developpers, the problem seems not to be mentioned as "rare"..
It seems we can easily cause Warning. right ?

Even if you don't want to handle this case now, please mention as "TBD" 
rather than as "NOTE".


> +
> +/*
> + * Add the value val to the resource counter and check if we are
> + * still under the limit.
> + */
> +static inline bool res_counter_add_check(struct res_counter *cnt,
> +						unsigned long val)
> +{
> +	bool ret = false;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	if (cnt->usage + val < cnt->limit)
> +		ret = true;
cnt->usage + val <= cnt->limit.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
