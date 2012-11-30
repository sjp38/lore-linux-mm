Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id EF8656B0078
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 22:00:53 -0500 (EST)
Message-ID: <50B82064.9000405@huawei.com>
Date: Fri, 30 Nov 2012 10:56:36 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <50B5CFAE.80103@huawei.com> <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com> <50B68467.5020008@zytor.com> <20121129110045.GX8218@suse.de>
In-Reply-To: <20121129110045.GX8218@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, "Luck, Tony" <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

Hi Mel,
	Thanks for your great comments!

On 2012-11-29 19:00, Mel Gorman wrote:
> On Wed, Nov 28, 2012 at 01:38:47PM -0800, H. Peter Anvin wrote:
>> On 11/28/2012 01:34 PM, Luck, Tony wrote:
>>>>
>>>> 2. use boot option
>>>>   This is our proposal. New boot option can specify memory range to use
>>>>   as movable memory.
>>>
>>> Isn't this just moving the work to the user? To pick good values for the
>>> movable areas, they need to know how the memory lines up across
>>> node boundaries ... because they need to make sure to allow some
>>> non-movable memory allocations on each node so that the kernel can
>>> take advantage of node locality.
>>>
>>> So the user would have to read at least the SRAT table, and perhaps
>>> more, to figure out what to provide as arguments.
>>>
>>> Since this is going to be used on a dynamic system where nodes might
>>> be added an removed - the right values for these arguments might
>>> change from one boot to the next. So even if the user gets them right
>>> on day 1, a month later when a new node has been added, or a broken
>>> node removed the values would be stale.
>>>
>>
>> I gave this feedback in person at LCE: I consider the kernel
>> configuration option to be useless for anything other than debugging.
>> Trying to promote it as an actual solution, to be used by end users in
>> the field, is ridiculous at best.
>>
> 
> I've not been paying a whole pile of attention to this because it's not an
> area I'm active in but I agree that configuring ZONE_MOVABLE like
> this at boot-time is going to be problematic. As awkward as it is, it
> would probably work out better to only boot with one node by default and
> then hot-add the nodes at runtime using either an online sysfs file or
> an online-reserved file that hot-adds the memory to ZONE_MOVABLE. Still
> clumsy but better than specifying addresses on the command line.
> 
> That said, I also find using ZONE_MOVABLE to be a problem in itself that
> will cause problems down the road. Maybe this was discussed already but
> just in case I'll describe the problems I see.
> 
> If any significant percentage of memory is in ZONE_MOVABLE then the memory
> hotplug people will have to deal with all the lowmem/highmem problems
> that used to be faced by 32-bit x86 with PAE enabled. As a simple example,
> metadata intensive workloads will not be able to use all of memory because
> the kernel allocations will be confined to a subset of memory. A more
> complex example is that page table page allocations are also restricted
> meaning it's possible that a process will not even be able to mmap() a high
> percentage of memory simply because it cannot allocate the page tables to
> store the mappings. ZONE_MOVABLE works up to a *point*, but it's a hack. It
> was a hack when it was introduced but at least then the expectation was
> that ZONE_MOVABLE was going to be used for huge pages and there at least
> an expectation that it would not be available for normal usage.
> 
> Fundamentally the reason one would want to use ZONE_MOVABLE is because
> we cannot migrate a lot of kernel memory -- slab pages, page table pages,
> device-allocated buffers etc.  My understanding is that other OS's get around
> this by requiring that subsystems and drivers have callbacks that allow the
> core VM to force certain memory to be released but that may be impractical
> for Linux. I don't know for sure though, this is just what I heard.
As I know, one other OS limits immovable pages at low end, and the limit
will increase on demand. But the drawback of this solution is serious
performance drop (average about 10%) because it essentially disable NUMA
optimization for kernel/DMA memory allocations.

> For Linux, the hotplug people need to start thinking about how to get
> around this migration problem. The first problem faced is the memory model
> and how it maps virt->phys addresses. We have a 1:1 mapping because it's
> fast but not because it's a fundamental requirement. Start considering
> what happens if the memory model is changed to allow some sections to have
> fast lookup for virt_to_phys and other sections to have slow lookups. On
> hotplug, try and empty all the sections. If the section cannot be emptied
> because of kernel pages then the section gets marked as "offline-migrated"
> or something. Stop the whole machine (yes, I mean stop_machine), copy
> those unmovable pages to another location, update the kernel virt->phys
> mapping for the section being offlined so the virt addresses point to the
> new physical addresses and resume.  Virt->phys lookups are going to be
> a lot slower because a full section lookup will be necessary every time
> effectively breaking SPARSE_VMEMMAP and there will be a performance penalty
> but it should work. This will cover some slab pages where the data is only
> accessed via the virtual address -- inode caches, dcache etc.
> 
> It will not work where the physical address is used. The obvious example
> is page table pages. For page tables, during stop machine you will have to
> walk all processes page tables looking for references to the page you're
> trying to move and update them. It is possible to just plain migrate
> page table pages but when it was last implemented years ago there was a
> constant performance penalty for everybody and it was not popular.  Taking a
> heavy-handed approach just during memory hot-remove might be more palatable.
> 
> For the remaining pages such as those that have been handed to devices
> or are pinned for DMA then your options become more limited. You may
> still have to restrict allocating these pages (where possible) to a
> region that cannot be hot-removed but at least this will be relatively
> few pages.
> 
> The big downside of this proposal is that it's unproven, not designed,
> would be extremely intrusive and I expect it would be a *massive* amount
> of development effort that will be difficult to get right. The upside is
> configuring it will be a lot easier because all you'll need is a variation
> of kernelcore= to reserve a percentage of memory for allocations we *really*
> cannot migrate because the physical pages are owned by a device that cannot
> release them, potentially forever. The other upside is that it does not
> hit crazy lowmem/highmem style problems.
> 
> ZONE_MOVABLE at least will all a node to be removed very quickly but
> because it will paste you into a corner there should be a plan on what
> you're going to replace it with.

I have some thoughts here. The basic idea is that it needs cooperation
between OS, BIOS and hardware to implement a flexible memory hotplug
solution.

As you have mentioned, ZONE_MOVABLE is a quick but a little dirty
solution. It's quick because we could rely on existing mechanism
to configure movable zone and no changes to the memory model needed.
It's a little dirty because:
1) We need to handle cases of running out of immovable pages. The hotplug
implementation shouldn't cause extra service interruption when normal zones
are under pressure. Otherwise it's really a joke that some service
interruptions are really caused by features trying to improve service
availabilities.
2) We still can't handle normal kernel pages used by kernel, device etc.
3) It may cause serious performance drop if we configure all memory
on a NUMA node as ZONE_MOVABLE.

For the first issue, I think we could automatically convert pages
from movable zones into normal zones. Congyan from Fujitsu has provided
a patchset to manually convert pages from movable zones into normal zones,
I think we could extend that mechanism to automatically convert when
normal zones are under pressure by hooking into the slow page allocation
path.

We rely on hardware features to solve the second and third issues.
Some new platforms provide a new RAS feature called "hardware memory
migration", which transparent migrate memory from one memory device
to another. With hardware memory migration, we could configure one
memory device on a NUMA node to host normal zone, and the other memory
devices to host movable zone. By this configuration, it won't cause
performance drop because each NUMA node still has local normal zone.
When trying to remove a memory device hosting normal zone, we just
need to find another spare memory device and use hardware memory migration
to transparently migrate memory content to the spare one. The drawback
is we have strong dependency on hardware features so it's not a common
solution for all architectures.

Regards!
Gerry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
