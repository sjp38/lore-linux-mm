Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B56AB6B771A
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 19:26:33 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id h10so16036353plk.12
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 16:26:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id az5sor29170747plb.11.2018.12.05.16.26.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 16:26:32 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v2 1/2] admin-guide/memory-hotplug.rst: remove locking internal part from admin-guide
Date: Thu,  6 Dec 2018 08:26:21 +0800
Message-Id: <20181206002622.30675-1-richard.weiyang@gmail.com>
In-Reply-To: <20181205023426.24029-1-richard.weiyang@gmail.com>
References: <20181205023426.24029-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.ibm.com, david@redhat.com, mhocko@suse.com, osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Locking Internal section exists in core-api documentation, which is more
suitable for this.

This patch removes the duplication part here.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Acked-by: Mike Rapoport <rppt@linux.ibm.com>
---
 Documentation/admin-guide/mm/memory-hotplug.rst | 40 -------------------------
 1 file changed, 40 deletions(-)

diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
index 5c4432c96c4b..241f4ce1e387 100644
--- a/Documentation/admin-guide/mm/memory-hotplug.rst
+++ b/Documentation/admin-guide/mm/memory-hotplug.rst
@@ -392,46 +392,6 @@ Need more implementation yet....
  - Notification completion of remove works by OS to firmware.
  - Guard from remove if not yet.
 
-
-Locking Internals
-=================
-
-When adding/removing memory that uses memory block devices (i.e. ordinary RAM),
-the device_hotplug_lock should be held to:
-
-- synchronize against online/offline requests (e.g. via sysfs). This way, memory
-  block devices can only be accessed (.online/.state attributes) by user
-  space once memory has been fully added. And when removing memory, we
-  know nobody is in critical sections.
-- synchronize against CPU hotplug and similar (e.g. relevant for ACPI and PPC)
-
-Especially, there is a possible lock inversion that is avoided using
-device_hotplug_lock when adding memory and user space tries to online that
-memory faster than expected:
-
-- device_online() will first take the device_lock(), followed by
-  mem_hotplug_lock
-- add_memory_resource() will first take the mem_hotplug_lock, followed by
-  the device_lock() (while creating the devices, during bus_add_device()).
-
-As the device is visible to user space before taking the device_lock(), this
-can result in a lock inversion.
-
-onlining/offlining of memory should be done via device_online()/
-device_offline() - to make sure it is properly synchronized to actions
-via sysfs. Holding device_hotplug_lock is advised (to e.g. protect online_type)
-
-When adding/removing/onlining/offlining memory or adding/removing
-heterogeneous/device memory, we should always hold the mem_hotplug_lock in
-write mode to serialise memory hotplug (e.g. access to global/zone
-variables).
-
-In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
-mode allows for a quite efficient get_online_mems/put_online_mems
-implementation, so code accessing memory can protect from that memory
-vanishing.
-
-
 Future Work
 ===========
 
-- 
2.15.1
