Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5KBZ00I8011896
	for <linux-mm@kvack.org>; Wed, 20 Jun 2007 21:35:01 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KBbNx9027730
	for <linux-mm@kvack.org>; Wed, 20 Jun 2007 21:37:24 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KBXoKS026617
	for <linux-mm@kvack.org>; Wed, 20 Jun 2007 21:33:51 +1000
Message-ID: <46791098.4010801@linux.vnet.ibm.com>
Date: Wed, 20 Jun 2007 17:03:44 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/4] Containers: Pagecache accounting and control subsystem
 (v4)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, linux-mm@kvack.org
Cc: Balbir Singh <balbir@in.ibm.com>, Pavel Emelianov <xemul@sw.ru>, Paul Menage <menage@google.com>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>, Roy Huang <royhuang9@gmail.com>, Aubrey Li <aubreylee@gmail.com>
List-ID: <linux-mm.kvack.org>

-----------------------------------------------------------

This patch extends the RSS controller to account and reclaim pagecache
and swapcache pages.  This is a prototype to demonstrate that the existing
container infrastructure is useful to build different VM controller.

This patch is based on RSS Controller V3.1 by Pavel and Balbir.  This patch
depends on

1. Paul Menage's Containers(V10): Generic Process Containers
http://lwn.net/Articles/236032/
2. Pavel Emelianov's RSS controller based on process containers (v3.1)
http://lwn.net/Articles/236817/
3. Balbir's fixes for RSS controller as mentioned in
http://lkml.org/lkml/2007/6/04/185

This is very much work-in-progress and it have been posted for comments
after some basic testing.

Comments, suggestions and criticisms are welcome.

Thanks,
Vaidy

Features:
--------
* No new subsystem is added. The RSS controller subsystem is extended
  since most of the code can be shared between pagecache control and
  RSS control.
* The accounting number include pages in swap cache and filesystem
  buffer pages apart from pagecache, basically everything under
  NR_FILE_PAGES is counted as pagecache.
* Limits on pagecache can be set by echo -n 100000 > pagecache_limit on
  the /container file system.  The unit is in pages or 4 kilobytes
* If the pagecache utilisation limit is exceeded, the container reclaim
  code is invoked to recover pages from the container.

Advantages:
-----------
* Minimal code changes to RSS controller to include pagecache pages

Limitations:
-----------
* All limitation of RSS controller applies to this code as well
* Page reclaim needs to be reworked to select correct pages when the
  respective limits are exceeded
* Concurrent and recursive triggering of reclaimer code is a mess leading
  to deadlocks.  Reclaimer needs to be serialised and reworked to
  do the right job and also improve performance

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
* There are two files pagecache_usage and pagecache_limit
* In order to set limit, echo value in pages (4KB) to pagecache_limit
	echo -n 100000 > pagecache_limit
	#This would set 409MB limit on pagecache usage
* Trash the system from current shell using scp/cp/dd/tar etc
* Watch pagecache_usage and /proc/meminfo to verify behavior

Tests:
------
* Simple dd/cat/cp test on pagecache limit
* rss_limit was tested with simple test application that would malloc
  predefined size of memory and touch them to allocate pages.

ToDo:
----
* Optimise the reclaim.  Currently isolate_container_pages does not distinguish
  between whether pagecache limit is hit or rss limit is hit
* Prevent concurrent reclaim and recursive reclaim when both limits are set.

Patch Series:
-------------
pagecache-controller-v4-setup.patch
pagecache-controller-v4-acct.patch
pagecache-controller-v4-acct-hooks.patch
pagecache-controller-v4-reclaim.patch

ChangeLog:
---------

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
