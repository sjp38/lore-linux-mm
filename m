Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 318676B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:48:50 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u7so2282623qkk.17
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 07:48:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d26si944942qtf.195.2018.04.16.07.48.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 07:48:48 -0700 (PDT)
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180413131632.1413-1-david@redhat.com>
 <20180413155917.GX17484@dhcp22.suse.cz>
 <b51ca7a1-c5ae-fbbb-8edf-e71f383da07e@redhat.com>
 <20180416140810.GR17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <4376089c-a2fc-2e51-ed81-a1e8ab8b29bf@redhat.com>
Date: Mon, 16 Apr 2018 16:48:47 +0200
MIME-Version: 1.0
In-Reply-To: <20180416140810.GR17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On 16.04.2018 16:08, Michal Hocko wrote:
> On Fri 13-04-18 18:31:02, David Hildenbrand wrote:
>> On 13.04.2018 17:59, Michal Hocko wrote:
>>> On Fri 13-04-18 15:16:24, David Hildenbrand wrote:
>>> [...]
>>>> In contrast to existing balloon solutions:
>>>> - The device is responsible for its own memory only.
>>>
>>> Please be more specific. Any ballooning driver is responsible for its
>>> own memory. So what exactly does that mean?
>>
>> Simple example (virtio-balloon):
>>
>> You boot Linux with 8GB. You hotplug two DIMM2 with 4GB each.
>> You use virtio-balloon to "unplug"(although it's not) 4GB. Memory will
>> be removed on *any* memory the allocator is willing to give away.
>>
>> Now imagine you want to reboot and keep the 4GB unplugged by e.g.
>> resizing memory/DIMM. What to resize to how much? A DIMM? Two DIMMS?
>> Delete one DIMM and keep only one? Drop all DIMMs and resize the
>> initital memory? This makes implementation in the hypervisor extremely
>> hard (especially thinking about migration).
> 
> I do not follow. Why does this even matter in the virtualized env.?

Because we care about live migration of VMs? :)

No, honestly, we want to be able to provided as much flexibility when it
comes to re-sizing virtual machine memory. See below where you asked
about a use case.

Handling live migration and reboots is tricky when we have changing
resources (number/size of DIMMs etc.) automatically in the hypervisor.
This is the tip of the ice berg.

> 
>> So a ballooning driver does not inflate on its device memory but simply
>> on *any* memory. That's why you only have one virtio-balloon device per
>> VM. It is basically "per machine", while paravirtualied memory devices
>> manage their assigned memory. Like a resizable DIMM, so to say.
>>
>>>
>>>> - Works on a coarser granularity (e.g. 4MB because that's what we can
>>>>   online/offline in Linux). We are not using the buddy allocator when unplugging
>>>>   but really search for chunks of memory we can offline.
>>>
>>> Again, more details please. Virtio driver already tries to scan suitable
>>> pages to balloon AFAIK.
>> Virtio balloon simply uses alloc_page().
>>
>> That's it. Also, if we wanted to alloc bigger chunks at a time, we would
>> be limited to MAX_ORDER - 1. But that's a different story.
> 
> Not really, we do have means to do a pfn walk and then try to isolate
> pages one-by-one. Have a look at http://lkml.kernel.org/r/1523017045-18315-1-git-send-email-wei.w.wang@intel.com
> 

Yes, seen that work. I am talking about the current state. A lot of
things are theoretically possible (like removing struct pages for
current balloon implementations).

>> One goal of paravirtualied memory is to be able to unplug more memory
>> than with simple DIMM devices (e.g. 2GB) without having it to online it
>> as MOVABLE.
> 
> I am not sure I understand but any hotplug based solution without
> handling that memory on ZONE_MOVABLE is a lost bettle. It is simply
> usable only to hotadd memory. Shrinking it back will most likely fail on
> many workloads.

It will fail on some and succeed on some. hotadd is always more
important than hotremove. The smaller the chunks size, the more likely
hotremove will succeed. With big DIMMs, hotemove will most likely fail.
With 4MB chunks, less likely to fail. With 4k pages very unlikely to
fail. The smaller the chunks, the higher the memory fragmentation.

(but to come back to the ZONE thing, I was also thinking about auto
managing assignment to different ZONES (based on heuristics) to make
unplug work more reliably, but this is also stuff for the future). For
now I'd like to keep it simple.

> 
>> We don't want to squeeze the last little piece of memory out
>> if the system like a balloon driver does. So we *don't* want to go down
>> to a page level. If we can't unplug any bigger chunks anymore, we tried
>> our best and can't do anything about it.
>>
>> That's why I don't like to call it a balloon. It is not meant to be used
>> for purposes an ordinary balloon is used (besides memory unplug) - like
>> reducing the size of the dcache or cooperative memory management
>> (meaning a high frequency of inflate and deflate).
> 
> OK, so what is the typical usecase? And how does the usual setup looks
> like?

Typical use case:

Allow to resize virtual machine memory. Allow a customer/tooling to
add/remove memory on demand. Account in the hypervisor how much memory
is currently being used.

Typical set up:

- Initital boot memory: 4GB
- Memory device (NODE 0): 4GB, max size 128GB
- Memory device (NODE 1): 4GB, max size 128GB

Let the customer/tooling decide how much memory to give to the virtual
machine. Anything between 4GB and ~256GB is possible. (although, as you
mentioned, going back down to 4GB is very unlikely :) )

Most importantly:

- Don't have to deal with DIMMs
-- Which size to plug? (we have to know upfront how much we want to
   unplug to find the right size. But small DIMMs will not allow us to
   grow a VM reasonably large (number of DIMMs limited) )
-- How to online memory? MOVABLE?

- Don't have to deal with a mixture of DIMM and balloon
-- plugging with DIMM and unplugging with balloon is not what we want
   (struct pages, fragmentation, mentioned hypervisor implementation
    problems)

- Be able to add/remove memory to a guest in a finer granularity than
  > 128MB (e.g. 256MB for s390x but way more for other architectures)

> 
>>>> - A device can belong to exactly one NUMA node. This way we can online/offline
>>>>   memory in a fine granularity NUMA aware.
>>>
>>> What does prevent existing balloon solutions to be NUMA aware?
>>
>> They usually (e.g. virtio-balloon) only have one "target pages" goal
>> defined. Not per NUMA node. We could implement such a feature (with
>> quite some obstacles - e.g. what happens if NUMA nodes are merged in the
>> guest but the hypervisor wants to verify that memory is ballooned on the
>> right NUMA node?), but with paravirtualized memory devices it comes
>> "naturally" and "for free". You just request to resize a certain memory
>> device, that's it.
> 
> I do not follow. I expected that gues NUMA topology matches the host one
> or it is a subset. So both ends should know which memory to
> {in,de}flate. Maybe I am just to naive because I am not familiar with
> any ballooning implementation much.
> 

You are using the right word, "expecting". I don't like to expect things
that might not be true in real life. Imagine cloud environments where
people install their custom kernels. Turn NUMA on/off. Configure the
number of supported NUMA nodes. Many variations. And especially you
cannot trust your guest.

This is the main reason I think NUMA aware ballooning was never
implemented. If the hypervisor asks the guest to balloon on NODE 1, but
the guest balloons on NODE 0, you can't do much but tolerate it. But
that is not what you expected.

Long story short, what I am proposing simply works without having to
guess about setups.

[...]
>>>
>>>> Todo:
>>>> - We might have to add a parameter to offline_pages(), telling it to not
>>>>   try forever but abort in case it takes too long.
>>>
>>> Offlining fails when it see non-migrateable pages but other than that it
>>> should always succeed in the finite time. If not then there is a bug to
>>> be fixed.
>>
>> I just found the -EINTR in the offlining code and thought this might be
>> problematic. (e.g. if somebody pins a page that is still to be migrated
>> - or is that avoided by isolating?) I haven't managed to trigger this
>> scenario yet. Was just a thought, that's why I mentioned it but didn't
>> implement it.
> 
> Offlining is a 3 stage thing. Check for unmovable pages and fail with
> EBUSY, isolating free memory and migrating the rest. If the first 2
> succeed we expect the migration will finish in a finite time. 
> 

Thanks, good to know.


-- 

Thanks,

David / dhildenb
