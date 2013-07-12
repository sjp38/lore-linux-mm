Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 0E82D6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:55:48 -0400 (EDT)
Message-ID: <51DFD253.3030501@huawei.com>
Date: Fri, 12 Jul 2013 17:54:27 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vmpressure: make sure memcg stays alive until all
 users are signaled
References: <20130711083110.GC21667@dhcp22.suse.cz> <51DE701C.6010800@huawei.com> <20130711092542.GD21667@dhcp22.suse.cz> <51DE7AAF.6070004@huawei.com> <20130711093300.GE21667@dhcp22.suse.cz> <20130711154408.GA9229@mtj.dyndns.org> <20130711162215.GM21667@dhcp22.suse.cz> <20130711163238.GC9229@mtj.dyndns.org> <20130712084039.GA13224@dhcp22.suse.cz> <51DFCA49.4080407@huawei.com> <20130712092927.GA15307@dhcp22.suse.cz>
In-Reply-To: <20130712092927.GA15307@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On 2013/7/12 17:29, Michal Hocko wrote:
> On Fri 12-07-13 17:20:09, Li Zefan wrote:
> [...]
>> But if I read the code correctly, even no one registers a vmpressure event,
>> vmpressure() is always running and queue the work item.
> 
> True but checking there is somebody is rather impractical. First we
> would have to take a events_lock to check this and then drop it after
> scheduling the work. Which doesn't guarantee that the registered event
> wouldn't go away.
> And even trickier, we would have to do the same for all parents up the
> hierarchy.
> 

The thing is, we can forget about eventfd. eventfd is checked in
vmpressure_work_fn(), while vmpressure() is always called no matter what.

vmpressure()
  queue_work()
                      cgroup_diput()
                        call_rcu(cgroup_free_rcu)                        
                      ...
                      queue_work(destroy_cgroup)
                      ...
                      cgroup_free_fn()
                        mem_cgroup_destroy()
  ...
  vmpress_work_fn()

There's no guarantee that vmpressure work is run before cgroup destroy
work, I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
