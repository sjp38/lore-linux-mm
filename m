Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 762AF6B02A8
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 15:20:12 -0400 (EDT)
Message-ID: <4C5C6067.1000403@goop.org>
Date: Fri, 06 Aug 2010 12:20:07 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] GSoC 2010 - Memory hotplug support for Xen guests - second
 fully working version - once again
References: <20100806111147.GA31683@router-fw-old.local.net-space.pl> <20100806163408.GA8678@phenom.dumpdata.com>
In-Reply-To: <20100806163408.GA8678@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, stefano.stabellini@eu.citrix.com, linux-mm@kvack.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, v.tolstov@selfip.ru
List-ID: <linux-mm.kvack.org>

  On 08/06/2010 09:34 AM, Konrad Rzeszutek Wilk wrote:
> On Fri, Aug 06, 2010 at 01:11:47PM +0200, Daniel Kiper wrote:
>> Hi,
>>
>> I am sending this e-mail once again because it probably
>> has been lost in abyss of Xen-devel/LKLM list.
>>
>> Here is the second version of memory hotplug support
>> for Xen guests patch. This one cleanly applies to
>> git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen.git
>> repository, xen/memory-hotplug head.
>>
>> Changes:
>>    - /sys/devices/system/memory/probe interface has been removed;
>>      /sys/devices/system/xen_memory/xen_memory0/{target,target_kb}
>>      are much better (I forgot about them),
>>    - most of the code have been moved to drivers/xen/balloon.c,
>>    - this changes forced me to export hotadd_new_pgdat and
>>      rollback_node_hotadd function from mm/memory_hotplug.c;
>>      could it be accepted by mm/memory_hotplug.c maintainers ???
>>    - PV on HVM mode is supported now; it was tested on
>>      git://xenbits.xen.org/people/sstabellini/linux-pvhvm.git
>>      repository, 2.6.34-pvhvm head,
>>    - most of Jeremy suggestions have been applied.
>>
>> On Wed, Jul 28, 2010 at 11:36:29AM +0400, Vasiliy G Tolstov wrote:
>> [...]
>>> Work's fine with opensuse 11.3 (dom0 and domU)
>> Thx.
>>
>> On Thu, Jul 29, 2010 at 12:39:52PM -0700, Jeremy Fitzhardinge wrote:
>>>   On 07/26/2010 05:41 PM, Daniel Kiper wrote:
>>>> Hi,
>>>>
>>>> Currently there is fully working version.
>>>> It has been tested on Xen Ver. 4.0.0 in PV
>>>> guest i386/x86_64 with Linux kernel Ver. 2.6.32.16
>>>> and Ver. 2.6.34.1. This patch cleanly applys
>>>> to Ver. 2.6.34.1
>>> Thanks.  I've pushed this into xen.git as xen/memory-hotplug so people
>>> can play with it more easily (but I haven't merged it into any of the
>>> other branches yet).
>> Thx.
>>
>>>> +#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
>>>> +static inline unsigned long current_target(void)
>>>> +{
>>>> +	return balloon_stats.target_pages;
>>> Why does this need its own version?
>> Because original version return values not bigger
>> then initial memory allocation which does not allow
>> memory hotplug to function.
>>
>>>> +int __ref xen_add_memory(int nid, u64 start, u64 size)
>>>> +{
>>>> +	pg_data_t *pgdat = NULL;
>>>> +	int new_pgdat = 0, ret;
>>>> +
>>>> +	lock_system_sleep();
>>>> +
>>>> +	if (!node_online(nid)) {
>>>> +		pgdat = hotadd_new_pgdat(nid, start);
>>>> +		ret = -ENOMEM;
>>>> +		if (!pgdat)
>>>> +			goto out;
>>>> +		new_pgdat = 1;
>>>> +	}
>>>> +
>>>> +	/* call arch's memory hotadd */
>>>> +	ret = arch_add_memory(nid, start, size);
>>>> +
>>>> +	if (ret<   0)
>>>> +		goto error;
>>>> +
>>>> +	/* we online node here. we can't roll back from here. */
>>>> +	node_set_online(nid);
>>>> +
>>>> +	if (new_pgdat) {
>>>> +		ret = register_one_node(nid);
>>>> +		/*
>>>> +		 * If sysfs file of new node can't create, cpu on the node
>>>> +		 * can't be hot-added. There is no rollback way now.
>>>> +		 * So, check by BUG_ON() to catch it reluctantly..
>>>> +		 */
>>>> +		BUG_ON(ret);
>>>> +	}
>>> This doesn't seem to be doing anything particularly xen-specific.
>> In general it could be generic however I do not know
>> it will be useful for others. If this function would
>> be accepted by mm/memory_hotplug.c maintainers we could
>> move it there. I removed from original add_memory funtion
>> resource allocation (and deallocation after error), which
>> must be done before XENMEM_populate_physmap in Xen. xen_add_memory
>> is called after physmap is fully populated.
>>
>> If you have a questions please drop me a line.
>
>
> Can you repost a patch that is on top of a virgin tree please?

I just thanked him for posting a delta ;)  I've pushed this into 
xen/memory-hotplug so you can easily generate a complete diff with "git 
diff v2.6.34..xen/memory-hotplug".

> + spin_lock_irqsave(&balloon_lock, flags);
>> +
>> +	if (!is_memory_resource_reserved()) {
>> +
>> +		/*
>> +		 * Look for first unused memory region starting at page
>> +		 * boundary. Skip last memory section created at boot time
>> +		 * becuase it may contains unused memory pages with PG_reserved
>> +		 * bit not set (online_pages require PG_reserved bit set).
>> +		 */
>> +
>> +		r = kzalloc(sizeof(struct resource), GFP_KERNEL);
>
>
> You are holding a spinlock here. Kzalloc can sleep

Good point.

     J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
