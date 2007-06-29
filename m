Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5T6eFSJ233204
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:40:25 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5T6LJsF206890
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:21:29 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5T6HY6F003825
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:17:37 +1000
Message-ID: <4684A3F3.40001@linux.vnet.ibm.com>
Date: Fri, 29 Jun 2007 11:47:23 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/3] Containers: Integrated RSS and pagecache control
 v5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@in.ibm.com>, Pavel Emelianov <xemul@sw.ru>, Paul Menage <menage@google.com>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>, Roy Huang <royhuang9@gmail.com>, Aubrey Li <aubreylee@gmail.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

------------------------------------------------------------------

Based on the discussions at OLS yesterday, the consensus was to try an
integrated pagecache controller along with RSS controller under the
same usage limit.

This patch extends the RSS controller to account and reclaim pagecache
and swapcache pages.  The same 'rss_limit' now applies to both RSS pages
and pagecache pages. When the limit is reached, both pagecache and RSS
pages are reclaimed in LRU order as per the normal system wide reclaim
policy.

This patch is based on RSS Controller V3.1 by Pavel and Balbir.  This patch
depends on

1. Paul Menage's Containers(V10): Generic Process Containers
http://lwn.net/Articles/236032/
2. Pavel Emelianov's RSS controller based on process containers (v3.1)
http://lwn.net/Articles/236817/
3. Balbir's fixes for RSS controller as mentioned in
http://lkml.org/lkml/2007/6/04/185

This is very much work-in-progress and it have been posted for comments
after some basic testing with kernbench.

Comments, suggestions and criticisms are welcome.

--Vaidy

Features:
--------
* Single limit for both RSS and pagecache/swapcache pages
* No new subsystem is added. The RSS controller subsystem is extended
  since most of the code can be shared between pagecache control and
  RSS control.
* The accounting number include pages in swap cache and filesystem
  buffer pages apart from pagecache, basically everything under
  NR_FILE_PAGES is counted under rss_usage.
* The usage limit set in rss_limit applies to sum of both RSS and
  pagecache pages
* Limits on pagecache can be set by echo -n 100000 > rss_limit on
  the /container file system.  The unit is in pages or 4 kilobytes
* If the pagecache+RSS utilisation exceed the limit, the container reclaim
  code is invoked to recover pages from the container.

Advantages:
-----------
* Minimal code changes to RSS controller to include pagecache pages

Limitations:
-----------
* All limitation of RSS controller applies to this code as well
* Per-container reclaim knobs like dirty ratio, vm_swappiness may
  provide better control

Usage:
------
* Add all dependent patches before including this patch
* No new config settings apart from enabling CONFIG_RSS_CONTAINER
* Boot new kernel
* Mount container filesystem
	mount -t container none /container
	cd /container
* Create new container
	mkdir mybox
	cd /container/mybox
* Add current shell to container
	echo $$ > tasks
* In order to set limit, echo value in pages (4KB) to rss_limit
	echo -n 100000 > rss_limit
	#This would set 409MB limit on pagecache+rss usage
* Trash the system from current shell using scp/cp/dd/tar etc
* Watch rss_usage and /proc/meminfo to verify behavior

Tests:
------
* Simple dd/cat/cp test on pagecache limit/reclaim
* rss_limit was tested with simple test application that would malloc
  predefined size of memory and touch them to allocate pages.
* kernbench was run under container with 400MB memory limit

ToDo:
----
* Optimise the reclaim.
* Per-container VM stats and knobs

Patch Series:
-------------
pagecache-controller-v5-acct.patch
pagecache-controller-v5-acct-hooks.patch
pagecache-controller-v5-reclaim.patch

ChangeLog:
---------

v5: Integrated pagecache + rss controller

* No separate pagecache_limit
* pagecache and rss pages accounted in rss_usage and governed by rss_limit
* Each page counted only once in rss_usage.  Mapped or unmapped
  pagecache pages are counted alike in rss_usage

v4:
* Patch remerged to Container v10 and RSS v3.1
* Bug fixes
* Tested with kernbench

v3:
* Patch merged with Containers v8 and RSS v2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
