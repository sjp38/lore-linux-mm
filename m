Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4NF9Q7n126922
	for <linux-mm@kvack.org>; Thu, 24 May 2007 01:09:27 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4NEqWmb163990
	for <linux-mm@kvack.org>; Thu, 24 May 2007 00:52:34 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4NEn0HK001212
	for <linux-mm@kvack.org>; Thu, 24 May 2007 00:49:00 +1000
Message-ID: <46545459.2090804@linux.vnet.ibm.com>
Date: Wed, 23 May 2007 20:18:57 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/3] Containers: Pagecache accounting and control subsystem
 (v3)
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

This patch is based on RSS Controller V2 by Pavel and Balbir.  This patch
depends on
1. Paul Menage's Containers (V8): Generic Process Containers
http://lkml.org/lkml/2007/4/6/297
2. Pavel Emelianov's RSS controller based on process containers (v2)
http://lkml.org/lkml/2007/4/9/78
3. Balbir's fixes for RSS controller as mentioned in
http://lkml.org/lkml/2007/5/17/232

This is very much work-in-progress, you can certainly expect hangs/crash if
both pagecache and rss limits are set and the container is stressed.

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
* All limitation of RSS controller v2 applies to this code as well
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
pagecache-controller-v3-setup.patch
pagecache-controller-v3-acct.patch
pagecache-controller-v3-acct-hooks.patch


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
