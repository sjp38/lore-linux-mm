Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C516F6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 08:34:39 -0400 (EDT)
Message-ID: <50853D47.4030409@parallels.com>
Date: Mon, 22 Oct 2012 16:34:15 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 06/14] memcg: kmem controller infrastructure
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-7-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1210171515290.20712@chino.kir.corp.google.com> <507FCA90.8060307@parallels.com> <alpine.DEB.2.00.1210181454100.30894@chino.kir.corp.google.com> <5081269B.5000603@parallels.com> <alpine.DEB.2.00.1210191331400.17804@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210191331400.17804@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 10/20/2012 12:34 AM, David Rientjes wrote:
> On Fri, 19 Oct 2012, Glauber Costa wrote:
> 
>>>>> What about gfp & __GFP_FS?
>>>>>
>>>>
>>>> Do you intend to prevent or allow OOM under that flag? I personally
>>>> think that anything that accepts to be OOM-killed should have GFP_WAIT
>>>> set, so that ought to be enough.
>>>>
>>>
>>> The oom killer in the page allocator cannot trigger without __GFP_FS 
>>> because direct reclaim has little chance of being very successful and 
>>> thus we end up needlessly killing processes, and that tends to happen 
>>> quite a bit if we dont check for it.  Seems like this would also happen 
>>> with memcg if mem_cgroup_reclaim() has a large probability of failing?
>>>
>>
>> I can indeed see tests for GFP_FS in some key locations in mm/ before
>> calling the OOM Killer.
>>
>> Should I test for GFP_IO as well?
> 
> It's not really necessary, if __GFP_IO isn't set then it wouldn't make 
> sense for __GFP_FS to be set.
> 
>> If the idea is preventing OOM to
>> trigger for allocations that can write their pages back, how would you
>> feel about the following test:
>>
>> may_oom = (gfp & GFP_KERNEL) && !(gfp & __GFP_NORETRY) ?
>>
> 
> I would simply copy the logic from the page allocator and only trigger oom 
> for __GFP_FS and !__GFP_NORETRY.
> 

That seems reasonable to me. Michal ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
