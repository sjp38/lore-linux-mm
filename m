Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62CAD8E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 05:15:52 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id c14-v6so7974012qtc.7
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 02:15:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m18-v6si1297488qka.155.2018.09.25.02.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 02:15:51 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 6/6] memory-hotplug.txt: Add some details about locking internals
Date: Tue, 25 Sep 2018 11:14:57 +0200
Message-Id: <20180925091457.28651-7-david@redhat.com>
In-Reply-To: <20180925091457.28651-1-david@redhat.com>
References: <20180925091457.28651-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, David Hildenbrand <david@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

Let's document the magic a bit, especially why device_hotplug_lock is
required when adding/removing memory and how it all play together with
requests to online/offline memory from user space.

Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 Documentation/memory-hotplug.txt | 42 +++++++++++++++++++++++++++++++-
 1 file changed, 41 insertions(+), 1 deletion(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 7f49ebf3ddb2..ce4faa5530fa 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -3,7 +3,7 @@ Memory Hotplug
 ==============
 
 :Created:							Jul 28 2007
-:Updated: Add description of notifier of memory hotplug:	Oct 11 2007
+:Updated: Add some details about locking internals:		Aug 20 2018
 
 This document is about memory hotplug including how-to-use and current status.
 Because Memory Hotplug is still under development, contents of this text will
@@ -495,6 +495,46 @@ further processing of the notification queue.
 
 NOTIFY_STOP stops further processing of the notification queue.
 
+
+Locking Internals
+=================
+
+When adding/removing memory that uses memory block devices (i.e. ordinary RAM),
+the device_hotplug_lock should be held to:
+
+- synchronize against online/offline requests (e.g. via sysfs). This way, memory
+  block devices can only be accessed (.online/.state attributes) by user
+  space once memory has been fully added. And when removing memory, we
+  know nobody is in critical sections.
+- synchronize against CPU hotplug and similar (e.g. relevant for ACPI and PPC)
+
+Especially, there is a possible lock inversion that is avoided using
+device_hotplug_lock when adding memory and user space tries to online that
+memory faster than expected:
+
+- device_online() will first take the device_lock(), followed by
+  mem_hotplug_lock
+- add_memory_resource() will first take the mem_hotplug_lock, followed by
+  the device_lock() (while creating the devices, during bus_add_device()).
+
+As the device is visible to user space before taking the device_lock(), this
+can result in a lock inversion.
+
+onlining/offlining of memory should be done via device_online()/
+device_offline() - to make sure it is properly synchronized to actions
+via sysfs. Holding device_hotplug_lock is advised (to e.g. protect online_type)
+
+When adding/removing/onlining/offlining memory or adding/removing
+heterogeneous/device memory, we should always hold the mem_hotplug_lock in
+write mode to serialise memory hotplug (e.g. access to global/zone
+variables).
+
+In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
+mode allows for a quite efficient get_online_mems/put_online_mems
+implementation, so code accessing memory can protect from that memory
+vanishing.
+
+
 Future Work
 ===========
 
-- 
2.17.1
