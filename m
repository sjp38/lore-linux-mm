Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 22DCF828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 05:26:54 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id b35so320576745qge.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 02:26:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b23si705277qhc.14.2016.01.13.02.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 02:26:53 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH v2 2/2] memory-hotplug: keep the request_resource() error code
References: <1451924251-4189-1-git-send-email-vkuznets@redhat.com>
	<1451924251-4189-3-git-send-email-vkuznets@redhat.com>
	<alpine.DEB.2.10.1601121520530.28831@chino.kir.corp.google.com>
Date: Wed, 13 Jan 2016 11:26:47 +0100
In-Reply-To: <alpine.DEB.2.10.1601121520530.28831@chino.kir.corp.google.com>
	(David Rientjes's message of "Tue, 12 Jan 2016 15:25:05 -0800 (PST)")
Message-ID: <87si216ahk.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dan Williams <dan.j.williams@intel.com>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>

David Rientjes <rientjes@google.com> writes:

> On Mon, 4 Jan 2016, Vitaly Kuznetsov wrote:
>
>> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
>> index 6b0d3ef..e367e4b 100644
>> --- a/drivers/acpi/acpi_memhotplug.c
>> +++ b/drivers/acpi/acpi_memhotplug.c
>> @@ -232,10 +232,10 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>>  
>>  		/*
>>  		 * If the memory block has been used by the kernel, add_memory()
>> -		 * returns -EEXIST. If add_memory() returns the other error, it
>> +		 * returns -EBUSY. If add_memory() returns the other error, it
>>  		 * means that this memory block is not used by the kernel.
>>  		 */
>> -		if (result && result != -EEXIST)
>> +		if (result && result != -EBUSY)
>>  			continue;
>>  
>>  		result = acpi_bind_memory_blocks(info, mem_device->device);
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 92f9595..07eab2c 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -130,6 +130,7 @@ void mem_hotplug_done(void)
>>  static struct resource *register_memory_resource(u64 start, u64 size)
>>  {
>>  	struct resource *res;
>> +	int ret;
>>  	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
>>  	if (!res)
>>  		return ERR_PTR(-ENOMEM);
>> @@ -138,10 +139,11 @@ static struct resource *register_memory_resource(u64 start, u64 size)
>>  	res->start = start;
>>  	res->end = start + size - 1;
>>  	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
>> -	if (request_resource(&iomem_resource, res) < 0) {
>> +	ret = request_resource(&iomem_resource, res);
>> +	if (ret < 0) {
>>  		pr_debug("System RAM resource %pR cannot be added\n", res);
>>  		kfree(res);
>> -		return ERR_PTR(-EEXIST);
>> +		return ERR_PTR(ret);
>>  	}
>>  	return res;
>>  }
>
> The result of this change is that add_memory() returns -EBUSY instead of 
> -EEXIST for overlapping ranges.  This patch breaks hv_mem_hot_add() since 
> it strictly uses a return value of -EEXIST to indicate a non-transient 
> failure, so NACK.

While this is shameful but fixable ...

> It also changes the return value of both the "probe" 
> and "dlpar" (on ppc) userspace triggers, which I could imagine is tested 
> from existing userspace scripts.

this is probably a show-stopper as we're bound by "we don't break
userspace" rule (and it's not worth it anyway). Thanks for pointing this
out!

Andrew, please drop this patch from your queue permanently. The patch 1
of the series is worthwhile (and is acked by David).

Thanks,

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
