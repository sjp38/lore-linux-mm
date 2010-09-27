Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA8F6B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:28:58 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8RJDKHg013164
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:13:20 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8RJSuVw354200
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:28:56 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8RJStGN005417
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 15:28:56 -0400
Message-ID: <4CA0F076.1070803@austin.ibm.com>
Date: Mon, 27 Sep 2010 14:28:54 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 8/8] v2 Update memory hotplug documentation
References: <4CA0EBEB.1030204@austin.ibm.com>
In-Reply-To: <4CA0EBEB.1030204@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Update the memory hotplug documentation to reflect the new behaviors of
memory blocks reflected in sysfs.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

---
 Documentation/memory-hotplug.txt |   46 +++++++++++++++++++++++++--------------
 1 file changed, 30 insertions(+), 16 deletions(-)

Index: linux-next/Documentation/memory-hotplug.txt
===================================================================
--- linux-next.orig/Documentation/memory-hotplug.txt	2010-09-27 13:49:33.000000000 -0500
+++ linux-next/Documentation/memory-hotplug.txt	2010-09-27 13:50:48.000000000 -0500
@@ -126,36 +126,50 @@
 --------------------------------
 4 sysfs files for memory hotplug
 --------------------------------
-All sections have their device information under /sys/devices/system/memory as
+All sections have their device information in sysfs.  Each section is part of
+a memory block under /sys/devices/system/memory as
 
 /sys/devices/system/memory/memoryXXX
-(XXX is section id.)
+(XXX is the section id.)
 
-Now, XXX is defined as start_address_of_section / section_size.
+Now, XXX is defined as (start_address_of_section / section_size) of the first
+section contained in the memory block.  The files 'phys_index' and
+'end_phys_index' under each directory report the beginning and end section id's
+for the memory block covered by the sysfs directory.  It is expected that all
+memory sections in this range are present and no memory holes exist in the
+range. Currently there is no way to determine if there is a memory hole, but
+the existence of one should not affect the hotplug capabilities of the memory
+block.
 
 For example, assume 1GiB section size. A device for a memory starting at
 0x100000000 is /sys/device/system/memory/memory4
 (0x100000000 / 1Gib = 4)
 This device covers address range [0x100000000 ... 0x140000000)
 
-Under each section, you can see 4 files.
+Under each section, you can see 5 files.
 
-/sys/devices/system/memory/memoryXXX/phys_index
+/sys/devices/system/memory/memoryXXX/start_phys_index
+/sys/devices/system/memory/memoryXXX/end_phys_index
 /sys/devices/system/memory/memoryXXX/phys_device
 /sys/devices/system/memory/memoryXXX/state
 /sys/devices/system/memory/memoryXXX/removable
 
-'phys_index' : read-only and contains section id, same as XXX.
-'state'      : read-write
-               at read:  contains online/offline state of memory.
-               at write: user can specify "online", "offline" command
-'phys_device': read-only: designed to show the name of physical memory device.
-               This is not well implemented now.
-'removable'  : read-only: contains an integer value indicating
-               whether the memory section is removable or not
-               removable.  A value of 1 indicates that the memory
-               section is removable and a value of 0 indicates that
-               it is not removable.
+'phys_index'      : read-only and contains section id of the first section
+		    in the memory block, same as XXX.
+'end_phys_index'  : read-only and contains section id of the last section
+		    in the memory block.
+'state'           : read-write
+                    at read:  contains online/offline state of memory.
+                    at write: user can specify "online", "offline" command
+                    which will be performed on al sections in the block.
+'phys_device'     : read-only: designed to show the name of physical memory
+                    device.  This is not well implemented now.
+'removable'       : read-only: contains an integer value indicating
+                    whether the memory block is removable or not
+                    removable.  A value of 1 indicates that the memory
+                    block is removable and a value of 0 indicates that
+                    it is not removable. A memory block is removable only if
+                    every section in the block is removable.
 
 NOTE:
   These directories/files appear after physical memory hotplug phase.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
