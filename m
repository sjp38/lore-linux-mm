Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m285f6uM013965
	for <linux-mm@kvack.org>; Sat, 8 Mar 2008 11:11:06 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m285f6Gs893128
	for <linux-mm@kvack.org>; Sat, 8 Mar 2008 11:11:06 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m285fCHu030258
	for <linux-mm@kvack.org>; Sat, 8 Mar 2008 05:41:12 GMT
Message-ID: <47D22682.6060108@linux.vnet.ibm.com>
Date: Sat, 08 Mar 2008 11:09:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Add the max_usage member on the res_counter
References: <47D15FAF.3000204@openvz.org>
In-Reply-To: <47D15FAF.3000204@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Pavel Emelyanov wrote:
> This is a very usefull feature. E.g. one may set the
> limit to "unlimited" value and check for the memory
> requirements of a new container.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
>  include/linux/res_counter.h |    5 +++++
>  kernel/res_counter.c        |    4 ++++
>  mm/memcontrol.c             |    5 +++++
>  3 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index 8cb1ecd..2c4deb5 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -25,6 +25,10 @@ struct res_counter {
>  	 */
>  	unsigned long long usage;
>  	/*
> +	 * the maximal value of the usage from the counter creation
> +	 */
> +	unsigned long long max_usage;
> +	/*
>  	 * the limit that usage cannot exceed
>  	 */
>  	unsigned long long limit;
> @@ -67,6 +71,7 @@ ssize_t res_counter_write(struct res_counter *counter, int member,
> 
>  enum {
>  	RES_USAGE,
> +	RES_MAX_USAGE,
>  	RES_LIMIT,
>  	RES_FAILCNT,
>  };
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index 791ff2b..f1f20c2 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -27,6 +27,8 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
>  	}
> 
>  	counter->usage += val;
> +	if (counter->usage > counter->max_usage)
> +		counter->max_usage = counter->usage;

How about

	counter->max_usage = max(counter->usage, counter->max_usage);

>  	return 0;
>  }
> 
> @@ -65,6 +67,8 @@ res_counter_member(struct res_counter *counter, int member)
>  	switch (member) {
>  	case RES_USAGE:
>  		return &counter->usage;
> +	case RES_MAX_USAGE:
> +		return &counter->max_usage;
>  	case RES_LIMIT:
>  		return &counter->limit;
>  	case RES_FAILCNT:
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2d59163..e5c741a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -911,6 +911,11 @@ static struct cftype mem_cgroup_files[] = {
>  		.read_u64 = mem_cgroup_read,
>  	},
>  	{
> +		.name = "max_usage_in_bytes",
> +		.private = RES_MAX_USAGE,
> +		.read_u64 = mem_cgroup_read,
> +	},
> +	{
>  		.name = "limit_in_bytes",
>  		.private = RES_LIMIT,
>  		.write = mem_cgroup_write,

Looks very good,

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
