Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id DFAC36B0260
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 11:32:43 -0500 (EST)
Received: by lfaz4 with SMTP id z4so38236716lfa.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 08:32:43 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.73])
        by mx.google.com with ESMTPS id tb10si5053623lbb.208.2015.12.09.08.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 08:32:42 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: memcontrol: MEMCG no longer works with SLOB
Date: Wed, 09 Dec 2015 17:32:39 +0100
Message-ID: <1558902.EBTjGmY9S2@wuerfel>
In-Reply-To: <2564892.qO1q7YJ6Nb@wuerfel>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org> <2564892.qO1q7YJ6Nb@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The change to move the kmem accounting into the normal memcg
code means we can no longer use memcg with slob, which lacks
the memcg_params member in its struct kmem_cache:

../mm/slab.h: In function 'is_root_cache':
../mm/slab.h:187:10: error: 'struct kmem_cache' has no member named 'memcg_params'

This enforces the new dependency in Kconfig. Alternatively,
we could change the slob code to allow using MEMCG.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 6e6133536d82 ("mm: memcontrol: move kmem accounting code to CONFIG_MEMCG")

diff --git a/init/Kconfig b/init/Kconfig
index 4822bb359fea..f4d81d382608 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -999,6 +999,7 @@ config PAGE_COUNTER
 
 config MEMCG
 	bool "Memory Resource Controller for Control Groups"
+	depends on SLAB || SLUB
 	select PAGE_COUNTER
 	select EVENTFD
 	help
@@ -1040,7 +1041,6 @@ config MEMCG_LEGACY_KMEM
 config MEMCG_KMEM
 	bool "Legacy Memory Resource Controller Kernel Memory accounting"
 	depends on MEMCG
-	depends on SLUB || SLAB
 	select MEMCG_LEGACY_KMEM
 	help
 	  The Kernel Memory extension for Memory Resource Controller can limit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
