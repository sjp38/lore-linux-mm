Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4B4B6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 21:06:54 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id n76so112230781ioe.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 18:06:54 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z28sor4842383ioi.14.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Mar 2017 18:06:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAABpnA-Pqn-ptF03b-Am5MWZTfPwF6NiBMp5MnqRetauC5V9Tw@mail.gmail.com>
References: <20170222120121.12601-1-mhocko@kernel.org> <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
 <CA+_MTtzj9z3JEH528iTjAuNivKo9tNzAx9dwpAJo6U5kgf636g@mail.gmail.com>
 <20170224093405.GD19161@dhcp22.suse.cz> <CAEe=SxnHWw0aU6SUO6Ce2YCDxmP4KgmrbShh0uudkuBO1FEFWg@mail.gmail.com>
 <CAABpnA-Pqn-ptF03b-Am5MWZTfPwF6NiBMp5MnqRetauC5V9Tw@mail.gmail.com>
From: Tim Murray <timmurray@google.com>
Date: Fri, 3 Mar 2017 18:06:51 -0800
Message-ID: <CAEe=Sx==VrhUaQ1uNB-NbUzmjuejfijW0+uvSbiQD7Q0K3R+1g@mail.gmail.com>
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rom Lemarchand <romlem@google.com>
Cc: Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@kernel.org>, Martijn Coenen <maco@google.com>, John Stultz <john.stultz@linaro.org>, Greg KH <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Riley Andrews <riandrews@android.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Todd Kjos <tkjos@google.com>, Android Kernel Team <kernel-team@android.com>

Hi all,

I mentioned before that I had some ideas to overhaul lowmemorykiller,
which would have the side effect of getting it out of the kernel. I've
been working through some prototypes over the past few weeks (actually
started before Michal sent his patch out), and I'd appreciate some
feedback on what I'd like to do so I can start working on more
complete patches.

First, Michal has mentioned why the current lowmemorykiller
implementation is bad. However, the design and implementation of
lowmemorykiller is bad for Android users as well. Rather than fixing
lowmemorykiller in the kernel or enabling an equivalent
reimplementation of lowmemorykiller in userspace, I think we can solve
the Android problems and remove lowmemorykiller from the tree at the
same time.

What's wrong with lowmemorykiller from an Android user's POV?

1. lowmemorykiller can be way too aggressive when there are transient
spikes in memory consumption. LMK relies on hand-tuned thresholds to
determine when to kill a process, but hitting the threshold shouldn't
always imply a kill. For example, on some current high-end Android
devices, lowmemorykiller will start to kill oom_score_adj 200
processes once there is less than 112MB in the page cache and less
than 112MB of free pages. oom_score_adj 200 is used for processes that
are important and visible to the user but not the currently-used
foreground app; music playback or camera post-processing for some apps
usually runs as adj 200. This threshold means that even if the system
would quiesce at 110MB in the page cache and 110MB of free pages,
something important to the user may die. This is bad!

2. lowmemorykiller can be way too passive on lower memory devices.
Because lowmemorykiller has a shared threshold for the amount of free
pages and the size of the page cache before it will kill a process,
there is a scenario that we hit all the time that results in low
memory devices becoming unusable. Assume the current application and
supporting system software need X bytes in the page cache in order to
provide reasonable UI performance, and X is larger than the zone_high
watermark that stops kswapd. The number of free pages can drop below
zone_low and kswapd will start evicting pages from the page cache;
however, because the working set is actually of size X, those pages
will be paged back in about as quickly as they can be paged out. This
manifests as kswapd constantly evicting file pages and the foreground
UI workload constantly waiting on page faults. Meanwhile, even if
there are very unimportant processes to kill, lowmemorykiller won't do
anything to kill them.

#2 can be addressed somewhat by separating the limits for number of
free pages and the size of the page cache, but then lowmemorykiller
would have two sets of arbitrary hand-tuned values and still no
knowledge of kswapd/reclaim. It doesn't make sense to do that if we
can avoid it.

We have plenty of evidence for both of these on real Android devices.
I'm bringing up these issues to not only explain the problems that
we'd like to solve, but also to provide some evidence that we're
serious about fixing lowmemorykiller once and for all.

Here's where I'd like to go.

First of all, lowmemorykiller should not be in the kernel, and Android
should move to per-app mem cgroups and kill unnecessary background
tasks when under memory pressure from userspace, not the kernel.

Second, Android has good knowledge of what's important to the user and
what's not. I'd like the ability to use that information to drive
decisions about reclaiming memory, so kswapd can shrink the mem
cgroups associated with background tasks before moving on to
foreground tasks. As far as I can tell, what I'm suggesting isn't a
soft limit or something like that. We don't have specific limits on
memory consumption for particular processes, and there's no size we
definitely want to get background processes to via reclaim before we
start reclaiming from foreground or persistent processes. In practice,
I think this looks like a per-memory-cgroup reclaim priority. I have a
prototype of this where I've added a new knob called memory.priority
from 0 to 10 that serves two purposes:

- Skip reclaiming from higher-priority cgroups entirely until the
priority from shrink_zone is high enough.
- Reduce the number of pages scanned from higher-priority cgroups once
they are eligible for reclamation.

This would let kswapd reclaim from applications that aren't critical
to the user while still occasionally reclaiming from persistent
processes (evicting pages that are used very rarely from
always-running system processes). This would effectively reduce the
size of backgrounded applications without impacting UI performance--a
huge improvement over what Android can do today.

Third, assuming we can do this kind of prioritized reclaim, I'd like
more information available via vmpressure (or similar) about the
current state of kswapd in terms of what priority it's trying to
reclaim. If lmkd knew that kswapd had moved on to higher-priority
cgroups while there were very unimportant processes remaining, lmkd
could be much more accurate about when to kill a process. This means
lmkd would run only in response to actual kswapd/direct reclaim
behavior, not because of arbitrary thresholds. This would unify how to
tune Android devices for memory consumption; the knobs in /proc/sys/vm
(primarily min_free_kbytes and extra_free_kbytes) would control both
kswapd *and* lmkd. I think this would also solve the "too aggressive
killing during transient spike" issue.

I'm working on an RFC of prioritized reclaim to follow (I hope)
sometime next week. I don't have a vmpressure patch prototyped yet,
since it depends on what the prioritized reclaim interface looks like.
Also, to be perfectly clear, I don't think my current approach is
necessarily the right one at all. All I have right now is a minimal
patch (against 3.18, hence the delay) to support memory cgroup
priorities: the interface makes no sense if you aren't familiar with
mm internals, I haven't thought through how this interacts with soft
limits, it doesn't make sense with cgroup hierarchies, etc. At this
stage, I'm mainly wondering if the broader community thinks
prioritized reclaim is a viable direction.

Thanks for any feedback you can provide.

Tim

On Fri, Feb 24, 2017 at 10:42 AM, Rom Lemarchand <romlem@google.com> wrote:
> +surenb
>
> On Fri, Feb 24, 2017 at 10:38 AM, Tim Murray <timmurray@google.com> wrote:
>>
>> Hi all, I've recently been looking at lowmemorykiller, userspace lmkd, and
>> memory cgroups on Android.
>>
>> First of all, no, an Android device will probably not function without a
>> kernel or userspace version of lowmemorykiller. Android userspace expects
>> that if there are many apps running in the background on a machine and the
>> foreground app allocates additional memory, something on the system will
>> kill background apps to free up more memory. If this doesn't happen, I
>> expect that at the very least you'll see page cache thrashing, and you'll
>> probably see the OOM killer run regularly, which has a tendency to cause
>> Android userspace to restart. To the best of my knowledge, no device has
>> shipped with a userspace lmkd.
>>
>> Second, yes, the current design and implementation of lowmemorykiller are
>> unsatisfactory. I now have some concrete evidence that the design of
>> lowmemorykiller is directly responsible for some very negative user-visible
>> behaviors (particularly the triggers for when to kill), so I'm currently
>> working on an overhaul to the Android memory model that would use mem
>> cgroups and userspace lmkd to make smarter decisions about reclaim vs
>> killing. Yes, this means that we would move to vmpressure (which will
>> require improvements to vmpressure). I can't give a firm ETA for this, as
>> it's still in the prototype phase, but the initial results are promising.
>>
>> On Fri, Feb 24, 2017 at 1:34 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>>
>>> On Thu 23-02-17 21:36:00, Martijn Coenen wrote:
>>> > On Thu, Feb 23, 2017 at 9:24 PM, John Stultz <john.stultz@linaro.org>
>>> > wrote:
>>> [...]
>>> > > This is reportedly because while the mempressure notifiers provide a
>>> > > the signal to userspace, the work the deamon then has to do to look
>>> > > up
>>> > > per process memory usage, in order to figure out who is best to kill
>>> > > at that point was too costly and resulted in poor device performance.
>>> >
>>> > In particular, mempressure requires memory cgroups to function, and we
>>> > saw performance regressions due to the accounting done in mem cgroups.
>>> > At the time we didn't have enough time left to solve this before the
>>> > release, and we reverted back to kernel lmkd.
>>>
>>> I would be more than interested to hear details. We used to have some
>>> visible charge path performance footprint but this should be gone now.
>>>
>>> [...]
>>> > > It would be great however to get a discussion going here on what the
>>> > > ulmkd needs from the kernel in order to efficiently determine who
>>> > > best
>>> > > to kill, and how we might best implement that.
>>> >
>>> > The two main issues I think we need to address are:
>>> > 1) Getting the right granularity of events from the kernel; I once
>>> > tried to submit a patch upstream to address this:
>>> > https://lkml.org/lkml/2016/2/24/582
>>>
>>> Not only that, the implementation of tht vmpressure needs some serious
>>> rethinking as well. The current one can hit critical events
>>> unexpectedly. The calculation also doesn't consider slab reclaim
>>> sensibly.
>>>
>>> > 2) Find out where exactly the memory cgroup overhead is coming from,
>>> > and how to reduce it or work around it to acceptable levels for
>>> > Android. This was also on 3.10, and maybe this has long been fixed or
>>> > improved in more recent kernel versions.
>>>
>>> 3e32cb2e0a12 ("mm: memcontrol: lockless page counters") has improved
>>> situation a lot as all the charging is lockless since then (3.19).
>>> --
>>> Michal Hocko
>>> SUSE Labs
>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
