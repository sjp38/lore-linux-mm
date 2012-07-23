Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id BD13D6B0044
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 08:13:35 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so13213358pbb.14
        for <linux-mm@kvack.org>; Mon, 23 Jul 2012 05:13:35 -0700 (PDT)
Message-ID: <500D3FEE.2050109@gmail.com>
Date: Mon, 23 Jul 2012 20:13:34 +0800
From: Wen Congyang <wencongyang@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] memory-hotplug: Add memblock_state notifier
References: <1342783088-29970-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <500D1474.9070708@cn.fujitsu.com> <20120723110610.GB18801@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20120723110610.GB18801@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org

At 2012/7/23 19:06, Vasilis Liaskovitis Wrote:
> Hi,
>
> On Mon, Jul 23, 2012 at 05:08:04PM +0800, Wen Congyang wrote:
>>> +static int memblock_state_notifier_nb(struct notifier_block *nb, unsigned long
>>> +		val, void *v)
>>> +{
>>> +	struct memory_notify *arg = (struct memory_notify *)v;
>>> +	struct memory_block *mem = NULL;
>>> +	struct mem_section *ms;
>>> +	unsigned long section_nr;
>>> +
>>> +	section_nr = pfn_to_section_nr(arg->start_pfn);
>>> +	ms = __nr_to_section(section_nr);
>>> +	mem = find_memory_block(ms);
>>> +	if (!mem)
>>> +		goto out;
>>
>> we may offline more than one memory block.
>>
> thanks, you are right.
>
>>> +
>>> +	switch (val) {
>>> +	case MEM_GOING_OFFLINE:
>>> +	case MEM_OFFLINE:
>>> +	case MEM_GOING_ONLINE:
>>> +	case MEM_ONLINE:
>>> +	case MEM_CANCEL_ONLINE:
>>> +	case MEM_CANCEL_OFFLINE:
>>> +		mem->state = val;
>>
>> mem->state is protected by the lock mem->state_mutex, so if you want to
>> update the state, you must lock mem->state_mutex. But you cannot lock it
>> here, because it may cause deadlock:
>>
>> acpi_memhotplug                           sysfs interface
>> ===============================================================================
>>                                            memory_block_change_state()
>>                                                lock mem->state_mutex
>>                                                memory_block_action()
>> offline_pages()
>>      lock_memory_hotplug()
>>                                                    offline_memory()
>>                                                        lock_memory_hotplug() // block
>>      memory_notify()
>>          memblock_state_notifier_nb()
>> ===============================================================================
>
> good point. Maybe if memory_hotplug_lock and state_mutex locks are acquired in
> the same order in the 2 code paths, this could be avoided.

Yes, I am trying to fix another 2 problems(also based on ishimatsu's 
patchset):
1. offline_memory() will fail if part of the memory is onlined and part 
of the memory
    is offlined.
2. notify the userspace if the memory block's status is changed

I guess this problem can be fixed together.

Thanks
Wen Congyang

>
>> I'm writing another patch to fix it.
>
> ok, I 'll test.
> thanks,
>
> - Vasilis
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
