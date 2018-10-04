Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id DDCEF6B026B
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 18:11:24 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id p11-v6so7309824oih.17
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 15:11:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g1-v6si3137101otb.294.2018.10.04.15.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 15:11:23 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w94M9FCT124116
	for <linux-mm@kvack.org>; Thu, 4 Oct 2018 18:11:22 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mwrs9g1qd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Oct 2018 18:11:22 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Oct 2018 23:11:20 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/2] docs/vm: split memory hotplug notifier description to Documentation/core-api
Date: Fri,  5 Oct 2018 01:11:01 +0300
In-Reply-To: <1538691061-31289-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1538691061-31289-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1538691061-31289-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The memory hotplug notifier description is about kernel internals rather
than admin/user visible API. Place it appropriately.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/admin-guide/mm/memory-hotplug.rst    | 83 ---------------------
 Documentation/core-api/index.rst                   |  2 +
 Documentation/core-api/memory-hotplug-notifier.rst | 84 ++++++++++++++++++++++
 3 files changed, 86 insertions(+), 83 deletions(-)
 create mode 100644 Documentation/core-api/memory-hotplug-notifier.rst

diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
index a33090c..0b9c83e 100644
--- a/Documentation/admin-guide/mm/memory-hotplug.rst
+++ b/Documentation/admin-guide/mm/memory-hotplug.rst
@@ -31,7 +31,6 @@ be changed often.
     6.1 Memory offline and ZONE_MOVABLE
     6.2. How to offline memory
   7. Physical memory remove
-  8. Memory hotplug event notifier
   9. Future Work List
 
 
@@ -414,88 +413,6 @@ Need more implementation yet....
  - Notification completion of remove works by OS to firmware.
  - Guard from remove if not yet.
 
-Memory hotplug event notifier
-=============================
-
-Hotplugging events are sent to a notification queue.
-
-There are six types of notification defined in ``include/linux/memory.h``:
-
-MEM_GOING_ONLINE
-  Generated before new memory becomes available in order to be able to
-  prepare subsystems to handle memory. The page allocator is still unable
-  to allocate from the new memory.
-
-MEM_CANCEL_ONLINE
-  Generated if MEMORY_GOING_ONLINE fails.
-
-MEM_ONLINE
-  Generated when memory has successfully brought online. The callback may
-  allocate pages from the new memory.
-
-MEM_GOING_OFFLINE
-  Generated to begin the process of offlining memory. Allocations are no
-  longer possible from the memory but some of the memory to be offlined
-  is still in use. The callback can be used to free memory known to a
-  subsystem from the indicated memory block.
-
-MEM_CANCEL_OFFLINE
-  Generated if MEMORY_GOING_OFFLINE fails. Memory is available again from
-  the memory block that we attempted to offline.
-
-MEM_OFFLINE
-  Generated after offlining memory is complete.
-
-A callback routine can be registered by calling::
-
-  hotplug_memory_notifier(callback_func, priority)
-
-Callback functions with higher values of priority are called before callback
-functions with lower values.
-
-A callback function must have the following prototype::
-
-  int callback_func(
-    struct notifier_block *self, unsigned long action, void *arg);
-
-The first argument of the callback function (self) is a pointer to the block
-of the notifier chain that points to the callback function itself.
-The second argument (action) is one of the event types described above.
-The third argument (arg) passes a pointer of struct memory_notify::
-
-	struct memory_notify {
-		unsigned long start_pfn;
-		unsigned long nr_pages;
-		int status_change_nid_normal;
-		int status_change_nid_high;
-		int status_change_nid;
-	}
-
-- start_pfn is start_pfn of online/offline memory.
-- nr_pages is # of pages of online/offline memory.
-- status_change_nid_normal is set node id when N_NORMAL_MEMORY of nodemask
-  is (will be) set/clear, if this is -1, then nodemask status is not changed.
-- status_change_nid_high is set node id when N_HIGH_MEMORY of nodemask
-  is (will be) set/clear, if this is -1, then nodemask status is not changed.
-- status_change_nid is set node id when N_MEMORY of nodemask is (will be)
-  set/clear. It means a new(memoryless) node gets new memory by online and a
-  node loses all memory. If this is -1, then nodemask status is not changed.
-
-  If status_changed_nid* >= 0, callback should create/discard structures for the
-  node if necessary.
-
-The callback routine shall return one of the values
-NOTIFY_DONE, NOTIFY_OK, NOTIFY_BAD, NOTIFY_STOP
-defined in ``include/linux/notifier.h``
-
-NOTIFY_DONE and NOTIFY_OK have no effect on the further processing.
-
-NOTIFY_BAD is used as response to the MEM_GOING_ONLINE, MEM_GOING_OFFLINE,
-MEM_ONLINE, or MEM_OFFLINE action to cancel hotplugging. It stops
-further processing of the notification queue.
-
-NOTIFY_STOP stops further processing of the notification queue.
-
 Future Work
 ===========
 
diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index 165d7688..4f8a426 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -32,6 +32,8 @@ Core utilities
    gfp_mask-from-fs-io
    timekeeping
    boot-time-mm
+   memory-hotplug-notifier
+
 
 Interfaces for kernel debugging
 ===============================
diff --git a/Documentation/core-api/memory-hotplug-notifier.rst b/Documentation/core-api/memory-hotplug-notifier.rst
new file mode 100644
index 0000000..35347cc
--- /dev/null
+++ b/Documentation/core-api/memory-hotplug-notifier.rst
@@ -0,0 +1,84 @@
+.. _memory_hotplug_notifier:
+
+=============================
+Memory hotplug event notifier
+=============================
+
+Hotplugging events are sent to a notification queue.
+
+There are six types of notification defined in ``include/linux/memory.h``:
+
+MEM_GOING_ONLINE
+  Generated before new memory becomes available in order to be able to
+  prepare subsystems to handle memory. The page allocator is still unable
+  to allocate from the new memory.
+
+MEM_CANCEL_ONLINE
+  Generated if MEM_GOING_ONLINE fails.
+
+MEM_ONLINE
+  Generated when memory has successfully brought online. The callback may
+  allocate pages from the new memory.
+
+MEM_GOING_OFFLINE
+  Generated to begin the process of offlining memory. Allocations are no
+  longer possible from the memory but some of the memory to be offlined
+  is still in use. The callback can be used to free memory known to a
+  subsystem from the indicated memory block.
+
+MEM_CANCEL_OFFLINE
+  Generated if MEM_GOING_OFFLINE fails. Memory is available again from
+  the memory block that we attempted to offline.
+
+MEM_OFFLINE
+  Generated after offlining memory is complete.
+
+A callback routine can be registered by calling::
+
+  hotplug_memory_notifier(callback_func, priority)
+
+Callback functions with higher values of priority are called before callback
+functions with lower values.
+
+A callback function must have the following prototype::
+
+  int callback_func(
+    struct notifier_block *self, unsigned long action, void *arg);
+
+The first argument of the callback function (self) is a pointer to the block
+of the notifier chain that points to the callback function itself.
+The second argument (action) is one of the event types described above.
+The third argument (arg) passes a pointer of struct memory_notify::
+
+	struct memory_notify {
+		unsigned long start_pfn;
+		unsigned long nr_pages;
+		int status_change_nid_normal;
+		int status_change_nid_high;
+		int status_change_nid;
+	}
+
+- start_pfn is start_pfn of online/offline memory.
+- nr_pages is # of pages of online/offline memory.
+- status_change_nid_normal is set node id when N_NORMAL_MEMORY of nodemask
+  is (will be) set/clear, if this is -1, then nodemask status is not changed.
+- status_change_nid_high is set node id when N_HIGH_MEMORY of nodemask
+  is (will be) set/clear, if this is -1, then nodemask status is not changed.
+- status_change_nid is set node id when N_MEMORY of nodemask is (will be)
+  set/clear. It means a new(memoryless) node gets new memory by online and a
+  node loses all memory. If this is -1, then nodemask status is not changed.
+
+  If status_changed_nid* >= 0, callback should create/discard structures for the
+  node if necessary.
+
+The callback routine shall return one of the values
+NOTIFY_DONE, NOTIFY_OK, NOTIFY_BAD, NOTIFY_STOP
+defined in ``include/linux/notifier.h``
+
+NOTIFY_DONE and NOTIFY_OK have no effect on the further processing.
+
+NOTIFY_BAD is used as response to the MEM_GOING_ONLINE, MEM_GOING_OFFLINE,
+MEM_ONLINE, or MEM_OFFLINE action to cancel hotplugging. It stops
+further processing of the notification queue.
+
+NOTIFY_STOP stops further processing of the notification queue.
-- 
2.7.4
