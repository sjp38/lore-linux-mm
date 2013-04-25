Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 89ACB6B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 20:57:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 905733EE0AE
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 09:57:30 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FBA245DE52
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 09:57:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C59C45DE4D
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 09:57:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EDB11DB803A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 09:57:30 +0900 (JST)
Received: from G01JPEXCHYT17.g01.fujitsu.local (G01JPEXCHYT17.g01.fujitsu.local [10.128.194.56])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EFFC9E08002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 09:57:29 +0900 (JST)
Message-ID: <51787F55.80403@jp.fujitsu.com>
Date: Thu, 25 Apr 2013 09:56:53 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Resend][Bug fix PATCH v5] Reusing a resource structure allocated
 by bootmem
References: <5175E5E8.3010003@jp.fujitsu.com> <51771E3D.6060203@jp.fujitsu.com> <20130424133719.94c7d301df844c4bcc987a53@linux-foundation.org>
In-Reply-To: <20130424133719.94c7d301df844c4bcc987a53@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hannes@cmpxchg.org, toshi.kani@hp.com, linuxram@us.ibm.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2013/04/25 5:37, Andrew Morton wrote:
> On Wed, 24 Apr 2013 08:50:21 +0900 Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:
>
>> When hot removing memory presented at boot time, following messages are shown:
>>
>> [  296.867031] ------------[ cut here ]------------
>> [  296.922273] kernel BUG at mm/slub.c:3409!
>>
>> ...
>>
>> The reason why the messages are shown is to release a resource structure,
>> allocated by bootmem, by kfree(). So when we release a resource structure,
>> we should check whether it is allocated by bootmem or not.
>>
>> But even if we know a resource structure is allocated by bootmem, we cannot
>> release it since SLxB cannot treat it. So for reusing a resource structure,
>> this patch remembers it by using bootmem_resource as follows:
>>
>> When releasing a resource structure by free_resource(), free_resource() checks
>> whether the resource structure is allocated by bootmem or not. If it is
>> allocated by bootmem, free_resource() adds it to bootmem_resource. If it is
>> not allocated by bootmem, free_resource() release it by kfree().
>>
>> And when getting a new resource structure by get_resource(), get_resource()
>> checks whether bootmem_resource has released resource structures or not. If
>> there is a released resource structure, get_resource() returns it. If there is
>> not a releaed resource structure, get_resource() returns new resource structure
>> allocated by kzalloc().
>>
>> ...
>>
>
> Looks good to me.
>
>> --- a/kernel/resource.c
>> +++ b/kernel/resource.c
>> @@ -21,6 +21,7 @@
>>   #include <linux/seq_file.h>
>>   #include <linux/device.h>
>>   #include <linux/pfn.h>
>> +#include <linux/mm.h>
>>   #include <asm/io.h>
>>
>>
>> @@ -50,6 +51,14 @@ struct resource_constraint {
>>
>>   static DEFINE_RWLOCK(resource_lock);
>>
>> +/*
>> + * For memory hotplug, there is no way to free resource entries allocated
>> + * by boot mem after the system is up. So for reusing the resource entry
>> + * we need to remember the resource.
>> + */
>> +static struct resource *bootmem_resource_free;
>> +static DEFINE_SPINLOCK(bootmem_resource_lock);
>> +
>>   static void *r_next(struct seq_file *m, void *v, loff_t *pos)
>>   {
>>   	struct resource *p = v;
>> @@ -151,6 +160,40 @@ __initcall(ioresources_init);
>>
>>   #endif /* CONFIG_PROC_FS */
>>
>> +static void free_resource(struct resource *res)
>> +{
>> +	if (!res)
>> +		return;
>> +
>> +	if (!PageSlab(virt_to_head_page(res))) {
>

> Did you consider using a bit in resource.flags?

I considered to add a new flag such as IORESOURCE_BOOTMEM first.
But even if we don't add the new flag, we can check whether
struct resource is managed by SLxB or not. So I selected this way.

Thanks,
Yasuaki Ishimatsu

> There appear to be
> four free ones left.  The VM trickery will work OK I guess, but isn't
> very "nice".
>
>> +		spin_lock(&bootmem_resource_lock);
>> +		res->sibling = bootmem_resource_free;
>> +		bootmem_resource_free = res;
>> +		spin_unlock(&bootmem_resource_lock);
>> +	} else {
>> +		kfree(res);
>> +	}
>> +}
>> +
>> +static struct resource *get_resource(gfp_t flags)
>> +{
>> +	struct resource *res = NULL;
>> +
>> +	spin_lock(&bootmem_resource_lock);
>> +	if (bootmem_resource_free) {
>> +		res = bootmem_resource_free;
>> +		bootmem_resource_free = res->sibling;
>> +	}
>> +	spin_unlock(&bootmem_resource_lock);
>> +
>> +	if (res)
>> +		memset(res, 0, sizeof(struct resource));
>> +	else
>> +		res = kzalloc(sizeof(struct resource), flags);
>> +
>> +	return res;
>> +}
>

> I think I'll rename this to alloc_resource().  In Linux "get" often
> (but not always) means "take a reference on".  So "get" pairs with
> "put" and "alloc" pairs with "free".




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
