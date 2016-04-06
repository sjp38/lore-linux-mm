Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id C914E6B007E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 09:45:20 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id f52so36022384qga.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 06:45:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 10si2114391qhw.26.2016.04.06.06.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 06:45:20 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH 1/2] memory_hotplug: introduce CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
Date: Wed,  6 Apr 2016 15:45:11 +0200
Message-Id: <1459950312-25504-2-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1459950312-25504-1-git-send-email-vkuznets@redhat.com>
References: <1459950312-25504-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Igor Mammedov <imammedo@redhat.com>

Introduce config option to set the default value for memory hotplug
onlining policy (/sys/devices/system/memory/auto_online_blocks). The
reason one would want to turn this option on are to have early onlining
for hotpluggable memory available at boot and to not require any userspace
actions to make memory hotplug work.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 Documentation/memory-hotplug.txt |  9 +++++----
 mm/Kconfig                       | 16 ++++++++++++++++
 mm/memory_hotplug.c              |  4 ++++
 3 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 443f4b4..0d7cb95 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -261,10 +261,11 @@ it according to the policy which can be read from "auto_online_blocks" file:
 
 % cat /sys/devices/system/memory/auto_online_blocks
 
-The default is "offline" which means the newly added memory is not in a
-ready-to-use state and you have to "online" the newly added memory blocks
-manually. Automatic onlining can be requested by writing "online" to
-"auto_online_blocks" file:
+The default depends on the CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE kernel config
+option. If it is disabled the default is "offline" which means the newly added
+memory is not in a ready-to-use state and you have to "online" the newly added
+memory blocks manually. Automatic onlining can be requested by writing "online"
+to "auto_online_blocks" file:
 
 % echo online > /sys/devices/system/memory/auto_online_blocks
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 989f8f3..4c7dd6e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -192,6 +192,22 @@ config MEMORY_HOTPLUG_SPARSE
 	def_bool y
 	depends on SPARSEMEM && MEMORY_HOTPLUG
 
+config MEMORY_HOTPLUG_DEFAULT_ONLINE
+        bool "Online the newly added memory blocks by default"
+        default n
+        depends on MEMORY_HOTPLUG
+        help
+	  This option changes the default policy setting for memory hotplug
+	  onlining policy (/sys/devices/system/memory/auto_online_blocks) which
+	  determines what happens to the newly added memory regions. Policy
+	  setting can always be changed in runtime.
+	  See Documentation/memory-hotplug.txt for more information.
+
+	  Say Y here if you want all hot-plugged memory blocks to appear in
+	  'online' state by default.
+	  Say N here if you want the default policy to keep all hot-plugged
+	  memory blocks in 'offline' state.
+
 config MEMORY_HOTREMOVE
 	bool "Allow for memory hot remove"
 	select MEMORY_ISOLATION
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index aa34431..072e0a1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -78,7 +78,11 @@ static struct {
 #define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
 #define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
 
+#ifndef CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
 bool memhp_auto_online;
+#else
+bool memhp_auto_online = true;
+#endif
 EXPORT_SYMBOL_GPL(memhp_auto_online);
 
 void get_online_mems(void)
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
