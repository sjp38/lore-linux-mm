Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6935E6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 11:21:28 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p63so31915384wmp.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 08:21:28 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id q200si5079566wmg.67.2016.01.28.08.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 08:21:27 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id 128so2549914wmz.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 08:21:27 -0800 (PST)
Date: Thu, 28 Jan 2016 17:21:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] mm: memcontrol: cgroup2 memory statistics
Message-ID: <20160128162125.GG15948@dhcp22.suse.cz>
References: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
 <20160113144916.03f03766e201b6b04a8a47cc@linux-foundation.org>
 <20160114202408.GA20218@cmpxchg.org>
 <20160115095834.GP30160@esperanza>
 <20160115203059.GA25092@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160115203059.GA25092@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

[I am sorry I am coming here late but I didn't have time earlier]

On Fri 15-01-16 15:30:59, Johannes Weiner wrote:
> On Fri, Jan 15, 2016 at 12:58:34PM +0300, Vladimir Davydov wrote:
> > With the follow-up it looks good to me. All exported counters look
> > justified enough and the format follows that of other cgroup2
> > controllers (cpu, blkio). Thanks!
> > 
> > Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> Thanks Vladimir.

Patches got merged in the meantime but anyway just for the record

Acked-by: Michal Hocko <mhocko@suse.com>

I would have liked nr_pages more than B because they are neither
following /proc/vmstat nor /proc/meminfo (which is in kB). It is true
that other memcg knobs are primarily bytes oriented so there is some
reason to use B here as well.

> > One addition though. May be, we could add 'total' field which would show
> > memory.current? Yeah, this would result in a little redundancy, but I
> > think that from userspace pov it's much more convenient to read the
> > only file and get all stat counters than having them spread throughout
> > several files.
> 
> I am not fully convinced that a total value or even memory.current
> will be looked at that often in practice, because in all but a few
> cornercases that value will be pegged to the configured limit. In
> those instances I think it should be okay to check another file.

Agreed

> > Come to think of it, do we really need separate memory.events file?
> > Can't these counters live in memory.stat either?
> 
> I think it sits at a different level of the interface. The events file
> indicates cgroup-specific dynamics between configuration and memory
> footprint, and so it sits on the same level as low, high, max, and
> current. These are the parts involved in the most basic control loop
> between the kernel and the job scheduler--monitor and adjust or notify
> the admin. It's for the entity that allocates and manages the system.
> 
> The memory.stat file on the other hand is geared toward analyzing and
> understanding workload-specific performance (whether by humans or with
> some automated heuristics) and if necessary correcting the config file
> that describes the application's requirements to the job scheduler.
> 
> I think it makes sense to not conflate these two interfaces.

Agreed here as well.
 
> > Yeah, this file
> > generates events, but IMHO it's not very useful the way it is currently
> > implemented:
> > 
> > Suppose, a user wants to receive notifications about OOM or LOW events,
> > which are rather rare normally and might require immediate action. The
> > only way to do that is to listen to memory.events, but this file can
> > generate tons of MAX/HIGH when the cgroup is performing normally. The
> > userspace app will have to wake up every time the cgroup performs
> > reclaim and check memory.events just to ensure no OOM happened and this
> > all will result in wasting cpu time.
> 
> Under optimal system load there is no limit reclaim, and memory
> pressure comes exclusively from a shortage of physical pages that
> global reclaim balances based on memory.low. If groups run into their
> own limits, it means that there are idle resources left on the table.

I would expect that the high limit will be routinely hit due to page
cache consumption.
 
> So events only happen when the machine is over or under utilized, and
> as per above, the events file is mainly meant for something like a job
> scheduler tasked with allocating the machine's resources. It's hard to
> imagine a job scheduler scenario where the long-term goal is anything
> other than optimal utilization.
> 
> There are reasonable cases in which memory could be temporarily left
> idle, say to keep startup latency of new jobs low. In those it's true
> that the max and high notifications might become annoying. But do you
> really think that could become problematic in practice? In that case
> it should be enough if we ratelimit the file-changed notifications.

I am not sure this would be a real problem either. Sure you can see a
lot of events but AFAIU no events will be lost, right?

> > May be, we could generate LOW/HIGH/MAX events on memory.low/high/max?
> > This would look natural IMO. Don't know where OOM events should go in
> > this case though.
> 
> Without a natural place for OOM notifications, it probably makes sense
> to stick with memory.events.

yes
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
