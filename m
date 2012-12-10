Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id DD8216B0072
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 15:12:17 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so2369005pad.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 12:12:17 -0800 (PST)
Date: Mon, 10 Dec 2012 12:08:51 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC v2] Add mempressure cgroup
Message-ID: <20121210200851.GB23814@lizard>
References: <20121210095838.GA21065@lizard>
 <20121210115028.GA31788@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121210115028.GA31788@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patchen@ninaro.org, kernel-team@android.com, linux.api@vger.kernel.org

On Mon, Dec 10, 2012 at 01:50:28PM +0200, Kirill A. Shutemov wrote:
[...]
> I think the interface is broken. One eventfd can be registered to get
> many different notifications.

But anyone is free to do anything they like with a gun and their leg. :)
They simply should not do this, since yes, they won't able to distinguish
notifications.

> The only information you have on POLLIN/read() is "something happened".
> Then, it's up to userspace to find out what had happened: if it's memory
> pressure or cgroup is removed or whatever else.

Not only "something happened" but also a counter, which is very useful,
since we want to avoid excessive communication with the kernel (i.e. we
don't want to issue another syscall on every notification).

I'm not sure what counter equals to on "cgroup removed", but in any case
it can be handled (if it is 0 -- it will be our marker, if it's 1, then we
can pass '1+chunks', making 1 our signal for "control" information).

> One more point: unlike kernel side shrinkers, userspace shrinkers cannot
> be synchronous.

Yes, it's very true. And I told exactly this a week ago: we have to be
async.

> I doubt they can be useful in real world situations.

...but I disagree that it cannot be useful. For example the test app, it
successfully reclaims memory, with another thread allocating more that
RAM+swap. So it works, it can maintain cache level.

Under load it does not matter whether it is sync or async, see my lengthy
explanations why so:
  
  http://lkml.org/lkml/2012/12/1/18

It explains when async shrinker makes sense (well, the long story short:
it makes sense the same way as kswapd).

> I personally feel that mempressure.level interface is enough.

For our needs it is enough too.

I wanted to implement shrinker since the idea is really cool, plus I
wanted prove that it can be actually done and it can actually maintain
memory level (i.e. prevent OOM). Plus, it addresses Andrew's desire for a
testable interface with the kernel in charge. :)

For Android we use levels, yes. And the shrinker is not a substitution for
levels, since levels carry different information.

But let's do this, I'll split the patch into two: levels and shrinkers
interface. So, if we agree on levels, it is great. And shrinkers can be
discussed further.

> > +  /sys/fs/cgroup/.../mempressure.level
> > +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > +  Instead of working on the bytes level (like shrinkers), one may decide
> > +  to maintain the interactivity/memory allocation cost.
> > +
> > +  For this, the cgroup has memory pressure level notifications, and the
> > +  levels are defined like this:
> > +
> > +  The "low" level means that the system is reclaiming memory for new
> > +  allocations. Monitoring reclaiming activity might be useful for
> > +  maintaining overall system's cache level. Upon notification, the program
> > +  (typically "Activity Manager") might analyze vmstat and act in advance
> > +  (i.e. prematurely shutdown unimportant services).
> > +
> > +  The "medium" level means that the system is experiencing medium memory
> > +  pressure, there is some mild swapping activity. Upon this event
> > +  applications may decide to free any resources that can be easily
> > +  reconstructed or re-read from a disk. Note that for a fine-grained
> > +  control, you should probably use the shrinker interface, as described
> > +  above.
> > +
> > +  The "oom" level means that the system is actively thrashing, it is about
> > +  to out of memory (OOM) or even the in-kernel OOM killer is on its way to
> > +  trigger. Applications should do whatever they can to help the system.
> > +
> > +  Event control:
> > +    Is used to setup an eventfd with a level threshold. The argument to
> > +    the event control specifies the level threshold.
> > +  Read:
> > +    Reads mempory presure levels: low, medium or oom.
> > +  Write:
> > +    Not implemented.
> > +  Test:
> > +    To set up a notification:
> > +
> > +    # cgroup_event_listener ./mempressure.level low
> > +    ("low", "medium", "oom" are permitted.)
> 
> Interface look okay for me.
> 
> BTW, do you track pressure level changes due changes in
> memory[.memsw].limit_in_bytes or memory hotplug?

It should not matter, as we don't count bytes, but hook into the kernel
reclaimer.

Although, ideally, on limit and hotplug changes we could reset our
scanned/reclaimed counters, just to be more precise. But as the window is
small, I don't think we should bother too much.

> > diff --git a/Documentation/cgroups/mempressure_test.c b/Documentation/cgroups/mempressure_test.c
[...]
> > +static void init_shrinker(void)
> > +{
> > +	int cfd;
> > +	int ret;
> > +	char *str;
> > +
> > +	cfd = open(CG_EVENT_CONTROL, O_WRONLY);
> > +	pabort(cfd < 0, cfd, CG_EVENT_CONTROL);
> > +
> > +	sfd = open(CG_SHRINKER, O_RDWR);
> > +	pabort(sfd < 0, sfd, CG_SHRINKER);
> > +
> > +	efd = eventfd(0, 0);
> > +	pabort(efd < 0, efd, "eventfd()");
> > +
> > +	ret = asprintf(&str, "%d %d %d\n", efd, sfd, CHUNK_SIZE);
> > +	printf("%s\n", str);
> 
> str value is undefined here if asprintf() failed.
> 
> > +	pabort(ret == -1, ret, "control string");
> > +
> > +	ret = write(cfd, str, ret + 1);
> > +	pabort(ret == -1, ret, "write() to event_control");
> 
> str is leaked.
> 
> > +}
> > +
> > +static void add_reclaimable(int chunks)
> > +{
> > +	int ret;
> > +	char *str;
> > +
> > +	ret = asprintf(&str, "%d %d\n", efd, CHUNK_SIZE);
> 
> s/CHUNK_SIZE/chunks/ ?
> 
> same problems with str here.

Thanks, everything fixed!

> > +	pabort(ret == -1, ret, "add_reclaimable, asprintf");
> > +
> > +	ret = write(sfd, str, ret + 1);
> > +	pabort(ret <= 0, ret, "add_reclaimable, write");
> > +}
> > +
[...]
> > +static void mpc_event(struct mpc_state *mpc, ulong s, ulong r)
> > +{
> > +	struct mpc_event *ev;
> > +	int level = vmpressure_calc_level(vmpressure_win, s, r);
> > +
> > +	mutex_lock(&mpc->events_lock);
> > +
> > +	list_for_each_entry(ev, &mpc->events, node) {
> > +		if (level >= ev->level)
> 
> What about per-level lists?

Sure, can be done.

> > +			eventfd_signal(ev->efd, 1);
> > +	}
> > +
> > +	mutex_unlock(&mpc->events_lock);
> > +}
[...]
> > +static struct cftype mpc_files[] = {
> > +	{
> > +		.name = "level",
> > +		.read = mpc_read_level,
> > +		.register_event = mpc_register_level_event,
> > +		.unregister_event = mpc_unregister_event,
> 
> mpc_unregister_level_event for consistency.

Yeah, will do.

Thanks a lot!

Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
