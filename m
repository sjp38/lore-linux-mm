Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B6FD08D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:42:13 -0500 (EST)
Date: Mon, 31 Jan 2011 14:41:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/3] memcg: prevent endless loop when charging huge
 pages to near-limit group
Message-Id: <20110131144131.6733aa3a.akpm@linux-foundation.org>
In-Reply-To: <1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 31 Jan 2011 15:03:54 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> +static inline bool res_counter_check_margin(struct res_counter *cnt,
> +					    unsigned long bytes)
> +{
> +	bool ret;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	ret = cnt->limit - cnt->usage >= bytes;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return ret;
> +}
> +
>  static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
>  {
>  	bool ret;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 73ea323..c28072f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1111,6 +1111,15 @@ static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
>  	return false;
>  }
>  
> +static bool mem_cgroup_check_margin(struct mem_cgroup *mem, unsigned long bytes)
> +{
> +	if (!res_counter_check_margin(&mem->res, bytes))
> +		return false;
> +	if (do_swap_account && !res_counter_check_margin(&mem->memsw, bytes))
> +		return false;
> +	return true;
> +}

argh.

If you ever have a function with the string "check" in its name, it's a
good sign that you did something wrong.

Check what?  Against what?  Returning what?

mem_cgroup_check_under_limit() isn't toooo bad - the name tells you
what's being checked and tells you what to expect the return value to
mean.

But "res_counter_check_margin" and "mem_cgroup_check_margin" are just
awful.  Something like

	bool res_counter_may_charge(counter, bytes)

would be much clearer.

If we really want to stick with the "check" names (perhaps as an ironic
reference to res_counter's past mistakes) then please at least document
the sorry things?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
