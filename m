Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A9E728D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 20:08:41 -0500 (EST)
Date: Wed, 26 Jan 2011 17:08:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUGFIX] memcg: fix res_counter_read_u64 lock aware (Was Re:
 [PATCH] oom: handle overflow in mem_cgroup_out_of_memory()
Message-Id: <20110126170824.ef2ab571.akpm@linux-foundation.org>
In-Reply-To: <20110127095342.3d81cf5f.kamezawa.hiroyu@jp.fujitsu.com>
References: <1296030555-3594-1-git-send-email-gthelen@google.com>
	<20110126170713.GA2401@cmpxchg.org>
	<xr93y667lgdm.fsf@gthelen.mtv.corp.google.com>
	<20110126183023.GB2401@cmpxchg.org>
	<xr9362tbl83f.fsf@gthelen.mtv.corp.google.com>
	<20110126142909.0b710a0c.akpm@linux-foundation.org>
	<20110127092434.df18c7a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110127095342.3d81cf5f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jan 2011 09:53:42 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> res_counter_read_u64 reads u64 value without lock. It's dangerous
> in 32bit environment. This patch adds lock.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/res_counter.h |   13 ++++++++++++-
>  kernel/res_counter.c        |    2 +-
>  2 files changed, 13 insertions(+), 2 deletions(-)
> 
> Index: mmotm-0125/include/linux/res_counter.h
> ===================================================================
> --- mmotm-0125.orig/include/linux/res_counter.h
> +++ mmotm-0125/include/linux/res_counter.h
> @@ -68,7 +68,18 @@ struct res_counter {
>   * @pos:     and the offset.
>   */
>  
> -u64 res_counter_read_u64(struct res_counter *counter, int member);
> +u64 res_counter_read_u64_locked(struct res_counter *counter, int member);
> +
> +static inline u64 res_counter_read_u64(struct res_counter *counter, int member)
> +{
> +	unsigned long flags;
> +	u64 ret;
> +
> +	spin_lock_irqsave(&counter->lock, flags);
> +	ret = res_counter_read_u64_locked(counter, member);
> +	spin_unlock_irqrestore(&counter->lock, flags);
> +	return ret;
> +}
>  
>  ssize_t res_counter_read(struct res_counter *counter, int member,
>  		const char __user *buf, size_t nbytes, loff_t *pos,
> Index: mmotm-0125/kernel/res_counter.c
> ===================================================================
> --- mmotm-0125.orig/kernel/res_counter.c
> +++ mmotm-0125/kernel/res_counter.c
> @@ -126,7 +126,7 @@ ssize_t res_counter_read(struct res_coun
>  			pos, buf, s - buf);
>  }
>  
> -u64 res_counter_read_u64(struct res_counter *counter, int member)
> +u64 res_counter_read_u64_locked(struct res_counter *counter, int member)
>  {
>  	return *res_counter_member(counter, member);
>  }

We don't need the lock on 64-bit platforms!

And there's zero benefit to inlining the spin_lock/unlock(), given that
the function will always be making a function call anyway.

See i_size_read() for inspiration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
