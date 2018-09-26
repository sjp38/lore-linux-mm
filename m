Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A842E8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 15:15:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n17-v6so50568pff.17
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 12:15:11 -0700 (PDT)
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id q90-v6si5539344pfa.272.2018.09.26.12.15.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 26 Sep 2018 12:15:10 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v3 00/20] vmw_balloon: compaction, shrinker, 64-bit, etc.
Date: Wed, 26 Sep 2018 12:13:16 -0700
Message-ID: <20180926191336.101885-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, gregkh@linuxfoundation.org
Cc: Xavier Deguillard <xdeguillard@vmware.com>, linux-kernel@vger.kernel.org, Nadav Amit <namit@vmware.com>, "Michael S.
 Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

This patch-set adds the following enhancements to the VMware balloon
driver:

1. Balloon compaction support.
2. Report the number of inflated/deflated ballooned pages through vmstat.
3. Memory shrinker to avoid balloon over-inflation (and OOM).
4. Support VMs with memory limit that is greater than 16TB.
5. Faster and more aggressive inflation.

To support compaction we wish to use the existing infrastructure.
However, we need to make slight adaptions for it. We add a new list
interface to balloon-compaction, which is more generic and efficient,
since it does not require as many IRQ save/restore operations. We leave
the old interface that is used by the virtio balloon.

Big parts of this patch-set are cleanup and documentation. Patches 1-13
simplify the balloon code, document its behavior and allow the balloon
code to run concurrently. The support for concurrency is required for
compaction and the shrinker interface.

For documentation we use the kernel-doc format. We are aware that the
balloon interface is not public, but following the kernel-doc format may
be useful one day.

v2->v3: * Moving the balloon magic-number out of uapi (Greg)

v1->v2:	* Fix build error when THP is off (kbuild)
	* Fix build error on i386 (kbuild)

Cc: Xavier Deguillard <xdeguillard@vmware.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: linux-mm@kvack.org
Cc: virtualization@lists.linux-foundation.org

Nadav Amit (19):
  vmw_balloon: handle commands in a single function.
  vmw_balloon: unify commands tracing and stats
  vmw_balloon: merge send_lock and send_unlock path
  vmw_balloon: simplifying batch access
  vmw_balloon: remove sleeping allocations
  vmw_balloon: change batch/single lock abstractions
  vmw_balloon: treat all refused pages equally
  vmw_balloon: rename VMW_BALLOON_2M_SHIFT to VMW_BALLOON_2M_ORDER
  vmw_balloon: refactor change size from vmballoon_work
  vmw_balloon: simplify vmballoon_send_get_target()
  vmw_balloon: stats rework
  vmw_balloon: rework the inflate and deflate loops
  vmw_balloon: general style cleanup
  vmw_balloon: add reset stat
  mm/balloon_compaction: suppress allocation warnings
  mm/balloon_compaction: list interfaces
  vmw_balloon: compaction support
  vmw_balloon: memory shrinker
  vmw_balloon: split refused pages

Xavier Deguillard (1):
  vmw_balloon: support 64-bit memory limit

 drivers/misc/Kconfig               |    1 +
 drivers/misc/vmw_balloon.c         | 2198 +++++++++++++++++++---------
 include/linux/balloon_compaction.h |    4 +
 mm/balloon_compaction.c            |  142 +-
 4 files changed, 1578 insertions(+), 767 deletions(-)

-- 
2.17.1
