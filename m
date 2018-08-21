Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06A4B6B1E51
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 06:44:55 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w8-v6so17429851qkf.8
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 03:44:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v8-v6si3315525qtp.169.2018.08.21.03.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 03:44:54 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFCv2 6/6] memory-hotplug.txt: Add some details about locking internals
Date: Tue, 21 Aug 2018 12:44:18 +0200
Message-Id: <20180821104418.12710-7-david@redhat.com>
In-Reply-To: <20180821104418.12710-1-david@redhat.com>
References: <20180821104418.12710-1-david@redhat.com>
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
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 Documentation/memory-hotplug.txt | 39 +++++++++++++++++++++++++++++++-
 1 file changed, 38 insertions(+), 1 deletion(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 7f49ebf3ddb2..03aaad7d7373 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -3,7 +3,7 @@ Memory Hotplug
 ==============
 
 :Created:							Jul 28 2007
-:Updated: Add description of notifier of memory hotplug:	Oct 11 2007
+:Updated: Add some details about locking internals:		Aug 20 2018
 
 This document is about memory hotplug including how-to-use and current status.
 Because Memory Hotplug is still under development, contents of this text will
@@ -495,6 +495,43 @@ further processing of the notification queue.
 
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
+heterogeneous/device memory, we should always hold the mem_hotplug_lock to
+serialise memory hotplug (e.g. access to global/zone variables).
+
+In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) allows
+for a quite efficient get_online_mems/put_online_mems implementation.
+
+
 Future Work
 ===========
 
-- 
2.17.1
