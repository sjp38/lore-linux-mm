Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC7D828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 04:58:55 -0500 (EST)
Received: by mail-lb0-f176.google.com with SMTP id x4so55525360lbm.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 01:58:55 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id qt2si5290815lbb.174.2016.01.15.01.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 01:58:53 -0800 (PST)
Date: Fri, 15 Jan 2016 12:58:34 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 0/2] mm: memcontrol: cgroup2 memory statistics
Message-ID: <20160115095834.GP30160@esperanza>
References: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
 <20160113144916.03f03766e201b6b04a8a47cc@linux-foundation.org>
 <20160114202408.GA20218@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160114202408.GA20218@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Johannes,

On Thu, Jan 14, 2016 at 03:24:08PM -0500, Johannes Weiner wrote:
...
> The output of this file looks as follows:
> 
> $ cat memory.stat
> anon 167936
> file 87302144
> file_mapped 0
> file_dirty 0
> file_writeback 0
> inactive_anon 0
> active_anon 155648
> inactive_file 87298048
> active_file 4096
> unevictable 0
> pgfault 636
> pgmajfault 0
> 
> The list consists of two sections: statistics reflecting the current
> state of the memory management subsystem, and statistics reflecting
> past events. The items themselves are sorted such that generic big
> picture items come before specific details, and items related to
> userspace activity come before items related to kernel heuristics.
> 
> All memory counters are in bytes to eliminate all ambiguity with
> variable page sizes.
> 
> There will be more items and statistics added in the future, but this
> is a good initial set to get a minimum of insight into how a cgroup is
> using memory, and the items chosen for now are likely to remain valid
> even with significant changes to the memory management implementation.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

With the follow-up it looks good to me. All exported counters look
justified enough and the format follows that of other cgroup2
controllers (cpu, blkio). Thanks!

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

One addition though. May be, we could add 'total' field which would show
memory.current? Yeah, this would result in a little redundancy, but I
think that from userspace pov it's much more convenient to read the
only file and get all stat counters than having them spread throughout
several files.

Come to think of it, do we really need separate memory.events file?
Can't these counters live in memory.stat either? Yeah, this file
generates events, but IMHO it's not very useful the way it is currently
implemented:

Suppose, a user wants to receive notifications about OOM or LOW events,
which are rather rare normally and might require immediate action. The
only way to do that is to listen to memory.events, but this file can
generate tons of MAX/HIGH when the cgroup is performing normally. The
userspace app will have to wake up every time the cgroup performs
reclaim and check memory.events just to ensure no OOM happened and this
all will result in wasting cpu time.

May be, we could generate LOW/HIGH/MAX events on memory.low/high/max?
This would look natural IMO. Don't know where OOM events should go in
this case though.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
