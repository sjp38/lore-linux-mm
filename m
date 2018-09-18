Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81B078E0003
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 02:40:22 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h3-v6so562142pgc.8
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 23:40:22 -0700 (PDT)
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f8-v6si17201045pgl.383.2018.09.17.23.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Sep 2018 23:40:20 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH 00/19] vmw_balloon: compaction, shrinker, 64-bit, etc.
Date: Mon, 17 Sep 2018 23:38:34 -0700
Message-ID: <20180918063853.198332-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Nadav Amit <namit@vmware.com>, Xavier Deguillard <xdeguillard@vmware.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

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

Cc: Xavier Deguillard <xdeguillard@vmware.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: linux-mm@kvack.org
Cc: virtualization@lists.linux-foundation.org

Nadav Amit (18):
  vmw_balloon: handle commands in a single function.
  vmw_balloon: unify commands tracing and stats
  vmw_balloon: merge send_lock and send_unlock path
  vmw_balloon: simplifying batch access
  vmw_balloon: remove sleeping allocations
  vmw_balloon: change batch/single lock abstractions
  vmw_balloon: treat all refused pages equally
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
 drivers/misc/vmw_balloon.c         | 2181 ++++++++++++++++++----------
 include/linux/balloon_compaction.h |    4 +
 include/uapi/linux/magic.h         |    1 +
 mm/balloon_compaction.c            |  142 +-
 5 files changed, 1560 insertions(+), 769 deletions(-)

-- 
2.17.1
