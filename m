Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6796B0038
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 15:48:21 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id w62so932298wes.38
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 12:48:21 -0800 (PST)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id n3si1299811wjr.169.2014.01.14.12.48.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 12:48:20 -0800 (PST)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 3/3] mm: audit/fix non-modular users of module_init in core code
Date: Tue, 14 Jan 2014 15:44:48 -0500
Message-ID: <1389732288-4389-4-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1389732288-4389-1-git-send-email-paul.gortmaker@windriver.com>
References: <1389732288-4389-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>

Code that is obj-y (always built-in) or dependent on a bool Kconfig
(built-in or absent) can never be modular.  So using module_init as
an alias for __initcall can be somewhat misleading.

Fix these up now, so that we can relocate module_init from
init.h into module.h in the future.  If we don't do this, we'd
have to add module.h to obviously non-modular code, and that
would be a worse thing.

The audit targets the following module_init users for change:
 mm/ksm.c                       bool KSM
 mm/mmap.c                      bool MMU
 mm/huge_memory.c               bool TRANSPARENT_HUGEPAGE
 mm/mmu_notifier.c              bool MMU_NOTIFIER

Note that direct use of __initcall is discouraged, vs. one
of the priority categorized subgroups.  As __initcall gets
mapped onto device_initcall, our use of subsys_initcall (which
makes sense for these files) will thus change this registration
from level 6-device to level 4-subsys (i.e. slightly earlier).

However no observable impact of that difference has been observed
during testing.

One might think that core_initcall (l2) or postcore_initcall (l3)
would be more appropriate for anything in mm/ but if we look
at some actual init functions themselves, we see things like:

mm/huge_memory.c --> hugepage_init     --> hugepage_init_sysfs
mm/mmap.c        --> init_user_reserve --> sysctl_user_reserve_kbytes
mm/ksm.c         --> ksm_init          --> sysfs_create_group

and hence the choice of subsys_initcall (l4) seems reasonable,
and at the same time minimizes the risk of changing the priority
too drastically all at once.  We can adjust further in the future.

Also, several instances of missing ";" at EOL are fixed.

Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/huge_memory.c  | 2 +-
 mm/ksm.c          | 2 +-
 mm/mmap.c         | 6 +++---
 mm/mmu_notifier.c | 3 +--
 4 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 95d1acb0f3d2..c6e7e0f60708 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -655,7 +655,7 @@ out:
 	hugepage_exit_sysfs(hugepage_kobj);
 	return err;
 }
-module_init(hugepage_init)
+subsys_initcall(hugepage_init);
 
 static int __init setup_transparent_hugepage(char *str)
 {
diff --git a/mm/ksm.c b/mm/ksm.c
index 175fff79dc95..dce1ad1cb696 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2438,4 +2438,4 @@ out_free:
 out:
 	return err;
 }
-module_init(ksm_init)
+subsys_initcall(ksm_init);
diff --git a/mm/mmap.c b/mm/mmap.c
index 834b2d785f1e..0a7717664c9e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3140,7 +3140,7 @@ static int init_user_reserve(void)
 	sysctl_user_reserve_kbytes = min(free_kbytes / 32, 1UL << 17);
 	return 0;
 }
-module_init(init_user_reserve)
+subsys_initcall(init_user_reserve);
 
 /*
  * Initialise sysctl_admin_reserve_kbytes.
@@ -3161,7 +3161,7 @@ static int init_admin_reserve(void)
 	sysctl_admin_reserve_kbytes = min(free_kbytes / 32, 1UL << 13);
 	return 0;
 }
-module_init(init_admin_reserve)
+subsys_initcall(init_admin_reserve);
 
 /*
  * Reinititalise user and admin reserves if memory is added or removed.
@@ -3231,4 +3231,4 @@ static int __meminit init_reserve_notifier(void)
 
 	return 0;
 }
-module_init(init_reserve_notifier)
+subsys_initcall(init_reserve_notifier);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 93e6089cb456..41cefdf0aadd 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -329,5 +329,4 @@ static int __init mmu_notifier_init(void)
 {
 	return init_srcu_struct(&srcu);
 }
-
-module_init(mmu_notifier_init);
+subsys_initcall(mmu_notifier_init);
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
