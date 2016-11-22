Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C44F6B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:35:49 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so2481484wme.5
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 21:35:49 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ay9si23805195wjc.120.2016.11.21.21.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 21:35:47 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAM5ZHml017190
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:35:46 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26uyx4sj07-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 00:35:46 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 22 Nov 2016 15:35:43 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B88112CE8059
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 16:35:40 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAM5ZeC151904720
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 16:35:40 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAM5Zdiu028453
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 16:35:40 +1100
Subject: Re: [HMM v13 01/18] mm/memory/hotplug: convert device parameter bool
 to set of flags
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-2-git-send-email-jglisse@redhat.com>
 <5832972E.1050405@linux.vnet.ibm.com> <20161121122740.GB2392@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 22 Nov 2016 11:05:30 +0530
MIME-Version: 1.0
In-Reply-To: <20161121122740.GB2392@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Message-Id: <5833D922.1070900@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dan Williams <dan.j.williams@intel.com>

On 11/21/2016 05:57 PM, Jerome Glisse wrote:
> On Mon, Nov 21, 2016 at 12:11:50PM +0530, Anshuman Khandual wrote:
>> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
> 
> [...]
> 
>>> @@ -956,7 +963,7 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>>>  	remove_pagetable(start, end, true);
>>>  }
>>>  
>>> -int __ref arch_remove_memory(u64 start, u64 size)
>>> +int __ref arch_remove_memory(u64 start, u64 size, int flags)
>>>  {
>>>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>>>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>>> @@ -965,6 +972,12 @@ int __ref arch_remove_memory(u64 start, u64 size)
>>>  	struct zone *zone;
>>>  	int ret;
>>>  
>>> +	/* Need to add support for device and unaddressable memory if needed */
>>> +	if (flags & MEMORY_UNADDRESSABLE) {
>>> +		BUG();
>>> +		return -EINVAL;
>>> +	}
>>> +
>>>  	/* With altmap the first mapped page is offset from @start */
>>>  	altmap = to_vmem_altmap((unsigned long) page);
>>>  	if (altmap)
>>
>> So with this patch none of the architectures support un-addressable
>> memory but then support will be added through later patches ?
>> zone_for_memory function's flag now takes MEMORY_DEVICE parameter.
>> Then we need to change all the previous ZONE_DEVICE changes which
>> ever took "for_device" to accommodate this new flag ? just curious.
> 
> Yes correct.
> 
> 
>>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>>> index 01033fa..ba9b12e 100644
>>> --- a/include/linux/memory_hotplug.h
>>> +++ b/include/linux/memory_hotplug.h
>>> @@ -103,7 +103,7 @@ extern bool memhp_auto_online;
>>>  
>>>  #ifdef CONFIG_MEMORY_HOTREMOVE
>>>  extern bool is_pageblock_removable_nolock(struct page *page);
>>> -extern int arch_remove_memory(u64 start, u64 size);
>>> +extern int arch_remove_memory(u64 start, u64 size, int flags);
>>>  extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
>>>  	unsigned long nr_pages);
>>>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>>> @@ -275,7 +275,20 @@ extern int add_memory(int nid, u64 start, u64 size);
>>>  extern int add_memory_resource(int nid, struct resource *resource, bool online);
>>>  extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
>>>  		bool for_device);
>>> -extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
>>> +
>>> +/*
>>> + * For device memory we want more informations than just knowing it is device
>>> + * memory. We want to know if we can migrate it (ie it is not storage memory
>>> + * use by DAX). Is it addressable by the CPU ? Some device memory like GPU
>>> + * memory can not be access by CPU but we still want struct page so that we
>>> + * can use it like regular memory.
>>
>> Some typos here. Needs to be cleaned up as well. But please have a
>> look at comment below over the classification itself.
>>
>>> + */
>>> +#define MEMORY_FLAGS_NONE 0
>>> +#define MEMORY_DEVICE (1 << 0)
>>> +#define MEMORY_MOVABLE (1 << 1)
>>> +#define MEMORY_UNADDRESSABLE (1 << 2)
>>
>> It should be DEVICE_MEMORY_* instead of MEMORY_* as we are trying to
>> classify device memory (though they are represented with struct page)
>> not regular system ram memory. This should attempt to classify device
>> memory which is backed by struct pages. arch_add_memory/arch_remove
>> _memory does not come into play if it's traditional device memory
>> which is just PFN and does not have struct page associated with it.
> 
> Good idea i will change that.
> 
> 
>> Broadly they are either CPU accessible or in-accessible. Storage
>> memory like persistent memory represented though ZONE_DEVICE fall
>> under the accessible (coherent) category. IIUC right now they are
>> not movable because page->pgmap replaces page->lru in struct page
>> hence its inability to be on standard LRU lists as one of the
>> reasons. As there was a need to have struct page to exploit more
>> core VM features on these memory going forward it will have to be
>> migratable one way or the other to accommodate features like
>> compaction, HW poison etc in these storage memory. Hence my point
>> here is lets not classify any of these memories as non-movable.
>> Just addressable or not should be the only classification.
> 
> Being on the lru or not is not and issue in respect to migration. Being

Right, provided we we create separate migration interfaces for these non
LRU pages (preferably through HMM migration API layer). But where it
stands today, for NUMA migrate_pages() interface device non LRU memory
is a problem and we cannot use it for migration. Hence I brought up the
non LRU issue here.

> on the lru was use as an indication that the page is manage through the
> standard mm code and thus that many assumptions hold which in turn do
> allow migration. But if one use device memory following all rules of
> regular memory then migration can be done to no matter if page is on
> lru or not.

Right.

> 
> I still think that the MOVABLE is an important distinction as i am pretty
> sure that the persistent folks do not want to see their page migrated in
> anyway. I might rename it to DEVICE_MEMORY_ALLOW_MIGRATION.

We should not classify memory based on whether there is a *requirement*
for migration or not at this point of time, the classification should
be done if its inherently migratable or not. I dont see any reason why
persistent memory cannot be migrated. I am not very familiar with DAX
file system and its use of persistent memory but I would guess that
their requirement for compaction and error handling happens way above
in file system layers, hence they never needed these support at struct
page level. I am just guessing.

Added Dan J Williams in this thread list, he might be able to give us
some more details regarding persistent memory migration requirements
and it's current state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
