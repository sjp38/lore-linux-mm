Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 246BA6B0037
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 19:22:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EB5953EE0BD
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:22:07 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CF1D945DE50
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:22:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ADD9D45DE4D
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:22:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DEBD1DB803E
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:22:07 +0900 (JST)
Received: from G01JPEXCHYT17.g01.fujitsu.local (G01JPEXCHYT17.g01.fujitsu.local [10.128.194.56])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EA191DB803B
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 08:22:07 +0900 (JST)
Message-ID: <51708000.4060106@jp.fujitsu.com>
Date: Fri, 19 Apr 2013 08:21:36 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH v4] Reusing a resource structure allocated by
 bootmem
References: <516FB07C.9010603@jp.fujitsu.com> <20130418134206.GB21444@cmpxchg.org>
In-Reply-To: <20130418134206.GB21444@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, toshi.kani@hp.com, linuxram@us.ibm.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2013/04/18 22:42, Johannes Weiner wrote:
> On Thu, Apr 18, 2013 at 05:36:12PM +0900, Yasuaki Ishimatsu wrote:
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
>

> The branch is mixed up, you are collecting slab objects in
> bootmem_resource and kfreeing bootmem.

Ah. I'm wrong. I'll update soon.

Thanks,
Yasuaki Ishimatsu

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
>> +
>> +	if (!res)
>> +		res = kzalloc(sizeof(struct resource), flags);
>> +
>> +	return res;
>> +}
>> +
>>   /* Return the conflict entry if you can't request it */
>>   static struct resource * __request_resource(struct resource *root, struct resource *new)
>>   {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
