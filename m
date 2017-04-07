Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B97216B0038
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 16:29:09 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id b9so24668343qtg.4
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 13:29:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u90si2607646qtd.119.2017.04.07.13.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 13:29:08 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [RFC HMM CDM 0/3] Coherent Device Memory (CDM) on top of HMM
Date: Fri,  7 Apr 2017 16:28:50 -0400
Message-Id: <1491596933-21669-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <balbir@au1.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

This patch serie implement coherent device memory using ZONE_DEVICE
and adds new helper to the HMM framework to support this new kind
of ZONE_DEVICE memory. This is on top of HMM v19 and you can find a
branch here:

https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-cdm

It needs more special casing as it behaves differently from regular
ZONE_DEVICE (persistent memory). Unlike the unaddressable memory
type added with HMM patchset, the CDM type can be access by CPU.
Because of this any page can be migrated to CDM memory, private
anonymous or share memory (file back or not).

It is missing some features like allowing to direct device fault to
directly allocates device memory (intention is to add new fields to
vm_fault struct for this).


This is mostly un-tested but i am posting now because i believe we
want to start discussion on design consideration. So this differ from
the NUMA approach by adding yet a new type to ZONE_DEVICE with more
special casing. While it is a rather small patchset, i might have
miss some code-path that might require more special casing (i and
other need to audit mm to make sure that everytime mm is confronted
so such page it behaves as we want).

So i believe question is do we want to keep on adding new type to
ZONE_DEVICE and more special casing each of them or is a NUMA like
approach better ?


My personal belief is that the hierarchy of memory is getting deeper
(DDR, HBM stack memory, persistent memory, device memory, ...) and
it may make sense to try to mirror this complexity within mm concept.
Generalizing the NUMA abstraction is probably the best starting point
for this. I know there are strong feelings against changing NUMA so
i believe now is the time to pick a direction.

Note that i don't think choosing one would mean we will be stuck with
it, as long as we don't expose anything new (syscall) to userspace
and hide thing through driver API then we keep our options open to
change direction latter on.

Nonetheless we need to make progress on this as they are hardware
right around the corner and it would be a shame if we could not
leverage such hardware with linux.


JA(C)rA'me Glisse (3):
  mm/cache-coherent-device-memory: new type of ZONE_DEVICE
  mm/hmm: add new helper to hotplug CDM memory region
  mm/migrate: memory migration using a device DMA engine

 include/linux/hmm.h            |  10 +-
 include/linux/ioport.h         |   1 +
 include/linux/memory_hotplug.h |   8 +
 include/linux/memremap.h       |  26 +++
 include/linux/migrate.h        |  40 ++---
 mm/Kconfig                     |   9 +
 mm/gup.c                       |   1 +
 mm/hmm.c                       |  78 +++++++--
 mm/memcontrol.c                |  25 ++-
 mm/memory.c                    |  18 ++
 mm/migrate.c                   | 376 ++++++++++++++++++++++-------------------
 11 files changed, 380 insertions(+), 212 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
