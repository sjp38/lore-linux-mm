Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id D087C6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 04:15:42 -0500 (EST)
Received: by obbta7 with SMTP id ta7so5040430obb.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 01:15:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-2-git-send-email-minchan@kernel.org>
	<CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
	<4F15A34F.40808@redhat.com>
	<alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
	<84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
Date: Wed, 18 Jan 2012 11:15:41 +0200
Message-ID: <CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, rhod@redhat.com, kosaki.motohiro@jp.fujitsu.com

On Wed, Jan 18, 2012 at 11:06 AM,  <leonid.moiseichuk@nokia.com> wrote:
> Would be possible to not use percents for thesholds? Accounting in pages even
> not so difficult to user-space.

How does that work with memory hotplug?

On Wed, Jan 18, 2012 at 11:06 AM,  <leonid.moiseichuk@nokia.com> wrote:
> Also, looking on vmnotify_match I understand that events propagated to
> user-space only in case threshold trigger change state from 0 to 1 but not
> back, 1-> 0 is very useful event as well.
>
> Would be possible to use for threshold pointed value(s) e.g. according to
> enum zone_state_item, because kinds of memory to track could be different?
> E.g. to tracking paging activity NR_ACTIVE_ANON and NR_ACTIVE_FILE could be
> interesting, not only free.

I don't think there's anything in the ABI that would prevent that.

>> +struct vmnotify_event {
>> +     /* Size of the struct for ABI extensibility. */
>> +     __u32                   size;
>> +
>> +     __u64                   nr_avail_pages;
>> +
>> +     __u64                   nr_swap_pages;
>> +
>> +     __u64                   nr_free_pages;
>> +};
>
> Two fields here most likely session-constant, (nr_avail_pages and
> nr_swap_pages), seems not much sense to report them in every event.  If we
> have memory/swap hotplug user-space can use sysinfo() call.

I actually changed the ABI to look like this:

struct vmnotify_event {
        /*
         * Size of the struct for ABI extensibility.
         */
        __u32                   size;

        __u64                   attrs;

        __u64                   attr_values[];
};

So userspace can decide which fields to include in notifications.

On Wed, Jan 18, 2012 at 11:06 AM,  <leonid.moiseichuk@nokia.com> wrote:
>> +static void vmnotify_sample(struct vmnotify_watch *watch) {
> ...
>> +     si_meminfo(&si);
>> +     event.nr_avail_pages    = si.totalram;
>> +
>> +#ifdef CONFIG_SWAP
>> +     si_swapinfo(&si);
>> +     event.nr_swap_pages     = si.totalswap;
>> +#endif
>> +
>
> Why not to use global_page_state() directly? si_meminfo() and especial
> si_swapinfo are quite expensive call.

Sure, we can do that. Feel free to send a patch :-).

>> +static void vmnotify_start_timer(struct vmnotify_watch *watch) {
>> +     u64 sample_period = watch->config.sample_period_ns;
>> +
>> +     hrtimer_init(&watch->timer, CLOCK_MONOTONIC,
>> HRTIMER_MODE_REL);
>> +     watch->timer.function = vmnotify_timer_fn;
>> +
>> +     hrtimer_start(&watch->timer, ns_to_ktime(sample_period),
>> +HRTIMER_MODE_REL_PINNED); }
>
> Do I understand correct you allocate timer for every user-space client and
> propagate events every pointed interval?  What will happened with system if
> we have a timer but need to turn CPU off? The timer must not be a reason to
> wakeup if user-space is sleeping.

No idea what happens. The sampling code is just a proof of concept thing and I
expect it to be buggy as hell. :-)

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
