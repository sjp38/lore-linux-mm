Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 4014F6B005A
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 04:09:12 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [RFC 1/3] /dev/low_mem_notify
Date: Wed, 18 Jan 2012 09:06:06 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
 <1326788038-29141-2-git-send-email-minchan@kernel.org>
 <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
 <4F15A34F.40808@redhat.com>
 <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
In-Reply-To: <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org, riel@redhat.com
Cc: minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, rhod@redhat.com, kosaki.motohiro@jp.fujitsu.com

Hi,

Just couple of observations, which maybe wrong below

> -----Original Message-----
> From: Pekka Enberg [mailto:penberg@gmail.com] On Behalf Of ext Pekka
> Enberg
> Sent: 17 January, 2012 20:51
....

> +struct vmnotify_config {
> +	/*
> +	 * Size of the struct for ABI extensibility.
> +	 */
> +	__u32		   size;
> +
> +	/*
> +	 * Notification type bitmask
> +	 */
> +	__u64			type;
> +
> +	/*
> +	 * Free memory threshold in percentages [1..99]
> +	 */
> +	__u32			free_threshold;

Would be possible to not use percents for thesholds? Accounting in pages ev=
en not so difficult to user-space.
Also, looking on vmnotify_match I understand that events propagated to user=
-space only in case threshold trigger change state from 0 to 1 but not back=
, 1-> 0 is very useful event as well.

Would be possible to use for threshold pointed value(s) e.g. according to e=
num zone_state_item, because kinds of memory to track could be different?
E.g. to tracking paging activity NR_ACTIVE_ANON and NR_ACTIVE_FILE could be=
 interesting, not only free.

> +
> +	/*
> +	 * Sample period in nanoseconds
> +	 */
> +	__u64			sample_period_ns;
> +};
> +
....
> +struct vmnotify_event {
> +	/* Size of the struct for ABI extensibility. */
> +	__u32			size;
> +
> +	__u64			nr_avail_pages;
> +
> +	__u64			nr_swap_pages;
> +
> +	__u64			nr_free_pages;
> +};

Two fields here most likely session-constant, (nr_avail_pages and nr_swap_p=
ages), seems not much sense to report them in every event.
If we have memory/swap hotplug user-space can use sysinfo() call.

> +static void vmnotify_sample(struct vmnotify_watch *watch) {
...
> +	si_meminfo(&si);
> +	event.nr_avail_pages	=3D si.totalram;
> +
> +#ifdef CONFIG_SWAP
> +	si_swapinfo(&si);
> +	event.nr_swap_pages	=3D si.totalswap;
> +#endif
> +

Why not to use global_page_state() directly? si_meminfo() and especial si_s=
wapinfo are quite expensive call.

> +static void vmnotify_start_timer(struct vmnotify_watch *watch) {
> +	u64 sample_period =3D watch->config.sample_period_ns;
> +
> +	hrtimer_init(&watch->timer, CLOCK_MONOTONIC,
> HRTIMER_MODE_REL);
> +	watch->timer.function =3D vmnotify_timer_fn;
> +
> +	hrtimer_start(&watch->timer, ns_to_ktime(sample_period),
> +HRTIMER_MODE_REL_PINNED); }

Do I understand correct you allocate timer for every user-space client and =
propagate events every pointed interval?
What will happened with system if we have a timer but need to turn CPU off?=
 The timer must not be a reason to wakeup if user-space is sleeping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
