Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1LEPbT0008256
	for <linux-mm@kvack.org>; Wed, 21 Feb 2007 09:25:37 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1LEPbHg474584
	for <linux-mm@kvack.org>; Wed, 21 Feb 2007 07:25:37 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1LEPako015468
	for <linux-mm@kvack.org>; Wed, 21 Feb 2007 07:25:36 -0700
Message-Id: <20070221142451.193001000@linux.vnet.ibm.com>>
Date: Wed, 21 Feb 2007 19:54:51 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH 0/3][RFC] Containers: Pagecache accounting and control subsystem (v1)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: balbir@in.ibm.com, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, devel@openvz.org, xemul@sw.ru, menage@google.com, clameter@sgi.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

-----------------------------------------------------------

This patch adds pagecache accounting and control on top of 
Paul's container subsystem v7 posted at 
http://lkml.org/lkml/2007/2/12/88

and Balbir's RSS controller posted at
http://lkml.org/lkml/2007/2/19/10

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

ToDo:
----

* Merge with container RSS controller and eliminate redundant code
* Support and test task migration and container deletion
* Review reclaim performance
* Optimise page reclaim
	
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
