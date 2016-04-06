Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3F16B6B0253
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 09:45:23 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id c6so36052759qga.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 06:45:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s128si2104265qhs.53.2016.04.06.06.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 06:45:22 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH 2/2] memory_hotplug: introduce memhp_default_state= command line parameter
Date: Wed,  6 Apr 2016 15:45:12 +0200
Message-Id: <1459950312-25504-3-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1459950312-25504-1-git-send-email-vkuznets@redhat.com>
References: <1459950312-25504-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Igor Mammedov <imammedo@redhat.com>

CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE specifies the default value for the
memory hotplug onlining policy. Add a command line parameter to make it
possible to override the default. It may come handy for debug and testing
purposes.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 Documentation/kernel-parameters.txt |  8 ++++++++
 mm/memory_hotplug.c                 | 11 +++++++++++
 2 files changed, 19 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index ecc74fa..b05ee2f 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2141,6 +2141,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			[KNL,SH] Allow user to override the default size for
 			per-device physically contiguous DMA buffers.
 
+        memhp_default_state=online/offline
+			[KNL] Set the initial state for the memory hotplug
+			onlining policy. If not specified, the default value is
+			set according to the
+			CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE kernel config
+			option.
+			See Documentation/memory-hotplug.txt.
+
 	memmap=exactmap	[KNL,X86] Enable setting of an exact
 			E820 memory map, as specified by the user.
 			Such memmap=exactmap lines can be constructed based on
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 072e0a1..179f3af 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -85,6 +85,17 @@ bool memhp_auto_online = true;
 #endif
 EXPORT_SYMBOL_GPL(memhp_auto_online);
 
+static int __init setup_memhp_default_state(char *str)
+{
+	if (!strcmp(str, "online"))
+		memhp_auto_online = true;
+	else if (!strcmp(str, "offline"))
+		memhp_auto_online = false;
+
+	return 1;
+}
+__setup("memhp_default_state=", setup_memhp_default_state);
+
 void get_online_mems(void)
 {
 	might_sleep();
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
