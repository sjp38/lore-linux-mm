Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A5AC56B3F3C
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 20:44:55 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y35so8453171edb.5
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 17:44:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7-v6sor13684508eju.37.2018.11.25.17.44.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Nov 2018 17:44:53 -0800 (PST)
Date: Mon, 26 Nov 2018 01:44:51 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
Message-ID: <20181126014451.grrdei2luujiqwrh@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181122101241.7965-1-richard.weiyang@gmail.com>
 <18088694-22c8-b09b-f500-4932b6199004@redhat.com>
 <20181123084201.GA8625@dhcp22.suse.cz>
 <ca7d2320-6263-f213-d064-b5dc404bfa07@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ca7d2320-6263-f213-d064-b5dc404bfa07@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Nov 23, 2018 at 09:46:52AM +0100, David Hildenbrand wrote:
>On 23.11.18 09:42, Michal Hocko wrote:
>> On Thu 22-11-18 16:26:40, David Hildenbrand wrote:
>>> On 22.11.18 11:12, Wei Yang wrote:
>>>> During online_pages phase, pgdat->nr_zones will be updated in case this
>>>> zone is empty.
>>>>
>>>> Currently the online_pages phase is protected by the global lock
>>>> mem_hotplug_begin(), which ensures there is no contention during the
>>>> update of nr_zones. But this global lock introduces scalability issues.
>>>>
>>>> This patch is a preparation for removing the global lock during
>>>> online_pages phase. Also this patch changes the documentation of
>>>> node_size_lock to include the protectioin of nr_zones.
>>>
>>> I looked into locking recently, and there is more to it.
>>>
>>> Please read:
>>>
>>> commit dee6da22efac451d361f5224a60be2796d847b51
>>> Author: David Hildenbrand <david@redhat.com>
>>> Date:   Tue Oct 30 15:10:44 2018 -0700
>>>
>>>     memory-hotplug.rst: add some details about locking internals
>>>     
>>>     Let's document the magic a bit, especially why device_hotplug_lock is
>>>     required when adding/removing memory and how it all play together with
>>>     requests to online/offline memory from user space.
>>>
>>> Short summary: Onlining/offlining of memory requires the device_hotplug_lock
>>> as of now.
>> 
>> Well, I would tend to disagree here. You might be describing the current
>> state of art but the device_hotplug_lock doesn't make much sense for the
>> memory hotplug in principle. There is absolutely nothing in the core MM
>
>There are collisions with CPU hotplug that require this lock (when nodes
>come and go as far as I remember). And there is the problematic lock
>inversion that can happen when adding/remving memory. This all has to be
>sorted out, we'll have to see if we really need it for
>onlining/offlining, though, however ...
>

Seems I get a little understanding on this part.

There are two hotplug:
   * CPU hotplug 
   * Memory hotplug.

There are two phase for Memory hotplug:
   * physical add/remove 
   * logical online/offline

All of them are protected by device_hotplug_lock now, so we need to be
careful to release this in any case. Is my understanding correct?

>> that would require this lock. The current state just uses a BKL in some
>> sense and we really want to get rid of that longterm. This patch is a tiny
>> step in that direction and I suspect many more will need to come on the
>> way. We really want to end up with a clear scope of each lock being
>> taken. A project for a brave soul...
>
>... for now I don't consider "optimize for parallel
>onlining/offlining/adding/removing of memory and cpus" really necessary.
>What is necessary indeed is to not slowdown the whole system just
>because some memory is coming/going. Therefore I agree, this patch is a
>step into the right direction.
>

Agree.

The target is to accelerate the hot-plug without slow down the normal
process. 

>-- 
>
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me
