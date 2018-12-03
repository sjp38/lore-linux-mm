Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B87C16B689A
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 05:32:25 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id x125so12501486qka.17
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 02:32:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b83si4878603qkc.176.2018.12.03.02.32.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 02:32:24 -0800 (PST)
Subject: Re: [PATCH RFCv2 1/4] mm/memory_hotplug: Introduce memory block types
References: <20181130175922.10425-1-david@redhat.com>
 <20181130175922.10425-2-david@redhat.com>
 <20181201012507.lxfscl6ho3gc6gnn@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <af797dbb-0537-19ec-ef31-d72a3f979791@redhat.com>
Date: Mon, 3 Dec 2018 11:32:17 +0100
MIME-Version: 1.0
In-Reply-To: <20181201012507.lxfscl6ho3gc6gnn@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, xen-devel@lists.xenproject.org, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Banman <andrew.banman@hpe.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Oscar Salvador <osalvador@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Michal Such??nek <msuchanek@suse.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On 01.12.18 02:25, Wei Yang wrote:
> On Fri, Nov 30, 2018 at 06:59:19PM +0100, David Hildenbrand wrote:
>> Memory onlining should always be handled by user space, because only user
>> space knows which use cases it wants to satisfy. E.g. memory might be
>> onlined to the MOVABLE zone even if it can never be removed from the
>> system, e.g. to make usage of huge pages more reliable.
>>
>> However to implement such rules (especially default rules in distributions)
>> we need more information about the memory that was added in user space.
>>
>> E.g. on x86 we want to online memory provided by balloon devices (e.g.
>> XEN, Hyper-V) differently (-> will not be unplugged by offlining the whole
>> block) than ordinary DIMMs (-> might eventually be unplugged by offlining
>> the whole block). This might also become relevat for other architectures.
>>
>> Also, udev rules right now check if running on s390x and treat all added
>> memory blocks as standby memory (-> don't online automatically). As soon as
>> we support other memory hotplug mechanism (e.g. virtio-mem) checks would
>> have to get more involved (e.g. also check if under KVM) but eventually
>> also wrong (e.g. if KVM ever supports standby memory we are doomed).
>>
>> I decided to allow to specify the type of memory that is getting added
>> to the system. Let's start with two types, BOOT and UNSPECIFIED to get the
>> basic infrastructure running. We'll introduce and use further types in
>> follow-up patches. For now we classify any hotplugged memory temporarily
>> as as UNSPECIFIED (which will eventually be dropped later on).
>>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
>> Cc: Andrew Banman <andrew.banman@hpe.com>
>> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>> Cc: Oscar Salvador <osalvador@suse.com>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Michal Such??nek <msuchanek@suse.de>
>> Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>> drivers/base/memory.c  | 38 +++++++++++++++++++++++++++++++++++---
>> include/linux/memory.h | 27 +++++++++++++++++++++++++++
>> 2 files changed, 62 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index 0c290f86ab20..17f2985c07c5 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -381,6 +381,29 @@ static ssize_t show_phys_device(struct device *dev,
>> 	return sprintf(buf, "%d\n", mem->phys_device);
>> }
>>
>> +static ssize_t type_show(struct device *dev, struct device_attribute *attr,
>> +			 char *buf)
>> +{
>> +	struct memory_block *mem = to_memory_block(dev);
>> +	ssize_t len = 0;
>> +
>> +	switch (mem->type) {
>> +	case MEMORY_BLOCK_UNSPECIFIED:
>> +		len = sprintf(buf, "unspecified\n");
>> +		break;
>> +	case MEMORY_BLOCK_BOOT:
>> +		len = sprintf(buf, "boot\n");
>> +		break;
>> +	default:
>> +		len = sprintf(buf, "ERROR-UNKNOWN-%ld\n",
>> +				mem->state);
>> +		WARN_ON(1);
>> +		break;
>> +	}
>> +
>> +	return len;
>> +}
>> +
>> #ifdef CONFIG_MEMORY_HOTREMOVE
>> static void print_allowed_zone(char *buf, int nid, unsigned long start_pfn,
>> 		unsigned long nr_pages, int online_type,
>> @@ -442,6 +465,7 @@ static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
>> static DEVICE_ATTR(state, 0644, show_mem_state, store_mem_state);
>> static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
>> static DEVICE_ATTR(removable, 0444, show_mem_removable, NULL);
>> +static DEVICE_ATTR_RO(type);
> 
> This is correct, while looks not consistent with other attributes.
> 
> Not that beautiful :-)

I might change the other ones first, too (or keep this one consistent to
the existing ones). Thanks!

> 
>>
>> /*
>>  * Block size attribute stuff
>> @@ -620,6 +644,7 @@ static struct attribute *memory_memblk_attrs[] = {
>> 	&dev_attr_state.attr,
>> 	&dev_attr_phys_device.attr,
>> 	&dev_attr_removable.attr,
>> +	&dev_attr_type.attr,
>> #ifdef CONFIG_MEMORY_HOTREMOVE
>> 	&dev_attr_valid_zones.attr,
>> #endif
>> @@ -657,13 +682,17 @@ int register_memory(struct memory_block *memory)
>> }
>>
>> static int init_memory_block(struct memory_block **memory,
>> -			     struct mem_section *section, unsigned long state)
>> +			     struct mem_section *section, unsigned long state,
>> +			     int type)
>> {
>> 	struct memory_block *mem;
>> 	unsigned long start_pfn;
>> 	int scn_nr;
>> 	int ret = 0;
>>
>> +	if (type == MEMORY_BLOCK_NONE)
>> +		return -EINVAL;
> 
> No one will pass in this value. Can we omit this check for now?

I could move it to patch nr 2 I guess, but as I introduce
MEMORY_BLOCK_NONE here it made sense to keep it in here.

(and I think at least for now it makes sense to not squash patch 1 and
2, to easier discuss the new user interface/concept introduced in this
patch).

Thanks!

-- 

Thanks,

David / dhildenb
