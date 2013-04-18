Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 3287E6B0039
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 19:33:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BE80D3EE0C0
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:33:37 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A100A45DE4D
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:33:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CDFB45DD78
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:33:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B4631DB803F
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:33:37 +0900 (JST)
Received: from G01JPEXCHYT13.g01.fujitsu.local (G01JPEXCHYT13.g01.fujitsu.local [10.128.194.52])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 14ECA1DB803C
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:33:37 +0900 (JST)
Message-ID: <517082B9.7050708@jp.fujitsu.com>
Date: Fri, 19 Apr 2013 08:33:13 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH v4] Reusing a resource structure allocated by
 bootmem
References: <516FB07C.9010603@jp.fujitsu.com> <1366295000.3824.47.camel@misato.fc.hp.com>
In-Reply-To: <1366295000.3824.47.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linuxram@us.ibm.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Toshi,

2013/04/18 23:23, Toshi Kani wrote:
> On Thu, 2013-04-18 at 17:36 +0900, Yasuaki Ishimatsu wrote:
>> When hot removing memory presented at boot time, following messages are shown:
>   :
>> diff --git a/kernel/resource.c b/kernel/resource.c
>> index 4aef886..637e8d2 100644
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
>> @@ -50,6 +51,16 @@ struct resource_constraint {
>>
>>   static DEFINE_RWLOCK(resource_lock);
>>
>> +/*
>> + * For memory hotplug, there is no way to free resource entries allocated
>> + * by boot mem after the system is up. So for reusing the resource entry
>> + * we need to remember the resource.
>> + */
>> +struct resource bootmem_resource = {
>> +	.sibling = NULL,
>> +};
>

> This should be a pointer of struct resource and declared as static, such
> as:
>
> static struct resource *bootmem_resource_free;

O.K. I'll update it.

>
>> +static DEFINE_SPINLOCK(bootmem_resource_lock);
>> +
>>   static void *r_next(struct seq_file *m, void *v, loff_t *pos)
>>   {
>>   	struct resource *p = v;
>> @@ -151,6 +162,39 @@ __initcall(ioresources_init);
>>
>>   #endif /* CONFIG_PROC_FS */
>>
>> +static void free_resource(struct resource *res)
>> +{
>> +	if (!res)
>> +		return;
>> +
>> +	if (PageSlab(virt_to_head_page(res))) {
>> +		spin_lock(&bootmem_resource_lock);
>> +		res->sibling = bootmem_resource.sibling;
>> +		bootmem_resource.sibling = res;
>> +		spin_unlock(&bootmem_resource_lock);
>> +	} else {
>> +		kfree(res);
>> +	}
>> +}
>

> I second with Johannes.

I'll update it.

>
>> +static struct resource *get_resource(gfp_t flags)
>> +{
>> +	struct resource *res = NULL;
>> +
>> +	spin_lock(&bootmem_resource_lock);
>> +	if (bootmem_resource.sibling) {
>> +		res = bootmem_resource.sibling;
>> +		bootmem_resource.sibling = res->sibling;
>> +		memset(res, 0, sizeof(struct resource));
>> +	}
>> +	spin_unlock(&bootmem_resource_lock);
>

> I prefer to keep memset() outside of the spin lock.
>
> spin_lock(&bootmem_resource_lock);
> if (..) {
> 	:
> 	spin_unlock(&bootmem_resource_lock);
> 	memset(res, 0, sizeof(struct resource));
> } else {
> 	spin_unlock(&bootmem_resource_lock);
> 	res = kzalloc(sizeof(struct resource), flags);
> }

Hmm. It is a little ugly. How about it?

spin_lock(&bootmem_resource_lock);
if (bootmem_resource.sibling) {
	res = bootmem_resource.sibling;
	bootmem_resource.sibling = res->sibling;
}
spin_unlock(&bootmem_resource_lock);

if (res)
	memset(res, 0, sizeof(struct resource));
else	
	res = kzalloc(sizeof(struct resource), flags);

Thanks,
Yasuaki Ishimatsu

>
> Thanks,
> -Toshi
>
>> +
>> +
>> +	return res;
>> +}
>> +
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
