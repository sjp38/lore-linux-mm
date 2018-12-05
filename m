Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E37D56B71FD
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 21:35:26 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q64so15589282pfa.18
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 18:35:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 24sor23920910pgq.13.2018.12.04.18.35.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 18:35:25 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/2] admin-guide/memory-hotplug.rst: remove locking internal part from admin-guide
Date: Wed,  5 Dec 2018 10:34:25 +0800
Message-Id: <20181205023426.24029-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@redhat.com, mhocko@suse.com, osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Locking Internal section exists in core-api documentation, which is more
suitable for this.

This patch removes the duplication part here.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
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
