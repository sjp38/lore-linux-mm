Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3926B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 12:31:05 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l9so5770162qtp.23
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:31:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c4si7670375qth.337.2018.04.13.09.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 09:31:03 -0700 (PDT)
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180413131632.1413-1-david@redhat.com>
 <20180413155917.GX17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <b51ca7a1-c5ae-fbbb-8edf-e71f383da07e@redhat.com>
Date: Fri, 13 Apr 2018 18:31:02 +0200
MIME-Version: 1.0
In-Reply-To: <20180413155917.GX17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On 13.04.2018 17:59, Michal Hocko wrote:
> On Fri 13-04-18 15:16:24, David Hildenbrand wrote:
> [...]
>> In contrast to existing balloon solutions:
>> - The device is responsible for its own memory only.
> 
> Please be more specific. Any ballooning driver is responsible for its
> own memory. So what exactly does that mean?

Simple example (virtio-balloon):

You boot Linux with 8GB. You hotplug two DIMM2 with 4GB each.
You use virtio-balloon to "unplug"(although it's not) 4GB. Memory will
be removed on *any* memory the allocator is willing to give away.

Now imagine you want to reboot and keep the 4GB unplugged by e.g.
resizing memory/DIMM. What to resize to how much? A DIMM? Two DIMMS?
Delete one DIMM and keep only one? Drop all DIMMs and resize the
initital memory? This makes implementation in the hypervisor extremely
hard (especially thinking about migration).

So a ballooning driver does not inflate on its device memory but simply
on *any* memory. That's why you only have one virtio-balloon device per
VM. It is basically "per machine", while paravirtualied memory devices
manage their assigned memory. Like a resizable DIMM, so to say.

> 
>> - Works on a coarser granularity (e.g. 4MB because that's what we can
>>   online/offline in Linux). We are not using the buddy allocator when unplugging
>>   but really search for chunks of memory we can offline.
> 
> Again, more details please. Virtio driver already tries to scan suitable
> pages to balloon AFAIK.
Virtio balloon simply uses alloc_page().

That's it. Also, if we wanted to alloc bigger chunks at a time, we would
be limited to MAX_ORDER - 1. But that's a different story.

One goal of paravirtualied memory is to be able to unplug more memory
than with simple DIMM devices (e.g. 2GB) without having it to online it
as MOVABLE. We don't want to squeeze the last little piece of memory out
if the system like a balloon driver does. So we *don't* want to go down
to a page level. If we can't unplug any bigger chunks anymore, we tried
our best and can't do anything about it.

That's why I don't like to call it a balloon. It is not meant to be used
for purposes an ordinary balloon is used (besides memory unplug) - like
reducing the size of the dcache or cooperative memory management
(meaning a high frequency of inflate and deflate).

> 
>> - A device can belong to exactly one NUMA node. This way we can online/offline
>>   memory in a fine granularity NUMA aware.
> 
> What does prevent existing balloon solutions to be NUMA aware?

They usually (e.g. virtio-balloon) only have one "target pages" goal
defined. Not per NUMA node. We could implement such a feature (with
quite some obstacles - e.g. what happens if NUMA nodes are merged in the
guest but the hypervisor wants to verify that memory is ballooned on the
right NUMA node?), but with paravirtualized memory devices it comes
"naturally" and "for free". You just request to resize a certain memory
device, that's it.

> 
>> - Architectures that don't have proper memory hotplug interfaces (e.g. s390x)
>>   get memory hotplug support. I have a prototype for s390x.
> 
> I am pretty sure that s390 does support memory hotplug. Or what do you
> mean?

There is no interface for s390x to tell it "hey, I just gave you another
DIMM/memory chunk, please online it" like we have on other
architectures. Such an interface does not exist. That's also the reason
why remove_memory() is not yet supported. All there is is standby memory
that Linux will simply add and try to online when booting up. Old
mainframe interfaces are different :)

You can read more about that here:

http://lists.gnu.org/archive/html/qemu-devel/2018-02/msg04951.html

> 
>> - Once all 4MB chunks of a memory block are offline, we can remove the
>>   memory block and therefore the struct pages (seems to work in my prototype),
>>   which is nice.
> 
> OK, so our existing ballooning solutions indeed do not free up memmaps
> which is suboptimal.

And we would have to hack deep into the current offlining code to make
it work (at least that's my understanding).

> 
>> Todo:
>> - We might have to add a parameter to offline_pages(), telling it to not
>>   try forever but abort in case it takes too long.
> 
> Offlining fails when it see non-migrateable pages but other than that it
> should always succeed in the finite time. If not then there is a bug to
> be fixed.

I just found the -EINTR in the offlining code and thought this might be
problematic. (e.g. if somebody pins a page that is still to be migrated
- or is that avoided by isolating?) I haven't managed to trigger this
scenario yet. Was just a thought, that's why I mentioned it but didn't
implement it.


-- 

Thanks,

David / dhildenb
