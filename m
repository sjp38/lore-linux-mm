Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 337ED6B0206
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:33:09 -0400 (EDT)
Message-ID: <4C758C12.2020107@goop.org>
Date: Wed, 25 Aug 2010 14:33:06 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] GSoC 2010 - Memory hotplug support for Xen guests - third
 fully working version
References: <20100812012224.GA16479@router-fw-old.local.net-space.pl> <4C649535.8050800@goop.org> <20100816154444.GA28219@router-fw-old.local.net-space.pl>
In-Reply-To: <20100816154444.GA28219@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daniel Kiper <dkiper@net-space.pl>
Cc: konrad.wilk@oracle.com, stefano.stabellini@eu.citrix.com, linux-mm@kvack.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, v.tolstov@selfip.ru, Dulloor <dulloor@gmail.com>
List-ID: <linux-mm.kvack.org>

 On 08/16/2010 08:44 AM, Daniel Kiper wrote:
> Hi,
>
> On Thu, Aug 12, 2010 at 05:43:33PM -0700, Jeremy Fitzhardinge wrote:
>>  On 08/11/2010 06:22 PM, Daniel Kiper wrote:
>>>> Overall, this looks much better.  The next step is to split this into at
>>>> least two patches: one for the core code, and one for the Xen bits.
>>>> Each patch should do just one logical operation, so if you have several
>>>> distinct changes to the core code, put them in separate patches.
>>> I will do that if this patch will be accepted.
>> First step is to post it to lkml for discussion, cc:ing the relevant
>> maintainers. (I'm not really sure who that is at the moment.  It will
>> take some digging around in the history.)
> I took all relevant addresses (sorry if I missed somebody) from MAINTAINERS
> file and they are in To in most of e-mails from me.

Unfortunately MAINTAINERS is often poorly maintained.  While you should
include those addresses, its also worth looking at the git history to
see who has been active in that area recently.

>>>> Can you find a clean way to prevent/disable ARCH_MEMORY_PROBE at runtime
>>>> when in a Xen context?
>>> There is no simple way to do that. It requiers to do some
>>> changes in drivers/base/memory.c code. I think it should
>>> be done as kernel boot option (on by default to not break
>>> things using this interface now). If it be useful for maintainers
>>> of mm/memory_hotplug.c and drivers/base/memory.c code then
>>> I could do that. Currently original arch/x86/Kconfig version
>>> is restored.
>> I think adding a global flag which the Xen balloon driver can disable
>> should be sufficient.  There's no need to make an separate user-settable
>> control.
> OK.
>
>>>>> +/* we are OK calling __meminit stuff here - we have
>>>>> CONFIG_MEMORY_HOTPLUG
>>>>> */
>>>>> +static int __ref xen_add_memory(int nid, u64 start, u64 size)
>>>> Could this be __meminit too then?
>>> Good question. I looked throught the code and could
>>> not find any simple explanation why mm/memory_hotplug.c
>>> authors used __ref instead __meminit. Could you (mm/memory_hotplug.c
>>> authors/maintainers) tell us why ???
>> Quite possibly a left-over from something else.  You could just try
>> making it __meminit, then compile with, erm, the option which shows you
>> section conflicts (it shows the number of conflicts at the end of the
>> kernel build by default, and tells you how to explicitly list them).
> Small reminder: make CONFIG_DEBUG_SECTION_MISMATCH=y
>
> I reviewed kernel source code once again. It is OK. Normaly it is
> not allowed to reference code/data tagged as .init.* because
> that sections are freed at the end of kernel boot sequence and
> they do not exists any more in memory. However it is sometimes
> required to use code/data marked .init.*. To allow that __ref
> tag is used and then referenced objects are not removed from
> memory (and no warnings are displayed during kernel compilation).
>
>>>> What's this for?  I see all its other users are in the memory hotplug
>>>> code, but presumably they're concerned about a real S3 suspend.  Do we
>>>> care about that here?
>>> Yes, because as I know S3 state is supported by Xen guests.
>> Yes, but I'm assuming the interaction between S3 and ACPI hotplug memory
>> isn't something that concerns a Xen guest; our hotplug mechanism is
>> completely different.
> Suspend/Hibernation code in Linux Kernel is platform independent
> to some extent and it does not require ACPI. It means that
> lock_system_sleep/unlock_system_sleep is required in that
> place to have memory state intact during suspend/hibernation.

My question is more along the lines of whether there's an *inherent*
dependency/interaction between suspend/hibernate and hotplug memory, or
whether the interaction is a side-effect of the x86 implementation.

But it doesn't really matter either way for our purposes.

>>>>> +		r->name = "System RAM";
>>>> How about making it clear its Xen hotplug RAM?  Or do things care about
>>>> the "System RAM" name?
>>> As I know no however as I saw anybody do not differentiate between
>>> normal and hotplugged memory. I thought about that ealier however
>>> stated that this soultion does not give us any real gain. That is why
>>> I decided to use standard name for hotplugged memory.
>> Its cosmetic, but it would be useful to see what's going on.
> If you wish I will do that, however then it should be changed
> as well add_registered_memory() function syntax. It should
> contain pointer to name published through /sys/firmware/memmap
> interface. I am not sure it is good solution to change
> add_registered_memory() function syntax which I think should be
> same as add_memory() function syntax.

OK, fair enough.

>>> +#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG + unsigned long
>>> boot_max_pfn; + u64 hotplug_start_paddr; + u64 hotplug_size;
>> So does this mean you only support adding a single hotplug region?  What
>> happens if your initial increase wasn't enough and you want to add
>> more?  Would you make this a list of hot-added memory or something?
>>
>> But I'm not even quite sure why you need to keep this as global data.
> No. It supports multiple allocations. This variables are
> used mostly for communication between allocate_additional_memory
> and hotplug_allocated_memory functions.

Using globals to communicate values between two functions is not
generally good practice.  Could the code be restructured to avoid it (by
passing them as parameters, for example)?


>>> + else if (is_memory_resource_reserved()) + hotplug_allocated_memory();
>> Why can't this be done in allocate_additional_memory()?
> Because memory is allocated in relatively small
> batches and then whole memory is hotplugged.

Is the batch allocation just to avoid having a single great big piece,
or is there some other deeper reason?  If not, I don't see why that
detail can't be hidden in an inner loop.

> Here is current algorithm:
>   - allocate_resource() with size requested by user,
>   - allocate memory in relatively small batches,
>   - add_registered_memory(),
>   - online_pages(),
>   - update /sys/devices/system/memory/memory*/state files.

That's OK as far as it goes, but I do tend to see memory hotplug as an
underlying implementation detail rather than something that should be
directly exposed to users (ie memory hotplug as the mechanism to allow
ballooning to expand beyond the initial domain size).

>> The tricky part is making sure that the memory for the page structures
>> has been populated so it can be used.  Aside from that, there should be
>> no need to have another call to
>> HYPERVISOR_memory_op(XENMEM_populate_physmap, ...) aside from the
>> existing one.
> Currently it is.
>
>> 2 requires a deeper understanding of the existing hotplug code.  It
>> needs to be refactored so that you can use the core hotplug machinery
>> without enabling the sysfs page-onlining mechanism, while still leaving
>> it available for physical hotplug.  In the short term, having a boolean
>> to disable the onlining mechanism is probably the pragmatic solution, so
>> the balloon code can simply disable it.
> I think that sysfs should stay intact because it contains some
> useful information for admins. We should reconsider avaibilty
> of /sys/devices/system/memory/probe. In physical systems it
> is available however usage without real hotplug support
> lead to big crash. I am not sure we should disable probe in Xen.
> Maybe it is better to stay in sync with standard behavior.
> Second solution is to prepare an interface (kernel option
> or only some enable/disable functions) which give possibilty
> to enable/disable probe interface when it is required.

My understanding is that on systems with real physical hotplug memory,
the process is:

   1. you insert/enable a DIMM or whatever to make the memory
      electrically active
   2. the kernel notices this and generates a udev event
   3. a usermode script sees this and, according to whatever policy it
      wants to implement, choose to online the memory at some point

I'm concerned that if we partially implement this but leave "online" as
a timebomb then existing installs with hotplug scripts in place may poke
at it - thinking they're dealing with physical hotplug - and cause problems.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
