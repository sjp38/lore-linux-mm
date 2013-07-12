Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 0C8C56B0036
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:25:52 -0400 (EDT)
Message-ID: <51DFCA49.4080407@huawei.com>
Date: Fri, 12 Jul 2013 17:20:09 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vmpressure: make sure memcg stays alive until all
 users are signaled
References: <20130710184254.GA16979@mtj.dyndns.org> <20130711083110.GC21667@dhcp22.suse.cz> <51DE701C.6010800@huawei.com> <20130711092542.GD21667@dhcp22.suse.cz> <51DE7AAF.6070004@huawei.com> <20130711093300.GE21667@dhcp22.suse.cz> <20130711154408.GA9229@mtj.dyndns.org> <20130711162215.GM21667@dhcp22.suse.cz> <20130711163238.GC9229@mtj.dyndns.org> <20130712084039.GA13224@dhcp22.suse.cz>
In-Reply-To: <20130712084039.GA13224@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

>> especially while shutting down objects as they enter a lingering stage
>> where they're de-registered but not destroyed and you should be
>> careful which parts of the object are still accessible.  I haven't
>> read it carefully but here I'm not sure whether it's safe to do event
>> related operations after removal.  From cgroup core side, event list
>> is shut down synchronously from cgroup_destroy_locked().  It doesn't
>> seem like that part is explicitly built to remain accessible
>> afterwards.
> 
> /me goes and checks the code
> 
> vmpressure_event sends signals to _registered_ events but those are
> unregistered from the work queue context by cgroup_event_remove (via
> vmpressure_unregister_event) queued from cgroup_destroy_locked.
> 
> I am not sure what are the guarantees for ordering on the workqueue but
> this all suggests that either vmpressure_event sees an empty vmpr->events
> or it can safely send signals as cgroup_event_remove is pending on the
> queue.
> 
> cgroup_event_remove drops a reference to cgrp->dentry after everything
> is unregistered and event->wait removed from the wait queue so
> cgroup_free_fn couldn't have been called yet and so memcg is still
> alive. This means that even css_get/put is not necessary.
> 
> So I guess we are safe with the code as is but this all is really
> _tricky_ and deserves a fat comment. So rather than adding flushing work
> item code we should document it properly.
> 
> Or am I missing something?
> 

But if I read the code correctly, even no one registers a vmpressure event,
vmpressure() is always running and queue the work item.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
