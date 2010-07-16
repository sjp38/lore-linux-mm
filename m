Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 391136B02A6
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 11:36:45 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6GFO5Qh011465
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 11:24:05 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6GFabEk1908924
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 11:36:37 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6GFaaWR018530
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 12:36:36 -0300
Message-ID: <4C407C83.7020708@austin.ibm.com>
Date: Fri, 16 Jul 2010 10:36:35 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] v2 Create new 'end_phys_index' file
References: <4C3F53D1.3090001@austin.ibm.com>	<4C3F55BC.4020600@austin.ibm.com> <20100716090857.5e5c91a3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100716090857.5e5c91a3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On 07/15/2010 07:08 PM, KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Jul 2010 13:38:52 -0500
> Nathan Fontenot <nfont@austin.ibm.com> wrote:
> 
>> Add a new 'end_phys_index' file to each memory sysfs directory to
>> report the physical index of the last memory section
>> covered by the sysfs directory.
>>
>> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> 
> Does memory_block have to be contiguous between [phys_index, end_phys_index] ?
> Should we provide "# of sections" or "amount of memory under a block" ?

Good point.  There is nothing that guarantees that a memory block contains
the contiguous memory sections [phys_index, end_phys_index].  Should there be
a 'memory_sections' file that list the memory sections present in a memory block?
Something along the lines of;

#> cat memory0/memory_sections
0,1,2,3

This could be done instead of the end_phys_index file.

-Nathan
 
> 
> No objections to end_phys_index...buf plz fix diff style.
> 
> Thanks,
> -Kame
> 
> 
>> ---
>>  drivers/base/memory.c  |   14 +++++++++++++-
>>  include/linux/memory.h |    3 +++
>>  2 files changed, 16 insertions(+), 1 deletion(-)
>>
>> Index: linux-2.6/drivers/base/memory.c
>> ===================================================================
>> --- linux-2.6.orig/drivers/base/memory.c	2010-07-15 09:55:54.000000000 -0500
>> +++ linux-2.6/drivers/base/memory.c	2010-07-15 09:56:05.000000000 -0500
>> @@ -121,7 +121,15 @@
>>  {
>>  	struct memory_block *mem =
>>  		container_of(dev, struct memory_block, sysdev);
>> -	return sprintf(buf, "%08lx\n", mem->phys_index);
>> +	return sprintf(buf, "%08lx\n", mem->start_phys_index);
>> +}
>> +
>> +static ssize_t show_mem_end_phys_index(struct sys_device *dev,
>> +			struct sysdev_attribute *attr, char *buf)
>> +{
>> +	struct memory_block *mem =
>> +		container_of(dev, struct memory_block, sysdev);
>> +	return sprintf(buf, "%08lx\n", mem->end_phys_index);
>>  }
>>  
>>  /*
>> @@ -321,6 +329,7 @@
>>  }
>>  
>>  static SYSDEV_ATTR(phys_index, 0444, show_mem_phys_index, NULL);
>> +static SYSDEV_ATTR(end_phys_index, 0444, show_mem_end_phys_index, NULL);
>>  static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
>>  static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
>>  static SYSDEV_ATTR(removable, 0444, show_mem_removable, NULL);
>> @@ -533,6 +542,8 @@
>>  		if (!ret)
>>  			ret = mem_create_simple_file(mem, phys_index);
>>  		if (!ret)
>> +			ret = mem_create_simple_file(mem, end_phys_index);
>> +		if (!ret)
>>  			ret = mem_create_simple_file(mem, state);
>>  		if (!ret)
>>  			ret = mem_create_simple_file(mem, phys_device);
>> @@ -577,6 +588,7 @@
>>  	if (list_empty(&mem->sections)) {
>>  		unregister_mem_sect_under_nodes(mem);
>>  		mem_remove_simple_file(mem, phys_index);
>> +		mem_remove_simple_file(mem, end_phys_index);
>>  		mem_remove_simple_file(mem, state);
>>  		mem_remove_simple_file(mem, phys_device);
>>  		mem_remove_simple_file(mem, removable);
>> Index: linux-2.6/include/linux/memory.h
>> ===================================================================
>> --- linux-2.6.orig/include/linux/memory.h	2010-07-15 09:54:06.000000000 -0500
>> +++ linux-2.6/include/linux/memory.h	2010-07-15 09:56:05.000000000 -0500
>> @@ -29,6 +29,9 @@
>>  
>>  struct memory_block {
>>  	unsigned long state;
>> +	unsigned long start_phys_index;
>> +	unsigned long end_phys_index;
>> +
>>  	/*
>>  	 * This serializes all state change requests.  It isn't
>>  	 * held during creation because the control files are
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
