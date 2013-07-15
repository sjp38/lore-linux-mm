Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 134846B00C0
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:55:04 -0400 (EDT)
Message-ID: <51E3C6A0.4070308@huawei.com>
Date: Mon, 15 Jul 2013 17:53:36 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vmpressure: make sure memcg stays alive until all
 users are signaled
References: <20130711093300.GE21667@dhcp22.suse.cz> <20130711154408.GA9229@mtj.dyndns.org> <20130711162215.GM21667@dhcp22.suse.cz> <20130711163238.GC9229@mtj.dyndns.org> <20130712084039.GA13224@dhcp22.suse.cz> <51DFCA49.4080407@huawei.com> <20130712092927.GA15307@dhcp22.suse.cz> <51DFD253.3030501@huawei.com> <20130712103731.GB15307@dhcp22.suse.cz> <51E36788.6080308@huawei.com> <20130715092033.GB26199@dhcp22.suse.cz>
In-Reply-To: <20130715092033.GB26199@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On 2013/7/15 17:20, Michal Hocko wrote:
> On Mon 15-07-13 11:07:52, Li Zefan wrote:
>> On 2013/7/12 18:37, Michal Hocko wrote:
>>> On Fri 12-07-13 17:54:27, Li Zefan wrote:
>>>> On 2013/7/12 17:29, Michal Hocko wrote:
>>>>> On Fri 12-07-13 17:20:09, Li Zefan wrote:
>>>>> [...]
>>>>>> But if I read the code correctly, even no one registers a vmpressure event,
>>>>>> vmpressure() is always running and queue the work item.
>>>>>
>>>>> True but checking there is somebody is rather impractical. First we
>>>>> would have to take a events_lock to check this and then drop it after
>>>>> scheduling the work. Which doesn't guarantee that the registered event
>>>>> wouldn't go away.
>>>>> And even trickier, we would have to do the same for all parents up the
>>>>> hierarchy.
>>>>>
>>>>
>>>> The thing is, we can forget about eventfd. eventfd is checked in
>>>> vmpressure_work_fn(), while vmpressure() is always called no matter what.
>>>
>>> But vmpressure is called only for an existing memcg. This means that
>>> it cannot be called past css_offline so it must happen _before_ cgroup
>>> eventfd cleanup code.
>>>
>>> Or am I missing something?
>>>
>>
>> Yeah.
>>
>> The vmpressure work item is queued if we sense some memory pressure, no matter
>> if there is any eventfd ever registered. This is the point.
> 
> But it is queued on vmpr which is embedded in the memcg which is the
> _target_ of the reclaim. There is _no reclaim_ for a memcg after css has
> been deactivated which happens _before_ css_offline.
> 

1. vmpressure() is called, and the work is queued.
2. then we rmdir cgroup, and struct mem_cgroup is freed finally.
3. workqueue schedules the work to run:

static void vmpressure_work_fn(struct work_struct *work)
{
        struct vmpressure *vmpr = work_to_vmpressure(work)
...

As vmpr is embeded in struct mem_cgroup, and memcg has been freed, this
leads to invalid memory access.

NOTE: no one ever registered an eventfd!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
