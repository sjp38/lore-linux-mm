Date: Thu, 27 Dec 2007 15:13:11 -0500
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] mem notifications v3
Message-ID: <20071227201311.GA14995@dmt>
References: <20071224203250.GA23149@dmt> <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, Daniel =?utf-8?B?U3DomqNn?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Kosaki,

On Tue, Dec 25, 2007 at 12:47:49PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> 
> > +/* maximum 5 notifications per second per cpu */
> > +void mem_notify_userspace(void)
> > +{
> > +	unsigned long target;
> > +	unsigned long now = jiffies;
> > +
> > +	target = __get_cpu_var(last_mem_notify) + (HZ/5);
> > +
> > +	if (time_after(now, target)) {
> > +		__get_cpu_var(last_mem_notify) = now;
> > +		mem_notify_status = 1;
> > +		wake_up(&mem_wait);
> > +	}
> > +}
> 
> Hmm,
> unfotunately, wake_up() wake up all process.
> because
>  1. poll method use poll_wait().
>  2. poll_wait() not add_wait_queue_exclusive() but add_wait_queue() is used. 
>  3. wake_up() function wake up 1 task *and* queueud item by add_wait_queue().
> 
> Conclusion:
> this code intention wakeup all process HZ/5 * #cpus times at high memory pressure.
> it is too much.
> 
> 
> BTW: I propose add to poll_wait_exclusive() in kernel ;-p
> 
> 
> > +		/* check if its not a spurious/stale notification */
> > +		pages_high = pages_free = pages_reserve = 0;
> > +		for_each_zone(zone) { 
> > +			if (!populated_zone(zone) || is_highmem(zone))
> > +				continue;
> 
> i think highmem ignoreed is very good improvement from before version :-D
> 
> 
> > +			pages_reserve += zone->lowmem_reserve[MAX_NR_ZONES-1];
> 
> Hmm...
> may be, don't works well.
> 
> MAX_NR_ZONES determined at compile time and determined by distribution vendor.
> but real highest zone is determined by box total memory.
> 
> ex.
> CONFIG_HIGHMEM config on but total memory < 4GB.
> CONFIG_DMA32 config on but total memory < 4GB.

That is OK because the calculation of lowmem reserves will take into account 
all zones (mm/page_alloc.c::setup_per_zone_lowmem_reserve).

But it might be better to use the precalculated totalreserve_pages instead.

> 
> > +		if (pages_free < (pages_high+pages_reserve)*2) 
> > +			val = POLLIN;
> 
> why do you choice fomula of (pages_high+pages_reserve)*2 ?

Just to make sure its not sending a spurious notification in the case the system
has enough free memory already.

> > -static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> > +static bool shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >  				struct scan_control *sc, int priority)
> 
> unnecessary type change.
> if directly call mem_notify_userspace() in shrink_active_list, works well too.
> because notify rate control can implement by mem_notify_userspace() and mem_notify_poll().

Yes, and doing that should also guarantee that the notification is sent
before swapout is performed (right now it sends the notification after
shrink_inactive_list(), which is performing swapout).

> last_mem_notify works better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
