Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id BA2B76B0069
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 03:01:24 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4B7283EE0BB
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:01:23 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F83845DE72
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:01:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 14A1145DE6E
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:01:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 039E81DB8042
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:01:23 +0900 (JST)
Received: from g01jpexchkw02.g01.fujitsu.local (g01jpexchkw02.g01.fujitsu.local [10.0.194.41])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC6A81DB803F
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:01:22 +0900 (JST)
Message-ID: <4FEC012E.5030209@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 16:01:02 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/12] memory-hogplug : check memory offline in offline_pages
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9DB1.7010303@jp.fujitsu.com> <alpine.DEB.2.00.1206262313440.32567@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206262313440.32567@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

Hi David,

2012/06/27 15:16, David Rientjes wrote:
> On Wed, 27 Jun 2012, Yasuaki Ishimatsu wrote:
>
>> Index: linux-3.5-rc4/mm/memory_hotplug.c
>> ===================================================================
>> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-06-26 13:28:16.743211538 +0900
>> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-06-26 13:48:38.264940468 +0900
>> @@ -887,6 +887,11 @@ static int __ref offline_pages(unsigned
>>
>>   	lock_memory_hotplug();
>>
>> +	if (memory_is_offline(start_pfn, end_pfn)) {
>> +		ret = 0;
>> +		goto out;
>> +	}
>> +
>>   	zone = page_zone(pfn_to_page(start_pfn));
>>   	node = zone_to_nid(zone);
>>   	nr_pages = end_pfn - start_pfn;
>
> Are there additional prerequisites for this patch?  Otherwise it changes
> the return value of offline_memory() which will now call
> acpi_memory_powerdown_device() in the acpi memhotplug case when disabling.
> Is that a problem?

I have understood there is a person who expects "offline_pages()" to fail
in this case by kosaki's comment. So I'll move memory_is_offline to caller
side.

Thanks,
Yasuaki Ishimatsu

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
