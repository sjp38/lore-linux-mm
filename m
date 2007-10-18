Date: Thu, 18 Oct 2007 12:23:30 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 001/002](memory hotplug) Make description of memory hotplug notifier in document
In-Reply-To: <20071018120343.5146.Y-GOTO@jp.fujitsu.com>
References: <20071018120343.5146.Y-GOTO@jp.fujitsu.com>
Message-Id: <20071018122104.514A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add description about event notification callback routine to the document.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 Documentation/memory-hotplug.txt |   58 ++++++++++++++++++++++++++++++++++++---
 1 file changed, 55 insertions(+), 3 deletions(-)

Index: current/Documentation/memory-hotplug.txt
===================================================================
--- current.orig/Documentation/memory-hotplug.txt	2007-10-17 15:57:50.000000000 +0900
+++ current/Documentation/memory-hotplug.txt	2007-10-17 21:26:30.000000000 +0900
@@ -2,7 +2,8 @@
 Memory Hotplug
 ==============
 
-Last Updated: Jul 28 2007
+Created:					Jul 28 2007
+Add description of notifier of memory hotplug	Oct 11 2007
 
 This document is about memory hotplug including how-to-use and current status.
 Because Memory Hotplug is still under development, contents of this text will
@@ -24,7 +25,8 @@ be changed often.
   6.1 Memory offline and ZONE_MOVABLE
   6.2. How to offline memory
 7. Physical memory remove
-8. Future Work List
+8. Memory hotplug event notifier
+9. Future Work List
 
 Note(1): x86_64's has special implementation for memory hotplug.
          This text does not describe it.
@@ -307,8 +309,58 @@ Need more implementation yet....
  - Notification completion of remove works by OS to firmware.
  - Guard from remove if not yet.
 
+--------------------------------
+8. Memory hotplug event notifier
+--------------------------------
+Memory hotplug has event notifer. There are 6 types of notification.
+
+MEMORY_GOING_ONLINE
+  Generated before new memory becomes available in order to be able to
+  prepare subsystems to handle memory. The page allocator is still unable
+  to allocate from the new memory.
+
+MEMORY_CANCEL_ONLINE
+  Generated if MEMORY_GOING_ONLINE fails.
+
+MEMORY_ONLINE
+  Generated when memory has succesfully brought online. The callback may
+  allocate pages from the new memory.
+
+MEMORY_GOING_OFFLINE
+  Generated to begin the process of offlining memory. Allocations are no
+  longer possible from the memory but some of the memory to be offlined
+  is still in use. The callback can be used to free memory known to a
+  subsystem from the indicated memory section.
+
+MEMORY_CANCEL_OFFLINE
+  Generated if MEMORY_GOING_OFFLINE fails. Memory is available again from
+  the section that we attempted to offline.
+
+MEMORY_OFFLINE
+  Generated after offlining memory is complete.
+
+A callback routine can be registered by
+  hotplug_memory_notifier(callback_func, priority)
+
+The second argument of callback function (action) is event types of above.
+The third argument is passed by pointer of struct memory_notify.
+
+struct memory_notify {
+       unsigned long start_pfn;
+       unsigned long nr_pages;
+       int status_cahnge_nid;
+}
+
+start_pfn is start_pfn of online/offline memory.
+nr_pages is # of pages of online/offline memory.
+status_change_nid is set node id when N_HIGH_MEMORY of nodemask is (will be)
+set/clear. It means a new(memoryless) node gets new memory by online and a
+node loses all memory. If this is -1, then nodemask status is not changed.
+If status_changed_nid >= 0, callback should create/discard structures for the
+node if necessary.
+
 --------------
-8. Future Work
+9. Future Work
 --------------
   - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
     sysctl or new control file.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
