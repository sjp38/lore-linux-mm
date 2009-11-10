Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3357D6B0062
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:36:49 -0500 (EST)
Subject: [PATCH v3 1/5] mm: add numa node symlink for memory section in sysfs
From: Alex Chiang <achiang@hp.com>
Date: Tue, 10 Nov 2009 15:36:44 -0700
Message-ID: <20091110223644.25636.77587.stgit@bob.kio>
In-Reply-To: <20091110223154.25636.48462.stgit@bob.kio>
References: <20091110223154.25636.48462.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Commit c04fc586c (mm: show node to memory section relationship with
symlinks in sysfs) created symlinks from nodes to memory sections, e.g.

/sys/devices/system/node/node1/memory135 -> ../../memory/memory135

If you're examining the memory section though and are wondering what
node it might belong to, you can find it by grovelling around in
sysfs, but it's a little cumbersome.

Add a reverse symlink for each memory section that points back to the
node to which it belongs.

Cc: Gary Hade <garyhade@us.ibm.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---

 Documentation/ABI/testing/sysfs-devices-memory |   14 +++++++++++++-
 Documentation/memory-hotplug.txt               |   11 +++++++----
 drivers/base/node.c                            |   11 ++++++++++-
 3 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
index 9fe91c0..bf1627b 100644
--- a/Documentation/ABI/testing/sysfs-devices-memory
+++ b/Documentation/ABI/testing/sysfs-devices-memory
@@ -60,6 +60,19 @@ Description:
 Users:		hotplug memory remove tools
 		https://w3.opensource.ibm.com/projects/powerpc-utils/
 
+
+What:		/sys/devices/system/memoryX/nodeY
+Date:		October 2009
+Contact:	Linux Memory Management list <linux-mm@kvack.org>
+Description:
+		When CONFIG_NUMA is enabled, a symbolic link that
+		points to the corresponding NUMA node directory.
+
+		For example, the following symbolic link is created for
+		memory section 9 on node0:
+		/sys/devices/system/memory/memory9/node0 -> ../../node/node0
+
+
 What:		/sys/devices/system/node/nodeX/memoryY
 Date:		September 2008
 Contact:	Gary Hade <garyhade@us.ibm.com>
@@ -70,4 +83,3 @@ Description:
 		memory section directory.  For example, the following symbolic
 		link is created for memory section 9 on node0.
 		/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
-
diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index bbc8a6a..57e7e9c 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -160,12 +160,15 @@ Under each section, you can see 4 files.
 NOTE:
   These directories/files appear after physical memory hotplug phase.
 
-If CONFIG_NUMA is enabled the
-/sys/devices/system/memory/memoryXXX memory section
-directories can also be accessed via symbolic links located in
-the /sys/devices/system/node/node* directories.  For example:
+If CONFIG_NUMA is enabled the memoryXXX/ directories can also be accessed
+via symbolic links located in the /sys/devices/system/node/node* directories.
+
+For example:
 /sys/devices/system/node/node0/memory9 -> ../../memory/memory9
 
+A backlink will also be created:
+/sys/devices/system/memory/memory9/node0 -> ../../node/node0
+
 --------------------------------
 4. Physical memory hot-add phase
 --------------------------------
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 1fe5536..3108b21 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -268,6 +268,7 @@ static int get_nid_for_pfn(unsigned long pfn)
 /* register memory section under specified node if it spans that node */
 int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
 {
+	int ret;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
 	if (!mem_blk)
@@ -284,9 +285,15 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
 			continue;
 		if (page_nid != nid)
 			continue;
-		return sysfs_create_link_nowarn(&node_devices[nid].sysdev.kobj,
+		ret = sysfs_create_link_nowarn(&node_devices[nid].sysdev.kobj,
 					&mem_blk->sysdev.kobj,
 					kobject_name(&mem_blk->sysdev.kobj));
+		if (ret)
+			return ret;
+
+		return sysfs_create_link_nowarn(&mem_blk->sysdev.kobj,
+				&node_devices[nid].sysdev.kobj,
+				kobject_name(&node_devices[nid].sysdev.kobj));
 	}
 	/* mem section does not span the specified node */
 	return 0;
@@ -315,6 +322,8 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
 			continue;
 		sysfs_remove_link(&node_devices[nid].sysdev.kobj,
 			 kobject_name(&mem_blk->sysdev.kobj));
+		sysfs_remove_link(&mem_blk->sysdev.kobj,
+			 kobject_name(&node_devices[nid].sysdev.kobj));
 	}
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
