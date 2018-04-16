Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFC156B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:08:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id i4so13242595wrh.4
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 07:08:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s10si1298533edc.383.2018.04.16.07.08.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 07:08:11 -0700 (PDT)
Date: Mon, 16 Apr 2018 16:08:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180416140810.GR17484@dhcp22.suse.cz>
References: <20180413131632.1413-1-david@redhat.com>
 <20180413155917.GX17484@dhcp22.suse.cz>
 <b51ca7a1-c5ae-fbbb-8edf-e71f383da07e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b51ca7a1-c5ae-fbbb-8edf-e71f383da07e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org

On Fri 13-04-18 18:31:02, David Hildenbrand wrote:
> On 13.04.2018 17:59, Michal Hocko wrote:
> > On Fri 13-04-18 15:16:24, David Hildenbrand wrote:
> > [...]
> >> In contrast to existing balloon solutions:
> >> - The device is responsible for its own memory only.
> > 
> > Please be more specific. Any ballooning driver is responsible for its
> > own memory. So what exactly does that mean?
> 
> Simple example (virtio-balloon):
> 
> You boot Linux with 8GB. You hotplug two DIMM2 with 4GB each.
> You use virtio-balloon to "unplug"(although it's not) 4GB. Memory will
> be removed on *any* memory the allocator is willing to give away.
> 
> Now imagine you want to reboot and keep the 4GB unplugged by e.g.
> resizing memory/DIMM. What to resize to how much? A DIMM? Two DIMMS?
> Delete one DIMM and keep only one? Drop all DIMMs and resize the
> initital memory? This makes implementation in the hypervisor extremely
> hard (especially thinking about migration).

I do not follow. Why does this even matter in the virtualized env.?

> So a ballooning driver does not inflate on its device memory but simply
> on *any* memory. That's why you only have one virtio-balloon device per
> VM. It is basically "per machine", while paravirtualied memory devices
> manage their assigned memory. Like a resizable DIMM, so to say.
> 
> > 
> >> - Works on a coarser granularity (e.g. 4MB because that's what we can
> >>   online/offline in Linux). We are not using the buddy allocator when unplugging
> >>   but really search for chunks of memory we can offline.
> > 
> > Again, more details please. Virtio driver already tries to scan suitable
> > pages to balloon AFAIK.
> Virtio balloon simply uses alloc_page().
> 
> That's it. Also, if we wanted to alloc bigger chunks at a time, we would
> be limited to MAX_ORDER - 1. But that's a different story.

Not really, we do have means to do a pfn walk and then try to isolate
pages one-by-one. Have a look at http://lkml.kernel.org/r/1523017045-18315-1-git-send-email-wei.w.wang@intel.com

> One goal of paravirtualied memory is to be able to unplug more memory
> than with simple DIMM devices (e.g. 2GB) without having it to online it
> as MOVABLE.

I am not sure I understand but any hotplug based solution without
handling that memory on ZONE_MOVABLE is a lost bettle. It is simply
usable only to hotadd memory. Shrinking it back will most likely fail on
many workloads.

> We don't want to squeeze the last little piece of memory out
> if the system like a balloon driver does. So we *don't* want to go down
> to a page level. If we can't unplug any bigger chunks anymore, we tried
> our best and can't do anything about it.
> 
> That's why I don't like to call it a balloon. It is not meant to be used
> for purposes an ordinary balloon is used (besides memory unplug) - like
> reducing the size of the dcache or cooperative memory management
> (meaning a high frequency of inflate and deflate).

OK, so what is the typical usecase? And how does the usual setup looks
like?

> >> - A device can belong to exactly one NUMA node. This way we can online/offline
> >>   memory in a fine granularity NUMA aware.
> > 
> > What does prevent existing balloon solutions to be NUMA aware?
> 
> They usually (e.g. virtio-balloon) only have one "target pages" goal
> defined. Not per NUMA node. We could implement such a feature (with
> quite some obstacles - e.g. what happens if NUMA nodes are merged in the
> guest but the hypervisor wants to verify that memory is ballooned on the
> right NUMA node?), but with paravirtualized memory devices it comes
> "naturally" and "for free". You just request to resize a certain memory
> device, that's it.

I do not follow. I expected that gues NUMA topology matches the host one
or it is a subset. So both ends should know which memory to
{in,de}flate. Maybe I am just to naive because I am not familiar with
any ballooning implementation much.

> >> - Architectures that don't have proper memory hotplug interfaces (e.g. s390x)
> >>   get memory hotplug support. I have a prototype for s390x.
> > 
> > I am pretty sure that s390 does support memory hotplug. Or what do you
> > mean?
> 
> There is no interface for s390x to tell it "hey, I just gave you another
> DIMM/memory chunk, please online it" like we have on other
> architectures. Such an interface does not exist. That's also the reason
> why remove_memory() is not yet supported. All there is is standby memory
> that Linux will simply add and try to online when booting up. Old
> mainframe interfaces are different :)
> 
> You can read more about that here:
> 
> http://lists.gnu.org/archive/html/qemu-devel/2018-02/msg04951.html

Thanks for the pointer

> >> - Once all 4MB chunks of a memory block are offline, we can remove the
> >>   memory block and therefore the struct pages (seems to work in my prototype),
> >>   which is nice.
> > 
> > OK, so our existing ballooning solutions indeed do not free up memmaps
> > which is suboptimal.
> 
> And we would have to hack deep into the current offlining code to make
> it work (at least that's my understanding).
> 
> > 
> >> Todo:
> >> - We might have to add a parameter to offline_pages(), telling it to not
> >>   try forever but abort in case it takes too long.
> > 
> > Offlining fails when it see non-migrateable pages but other than that it
> > should always succeed in the finite time. If not then there is a bug to
> > be fixed.
> 
> I just found the -EINTR in the offlining code and thought this might be
> problematic. (e.g. if somebody pins a page that is still to be migrated
> - or is that avoided by isolating?) I haven't managed to trigger this
> scenario yet. Was just a thought, that's why I mentioned it but didn't
> implement it.

Offlining is a 3 stage thing. Check for unmovable pages and fail with
EBUSY, isolating free memory and migrating the rest. If the first 2
succeed we expect the migration will finish in a finite time. 
-- 
Michal Hocko
SUSE Labs
