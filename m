Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 10B556B004A
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 10:35:39 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8OEGgcP010873
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 10:16:42 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8OEZbCV040688
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 10:35:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8OEZalZ031514
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 10:35:37 -0400
Message-ID: <4C9CB737.9000903@austin.ibm.com>
Date: Fri, 24 Sep 2010 09:35:35 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] De-couple sysfs memory directories from memory sections
References: <4C9A0F8F.2030409@austin.ibm.com> <20100923184002.GM3952@balbir.in.ibm.com>
In-Reply-To: <20100923184002.GM3952@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 09/23/2010 01:40 PM, Balbir Singh wrote:
> * Nathan Fontenot <nfont@austin.ibm.com> [2010-09-22 09:15:43]:
> 
>> This set of patches decouples the concept that a single memory
>> section corresponds to a single directory in 
>> /sys/devices/system/memory/.  On systems
>> with large amounts of memory (1+ TB) there are performance issues
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
> 
> What does this mean for memory hotplug or hotunplug? 
> 

Memory hotplug will function on a memory block size basis.  For
architectures that do not define their own memory_block_size_bytes()
routine, they will get the default size and everything will work
the same as it does today.

For architectures that define their own memory_block_size_bytes()
routine and have multiple memory sections per memory block, hotplug
operations will add or remove all of the memory sections in the memory
memory block.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
