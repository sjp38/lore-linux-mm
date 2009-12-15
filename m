Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A473C6B0047
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:25:13 -0500 (EST)
Date: Tue, 15 Dec 2009 09:25:01 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [mmotm][PATCH 2/5] mm : avoid  false sharing on mm_counter
In-Reply-To: <20091215181337.1c4f638d.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912150920160.16754@router.home>
References: <20091215180904.c307629f.kamezawa.hiroyu@jp.fujitsu.com> <20091215181337.1c4f638d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009, KAMEZAWA Hiroyuki wrote:

>  #if USE_SPLIT_PTLOCKS
> +#define SPLIT_RSS_COUNTING
>  struct mm_rss_stat {
>  	atomic_long_t count[NR_MM_COUNTERS];
>  };
> +/* per-thread cached information, */
> +struct task_rss_stat {
> +	int events;	/* for synchronization threshold */

Why count events? Just always increment the task counters and fold them
at appropriate points into mm_struct. Or get rid of the mm_struct counters
and only sum them up on the fly if needed?

Add a pointer to thread rss_stat structure to mm_struct and remove the
counters? If the task has only one thread then the pointer points to the
accurate data (most frequent case). Otherwise it can be NULL and then we
calculate it on the fly?

> +static void add_mm_counter_fast(struct mm_struct *mm, int member, int val)
> +{
> +	struct task_struct *task = current;
> +
> +	if (likely(task->mm == mm))
> +		task->rss_stat.count[member] += val;
> +	else
> +		add_mm_counter(mm, member, val);
> +}
> +#define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member,1)
> +#define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member,-1)
> +

Code will be much simpler if you always increment the task counts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
