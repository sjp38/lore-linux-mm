Date: Tue, 25 Dec 2007 12:47:49 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mem notifications v3
In-Reply-To: <20071224203250.GA23149@dmt>
References: <20071224203250.GA23149@dmt>
Message-Id: <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmc=?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi


> +/* maximum 5 notifications per second per cpu */
> +void mem_notify_userspace(void)
> +{
> +	unsigned long target;
> +	unsigned long now = jiffies;
> +
> +	target = __get_cpu_var(last_mem_notify) + (HZ/5);
> +
> +	if (time_after(now, target)) {
> +		__get_cpu_var(last_mem_notify) = now;
> +		mem_notify_status = 1;
> +		wake_up(&mem_wait);
> +	}
> +}

Hmm,
unfotunately, wake_up() wake up all process.
because
 1. poll method use poll_wait().
 2. poll_wait() not add_wait_queue_exclusive() but add_wait_queue() is used. 
 3. wake_up() function wake up 1 task *and* queueud item by add_wait_queue().

Conclusion:
this code intention wakeup all process HZ/5 * #cpus times at high memory pressure.
it is too much.


BTW: I propose add to poll_wait_exclusive() in kernel ;-p


> +		/* check if its not a spurious/stale notification */
> +		pages_high = pages_free = pages_reserve = 0;
> +		for_each_zone(zone) { 
> +			if (!populated_zone(zone) || is_highmem(zone))
> +				continue;

i think highmem ignoreed is very good improvement from before version :-D


> +			pages_reserve += zone->lowmem_reserve[MAX_NR_ZONES-1];

Hmm...
may be, don't works well.

MAX_NR_ZONES determined at compile time and determined by distribution vendor.
but real highest zone is determined by box total memory.

ex.
CONFIG_HIGHMEM config on but total memory < 4GB.
CONFIG_DMA32 config on but total memory < 4GB.


> +		if (pages_free < (pages_high+pages_reserve)*2) 
> +			val = POLLIN;

why do you choice fomula of (pages_high+pages_reserve)*2 ?


> -static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> +static bool shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  				struct scan_control *sc, int priority)

unnecessary type change.
if directly call mem_notify_userspace() in shrink_active_list, works well too.
because notify rate control can implement by mem_notify_userspace() and mem_notify_poll().

last_mem_notify works better.


/kosaki



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
