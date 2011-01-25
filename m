Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 29C6B6B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 00:04:49 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id p0P54aHH021960
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 10:34:36 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0P54Z8f3645576
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 10:34:36 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0P54Y5Y011922
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 10:34:34 +0530
Subject: [PATCH 0/3] Unmapped Page Cache Control (v4)
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 25 Jan 2011 10:34:07 +0530
Message-ID: <20110125050255.13141.688.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

The following series implements page cache control,
this is a split out version of patch 1 of version 3 of the
page cache optimization patches posted earlier at
Previous posting http://lwn.net/Articles/419564/

The previous few revision received lot of comments, I've tried to
address as many of those as possible in this revision.

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

The sysctl for min_unmapped_ratio provides further control from
within the guest on the amount of unmapped pages to reclaim, a similar
max_unmapped_ratio sysctl is added and helps in the decision making
process of when reclaim should occur. This is tunable and set by
default to 16 (based on tradeoff's seen between aggressiveness in
balancing versus size of unmapped pages). Distro's and administrators
can further tweak this for desired control.

Data from the previous patchsets can be found at
https://lkml.org/lkml/2010/11/30/79


---

Balbir Singh (3):
      Move zone_reclaim() outside of CONFIG_NUMA
      Refactor zone_reclaim code
      Provide control over unmapped pages


 Documentation/kernel-parameters.txt |    8 ++
 include/linux/mmzone.h              |    9 ++-
 include/linux/swap.h                |   23 +++++--
 init/Kconfig                        |   12 +++
 kernel/sysctl.c                     |   29 ++++++--
 mm/page_alloc.c                     |   31 ++++++++-
 mm/vmscan.c                         |  122 +++++++++++++++++++++++++++++++----
 7 files changed, 202 insertions(+), 32 deletions(-)

-- 
Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
