Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3316B0261
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 03:37:24 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e9so14390616pgc.5
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 00:37:24 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id b34si4106173pli.224.2016.11.23.00.37.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 00:37:23 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id c4so395670pfb.3
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 00:37:23 -0800 (PST)
Subject: Re: [mm v2 0/3] Support memory cgroup hotplug
References: <1479875814-11938-1-git-send-email-bsingharora@gmail.com>
 <20161123072543.GD2864@dhcp22.suse.cz>
 <342ebcca-b54c-4bc6-906b-653042caae06@gmail.com>
 <20161123080744.GG2864@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <61dc32fd-2802-6deb-24cf-fa11b5b31532@gmail.com>
Date: Wed, 23 Nov 2016 19:37:16 +1100
MIME-Version: 1.0
In-Reply-To: <20161123080744.GG2864@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>



On 23/11/16 19:07, Michal Hocko wrote:
> On Wed 23-11-16 18:50:42, Balbir Singh wrote:
>>
>>
>> On 23/11/16 18:25, Michal Hocko wrote:
>>> On Wed 23-11-16 15:36:51, Balbir Singh wrote:
>>>> In the absence of hotplug we use extra memory proportional to
>>>> (possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
>>>> to disable large consumption with large number of cgroups. This patch
>>>> adds hotplug support to memory cgroups and reverts the commit that
>>>> limited possible nodes to online nodes.
>>>
>>> Balbir,
>>> I have asked this in the previous version but there still seems to be a
>>> lack of information of _why_ do we want this, _how_ much do we save on
>>> the memory overhead on most systems and _why_ the additional complexity
>>> is really worth it. Please make sure to add all this in the cover
>>> letter.
>>>
>>
>> The data is in the patch referred to in patch 3. The order of waste was
>> 200MB for 400 cgroup directories enough for us to restrict possible_map
>> to online_map. These patches allow us to have a larger possible map and
>> allow onlining nodes not in the online_map, which is currently a restriction
>> on ppc64.
> 
> How common is to have possible_map >> online_map? If this is ppc64 then
> what is the downside of keeping the current restriction instead?
> 

On my system CONFIG_NODE_SHIFT is 8, 256 nodes and possible_nodes are 2
The downside is the ability to hotplug and online an offline node.
Please see http://www.spinics.net/lists/linux-mm/msg116724.html

>> A typical system that I use has about 100-150 directories, depending on the
>> number of users/docker instances/configuration/virtual machines. These numbers
>> will only grow as we pack more of these instances on them.
>>
>> From a complexity view point, the patches are quite straight forward.
> 
> Well, I would like to hear more about that. {get,put}_online_memory
> at random places doesn't sound all that straightforward to me.
> 

I thought those places were not random :) I tried to think them out as
discussed with Vladimir. I don't claim the code is bug free, we can fix
any bugs as we test this more.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
