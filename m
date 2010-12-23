Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BC9186B0088
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 13:09:43 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id oBNI9Mi6015521
	for <linux-mm@kvack.org>; Fri, 24 Dec 2010 05:09:22 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBNI9a3R2220076
	for <linux-mm@kvack.org>; Fri, 24 Dec 2010 05:09:36 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBNI9ZmX015650
	for <linux-mm@kvack.org>; Fri, 24 Dec 2010 05:09:36 +1100
Subject: [PATCH 0/3] Unmapped Page Control (v3)
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 23 Dec 2010 23:39:23 +0530
Message-ID: <20101223180022.3278.51404.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

The following series implements page cache control,
this is a split out version of patch 1 of version 3 of the
page cache optimization patches posted earlier at
Previous posting http://lwn.net/Articles/419564/

For those with LWN.net access, there is a detailed coverage
of the patchset at http://lwn.net/Articles/419713/

The previous few revision received lot of comments, I've tried to
address as many of those as possible in this revision. An earlier
series was reviewed-by Christoph Lameter.

There were comments on overlap with Nick's changes and overlap
with them. I don't feel these changes impact Nick's work and
integration can/will be considered as the patches evolve, if
need be.

Detailed Description
====================
This patch implements unmapped page cache control via preferred
page cache reclaim. The current patch hooks into kswapd and reclaims
page cache if the user has requested for unmapped page control.
This is useful in the following scenario
- In a virtualized environment with cache=writethrough, we see
  double caching - (one in the host and one in the guest). As
  we try to scale guests, cache usage across the system grows.
  The goal of this patch is to reclaim page cache when Linux is running
  as a guest and get the host to hold the page cache and manage it.
  There might be temporary duplication, but in the long run, memory
  in the guests would be used for mapped pages.
- The option is controlled via a boot option and the administrator
  can selectively turn it on, on a need to use basis.

A lot of the code is borrowed from zone_reclaim_mode logic for
__zone_reclaim(). One might argue that the with ballooning and
KSM this feature is not very useful, but even with ballooning,
we need extra logic to balloon multiple VM machines and it is hard
to figure out the correct amount of memory to balloon. With these
patches applied, each guest has a sufficient amount of free memory
available, that can be easily seen and reclaimed by the balloon driver.
The additional memory in the guest can be reused for additional
applications or used to start additional guests/balance memory in
the host.

KSM currently does not de-duplicate host and guest page cache. The goal
of this patch is to help automatically balance unmapped page cache when
instructed to do so.

There are some magic numbers in use in the code, UNMAPPED_PAGE_RATIO
and the number of pages to reclaim when unmapped_page_control argument
is supplied. These numbers were chosen to avoid aggressiveness in
reaping page cache ever so frequently, at the same time providing control.

The sysctl for min_unmapped_ratio provides further control from
within the guest on the amount of unmapped pages to reclaim.

Data from the previous patchsets can be found at
https://lkml.org/lkml/2010/11/30/79

Size measurement

CONFIG_UNMAPPED_PAGECACHE_CONTROL and CONFIG_NUMA enabled
# size mm/built-in.o 
   text    data     bss     dec     hex filename
 419431 1883047  140888 2443366  254866 mm/built-in.o

CONFIG_UNMAPPED_PAGECACHE_CONTROL disabled, CONFIG_NUMA enabled
# size mm/built-in.o 
   text    data     bss     dec     hex filename
 418908 1883023  140888 2442819  254643 mm/built-in.o


---

Balbir Singh (3):
      Move zone_reclaim() outside of CONFIG_NUMA
      Refactor zone_reclaim code
      Provide control over unmapped pages


 Documentation/kernel-parameters.txt |    8 ++
 include/linux/mmzone.h              |    4 +
 include/linux/swap.h                |   21 +++++-
 init/Kconfig                        |   12 +++
 kernel/sysctl.c                     |   20 +++--
 mm/page_alloc.c                     |    9 ++
 mm/vmscan.c                         |  132 +++++++++++++++++++++++++++++++----
 7 files changed, 175 insertions(+), 31 deletions(-)

-- 
Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
