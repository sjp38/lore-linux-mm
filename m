Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 58824620113
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:24:18 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o73DE9p3009841
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 09:14:09 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o73DWVNi136996
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 09:32:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o73DWVpu010580
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 10:32:31 -0300
Message-ID: <4C581A6D.9030908@austin.ibm.com>
Date: Tue, 03 Aug 2010 08:32:29 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 0/9] v4  De-couple sysfs memory directories from memory sections
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This set of patches de-couples the idea that there is a single
directory in sysfs for each memory section.  The intent of the
patches is to reduce the number of sysfs directories created to
resolve a boot-time performance issue.  On very large systems
boot time are getting very long (as seen on powerpc hardware)
due to the enormous number of sysfs directories being created.
On a system with 1 TB of memory we create ~63,000 directories.
For even larger systems boot times are being measured in hours.

This set of patches allows for each directory created in sysfs
to cover more than one memory section.  The default behavior for
sysfs directory creation is the same, in that each directory
represents a single memory section.  A new file 'end_phys_index'
in each directory contains the physical_id of the last memory
section covered by the directory so that users can easily
determine the memory section range of a directory.

Updates for version 4 of the patchset includes an additional
patch [4/9] that introduces a new mutex to be taken for any
add or remove (not hotplug) of memory.  The following updates
are also included.
 
Patch 2/9 Add new phys_index properties
- The start_phys_index property was reverted to the original
  phys_index name.

Patch 3/9 Add section count to memory_block
- Use atomic_dec_and_test()

Patch 7/9 Update the node sysfs code
- Update the inline definition of unregister_mem_sects_under_nodes
  for !CONFIG_NUMA builds.

Patch 8/9 Define memory_block_size_bytes() for ppc/pseries
- Use an unsigned long for getting property value.

Patch 9/9 Update memory-hotplug documentation
- Minor updates for reversion of phys_index property name.

Thanks,

Nathan Fontenot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
