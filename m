Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 63E5F6B0073
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 12:32:45 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id g10so4333707qah.12
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 09:32:44 -0700 (PDT)
Date: Thu, 11 Jul 2013 09:32:38 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] vmpressure: make sure memcg stays alive until all
 users are signaled
Message-ID: <20130711163238.GC9229@mtj.dyndns.org>
References: <20130710184254.GA16979@mtj.dyndns.org>
 <20130711083110.GC21667@dhcp22.suse.cz>
 <51DE701C.6010800@huawei.com>
 <20130711092542.GD21667@dhcp22.suse.cz>
 <51DE7AAF.6070004@huawei.com>
 <20130711093300.GE21667@dhcp22.suse.cz>
 <20130711154408.GA9229@mtj.dyndns.org>
 <20130711162215.GM21667@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130711162215.GM21667@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hello,

On Thu, Jul 11, 2013 at 06:22:15PM +0200, Michal Hocko wrote:
> I would rather not put vmpressure clean up code into memcg offlining.
> We have reference counting for exactly this purposes so it feels strange
> to overcome it like that.

It's not something white and black but for things which can be made
trivially synchrnous, it usually is better to do it that way,
especially while shutting down objects as they enter a lingering stage
where they're de-registered but not destroyed and you should be
careful which parts of the object are still accessible.  I haven't
read it carefully but here I'm not sure whether it's safe to do event
related operations after removal.  From cgroup core side, event list
is shut down synchronously from cgroup_destroy_locked().  It doesn't
seem like that part is explicitly built to remain accessible
afterwards.

> Besides that wouldn't be that racy? The work item could be already
> executing and preempted and we do not want vmpr to disappear from under
> our feet. I know this is _highly_ unlikely but why to play games?

Hmmm?  flush_work() and cancel_work_sync() guarantee that the work
item isn't executing on return unless it's being requeued.  There's no
race condition.

> Dunno, to be honest. From a quick look they both can be turned to spin
> locks but events_lock might cause long preempt disabled periods when
> zillions of events are registered.

I see.

> > Also, while at it, can you please remove the work_pending() check?
> > They're almost always spurious or racy and should be avoided in
> > general.
> 
> sure, this really looks bogus. I will cook patches for both issues and
> send them tomorrow.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
