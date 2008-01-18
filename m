Date: Fri, 18 Jan 2008 14:37:18 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC] Document about lowmem_reserve_ratio
Message-Id: <20080118142244.04EF.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

Hello.

I found the documentation about lowmem_reserve_ratio is not written, and
the lower_zone_protection's description remains yet. I fixed it.

I may be something wrong due to misunderstanding. And probably, sentence
is not natural. (I'm not native English speaker.)

So, please review it.

Thanks.

---

Though the lower_zone_protection was changed to lowmem_reserve_ratio,
the document has been not changed.
The lowmem_reserve_ratio seems quite hard to estimate, but there is
no guidance. This patch is to change document for it.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 Documentation/filesystems/proc.txt |   76 +++++++++++++++++++++++++++++--------
 1 file changed, 61 insertions(+), 15 deletions(-)

Index: current/Documentation/filesystems/proc.txt
===================================================================
--- current.orig/Documentation/filesystems/proc.txt	2008-01-17 20:01:37.000000000 +0900
+++ current/Documentation/filesystems/proc.txt	2008-01-18 12:22:10.000000000 +0900
@@ -1311,7 +1311,7 @@
 If non-zero, this sysctl disables the new 32-bit mmap mmap layout - the kernel
 will use the legacy (2.4) layout for all processes.
 
-lower_zone_protection
+lowmem_reserve_ratio
 ---------------------
 
 For some specialised workloads on highmem machines it is dangerous for
@@ -1331,25 +1331,71 @@
 mechanism will also defend that region from allocations which could use
 highmem or lowmem).
 
-The `lower_zone_protection' tunable determines how aggressive the kernel is
-in defending these lower zones.  The default value is zero - no
-protection at all.
+The `lowmem_reserve_ratio' tunable determines how aggressive the kernel is
+in defending these lower zones.
 
 If you have a machine which uses highmem or ISA DMA and your
 applications are using mlock(), or if you are running with no swap then
-you probably should increase the lower_zone_protection setting.
+you probably should change the lowmem_reserve_ratio setting.
 
-The units of this tunable are fairly vague.  It is approximately equal
-to "megabytes," so setting lower_zone_protection=100 will protect around 100
-megabytes of the lowmem zone from user allocations.  It will also make
-those 100 megabytes unavailable for use by applications and by
-pagecache, so there is a cost.
-
-The effects of this tunable may be observed by monitoring
-/proc/meminfo:LowFree.  Write a single huge file and observe the point
-at which LowFree ceases to fall.
+The lowmem_reserve_ratio is an array. You can see them by reading this file.
+-
+% cat /proc/sys/vm/lowmem_reserve_ratio
+256     256     32
+-
+Note: # of this elements is one fewer than number of zones. Because the highest
+      zone's value is not necessary for following calculation.
+
+But, these values are not used directly. The kernel calculates # of protection
+pages for each zones from them. These are shown as array of protection pages
+in /proc/zoneinfo like followings. (This is an example of x86-64 box).
+Each zone has an array of protection pages like this.
+
+-
+Node 0, zone      DMA
+  pages free     1355
+        min      3
+        low      3
+        high     4
+	:
+	:
+    numa_other   0
+        protection: (0, 2004, 2004, 2004)
+	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+  pagesets
+    cpu: 0 pcp: 0
+        :
+-
+These protections are added to score to judge whether this zone should be used
+for page allocation or should be reclaimed.
+
+In this example, if normal pages (index=2) are required to this DMA zone and
+pages_high is used for watermark, the kernel judges this zone should not be
+used because pages_free(1355) is smaller than watermark + protection[2]
+(4 + 2004 = 2008). If this protection value is 0, this zone would be used for
+normal page requirement. If requirement is DMA zone(index=0), protection[0]
+(=0) is used.
+
+zone[i]'s protection[j] is calculated by following exprssion.
+
+(i < j):
+  zone[i]->protection[j]
+  = (total sums of present_pages from zone[i+1] to zone[j] on the node)
+    / lowmem_reserve_ratio[i];
+(i = j):
+   (should not be protected. = 0;
+(i > j):
+   (not necessary, but looks 0)
+
+The default values of lowmem_reserve_ratio[i] are
+    256 (if zone[i] means DMA or DMA32 zone)
+    32  (others).
+As above expression, they are reciprocal number of ratio.
+256 means 1/256. # of protection pages becomes about "0.39%" of total present
+pages of higher zones on the node.
 
-A reasonable value for lower_zone_protection is 100.
+If you would like to protect more pages, smaller values are effective.
+The minimum value is 1 (1/1 -> 100%).
 
 page-cluster
 ------------

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
