Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EF7CF6B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 10:34:37 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7GEKvts030474
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 10:20:57 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7GEYWO6242084
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 10:34:32 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7GEY8KA020554
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 08:34:09 -0600
Message-ID: <4C694C60.6030207@austin.ibm.com>
Date: Mon, 16 Aug 2010 09:34:08 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] v5 De-couple sysfs memory directories from memory
 sections
References: <4C60407C.2080608@austin.ibm.com> <20100812120816.e97d8b9e.akpm@linux-foundation.org>
In-Reply-To: <20100812120816.e97d8b9e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On 08/12/2010 02:08 PM, Andrew Morton wrote:
> On Mon, 09 Aug 2010 12:53:00 -0500
> Nathan Fontenot <nfont@austin.ibm.com> wrote:
> 
>> This set of patches de-couples the idea that there is a single
>> directory in sysfs for each memory section.  The intent of the
>> patches is to reduce the number of sysfs directories created to
>> resolve a boot-time performance issue.  On very large systems
>> boot time are getting very long (as seen on powerpc hardware)
>> due to the enormous number of sysfs directories being created.
>> On a system with 1 TB of memory we create ~63,000 directories.
>> For even larger systems boot times are being measured in hours.
> 
> And those "hours" are mainly due to this problem, I assume.

Yes, those hours are spent creating the sysfs directories for each
of the memory sections.

> 
>> This set of patches allows for each directory created in sysfs
>> to cover more than one memory section.  The default behavior for
>> sysfs directory creation is the same, in that each directory
>> represents a single memory section.  A new file 'end_phys_index'
>> in each directory contains the physical_id of the last memory
>> section covered by the directory so that users can easily
>> determine the memory section range of a directory.
> 
> What you're proposing appears to be a non-back-compatible
> userspace-visible change.  This is a big issue!
> 
> It's not an unresolvable issue, as this is a must-fix problem.  But you
> should tell us what your proposal is to prevent breakage of existing
> installations.  A Kconfig option would be good, but a boot-time kernel
> command line option which selects the new format would be much better.

This shouldn't break existing installations, unless an architecture chooses
to do so.  With my patch only the powerpc/pseries arch is updated such that
what is seen in userspace is different.

The default behavior is maintained for all architectures unless they define
their own version of memory_block_size_bytes().  The default definition of
this routine (defined as __weak in Patch 5/8) sets the memory block size
to the same size it currently is, and thus preserving the exisitng 1 sysfs
directory per memory section.  The only change that will be seen is a new
propery for memory section, end_phys_addr, which will have the same value
as the existing 'phys_addr' property.

> 
> However you didn't mention this issue at all, and it's the most
> important one.
> 
> 
>> Updates for version 5 of the patchset include the following:
>>
>> Patch 4/8 Add mutex for add/remove of memory blocks
>> - Define the mutex using DEFINE_MUTEX macro.
>>
>> Patch 8/8 Update memory-hotplug documentation
>> - Add information concerning memory holes in phys_index..end_phys_index.
> 
> And you forgot to tell us how long those machines boot with the
> patchset applied, which is the entire point of the patchset!

Yes,  I am working on getting more time on our large systems to get
performance numbers with this patch.  I'll post them when I get them.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
