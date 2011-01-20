Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3488D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:36:54 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0KGRHFY006592
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:27:49 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 64F7A4DE8042
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:33:27 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0KGakN91679436
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:36:46 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0KGaj5b005566
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:36:45 -0500
Message-ID: <4D386498.9080201@austin.ibm.com>
Date: Thu, 20 Jan 2011 10:36:40 -0600
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 0/4] De-couple sysfs memory directories from memory sections
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

This is a re-send of the remaining patches that did not make it
into the last kernel release for de-coupling sysfs memory
directories from memory sections.  The first three patches of the
previous set went in, and this is the remaining patches that
need to be applied.

The patches decouple the concept that a single memory section corresponds
to a single directory in /sys/devices/system/memory/.  On systems
with large amounts of memory (1+ TB) there are performance issues
related to creating the large number of sysfs directories.  For
a powerpc machine with 1 TB of memory we are creating 63,000+
directories.  This is resulting in boot times of around 45-50
minutes for systems with 1 TB of memory and 8+ hours for systems
with 2 TB of memory.  With this patch set applied I am now seeing
boot times of 5 minutes or less.

The root of this issue is in sysfs directory creation. Every time
a directory is created a string compare is done against sibling
directories ( see sysfs_find_dirent() ) to ensure we do not create 
duplicates.  The list of directory nodes in sysfs is kept as an
unsorted list which results in this being an exponentially longer
operation as the number of directories are created.

The solution solved by this patch set is to allow a single
directory in sysfs to span multiple memory sections.  This is
controlled by an optional architecturally defined function
memory_block_size_bytes().  The default definition of this
routine returns a memory block size equal to the memory section
size. This maintains the current layout of sysfs memory
directories as it appears to userspace to remain the same as it
is today.

For architectures that define their own version of this routine,
as is done for powerpc and x86 in this patchset, the view in userspace
would change such that each memoryXXX directory would span
multiple memory sections.  The number of sections spanned would
depend on the value reported by memory_block_size_bytes.

-Nathan Fontenot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
