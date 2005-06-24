Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5OMT4qo137112
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 18:29:04 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5OMT4cC183678
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 16:29:04 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5OMT3Rx009258
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 16:29:03 -0600
Subject: [PATCH 6/6] CKRM: Documentation for mem controller
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
Content-Type: text/plain
Date: Fri, 24 Jun 2005 15:29:02 -0700
Message-Id: <1119652142.14910.0.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech <ckrm-tech@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Patch 6 of 6 patches to support memory controller under CKRM framework.
Documentaion for the memory controller.

 Documentation/ckrm/mem_rc.design |  184 +++++++++++++++++++++++++++++++
++++++++
 Documentation/ckrm/mem_rc.todo   |   12 ++
 Documentation/ckrm/mem_rc.usage  |  112 +++++++++++++++++++++++
 3 files changed, 308 insertions(+)

Content-Disposition: inline; filename=11-06-mem_config-docs

Index: linux-2.6.12/Documentation/ckrm/mem_rc.design
===================================================================
--- /dev/null
+++ linux-2.6.12/Documentation/ckrm/mem_rc.design
@@ -0,0 +1,184 @@
+0. Lifecycle of a LRU Page:
+----------------------------
+These are the events in a page's lifecycle:
+   - allocation of the page
+     there are multiple high level page alloc functions; __alloc_pages
()
+	 is the lowest level function that does the real allocation.
+   - get into LRU list (active list or inactive list)
+   - get out of LRU list
+   - freeing the page
+     there are multiple high level page free functions; free_pages_bulk
()
+	 is the lowest level function that does the real free.
+
+When the memory subsystem runs low on LRU pages, pages are reclaimed by
+    - moving pages from active list to inactive list
(refill_inactive_zone())
+    - freeing pages from the inactive list (shrink_zone)
+depending on the recent usage of the page(approximately).
+
+In the process of the life cycle a page can move from the lru list to
swap
+and back. For this document's purpose, we treat it same as freeing and
+allocating the page, respectfully.
+
+1. Introduction
+---------------
+Memory resource controller controls the number of lru physical pages
+(active and inactive list) a class uses. It does not restrict any
+other physical pages (slabs etc.,)
+
+For simplicity, this document will always refer lru physical pages as
+physical pages or simply pages.
+
+There are two parameters(that are set by the user) that affect the
number
+of pages a class is allowed to have in active/inactive list.
+They are
+  - guarantee - specifies the number of pages a class is
+	guaranteed to get. In other words, if a class is using less than
+	'guarantee' number of pages, its pages will not be freed when the
+	memory subsystem tries to free some pages.
+  - limit - specifies the maximum number of pages a class can get;
+    'limit' in essence can be considered as the 'hard limit'
+
+Rest of this document details how these two parameters are used in the
+memory allocation logic.
+
+Note that the numbers that are specified in the shares file, doesn't
+directly correspond to the number of pages. But, the user can make
+it so by making the total_guarantee and max_limit of the default class
+(/rcfs/taskclass) to be the total number of pages(given in stats file)
+available in the system.
+
+  for example:
+   # cd /rcfs/taskclass
+   # grep System stats
+   System: tot_pages=257512,active=5897,inactive=2931,free=243991
+   # cat shares
+   res=mem,guarantee=-2,limit=-2,total_guarantee=100,max_limit=100
+
+  "tot_pages=257512" above mean there are 257512 lru pages in
+  the system.
+
+  By making total_guarantee and max_limit to be same as this number at
+  this level (/rcfs/taskclass), one can make guarantee and limit in all
+  classes refer to the number of pages.
+
+  # echo 'res=mem,total_guarantee=257512,max_limit=257512' > shares
+  # cat shares
+  res=mem,guarantee=-2,limit=-2,total_guarantee=257512,max_limit=257512
+
+
+The number of pages a class can use be anywhere between zero and its
+limit. CKRM memory controller springs into action when the system needs
+to choose a victim page to swap out. While the number of pages a class
can
+have allocated may be anywhere between zero and its limit, victim
+pages will be choosen from classes that are above their guarantee.
+
+Victim class will be chosen by the number pages a class is using over
its
+guarantee. i.e a class that is using 10000 pages over its guarantee
will be
+chosen against a class that is using 1000 pages over its guarantee.
+Pages belonging to classes that are below their guarantee will not be
+chosen as a victim.
+
+Whenever a class's usage goes over its limit number of pages, memory
+allocations will fail. In order to reduce the failure rate and to
behave
+like the VM, CKRM provides config parameters that will free up pages
+of a class when it is getting closer to its limit. Next section details
+different parameters and how they can be used.
+
+2. Configuaration parameters
+---------------------------
+
+Memory controller provides the following configuration parameters.
Usage of
+these parameters will be made clear in the following section.
+
+state: Shows whether the memory controller is enabled(1) or disabled
(0). By
+    default, the controller is disabled. User can either enabled it by
just
+    changing the state or is is enabled automatically either when the
user
+    defines a new class or changes the shares of the default root
class.
+
+fail_over: When pages are being allocated, if the class is over
fail_over % of
+    its limit, then fail the memory allocation. Default is 110.
+    ex: If limit of a class is 30000 and fail_over is 110, then memory
+    allocations would start failing once the class is using more than
33000
+    pages.
+
+shrink_at: When a class is using shrink_at % of its limit, then start
+    shrinking the class, i.e start freeing the page to make more free
pages
+    available for this class. Default is 90.
+    ex: If limit of a class is 30000 and shrink_at is 90, then pages
from this
+    class will start to get freed when the class's usage is above 27000
+
+shrink_to: When a class reached shrink_at % of its limit, ckrm will try
to
+    shrink the class's usage to shrink_to %. Defalut is 80.
+    ex: If limit of a class is 30000 with shrink_at being 90 and
shrink_to
+    being 80, then ckrm will try to free pages from the class when its
+    usage reaches 27000 and will try to bring it down to 24000.
+
+num_shrinks: Number of shrink attempts ckrm will do within
shrink_interval
+    seconds. After this many attempts in a period, ckrm will not
attempt a
+    shrink even if the class's usage goes over shrink_at %. Default is
10.
+
+shrink_interval: Number of seconds in a shrink period. Default is 10.
+
+3. Design
+--------------------------
+
+CKRM memory resource controller taps at appropriate low level memory
+management functions to associate a page with a class and to charge
+a class that brings the page to the LRU list.
+
+CKRM maintains lru lists per-class instead of keeping it system-wide,
so
+that reducing a class's usage doesn't involve going through the system-
wide
+lru lists.
+
+3.1 Changes in page allocation function(__alloc_pages())
+--------------------------------------------------------
+- If the class that the current task belong to is over 'fail_over' % of
its
+  'limit', allocation of page(s) fail. Otherwise, the page allocation
will
+  proceed as before.
+- Note that the class is _not_ charged for the page(s) here.
+
+3.2 Adding/Deleting page to active/inactive list
+-------------------------------------------------
+When a page is added to the active or inactive list, the class that the
+task belongs to is charged for the page usage.
+
+When a page is deleted from the active or inactive list, the class that
the
+page belongs to is credited back.
+
+If a class uses 'shrink_at' % of its limit, attempt is made to shrink
+the class's usage to 'shrink_to' % of its limit, in order to help the
class
+stay within its limit.
+But, if the class is aggressive, and keep getting over the class's
limit
+often(more than such 'num_shrinks' events in 'shrink_interval'
seconds),
+then the memory resource controller gives up on the class and doesn't
try
+to shrink the class, which will eventually lead the class to reach
+fail_over % and then the page allocations will start failing.
+
+3.3 Changes in the page reclaimation path (refill_inactive_zone and
shrink_zone)
+-------------------------------------------------------------------------------
+Pages will be moved from active to inactive list(refill_inactive_zone)
and
+pages from inactive list by choosing victim classes. Victim classes are
+chosen depending on their usage over their guarantee.
+
+Classes with DONT_CARE guarantee are assumed an implicit guarantee
which is
+based on the number of children(with DONT_CARE guarantee) its parent
has
+(including the default class) and the unused pages its parent still
has.
+ex1: If a default root class /rcfs/taskclass has 3 children c1, c2 and
c3
+and has 200000 pages, and all the classes have DONT_CARE guarantees,
then
+all the classes (c1, c2, c3 and the default class of /rcfs/taskclass)
will
+get 50000 (200000 / 4) pages each.
+ex2: If, in the above example c1 is set with a guarantee of 80000
pages,
+then the other classes (c2, c3 and the default class
of /rcfs/taskclass)
+will get 40000 ((200000 - 80000) / 3) pages each.
+
+3.5 Handling of Shared pages
+----------------------------
+Even if a mm is shared by tasks, the pages that belong to the mm will
be
+charged against the individual tasks that bring the page into LRU.
+
+But, when any task that is using a mm moves to a different class or
exits,
+then all pages that belong to the mm will be charged against the
richest
+class among the tasks that are using the mm.
+
+Note: Shared page handling need to be improved with a better policy.
+
Index: linux-2.6.12/Documentation/ckrm/mem_rc.usage
===================================================================
--- /dev/null
+++ linux-2.6.12/Documentation/ckrm/mem_rc.usage
@@ -0,0 +1,112 @@
+Installation
+------------
+
+1. Configure "Class based physical memory controller" under CKRM (see
+      Documentation/ckrm/installation)
+
+2. Reboot the system with the new kernel.
+
+3. Verify that the memory controller is present by reading the file
+   /rcfs/taskclass/config (should show a line with res=mem)
+
+Usage
+-----
+
+For brevity, unless otherwise specified all the following commands are
+executed in the default class (/rcfs/taskclass).
+
+Initially, the systemwide default class gets 100% of the LRU pages, and
the
+stats file at the /rcfs/taskclass level displays the total number of
+physical pages.
+
+   # cd /rcfs/taskclass
+   # grep System stats
+   System: tot_pages=239778,active=60473,inactive=135285,free=44555
+   # cat shares
+   res=mem,guarantee=-2,limit=-2,total_guarantee=100,max_limit=100
+
+   tot_pages - total number of pages
+   active    - number of pages in the active list ( sum of all zones)
+   inactive  - number of pages in the inactive list ( sum of all zones)
+   free      - number of free pages (sum of all zones)
+
+   By making total_guarantee and max_limit to be same as tot_pages, one
can
+   make the numbers in shares file be same as the number of pages for a
+   class.
+
+   # echo 'res=mem,total_guarantee=239778,max_limit=239778' > shares
+   # cat shares
+
res=mem,guarantee=-2,limit=-2,total_guarantee=239778,max_limit=239778
+
+Changing configuration parameters:
+----------------------------------
+For description of the paramters read the file mem_rc.design in this
same directory.
+
+Following is the default values for the configuration parameters:
+
+   localhost:~ # cd /rcfs/taskclass
+   localhost:/rcfs/taskclass # cat config
+
res=mem,state=1,fail_over=110,shrink_at=90,shrink_to=80,num_shrinks=10,shrink_interval=10
+
+Here is how to change a specific configuration parameter. Note that
more than one
+configuration parameter can be changed in a single echo command though
for simplicity
+we show one per echo.
+
+ex: Changing fail_over:
+   localhost:/rcfs/taskclass # echo "res=mem,fail_over=120" > config
+   localhost:/rcfs/taskclass # cat config
+
res=mem,state=1,fail_over=120,shrink_at=90,shrink_to=80,num_shrinks=10,shrink_interval=10
+
+ex: Changing shrink_at:
+   localhost:/rcfs/taskclass # echo "res=mem,shrink_at=85" > config
+   localhost:/rcfs/taskclass # cat config
+
res=mem,state=1,fail_over=120,shrink_at=85,shrink_to=80,num_shrinks=10,shrink_interval=10
+
+ex: Changing shrink_to:
+   localhost:/rcfs/taskclass # echo "res=mem,shrink_to=75" > config
+   localhost:/rcfs/taskclass # cat config
+
res=mem,state=1,fail_over=120,shrink_at=85,shrink_to=75,num_shrinks=10,shrink_interval=10
+
+ex: Changing num_shrinks:
+   localhost:/rcfs/taskclass # echo "res=mem,num_shrinks=20" > config
+   localhost:/rcfs/taskclass # cat config
+
res=mem,state=1,fail_over=120,shrink_at=85,shrink_to=75,num_shrinks=20,shrink_interval=10
+
+ex: Changing shrink_interval:
+   localhost:/rcfs/taskclass # echo "res=mem,shrink_interval=15" >
config
+   localhost:/rcfs/taskclass # cat config
+
res=mem,state=1,fail_over=120,shrink_at=85,shrink_to=75,num_shrinks=20,shrink_interval=15
+
+Class creation
+--------------
+
+   # mkdir c1
+
+Its initial share is DONT_CARE. The parent's share values will be
unchanged.
+
+Setting a new class share
+-------------------------
+
+   # echo 'res=mem,guarantee=25000,limit=50000' > c1/shares
+
+   # cat c1/shares
+
res=mem,guarantee=25000,limit=50000,total_guarantee=100,max_limit=100
+
+   'guarantee' specifies the number of pages this class entitled to get
+   'limit' is the maximum number of pages this class can get.
+
+Monitoring
+----------
+
+stats file shows statistics of the page usage of a class
+   # cat stats
+   ----------- Memory Resource stats start -----------
+   System: tot_pages=239778,active=60473,inactive=135285,free=44555
+   Number of pages used(including pages lent to children): 196654
+   Number of pages guaranteed: 239778
+   Maximum limit of pages: 239778
+   Total number of pages available(after serving guarantees to
children): 214778
+   Number of pages lent to children: 0
+   Number of pages borrowed from the parent: 0
+   ----------- Memory Resource stats end -----------
+
Index: linux-2.6.12/Documentation/ckrm/mem_rc.todo
===================================================================
--- /dev/null
+++ linux-2.6.12/Documentation/ckrm/mem_rc.todo
@@ -0,0 +1,12 @@
+Here are list of things to be done in the memory controller.
+
+	- meaningful names for parres, mem_rcbs etc.,
+	- make functions set_impl() and recalc() clean and simple
+	- in __alloc_pages(), when try_harder is set, try reclaiming
+	  pages if class is over its limit.
+	- move accounting (from zone/ckrm_zone) to different area and
+	  use it in both places
+	- support NUMA
+	- account shared pages properly
+	- use attributes file and make most of the config parameters class
+	  specific.

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
