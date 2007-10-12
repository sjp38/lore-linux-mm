Date: Fri, 12 Oct 2007 11:20:02 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 001/002] Make description of memory hotplug notifier in document
In-Reply-To: <20071012111008.B995.Y-GOTO@jp.fujitsu.com>
References: <20071012111008.B995.Y-GOTO@jp.fujitsu.com>
Message-Id: <20071012111830.B997.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add description about event notification callback routine to the document.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 Documentation/memory-hotplug.txt |   56 ++++++++++++++++++++++++++++++++++++---
 1 file changed, 53 insertions(+), 3 deletions(-)

Index: current/Documentation/memory-hotplug.txt
===================================================================
--- current.orig/Documentation/memory-hotplug.txt
+++ current/Documentation/memory-hotplug.txt
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
@@ -307,8 +309,68 @@ Need more implementation yet....
  - Notification completion of remove works by OS to firmware.
  - Guard from remove if not yet.
 
+--------------------------------
+8. Memory hotplug event notifier
+--------------------------------
+Memory hotplug has event notifer. There are 6 types of notification.
+
+MEMORY_GOING_ONLINE
+  This is notified before memory online. If some structures must be prepared
+  for new memory, it should be done at this event's callback.
+  The new onlining memory can't be used yet.
+  
+MEMORY_CANCEL_ONLINE
+  If memory online fails, this event is notified for rollback of setting at
+  MEMORY_GOING_ONLINE.
+  (Currently, this event is notified only the case which a callback routine
+   of MEMORY_GOING_ONLINE fails).
+
+MEMORY_ONLINE
+  This event is called when memory online is completed. The page allocator uses
+  new memory area before this notification. In other words, callback routine
+  use new memory area via page allocator.
+  The failures of callbacks of this notification will be ignored.
+
+MEMORY_GOING_OFFLINE
+  This is notified on halfway of memory offline. The offlining pages are
+  isolated. In other words, the page allocater doesn't allocate new pages from
+  offlining memory area at this time. If callback routine freed some pages,
+  they are not used by the page allocator.
+  This is good place for shrinking cache. (If possible, it is desirable to
+  migrate to other area.)
+
+MEMORY_CANCEL_OFFLINE
+  If memory offline fails, this event is notified for rollback against
+  MEMORY_GOING_OFFLINE. The page allocator will use target memory area after
+  this callback again.
+
+MEMORY_OFFLINE
+  This is notified after memory offline completed. The failures of callbacks
+  of this notification will be ignored. Callback routine can return structures
+  for offlined memory.
+  If the node which has offlined memory,
+	
+A callback routine can be registered by 
+  hotplug_memory_notifier(callback_func, priority).
+
+The second argument of callback function (action) is event types of above.
+The third argument is passed by pointer of struct memory_notify.
+
+struct memory_notify {
+	unsigned long start_pfn;
+	unsigned long nr_pages;
+	int status_change_nid;
+};
+start_pfn is start pfn of online/offline memory.
+nr_pages is # of pages of online/offline memory.
+status_change_nid is set node id when N_HIGH_MEMORY of nodemask is (will be)
+set/clear. It means a new(memoryless) node gets new memory by online and a
+node lose all memory. If this is -1, then nodemask status is not changed.
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
