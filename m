Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5533F680FD0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 21:03:12 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so162801105pfx.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 18:03:12 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id r2si2192622plj.78.2017.02.14.18.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 18:03:11 -0800 (PST)
Subject: Re: [PATCH V2 1/3] mm: Define coherent device memory (CDM) node
References: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
 <20170210100640.26927-2-khandual@linux.vnet.ibm.com>
 <1c183237-d1f0-4fc3-cf5b-73fdfb9cb342@nvidia.com>
 <84c30cfe-d507-9756-8a7d-0d630476ae69@linux.vnet.ibm.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <a8a48e92-c70f-661b-a86a-8cc35694d943@nvidia.com>
Date: Tue, 14 Feb 2017 18:00:43 -0800
MIME-Version: 1.0
In-Reply-To: <84c30cfe-d507-9756-8a7d-0d630476ae69@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com


>>
>> Hi Anshuman,
>>
>> I'd question the need to avoid kernel allocations in device memory.
>> Maybe we should simply allow these pages to *potentially* participate in
>> everything that N_MEMORY pages do: huge pages, kernel allocations, for
>> example.
>
> No, allowing kernel allocations on CDM has two problems.
>
> * Kernel data structure should not go and be on CDM which is specialized
>   and may not be as reliable and may not have the same latency as that of
>   system RAM.
>
> * It prevents seamless hot plugging of CDM node in and out of kernel
>
>>
>> There is a bit too much emphasis being placed on the idea that these
>> devices are less reliable than system memory. It's true--they are less
>> reliable. However, they are reliable enough to be allowed direct
>> (coherent) addressing. And anything that allows that, is, IMHO, good
>> enough to allow all allocations on it.
>
> User space allocation not kernel at this point. Kernel is exposed to the
> unreliability while accessing it coherently but not being on it. There
> is a difference in the magnitude of risk and its mitigation afterwards.
>
>>
>> On the point of what reliability implies: I've been involved in the
>> development (and debugging) of similar systems over the years, and what
>> happens is: if the device has a fatal error, you have to take the
>> computer down, some time in the near future. There are a few reasons for
>> this:
>>
>>    -- sometimes the MCE (machine check) is wired up to fire, if the
>> device has errors, in which case you are all done very quickly. :)
>
> We can still handle MCE right now that may just involve killing the user
> application accessing given memory and the kernel can still continue
> running uninterrupted.
>
>>
>>    -- other times, the operating system relied upon now-corrupted data,
>> that came from the device. So even if you claim "OK, the device has a
>> fatal error, but the OS can continue running just fine", that's just
>> wrong! You may have corrupted something important.
>
> No, all that kernel facilitate is migration right now where it will access
> the CDM memory during which it can still crash if there is a memory error
> on CDM (which can be mitigated without crashing the kernel) but it does
> not depend on the content of memory which might have been corrupted by now.
>
>>
>>    -- even if the above two didn't get you, you still have a likely
>> expensive computer that cannot do what you bought it for, so you've got
>> to shut it down and replace the failed device.
>
> I am afraid that is not a valid kernel design goal :) But more likely the
> driver of the device can hot plug it out, repair it and plug it back on.
>
>>
>> Given all that, I think it is not especially worthwhile to design in a
>> lot of constraints and limitations around coherent device memory.
>
> I disagree on this because of all the points explained above.
>

Your points about hot plug (and latency, which we can't easily address yet) seem good, so I can 
accept the constraint of "no kernel allocations landing in CDM memory". OK.


>>
>> As for speed, we should be able to put in some hints to help with page
>> placement. I'm still coming up to speed with what is already there, and
>> I'm sure other people can comment on that.
>>
>> We should probably just let the allocations happen.
>>
>>
>>> To implement the integration as well as isolation, the coherent memory
>>> node
>>> must be present in N_MEMORY and a new N_COHERENT_DEVICE node mask inside
>>> the node_states[] array. During memory hotplug operations, the new
>>> nodemask
>>> N_COHERENT_DEVICE is updated along with N_MEMORY for these coherent
>>> device
>>> memory nodes. This also creates the following new sysfs based
>>> interface to
>>> list down all the coherent memory nodes of the system.
>>>
>>>     /sys/devices/system/node/is_coherent_node
>>
>> The naming bothers me: all nodes are coherent already. In fact, the
>> Coherent Device Memory naming is a little off-base already: what is it
>> *really* trying to say? Less reliable? Slower? My-special-device? :)
>
> I can change the above interface file to "is_cdm_node" to make it more
> on track. CDM conveys the fact that its a on device memory which is
> coherent not same as system RAM. This can also accommodate special memory
> which might be on the chip and but not same as system RAM.

"is_cdm_node" seems better to me, yes.

>
>> Will those things even always be true?  Makes me question the whole CDM
>> concept. Maybe just ZONE_MOVABLE (to handle hotplug) is the way to go.
>
> If you think any device memory which does not fit the description mentioned
> for a CDM memory, yes it can be plugged in as ZONE_MOVABLE into the kernel.
> CDM framework applies for device memory which fits the description as
> intended and explained.

OK, so you are planning on registering the CDM memory into ZONE_MOVABLE, that makes sense now. 
(Somehow I thought ZONE_MOVABLE was being left out.)

>
>>> +#ifdef CONFIG_COHERENT_DEVICE
>>> +inline int arch_check_node_cdm(int nid)
>>> +{
>>> +    return 0;
>>> +}
>>> +#endif
>>
>> I'm not sure that we really need this exact sort of arch_ check. Seems
>> like most arches could simply support the possibility of a CDM node.
>
> No, this will be a feature supported by few architectures for now. But the
> main reason to make this an arch specific call because only the architecture
> can detect which nodes are CDM looking into the platform information such as
> ACPI table, DT etc and we dont want that kind of detection to be performed
> from the generic MM code.
>
>>
>> But we can probably table that question until we ensure that we want a
>> new NUMA node type (vs. ZONE_MOVABLE).
>
> Not sure whether I got this but we want the new NUMA type for isolation
> purpose.

That's OK, I see how you want to do it now.

>
>>
>>> @@ -6392,8 +6394,10 @@ void __init free_area_init_nodes(unsigned long
>>> *max_zone_pfn)
>>>                  find_min_pfn_for_node(nid), NULL);
>>>
>>>          /* Any memory on that node */
>>> -        if (pgdat->node_present_pages)
>>> +        if (pgdat->node_present_pages) {
>>> +            node_set_state_cdm(nid);
>>>              node_set_state(nid, N_MEMORY);
>>
>>
>> I like that you provide clean wrapper functions, but air-dropping them
>> into all these routines (none of the other node types have to do this)
>> makes it look like CDM is sort of hacked in. :)
>
> Yeah and thats special casing CDM under a config option. These updates are
> required to make CDM nodes identifiable inside the kernel.

It's a minor point, but doing this sort of hides what is going on (does node_set_state override 
node_set_state_cdm, for example?).

So, seeing as how you still need to call into the arch layer to decide...maybe something like:

     node_arch_set_if_cdm(nid, N_COHERENT_DEVICE);

...although I realize N_COHERENT_DEVICE is not defined if not configured (but neither is N_MEMORY), 
so that needs to be handled.

thanks
john h

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
