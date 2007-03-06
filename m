Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l269fUIq233812
	for <linux-mm@kvack.org>; Tue, 6 Mar 2007 20:41:30 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l269Jj1K168842
	for <linux-mm@kvack.org>; Tue, 6 Mar 2007 20:28:27 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l268O8tu027405
	for <linux-mm@kvack.org>; Tue, 6 Mar 2007 19:24:08 +1100
Message-ID: <45ED251C.2010400@linux.vnet.ibm.com>
Date: Tue, 06 Mar 2007 13:53:56 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 0/3][RFC] Containers: Pagecache accounting and control subsystem
 (v1)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: ckrm-tech@lists.sourceforge.net, Balbir Singh <balbir@in.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>, devel@openvz.org, xemul@sw.ru, Paul Menage <menage@google.com>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Containers: Pagecache accounting and control subsystem (v1)
-----------------------------------------------------------

This patch adds pagecache accounting and control on top of
Paul's container subsystem v7 posted at
http://lkml.org/lkml/2007/2/12/88

and Balbir's RSS controller posted at
http://lkml.org/lkml/2007/2/26/8

This patchset depends on Balbir's RSS controller and cannot
work independent of it. The page reclaim code has been merged
with container RSS controller.  However compile time options
can individually enable/disable memory controller and/or
pagecache controller.

Comments, suggestions and criticisms are welcome.

Features:
--------
* New subsystem called 'pagecache_acct' is registered with containers
* Container pointer is added to struct address_space to keep track of
  associated container
* In filemap.c and swap_state.c, the corresponding container's
  pagecache_acct subsystem is charged and uncharged whenever a new
  page is added or removed from pagecache
* The accounting number include pages in swap cache and filesystem
  buffer pages apart from pagecache, basically everything under
  NR_FILE_PAGES is counted as pagecache.  However this excluded
  mapped and anonymous pages
* Limits on pagecache can be set by echo 100000 > pagecache_limit on
  the /container file system.  The unit is in kilobytes
* If the pagecache utilisation limit is exceeded, pagecache reclaim
  code is invoked to recover dirty and clean pagecache pages only.

Advantages:
-----------
* Does not add container pointers in struct page

Limitations:
-----------
* Code is not safe for container deletion/task migration
* Pagecache page reclaim needs performance improvements
* Global LRU is churned in search of pagecache pages

Usage:
-----

* Add patch on top of Paul container (v7) at kernel version 2.6.20
* Enable CONFIG_CONTAINER_PAGECACHE_ACCT in 'General Setup'
* Boot new kernel
* Mount container filesystem
	mount -t container /container
	cd /container
* Create new container
	mkdir mybox
	cd /container/mybox
* Add current shell to container
	echo $$ > tasks
* There are two files pagecache_usage and pagecache_limit
* In order to set limit, echo value in kilobytes to pagecache_limit
	echo 100000 > pagecache_limit
	#This would set 100MB limit on pagecache usage
* Trash the system from current shell using scp/cp/dd/tar etc
* Watch pagecache_usage and /proc/meminfo to verify behavior

* Only unmapped pagecache data will be accounted and controlled.
  These are memory used by cp, scp, tar etc.  While file mmap will
  be controlled by Balbir's RSS controller.

Tests:
------

* Ran kernbench within container with pagecache_limits set

ToDo:
----

* Merge with container RSS controller and eliminate redundant code
* Test and support task migration and container deletion
* Review reclaim performance
* Optimise page reclaim

Patch Series:
-------------
pagecache-controller-setup.patch
pagecache-controller-acct.patch
pagecache-controller-reclaim.patch

---	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
