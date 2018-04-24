Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0F36B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 11:13:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e14so13410507pfi.9
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:13:27 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id t2-v6si13947715plo.235.2018.04.24.08.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 08:13:25 -0700 (PDT)
Message-ID: <5ADF498C.1@windriver.com>
Date: Tue, 24 Apr 2018 11:13:16 -0400
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
Subject: Re: per-NUMA memory limits in mem cgroup?
References: <5ADA26AB.6080209@windriver.com> <20180422124648.GD17484@dhcp22.suse.cz> <5ADDFBD1.7010009@windriver.com> <20180424132721.GF17484@dhcp22.suse.cz>
In-Reply-To: <20180424132721.GF17484@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 04/24/2018 09:27 AM, Michal Hocko wrote:
> On Mon 23-04-18 11:29:21, Chris Friesen wrote:
>> On 04/22/2018 08:46 AM, Michal Hocko wrote:
>>> On Fri 20-04-18 11:43:07, Chris Friesen wrote:
>>
>>>> The specific scenario I'm considering is that of a hypervisor host.  I have
>>>> system management stuff running on the host that may need more than one
>>>> core, and currently these host tasks might be affined to cores from multiple
>>>> NUMA nodes.  I'd like to put a cap on how much memory the host tasks can
>>>> allocate from each NUMA node in order to ensure that there is a guaranteed
>>>> amount of memory available for VMs on each NUMA node.
>>>>
>>>> Is this possible, or are the knobs just not there?
>>>
>>> Not possible right now. What would be the policy when you reach the
>>> limit on one node? Fallback to other nodes? What if those hit the limit
>>> as well? OOM killer or an allocation failure?
>>
>> I'd envision it working exactly the same as the current memory cgroup, but
>> with the ability to specify optional per-NUMA-node limits in addition to
>> system-wide.
>
> OK, so you would have a per numa percentage of the hard limit?

I think it'd make more sense as a hard limit per NUMA node.

> But more
> importantly, note that the page allocation is done way before the charge
> so we do not have any control over where the memory get allocated from
> so we would have to play nasty tricks in the reclaim to somehow balance
> NUMA charge pools.

Reading the docs on the memory controller it does seem a bit tricky.  I had 
envisioned some sort of "is there memory left in this group" check before 
"approving" the memory allocation, but it seems it doesn't really work that way.

Chris
