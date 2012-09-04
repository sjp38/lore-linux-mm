Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id E3CCE6B005D
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 23:44:47 -0400 (EDT)
Message-ID: <50457983.1050304@cn.fujitsu.com>
Date: Tue, 04 Sep 2012 11:46:11 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v8 PATCH 13/20] memory-hotplug: check page type in get_page_bootmem
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>	<1346148027-24468-14-git-send-email-wency@cn.fujitsu.com> <20120831143032.1343e99a.akpm@linux-foundation.org>
In-Reply-To: <20120831143032.1343e99a.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, isimatu.yasuaki@jp.fujitsu.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com

Hi, isimatu-san

At 09/01/2012 05:30 AM, Andrew Morton Wrote:
> On Tue, 28 Aug 2012 18:00:20 +0800
> wency@cn.fujitsu.com wrote:
> 
>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> There is a possibility that get_page_bootmem() is called to the same page many
>> times. So when get_page_bootmem is called to the same page, the function only
>> increments page->_count.
> 
> I really don't understand this explanation, even after having looked at
> the code.  Can you please have another attempt at the changelog?

What is the problem that you want to fix? The function get_page_bootmem()
may be called to the same page more than once, but I don't find any problem
about current implementation.

Thanks
Wen Congyang

> 
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -95,10 +95,17 @@ static void release_memory_resource(struct resource *res)
>>  static void get_page_bootmem(unsigned long info,  struct page *page,
>>  			     unsigned long type)
>>  {
>> -	page->lru.next = (struct list_head *) type;
>> -	SetPagePrivate(page);
>> -	set_page_private(page, info);
>> -	atomic_inc(&page->_count);
>> +	unsigned long page_type;
>> +
>> +	page_type = (unsigned long) page->lru.next;
>> +	if (page_type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
>> +	    page_type > MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE){
>> +		page->lru.next = (struct list_head *) type;
>> +		SetPagePrivate(page);
>> +		set_page_private(page, info);
>> +		atomic_inc(&page->_count);
>> +	} else
>> +		atomic_inc(&page->_count);
>>  }
> 
> And a code comment which explains what is going on would be good.  As
> is always the case ;)
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
