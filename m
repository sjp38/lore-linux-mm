Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id F1B1D6B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 05:13:21 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id 74so33437745qgh.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 02:13:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 98si28855890qgc.23.2015.12.21.02.13.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 02:13:21 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH] memory-hotplug: don't BUG() in register_memory_resource()
References: <1450450224-18515-1-git-send-email-vkuznets@redhat.com>
	<20151218145022.eae1e368c82f090900582fcc@linux-foundation.org>
Date: Mon, 21 Dec 2015 11:13:15 +0100
In-Reply-To: <20151218145022.eae1e368c82f090900582fcc@linux-foundation.org>
	(Andrew Morton's message of "Fri, 18 Dec 2015 14:50:22 -0800")
Message-ID: <8737uwt8hw.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Sheng Yong <shengyong1@huawei.com>, David Rientjes <rientjes@google.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dan Williams <dan.j.williams@intel.com>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Fri, 18 Dec 2015 15:50:24 +0100 Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
>
>> Out of memory condition is not a bug and while we can't add new memory in
>> such case crashing the system seems wrong. Propagating the return value
>> from register_memory_resource() requires interface change.
>> 
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> +static int register_memory_resource(u64 start, u64 size,
>> +				    struct resource **resource)
>>  {
>>  	struct resource *res;
>>  	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
>> -	BUG_ON(!res);
>> +	if (!res)
>> +		return -ENOMEM;
>>  
>>  	res->name = "System RAM";
>>  	res->start = start;
>> @@ -140,9 +142,10 @@ static struct resource *register_memory_resource(u64 start, u64 size)
>>  	if (request_resource(&iomem_resource, res) < 0) {
>>  		pr_debug("System RAM resource %pR cannot be added\n", res);
>>  		kfree(res);
>> -		res = NULL;
>> +		return -EEXIST;
>>  	}
>> -	return res;
>> +	*resource = res;
>> +	return 0;
>>  }
>
> Was there a reason for overwriting the request_resource() return
> value?
> Ordinarily it should be propagated back to callers.
>
> Please review.
>

This is a nice-to-have addition but it will break at least ACPI
memhotplug: request_resource() has the following:

conflict = request_resource_conflict(root, new);
return conflict ? -EBUSY : 0;

so we'll end up returning -EBUSY from register_memory_resource() and
add_memory(), at the same time acpi_memory_enable_device() counts on
-EEXIST:

result = add_memory(node, info->start_addr, info->length);

/*
* If the memory block has been used by the kernel, add_memory()
* returns -EEXIST. If add_memory() returns the other error, it
* means that this memory block is not used by the kernel.
*/
if (result && result != -EEXIST)
continue;

So I see 3 options here:
1) Keep the overwrite
2) Change the request_resource() return value to -EEXIST
3) Adapt all add_memory() call sites to -EBUSY.

Please let me know your preference.

> --- a/mm/memory_hotplug.c~memory-hotplug-dont-bug-in-register_memory_resource-fix
> +++ a/mm/memory_hotplug.c
> @@ -131,7 +131,9 @@ static int register_memory_resource(u64
>  				    struct resource **resource)
>  {
>  	struct resource *res;
> +	int ret = 0;
>  	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
> +
>  	if (!res)
>  		return -ENOMEM;
>
> @@ -139,13 +141,14 @@ static int register_memory_resource(u64
>  	res->start = start;
>  	res->end = start + size - 1;
>  	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> -	if (request_resource(&iomem_resource, res) < 0) {
> +	ret = request_resource(&iomem_resource, res);
> +	if (ret < 0) {
>  		pr_debug("System RAM resource %pR cannot be added\n", res);
>  		kfree(res);
> -		return -EEXIST;
> +	} else {
> +		*resource = res;
>  	}
> -	*resource = res;
> -	return 0;
> +	return ret;
>  }
>
>  static void release_memory_resource(struct resource *res)
> _

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
