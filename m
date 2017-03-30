Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B831B6B03B4
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 11:51:32 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 34so11071968wrb.20
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 08:51:32 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h40si4053939wrh.7.2017.03.30.08.51.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 08:51:30 -0700 (PDT)
Date: Thu, 30 Mar 2017 11:51:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Message-ID: <20170330155123.GA3929@cmpxchg.org>
References: <20170317231636.142311-1-timmurray@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317231636.142311-1-timmurray@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Murray <timmurray@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, surenb@google.com, totte@google.com, kernel-team@android.com

Hi Tim,

On Fri, Mar 17, 2017 at 04:16:35PM -0700, Tim Murray wrote:
> Hi all,
> 
> I've been working to improve Android's memory management and drop lowmemorykiller from the kernel, and I'd like to get some feedback on a small patch with a lot of side effects. 
> 
> Currently, when an Android device is under memory pressure, one of three things will happen from kswapd:
> 
> 1. Compress an anonymous page to ZRAM.
> 2. Evict a file page.
> 3. Kill a process via lowmemorykiller.
> 
> The first two are cheap and per-page, the third is relatively cheap in the short term, frees many pages, and may cause power and performance penalties later on when the process has to be started again. For lots of reasons, I'd like a better balance between reclamation and killing on Android.
> 
> One of the nice things about Android from an optimization POV is that the execution model is more constrained than a generic Linux machine. There are only a limited number of processes that need to execute quickly for the device to appear to have good performance, and a userspace daemon (called ActivityManagerService) knows exactly what those processes are at any given time. We've made use of that in the past via cpusets and schedtune to limit the CPU resources available to background processes, and I think we can apply the same concept to memory.
> 
> This patch adds a new tunable to mem cgroups, memory.priority. A mem cgroup with a non-zero priority will not be eligible for scanning until the scan_control's priority is greater than zero. Once the mem cgroup is eligible for scanning, the priority acts as a bias to reduce the number of pages that should be scanned.
> 
> We've seen cases on Android where the global LRU isn't sufficient. For example, notifications in Android are rendered as part of a separate process that runs infrequently. However, when a notification appears and the user slides down the notification tray, we'll often see dropped frames due to page faults if there has been severe memory pressure. There are similar issues with other persistent processes.
> 
> The goal on an Android device is to aggressively evict from very low-priority background tasks that are likely to be killed anyway, since this will reduce the likelihood of lowmemorykiller running in the first place. It will still evict some from foreground and persistent processes, but it should help ensure that background processes are effectively reduced to the size of their heaps before evicting from more critical tasks. This should mean fewer background processes end up killed, which should improve performance and power on Android across the board (since it costs significantly less to page things back in than to replay the entirety of application startup).

In cgroup2, we've added a memory.low knob, where groups within their
memory.low setting are not reclaimed.

You can set that knob on foreground groups to the amount of memory
they need to function properly, and set it to 0 on background groups.

Have you tried doing that?

> The follow-on that I'm also experimenting with is how to improve vmpressure such that userspace can have some idea when low-priority memory cgroups are about as small as they can get. The correct time for Android to kill a background process under memory pressure is when there is evidence that a process has to be killed in order to alleviate memory pressure. If the device is below the low memory watermark and we know that there's probably no way to reclaim any more from background processes, then a userspace daemon should kill one or more background processes to fix that. Per-cgroup priority could be the first step toward that information.

Memory pressure is a wider-reaching issue, something I've been working
on for a while.

Both vmpressure and priority levels are based on reclaim efficiency,
which is problematic on solid state storage because page reads have
very low latency. It's rare that pages are still locked from the
read-in by the time reclaim gets to them on the LRU, so efficiency
tends to stay at 100%, until the system is essentially livelocked.

On solid state storage, the bigger problem when you don't have enough
memory is that you can reclaim just fine but wait a significant amount
of time to refault the recently evicted pages, i.e. on thrashing.

A more useful metric for memory pressure at this point is quantifying
that time you spend thrashing: time the job spends in direct reclaim
and on the flipside time the job waits for recently evicted pages to
come back. Combined, that gives you a good measure of overhead from
memory pressure; putting that in relation to a useful baseline of
meaningful work done gives you a portable scale of how effictively
your job is running.

I'm working on that right now, hopefully I'll have something useful
soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
