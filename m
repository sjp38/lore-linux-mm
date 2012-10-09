Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id EB5836B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 22:52:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 74DFE3EE0C0
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 11:52:08 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AD8345DE53
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 11:52:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4170945DE4E
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 11:52:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C5661DB803E
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 11:52:08 +0900 (JST)
Received: from g01jpexchyt06.g01.fujitsu.local (g01jpexchyt06.g01.fujitsu.local [10.128.194.45])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B36FA1DB8040
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 11:52:07 +0900 (JST)
Message-ID: <5073913A.3080103@jp.fujitsu.com>
Date: Tue, 9 Oct 2012 11:51:38 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: memory-hotplug : suppres "Trying to free nonexistent resource
 <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>" warning
References: <506D1F1D.9000301@jp.fujitsu.com> <20121005140938.e3e1e196.akpm@linux-foundation.org>
In-Reply-To: <20121005140938.e3e1e196.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com, dave@linux.vnet.ibm.com

Hi Andrew,

2012/10/06 6:09, Andrew Morton wrote:
> On Thu, 4 Oct 2012 14:31:09 +0900
> Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:
>
>> When our x86 box calls __remove_pages(), release_mem_region() shows
>> many warnings. And x86 box cannot unregister iomem_resource.
>>
>> "Trying to free nonexistent resource <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>"
>>
>> release_mem_region() has been changed as called in each PAGES_PER_SECTION
>> chunk since applying a patch(de7f0cba96786c). Because powerpc registers
>> iomem_resource in each PAGES_PER_SECTION chunk. But when I hot add memory
>> on x86 box, iomem_resource is register in each _CRS not PAGES_PER_SECTION
>> chunk. So x86 box unregisters iomem_resource.
>>
>> The patch fixes the problem.
>>
>> --- linux-3.6.orig/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-10-04 14:22:59.833520792 +0900
>> +++ linux-3.6/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-10-04 14:23:05.150521411 +0900
>> @@ -77,7 +77,8 @@ static int pseries_remove_memblock(unsig
>>   {
>>   	unsigned long start, start_pfn;
>>   	struct zone *zone;
>> -	int ret;
>> +	int i, ret;
>> +	int sections_to_remove;
>>
>>   	start_pfn = base >> PAGE_SHIFT;
>>
>> @@ -97,9 +98,13 @@ static int pseries_remove_memblock(unsig
>>   	 * to sysfs "state" file and we can't remove sysfs entries
>>   	 * while writing to it. So we have to defer it to here.
>>   	 */
>> -	ret = __remove_pages(zone, start_pfn, memblock_size >> PAGE_SHIFT);
>> -	if (ret)
>> -		return ret;
>> +	sections_to_remove = (memblock_size >> PAGE_SHIFT) / PAGES_PER_SECTION;
>> +	for (i = 0; i < sections_to_remove; i++) {
>> +		unsigned long pfn = start_pfn + i * PAGES_PER_SECTION;
>> +		ret = __remove_pages(zone, start_pfn,  PAGES_PER_SECTION);
>> +		if (ret)
>> +			return ret;
>> +	}
>
> It is inappropriate that `i' have a signed 32-bit type.  I doubt if
> there's any possibility of an overflow bug here, but using a consistent
> and well-chosen type would eliminate all doubt.
>
> Note that __remove_pages() does use an unsigned long for this, although
> it stupidly calls that variable "i", despite the C programmers'
> expectation that a variable called "i" has type "int".
>
> The same applies to `sections_to_remove', but __remove_pages() went and
> decided to use an `int' for that variable.  Sigh.
>
> Anyway, please have a think, and see if we can come up with the best
> and most accurate choice of types and identifiers in this code.

Your concern is right. Overflow bug may occur in the future.
So I changed type of "i" and "sections_to_remove" to "unsigned long".
Please merge it into your tree instead of previous patch.

__remove_pages() also has same concern. So I'll fix it.

-----------------------------------------------------------------------
When our x86 box calls __remove_pages(), release_mem_region() shows
many warnings. And x86 box cannot unregister iomem_resource.

"Trying to free nonexistent resource <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>"

release_mem_region() has been changed as called in each PAGES_PER_SECTION
chunk since applying a patch(de7f0cba96786c). Because powerpc registers
iomem_resource in each PAGES_PER_SECTION chunk. But when I hot add memory
on x86 box, iomem_resource is register in each _CRS not PAGES_PER_SECTION
chunk. So x86 box unregisters iomem_resource.

The patch fixes the problem.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
  arch/powerpc/platforms/pseries/hotplug-memory.c |   11 ++++++++---
  mm/memory_hotplug.c                             |    4 ++--
  2 files changed, 10 insertions(+), 5 deletions(-)

Index: linux-3.6/arch/powerpc/platforms/pseries/hotplug-memory.c
===================================================================
--- linux-3.6.orig/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-10-05 14:33:09.516197839 +0900
+++ linux-3.6/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-10-09 11:27:50.555709827 +0900
@@ -78,6 +78,7 @@ static int pseries_remove_memblock(unsig
  	unsigned long start, start_pfn;
  	struct zone *zone;
  	int ret;
+	unsigned long i, sections_to_remove;
  
  	start_pfn = base >> PAGE_SHIFT;
  
@@ -97,9 +98,13 @@ static int pseries_remove_memblock(unsig
  	 * to sysfs "state" file and we can't remove sysfs entries
  	 * while writing to it. So we have to defer it to here.
  	 */
-	ret = __remove_pages(zone, start_pfn, memblock_size >> PAGE_SHIFT);
-	if (ret)
-		return ret;
+	sections_to_remove = (memblock_size >> PAGE_SHIFT) / PAGES_PER_SECTION;
+	for (i = 0; i < sections_to_remove; i++) {
+		unsigned long pfn = start_pfn + i * PAGES_PER_SECTION;
+		ret = __remove_pages(zone, start_pfn,  PAGES_PER_SECTION);
+		if (ret)
+			return ret;
+	}
  
  	/*
  	 * Update memory regions for memory remove
Index: linux-3.6/mm/memory_hotplug.c
===================================================================
--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-05 15:21:42.856325965 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-05 15:21:43.047326148 +0900
@@ -596,11 +596,11 @@ int __remove_pages(struct zone *zone, un
  	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
  	BUG_ON(nr_pages % PAGES_PER_SECTION);
  
+	release_mem_region(phys_start_pfn << PAGE_SHIFT, nr_pages * PAGE_SIZE);
+
  	sections_to_remove = nr_pages / PAGES_PER_SECTION;
  	for (i = 0; i < sections_to_remove; i++) {
  		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
-		release_mem_region(pfn << PAGE_SHIFT,
-				   PAGES_PER_SECTION << PAGE_SHIFT);
  		ret = __remove_section(zone, __pfn_to_section(pfn));
  		if (ret)
  			break;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
