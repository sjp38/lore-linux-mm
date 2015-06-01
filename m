Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0DED16B0038
	for <linux-mm@kvack.org>; Sun, 31 May 2015 20:54:40 -0400 (EDT)
Received: by igbjd9 with SMTP id jd9so50156048igb.1
        for <linux-mm@kvack.org>; Sun, 31 May 2015 17:54:39 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id 80si9881928iog.101.2015.05.31.17.54.38
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 31 May 2015 17:54:38 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 01/11] mm: replace module_init usages with subsys_initcall in nommu.c
Date: Sun, 31 May 2015 20:54:02 -0400
Message-ID: <1433120052-18281-2-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1433120052-18281-1-git-send-email-paul.gortmaker@windriver.com>
References: <1433120052-18281-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Compiling some arm/m68k configs with "# CONFIG_MMU is not set" reveals
two more instances of module_init being used for code that can't
possibly be modular, as CONFIG_MMU is either on or off.

We replace them with subsys_initcall as per what was done in other
mmu-enabled code.

Note that direct use of __initcall is discouraged, vs.  one of the
priority categorized subgroups.  As __initcall gets mapped onto
device_initcall, our use of subsys_initcall (which makes sense for these
files) will thus change this registration from level 6-device to level
4-subsys (i.e.  slightly earlier).

One might think that core_initcall (l2) or postcore_initcall (l3) would
be more appropriate for anything in mm/ but if we look at the actual init
functions themselves, we see they are just sysctl setup stuff, and
hence the choice of subsys_initcall (l4) seems reasonable.  At the same
time it minimizes the risk of changing the priority too drastically all
at once.  We can adjust further in the future.

Also, a couple instances of missing ";" at EOL are fixed.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/nommu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index e544508e2a4b..e7b24dcec505 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -2157,7 +2157,7 @@ static int __meminit init_user_reserve(void)
 	sysctl_user_reserve_kbytes = min(free_kbytes / 32, 1UL << 17);
 	return 0;
 }
-module_init(init_user_reserve)
+subsys_initcall(init_user_reserve);
 
 /*
  * Initialise sysctl_admin_reserve_kbytes.
@@ -2178,4 +2178,4 @@ static int __meminit init_admin_reserve(void)
 	sysctl_admin_reserve_kbytes = min(free_kbytes / 32, 1UL << 13);
 	return 0;
 }
-module_init(init_admin_reserve)
+subsys_initcall(init_admin_reserve);
-- 
2.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
