Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DCAA36B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 02:03:59 -0400 (EDT)
Message-ID: <51DF9C33.7040708@huawei.com>
Date: Fri, 12 Jul 2013 14:03:31 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vmpressure: make sure memcg stays alive until all
 users are signaled
References: <20130710184254.GA16979@mtj.dyndns.org> <20130711083110.GC21667@dhcp22.suse.cz> <51DE701C.6010800@huawei.com> <20130711092542.GD21667@dhcp22.suse.cz> <51DE7AAF.6070004@huawei.com> <20130711093300.GE21667@dhcp22.suse.cz> <20130711154408.GA9229@mtj.dyndns.org> <20130711162215.GM21667@dhcp22.suse.cz>
In-Reply-To: <20130711162215.GM21667@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On 2013/7/12 0:22, Michal Hocko wrote:
> On Thu 11-07-13 08:44:08, Tejun Heo wrote:
>> Hello, Michal.
>>
>> On Thu, Jul 11, 2013 at 11:33:00AM +0200, Michal Hocko wrote:
>>> +static inline
>>> +struct mem_cgroup *vmpressure_to_mem_cgroup(struct vmpressure *vmpr)
>>> +{
>>> +	return container_of(vmpr, struct mem_cgroup, vmpressure);
>>> +}
>>> +
>>> +void vmpressure_pin_memcg(struct vmpressure *vmpr)
>>> +{
>>> +	struct mem_cgroup *memcg = vmpressure_to_mem_cgroup(vmpr);
>>> +
>>> +	css_get(&memcg->css);
>>> +}
>>> +
>>> +void vmpressure_unpin_memcg(struct vmpressure *vmpr)
>>> +{
>>> +	struct mem_cgroup *memcg = vmpressure_to_mem_cgroup(vmpr);
>>> +
>>> +	css_put(&memcg->css);
>>> +}
>>
>> So, while this *should* work, can't we just cancel/flush the work item
>> from offline? 
> 
> I would rather not put vmpressure clean up code into memcg offlining.
> We have reference counting for exactly this purposes so it feels strange
> to overcome it like that.

I'd agree with Tejun here. Asynchrously should be avoided if not necessary,
and the change would be simpler. There's already a vmpressure_init() in
mem_cgroup_css_alloc(), so it doesn't seem bad to do vmpressure cleanup
in memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
