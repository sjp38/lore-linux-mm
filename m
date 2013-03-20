Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id F19F66B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 04:33:33 -0400 (EDT)
Message-ID: <51497479.30701@parallels.com>
Date: Wed, 20 Mar 2013 12:34:01 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/5] memcg: provide root figures from system totals
References: <1362489058-3455-1-git-send-email-glommer@parallels.com> <1362489058-3455-3-git-send-email-glommer@parallels.com> <20130319124650.GE7869@dhcp22.suse.cz> <20130319125509.GF7869@dhcp22.suse.cz> <51495F35.9040302@parallels.com> <20130320080347.GE20045@dhcp22.suse.cz> <51496E71.5010707@parallels.com> <20130320081851.GG20045@dhcp22.suse.cz>
In-Reply-To: <20130320081851.GG20045@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On 03/20/2013 12:18 PM, Michal Hocko wrote:
> On Wed 20-03-13 12:08:17, Glauber Costa wrote:
>> On 03/20/2013 12:03 PM, Michal Hocko wrote:
>>> On Wed 20-03-13 11:03:17, Glauber Costa wrote:
>>>> On 03/19/2013 04:55 PM, Michal Hocko wrote:
>>>>> On Tue 19-03-13 13:46:50, Michal Hocko wrote:
>>>>>> On Tue 05-03-13 17:10:55, Glauber Costa wrote:
>>>>>>> For the root memcg, there is no need to rely on the res_counters if hierarchy
>>>>>>> is enabled The sum of all mem cgroups plus the tasks in root itself, is
>>>>>>> necessarily the amount of memory used for the whole system. Since those figures
>>>>>>> are already kept somewhere anyway, we can just return them here, without too
>>>>>>> much hassle.
>>>>>>>
>>>>>>> Limit and soft limit can't be set for the root cgroup, so they are left at
>>>>>>> RESOURCE_MAX. Failcnt is left at 0, because its actual meaning is how many
>>>>>>> times we failed allocations due to the limit being hit. We will fail
>>>>>>> allocations in the root cgroup, but the limit will never the reason.
>>>>>>
>>>>>> I do not like this very much to be honest. It just adds more hackery...
>>>>>> Why cannot we simply not account if nr_cgroups == 1 and move relevant
>>>>>> global counters to the root at the moment when a first group is
>>>>>> created?
>>>>>
>>>>> OK, it seems that the very next patch does what I was looking for. So
>>>>> why all the churn in this patch?
>>>>> Why do you want to make root even more special?
>>>>
>>>> Because I am operating under the assumption that we want to handle that
>>>> transparently and keep things working. If you tell me: "Hey, reading
>>>> memory.usage_in_bytes from root should return 0!", then I can get rid of
>>>> that.
>>>
>>> If you simply switch to accounting for root then you do not have to care
>>> about this, don't you?
>>>
>> Of course not, but the whole point here is *not* accounting root.
> 
> I thought the objective was to not account root if there are no
> children. 

It is the goal, yes. As I said: I want the root-only case to keep
providing userspace with meaningful statistics, therefore the bypass.
But since the machinery is in place, it is trivial to keep bypassing for
use_hierarchy = 1 at the root level. If you believe it would be simpler,
I could refrain from doing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
