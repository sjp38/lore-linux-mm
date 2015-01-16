Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id CB05B6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 10:49:25 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id ho1so5047511wib.4
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:49:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dv4si4885492wib.16.2015.01.16.07.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 07:49:24 -0800 (PST)
Date: Fri, 16 Jan 2015 16:49:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-ID: <20150116154922.GB4650@dhcp22.suse.cz>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
 <20150114165036.GI4706@dhcp22.suse.cz>
 <54B7F7C4.2070105@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54B7F7C4.2070105@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org, Christoph Lameter <cl@gentwo.org>

On Thu 15-01-15 22:54:20, Vinayak Menon wrote:
> On 01/14/2015 10:20 PM, Michal Hocko wrote:
> >On Wed 14-01-15 17:06:59, Vinayak Menon wrote:
> >[...]
> >>In one such instance, zone_page_state(zone, NR_ISOLATED_FILE)
> >>had returned 14, zone_page_state(zone, NR_INACTIVE_FILE)
> >>returned 92, and GFP_IOFS was set, and this resulted
> >>in too_many_isolated returning true. But one of the CPU's
> >>pageset vm_stat_diff had NR_ISOLATED_FILE as "-14". So the
> >>actual isolated count was zero. As there weren't any more
> >>updates to NR_ISOLATED_FILE and vmstat_update deffered work
> >>had not been scheduled yet, 7 tasks were spinning in the
> >>congestion wait loop for around 4 seconds, in the direct
> >>reclaim path.
> >
> >Not syncing for such a long time doesn't sound right. I am not familiar
> >with the vmstat syncing but sysctl_stat_interval is HZ so it should
> >happen much more often that every 4 seconds.
> >
> 
> Though the interval is HZ, since the vmstat_work is declared as a
> deferrable work, IIUC the timer trigger can be deferred to the next
> non-defferable timer expiry on the CPU which is in idle. This results
> in the vmstat syncing on an idle CPU delayed by seconds. May be in
> most cases this behavior is fine, except in cases like this.

I am not sure I understand the above because CPU being idle doesn't
seem important AFAICS. Anyway I have checked the current code which has
changed quite recently by 7cc36bbddde5 (vmstat: on-demand vmstat workers
V8). Let's CC Christoph (the thread starts here:
http://thread.gmane.org/gmane.linux.kernel.mm/127229).

__round_jiffies_relative can easily make timeout 2HZ from 1HZ. Now we
have vmstat_shepherd which waits to be queued and then wait to run. When
it runs finally it only queues per-cpu vmstat_work which can also end
up being 2HZ for some CPUs. So we can indeed have 4 seconds spent just
for queuing. Not even mentioning work item latencies. Especially when
workers are overloaded e.g. by fs work items and no additional workers
cannot be created e.g. due to memory pressure so they are processed only
by the workqueue rescuer. And latencies would grow a lot.

We have seen an issue where rescuer had to process thousands of work
items because all workers where blocked on memory allocation - see
http://thread.gmane.org/gmane.linux.kernel/1816452 - which is mainline
already 008847f66c38 (workqueue: allow rescuer thread to do more work.)
the patch reduces the latency considerably but it doesn't remove it
completely.

If the time between two syncs is large then the per-cpu drift might be
really large as well. Isn't this going to hurt other places where we
rely on stats as well?

In this particular case the reclaimers are throttled because they see
too many isolated pages which was just a result of the per-cpu drift and
small LRU list. The system seems to be under serious memory pressure
already because there is basically no file cache. If the reclaimers
wouldn't be throttled they would fail the reclaim probably and trigger
OOM killer which might help to resolve the situation. Reclaimers are
throttled instead.

Why cannot we simply update the global counters from vmstat_shepherd
directly? Sure we would access remote CPU counters but that wouldn't
happen often. That still wouldn't be enough because there is the
workqueue latency. So why cannot we do that whole shepherd thing from a
kernel thread instead? If the NUMA zone->pageset->pcp thing has to be
done locally then it could have per-node kthread rather than being part
of the unrelated vmstat code.
I might be missing obvious things because I still haven't digested the
code completely but this whole thing seems overly complicated and I
do not see a good reason for that. If the primary motivation was cpu
isolation then kthreads would sound like a better idea because you can
play with the explicit affinity from the userspace.

> Even in usual cases were the timer triggers in 1-2 secs, is it fine to
> let the tasks in reclaim path wait that long unnecessarily when there
> isn't any real congestion?

But how do we find that out?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
