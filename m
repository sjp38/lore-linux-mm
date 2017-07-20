Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 066A16B0313
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:16:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s79so1703017wma.15
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 23:16:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v39si5560182wrb.306.2017.07.19.23.16.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 23:16:50 -0700 (PDT)
Subject: Re: [PATCH 7/9] mm, page_alloc: remove stop_machine from
 build_all_zonelists
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-8-mhocko@kernel.org>
 <52b1af9a-a5a9-9157-8f0f-f17946aeb2da@suse.cz>
 <20170714114321.GJ2618@dhcp22.suse.cz> <20170714114509.GK2618@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0d4c6dad-5a4f-fc67-d401-20e49805e773@suse.cz>
Date: Thu, 20 Jul 2017 08:16:49 +0200
MIME-Version: 1.0
In-Reply-To: <20170714114509.GK2618@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 07/14/2017 01:45 PM, Michal Hocko wrote:
> On Fri 14-07-17 13:43:21, Michal Hocko wrote:
>> On Fri 14-07-17 13:29:14, Vlastimil Babka wrote:
>>> On 07/14/2017 10:00 AM, Michal Hocko wrote:
>>>> From: Michal Hocko <mhocko@suse.com>
>>>>
>>>> build_all_zonelists has been (ab)using stop_machine to make sure that
>>>> zonelists do not change while somebody is looking at them. This is
>>>> is just a gross hack because a) it complicates the context from which
>>>> we can call build_all_zonelists (see 3f906ba23689 ("mm/memory-hotplug:
>>>> switch locking to a percpu rwsem")) and b) is is not really necessary
>>>> especially after "mm, page_alloc: simplify zonelist initialization".
>>>>
>>>> Updates of the zonelists happen very seldom, basically only when a zone
>>>> becomes populated during memory online or when it loses all the memory
>>>> during offline. A racing iteration over zonelists could either miss a
>>>> zone or try to work on one zone twice. Both of these are something we
>>>> can live with occasionally because there will always be at least one
>>>> zone visible so we are not likely to fail allocation too easily for
>>>> example.
>>>
>>> Given the experience with with cpusets and mempolicies, I would rather
>>> avoid the risk of allocation not seeing the only zone(s) that are
>>> allowed by its nodemask, and triggering premature OOM.
>>
>> I would argue, those are a different beast because they are directly
>> under control of not fully priviledged user and change between the empty
>> nodemask and cpusets very often. For this one to trigger we
>> would have to online/offline the last memory block in the zone very
>> often and that doesn't resemble a sensible usecase even remotely.

OK.

>>> So maybe the
>>> updates could be done in a way to avoid that, e.g. first append a copy
>>> of the old zonelist to the end, then overwrite and terminate with NULL.
>>> But if this requires any barriers or something similar on the iteration
>>> site, which is performance critical, then it's bad.
>>> Maybe a seqcount, that the iteration side only starts checking in the
>>> slowpath? Like we have with cpusets now.
>>> I know that Mel noted that stop_machine() also never had such guarantees
>>> to prevent this, but it could have made the chances smaller.
>>
>> I think we can come up with some scheme but is this really worth it
>> considering how unlikely the whole thing is? Well, if somebody hits a
>> premature OOM killer or allocations failures it would have to be along
>> with a heavy memory hotplug operations and then it would be quite easy
>> to spot what is going on and try to fix it. I would rather not
>> overcomplicate it, to be honest.

Fine, we can always add it later.

> And one more thing, Mel has already brought this up in his response.
> stop_machine haven't is very roughly same strenght wrt. double zone
> visit or a missed zone because we do not restart zonelist iteration.

I know, that's why I wrote "I know that Mel noted that stop_machine()
also never had such guarantees to prevent this, but it could have made
the chances smaller." But I don't have any good proof that your patch is
indeed making things worse, so let's apply and see...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
