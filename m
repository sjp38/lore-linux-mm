Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 31E6B6B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 03:47:05 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id b8so2973778lan.12
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 00:47:04 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id q7si23634206lbw.155.2014.04.21.00.47.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Apr 2014 00:47:02 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] Documentation/memcg: warn about incomplete kmemcg state
Date: Mon, 21 Apr 2014 11:47:00 +0400
Message-ID: <1398066420-30707-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kmemcg is currently under development and lacks some important features.
In particular, it does not have support of kmem reclaim on memory
pressure inside cgroup, which practically makes it unusable in real
life. Let's warn about it in both Kconfig and Documentation to prevent
complaints arising.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 Documentation/cgroups/memory.txt |    5 +++++
 init/Kconfig                     |    6 ++++++
 2 files changed, 11 insertions(+)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 2622115276aa..af3cdfa3c07a 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -270,6 +270,11 @@ When oom event notifier is registered, event will be delivered.
 
 2.7 Kernel Memory Extension (CONFIG_MEMCG_KMEM)
 
+WARNING: Current implementation lacks reclaim support. That means allocation
+	 attempts will fail when close to the limit even if there are plenty of
+	 kmem available for reclaim. That makes this option unusable in real
+	 life so DO NOT SELECT IT unless for development purposes.
+
 With the Kernel memory extension, the Memory Controller is able to limit
 the amount of kernel memory used by the system. Kernel memory is fundamentally
 different than user memory, since it can't be swapped out, which makes it
diff --git a/init/Kconfig b/init/Kconfig
index 427ba60d638f..4d6e645c8ad4 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -993,6 +993,12 @@ config MEMCG_KMEM
 	  the kmem extension can use it to guarantee that no group of processes
 	  will ever exhaust kernel resources alone.
 
+	  WARNING: Current implementation lacks reclaim support. That means
+	  allocation attempts will fail when close to the limit even if there
+	  are plenty of kmem available for reclaim. That makes this option
+	  unusable in real life so DO NOT SELECT IT unless for development
+	  purposes.
+
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
 	depends on RESOURCE_COUNTERS && HUGETLB_PAGE
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
