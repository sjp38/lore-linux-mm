Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 49A226B02A5
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 20:43:37 -0400 (EDT)
Message-ID: <4C649535.8050800@goop.org>
Date: Thu, 12 Aug 2010 17:43:33 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] GSoC 2010 - Memory hotplug support for Xen guests - third
 fully working version
References: <20100812012224.GA16479@router-fw-old.local.net-space.pl>
In-Reply-To: <20100812012224.GA16479@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daniel Kiper <dkiper@net-space.pl>
Cc: konrad.wilk@oracle.com, stefano.stabellini@eu.citrix.com, linux-mm@kvack.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, v.tolstov@selfip.ru
List-ID: <linux-mm.kvack.org>

  On 08/11/2010 06:22 PM, Daniel Kiper wrote:
>> Overall, this looks much better.  The next step is to split this into at
>> least two patches: one for the core code, and one for the Xen bits.
>> Each patch should do just one logical operation, so if you have several
>> distinct changes to the core code, put them in separate patches.
> I will do that if this patch will be accepted.

First step is to post it to lkml for discussion, cc:ing the relevant 
maintainers. (I'm not really sure who that is at the moment.  It will 
take some digging around in the history.)

>>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>>> index 38434da..beb1aa7 100644
>>> --- a/arch/x86/Kconfig
>>> +++ b/arch/x86/Kconfig
>>> @@ -1273,7 +1273,7 @@ config ARCH_SELECT_MEMORY_MODEL
>>>   	depends on ARCH_SPARSEMEM_ENABLE
>>>
>>>   config ARCH_MEMORY_PROBE
>>> -	def_bool y
>>> +	def_bool X86_64&&   !XEN
>>>   	depends on MEMORY_HOTPLUG
>> The trouble with making anything statically depend on Xen at config time
>> is that you lose it even if you're not running under Xen.  A pvops
>> kernel can run on bare hardware as well, and we don't want to lose
>> functionality (assume that CONFIG_XEN is always set, since distros do
>> always set it).
>>
>> Can you find a clean way to prevent/disable ARCH_MEMORY_PROBE at runtime
>> when in a Xen context?
> There is no simple way to do that. It requiers to do some
> changes in drivers/base/memory.c code. I think it should
> be done as kernel boot option (on by default to not break
> things using this interface now). If it be useful for maintainers
> of mm/memory_hotplug.c and drivers/base/memory.c code then
> I could do that. Currently original arch/x86/Kconfig version
> is restored.

I think adding a global flag which the Xen balloon driver can disable 
should be sufficient.  There's no need to make an separate user-settable 
control.

>>> +/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG
>>> */
>>> +static int __ref xen_add_memory(int nid, u64 start, u64 size)
>> Could this be __meminit too then?
> Good question. I looked throught the code and could
> not find any simple explanation why mm/memory_hotplug.c
> authors used __ref instead __meminit. Could you (mm/memory_hotplug.c
> authors/maintainers) tell us why ???

Quite possibly a left-over from something else.  You could just try 
making it __meminit, then compile with, erm, the option which shows you 
section conflicts (it shows the number of conflicts at the end of the 
kernel build by default, and tells you how to explicitly list them).

>>> +{
>>> +	pg_data_t *pgdat = NULL;
>>> +	int new_pgdat = 0, ret;
>>> +
>>> +	lock_system_sleep();
>> What's this for?  I see all its other users are in the memory hotplug
>> code, but presumably they're concerned about a real S3 suspend.  Do we
>> care about that here?
> Yes, because as I know S3 state is supported by Xen guests.

Yes, but I'm assuming the interaction between S3 and ACPI hotplug memory 
isn't something that concerns a Xen guest; our hotplug mechanism is 
completely different.

>>> +		r->name = "System RAM";
>> How about making it clear its Xen hotplug RAM?  Or do things care about
>> the "System RAM" name?
> As I know no however as I saw anybody do not differentiate between
> normal and hotplugged memory. I thought about that ealier however
> stated that this soultion does not give us any real gain. That is why
> I decided to use standard name for hotplugged memory.

Its cosmetic, but it would be useful to see what's going on.

I'll send more detailed comments on the whole patch in a separate mail.

     J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
