Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 09F036B0044
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 20:50:30 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2DC273EE0C1
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:50:29 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1381A45DE56
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:50:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E3BC645DE50
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:50:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2A921DB8040
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:50:28 +0900 (JST)
Received: from G01JPEXCHKW28.g01.fujitsu.local (G01JPEXCHKW28.g01.fujitsu.local [10.0.193.111])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B32D1DB803F
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:50:28 +0900 (JST)
Message-ID: <5080A394.2000409@jp.fujitsu.com>
Date: Fri, 19 Oct 2012 09:49:24 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/10] memory-hotplug : memory-hotplug: check page type
 in get_page_bootmem
References: <506E43E0.70507@jp.fujitsu.com> <506E46B6.3060502@jp.fujitsu.com> <CAHGf_=raSH5C8ye90F1PLZ8mGQUGggB=J0HYU8UhkKVDTV5JXQ@mail.gmail.com>
In-Reply-To: <CAHGf_=raSH5C8ye90F1PLZ8mGQUGggB=J0HYU8UhkKVDTV5JXQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, wency@cn.fujitsu.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

Hi Kosaki,

Sorry for late reply.

2012/10/13 4:28, KOSAKI Motohiro wrote:
> On Thu, Oct 4, 2012 at 10:32 PM, Yasuaki Ishimatsu
> <isimatu.yasuaki@jp.fujitsu.com> wrote:
>> The function get_page_bootmem() may be called more than one time to the same
>> page. There is no need to set page's type, private if the function is not
>> the first time called to the page.
>>
>> Note: the patch is just optimization and does not fix any problem.
>>
>> CC: David Rientjes <rientjes@google.com>
>> CC: Jiang Liu <liuj97@gmail.com>
>> CC: Len Brown <len.brown@intel.com>
>> CC: Christoph Lameter <cl@linux.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> CC: Wen Congyang <wency@cn.fujitsu.com>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> ---
>>   mm/memory_hotplug.c |   15 +++++++++++----
>>   1 file changed, 11 insertions(+), 4 deletions(-)
>>
>> Index: linux-3.6/mm/memory_hotplug.c
>> ===================================================================
>> --- linux-3.6.orig/mm/memory_hotplug.c  2012-10-04 18:29:58.284676075 +0900
>> +++ linux-3.6/mm/memory_hotplug.c       2012-10-04 18:30:03.454680542 +0900
>> @@ -95,10 +95,17 @@ static void release_memory_resource(stru
>>   static void get_page_bootmem(unsigned long info,  struct page *page,
>>                               unsigned long type)
>>   {
>> -       page->lru.next = (struct list_head *) type;
>> -       SetPagePrivate(page);
>> -       set_page_private(page, info);
>> -       atomic_inc(&page->_count);
>> +       unsigned long page_type;
>> +
>> +       page_type = (unsigned long)page->lru.next;
>
> If I understand correctly, page->lru.next might be uninitialized yet.

Ah yes. I was misunderstanding...

Hi Wen,

When you update the physical hot remove patch-set, please drop the patch.

Thanks,
Yasuaki Ishimatsu  
  
> Moreover, I have no seen any good effect in this patch. I don't understand
> why we need to increase code complexity.
>
>
>
>> +       if (page_type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
>> +           page_type > MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE){
>> +               page->lru.next = (struct list_head *)type;
>> +               SetPagePrivate(page);
>> +               set_page_private(page, info);
>> +               atomic_inc(&page->_count);
>> +       } else
>> +               atomic_inc(&page->_count);
>>   }
>>
>>   /* reference to __meminit __free_pages_bootmem is valid
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
