Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 838BA6B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:17:53 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8SHvkXl015014
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 13:57:46 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8SIHnNn1622190
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:17:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8SIHm7i006965
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 15:17:49 -0300
Message-ID: <4CA2313D.2030508@austin.ibm.com>
Date: Tue, 28 Sep 2010 13:17:33 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] v2 De-Couple sysfs memory directories from memory
 sections
References: <4CA0EBEB.1030204@austin.ibm.com> <20100928123848.GH14068@sgi.com>
In-Reply-To: <20100928123848.GH14068@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 09/28/2010 07:38 AM, Robin Holt wrote:
> I was tasked with looking at a slowdown in similar sized SGI machines
> booting x86_64.  Jack Steiner had already looked into the memory_dev_init.
> I was looking at link_mem_sections().
> 
> I made a dramatic improvement on a 16TB machine in that function by
> merely caching the most recent memory section and checking to see if
> the next memory section happens to be the subsequent in the linked list
> of kobjects.
> 
> That simple cache reduced the time for link_mem_sections from 1 hour 27
> minutes down to 46 seconds.

Nice!

> 
> I would like to propose we implement something along those lines also,
> but I am currently swamped.  I can probably get you a patch tomorrow
> afternoon that applies at the end of this set.

Should this be done as a separate patch?  This patch set concentrates on
updates to the memory code with the node updates only being done due to the
memory changes.

I think its a good idea to do the caching and have no problem adding on to
this patchset if no one else has any objections.

-Nathan

> 
> Thanks,
> Robin
> 
> On Mon, Sep 27, 2010 at 02:09:31PM -0500, Nathan Fontenot wrote:
>> This set of patches decouples the concept that a single memory
>> section corresponds to a single directory in 
>> /sys/devices/system/memory/.  On systems
>> with large amounts of memory (1+ TB) there are perfomance issues
>> related to creating the large number of sysfs directories.  For
>> a powerpc machine with 1 TB of memory we are creating 63,000+
>> directories.  This is resulting in boot times of around 45-50
>> minutes for systems with 1 TB of memory and 8 hours for systems
>> with 2 TB of memory.  With this patch set applied I am now seeing
>> boot times of 5 minutes or less.
>>
>> The root of this issue is in sysfs directory creation. Every time
>> a directory is created a string compare is done against all sibling
>> directories to ensure we do not create duplicates.  The list of
>> directory nodes in sysfs is kept as an unsorted list which results
>> in this being an exponentially longer operation as the number of
>> directories are created.
>>
>> The solution solved by this patch set is to allow a single
>> directory in sysfs to span multiple memory sections.  This is
>> controlled by an optional architecturally defined function
>> memory_block_size_bytes().  The default definition of this
>> routine returns a memory block size equal to the memory section
>> size. This maintains the current layout of sysfs memory
>> directories as it appears to userspace to remain the same as it
>> is today.
>>
>> For architectures that define their own version of this routine,
>> as is done for powerpc in this patchset, the view in userspace
>> would change such that each memoryXXX directory would span
>> multiple memory sections.  The number of sections spanned would
>> depend on the value reported by memory_block_size_bytes.
>>
>> In both cases a new file 'end_phys_index' is created in each
>> memoryXXX directory.  This file will contain the physical id
>> of the last memory section covered by the sysfs directory.  For
>> the default case, the value in 'end_phys_index' will be the same
>> as in the existing 'phys_index' file.
>>
>> This version of the patch set includes an update to to properly
>> report block_size_bytes, phys_index, and end_phys_index.  Additionally,
>> the patch that adds the end_phys_index sysfs file is now patch 5/8
>> instead of being patch 2/8 as in the previous version of the patches.
>>
>> -Nathan Fontenot
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
