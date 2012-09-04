Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 478B86B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:55:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 39BFA3EE0C0
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:55:29 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DDFF45DE51
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:55:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFDF045DE4F
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:55:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DDE5D1DB803F
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:55:28 +0900 (JST)
Received: from G01JPEXCHKW08.g01.fujitsu.local (G01JPEXCHKW08.g01.fujitsu.local [10.0.194.47])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 96C841DB802F
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:55:28 +0900 (JST)
Message-ID: <5045CFD6.9040408@jp.fujitsu.com>
Date: Tue, 4 Sep 2012 18:54:30 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v8 PATCH 13/20] memory-hotplug: check page type in get_page_bootmem
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>	<1346148027-24468-14-git-send-email-wency@cn.fujitsu.com> <20120831143032.1343e99a.akpm@linux-foundation.org> <50457983.1050304@cn.fujitsu.com>
In-Reply-To: <50457983.1050304@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

2012/09/04 12:46, Wen Congyang wrote:
> Hi, isimatu-san
>
> At 09/01/2012 05:30 AM, Andrew Morton Wrote:
>> On Tue, 28 Aug 2012 18:00:20 +0800
>> wency@cn.fujitsu.com wrote:
>>
>>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>
>>> There is a possibility that get_page_bootmem() is called to the same page many
>>> times. So when get_page_bootmem is called to the same page, the function only
>>> increments page->_count.
>>
>> I really don't understand this explanation, even after having looked at
>> the code.  Can you please have another attempt at the changelog?
>
> What is the problem that you want to fix? The function get_page_bootmem()
> may be called to the same page more than once, but I don't find any problem
> about current implementation.

The patch is just optimization. The patch does not fix a problems.
As you know, the function may be called many times for the same page.
I think if a page is sets to page_type and Page Private flag and page->private,
the page need not be set the same things again. So we check page_type when
get_page_bootmem() is called. And if the page has been set to them, the page
is only incremented page->_count.

Thanks,
Yasuaki Ishimatsu

>
> Thanks
> Wen Congyang
>
>>
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -95,10 +95,17 @@ static void release_memory_resource(struct resource *res)
>>>   static void get_page_bootmem(unsigned long info,  struct page *page,
>>>   			     unsigned long type)
>>>   {
>>> -	page->lru.next = (struct list_head *) type;
>>> -	SetPagePrivate(page);
>>> -	set_page_private(page, info);
>>> -	atomic_inc(&page->_count);
>>> +	unsigned long page_type;
>>> +
>>> +	page_type = (unsigned long) page->lru.next;
>>> +	if (page_type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
>>> +	    page_type > MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE){
>>> +		page->lru.next = (struct list_head *) type;
>>> +		SetPagePrivate(page);
>>> +		set_page_private(page, info);
>>> +		atomic_inc(&page->_count);
>>> +	} else
>>> +		atomic_inc(&page->_count);
>>>   }
>>
>> And a code comment which explains what is going on would be good.  As
>> is always the case ;)
>>
>>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
