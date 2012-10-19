Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 853936B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 06:39:01 -0400 (EDT)
Message-ID: <50812F13.20503@cn.fujitsu.com>
Date: Fri, 19 Oct 2012 18:44:35 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/10] memory-hotplug : check whether memory is offline
 or not when removing memory
References: <506E43E0.70507@jp.fujitsu.com> <506E451E.1050403@jp.fujitsu.com> <CAHGf_=rVDm-JygjPoLHbmF28Dgd52HFc4-b5KCxhEieG60okuw@mail.gmail.com>
In-Reply-To: <CAHGf_=rVDm-JygjPoLHbmF28Dgd52HFc4-b5KCxhEieG60okuw@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

At 10/06/2012 03:27 AM, KOSAKI Motohiro Wrote:
> On Thu, Oct 4, 2012 at 10:25 PM, Yasuaki Ishimatsu
> <isimatu.yasuaki@jp.fujitsu.com> wrote:
>> When calling remove_memory(), the memory should be offline. If the function
>> is used to online memory, kernel panic may occur.
>>
>> So the patch checks whether memory is offline or not.
> 
> You don't explain WHY we need the check.

This patch is no necessary now, because the newest kernel has checked
it.

Thanks
Wen Congyang

> 
> 
>> CC: David Rientjes <rientjes@google.com>
>> CC: Jiang Liu <liuj97@gmail.com>
>> CC: Len Brown <len.brown@intel.com>
>> CC: Christoph Lameter <cl@linux.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> ---
>>  drivers/base/memory.c  |   39 +++++++++++++++++++++++++++++++++++++++
>>  include/linux/memory.h |    5 +++++
>>  mm/memory_hotplug.c    |   17 +++++++++++++++--
>>  3 files changed, 59 insertions(+), 2 deletions(-)
>>
>> Index: linux-3.6/drivers/base/memory.c
>> ===================================================================
>> --- linux-3.6.orig/drivers/base/memory.c        2012-10-04 14:22:57.000000000 +0900
>> +++ linux-3.6/drivers/base/memory.c     2012-10-04 14:45:46.653585860 +0900
>> @@ -70,6 +70,45 @@ void unregister_memory_isolate_notifier(
>>  }
>>  EXPORT_SYMBOL(unregister_memory_isolate_notifier);
>>
>> +bool is_memblk_offline(unsigned long start, unsigned long size)
> 
> Don't use memblk. Usually memblk mean struct numa_meminfo for x86/numa.
> Maybe memory_range_offlined() is better.
> 
> And, this function don't take struct memory_block, then this file may be no good
> place.
> 
> And you need to write down function comment.
> 
> 
>> +{
>> +       struct memory_block *mem = NULL;
>> +       struct mem_section *section;
>> +       unsigned long start_pfn, end_pfn;
>> +       unsigned long pfn, section_nr;
>> +
>> +       start_pfn = PFN_DOWN(start);
>> +       end_pfn = PFN_UP(start + size);
>> +
>> +       for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>> +               section_nr = pfn_to_section_nr(pfn);
>> +               if (!present_section_nr(section_nr))
>> +                       continue;
>> +
>> +               section = __nr_to_section(section_nr);
>> +               /* same memblock? */
>> +               if (mem)
>> +                       if ((section_nr >= mem->start_section_nr) &&
>> +                           (section_nr <= mem->end_section_nr))
>> +                               continue;
>> +
>> +               mem = find_memory_block_hinted(section, mem);
>> +               if (!mem)
>> +                       continue;
>> +               if (mem->state == MEM_OFFLINE)
>> +                       continue;
>> +
>> +               kobject_put(&mem->dev.kobj);
>> +               return false;
>> +       }
>> +
>> +       if (mem)
>> +               kobject_put(&mem->dev.kobj);
>> +
>> +       return true;
>> +}
>> +EXPORT_SYMBOL(is_memblk_offline);
>> +
>>  /*
>>   * register_memory - Setup a sysfs device for a memory block
>>   */
>> Index: linux-3.6/include/linux/memory.h
>> ===================================================================
>> --- linux-3.6.orig/include/linux/memory.h       2012-10-02 18:00:22.000000000 +0900
>> +++ linux-3.6/include/linux/memory.h    2012-10-04 14:44:40.902581028 +0900
>> @@ -106,6 +106,10 @@ static inline int memory_isolate_notify(
>>  {
>>         return 0;
>>  }
>> +static inline bool is_memblk_offline(unsigned long start, unsigned long size)
>> +{
>> +       return false;
>> +}
>>  #else
>>  extern int register_memory_notifier(struct notifier_block *nb);
>>  extern void unregister_memory_notifier(struct notifier_block *nb);
>> @@ -120,6 +124,7 @@ extern int memory_isolate_notify(unsigne
>>  extern struct memory_block *find_memory_block_hinted(struct mem_section *,
>>                                                         struct memory_block *);
>>  extern struct memory_block *find_memory_block(struct mem_section *);
>> +extern bool is_memblk_offline(unsigned long start, unsigned long size);
>>  #define CONFIG_MEM_BLOCK_SIZE  (PAGES_PER_SECTION<<PAGE_SHIFT)
>>  enum mem_add_context { BOOT, HOTPLUG };
>>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>> Index: linux-3.6/mm/memory_hotplug.c
>> ===================================================================
>> --- linux-3.6.orig/mm/memory_hotplug.c  2012-10-04 14:31:08.000000000 +0900
>> +++ linux-3.6/mm/memory_hotplug.c       2012-10-04 14:58:22.449687986 +0900
>> @@ -1045,8 +1045,21 @@ int offline_memory(u64 start, u64 size)
>>
>>  int remove_memory(int nid, u64 start, u64 size)
>>  {
> 
> Your remove_memory() don't remove anything. that's strange.
> 
> 
>> -       /* It is not implemented yet*/
>> -       return 0;
>> +       int ret = 0;
>> +       lock_memory_hotplug();
>> +       /*
>> +        * The memory might become online by other task, even if you offine it.
>> +        * So we check whether the memory has been onlined or not.
>> +        */
>> +       if (!is_memblk_offline(start, size)) {
>> +               pr_warn("memory removing [mem %#010llx-%#010llx] failed, "
>> +                       "because the memmory range is online\n",
>> +                       start, start + size);
> 
> No good warning. You should output which memory block can't be
> offlined, I think.
> 
> 
>> +               ret = -EAGAIN;
>> +       }
>> +
>> +       unlock_memory_hotplug();
>> +       return ret;
>>  }
>>  EXPORT_SYMBOL_GPL(remove_memory);
>>  #else
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
