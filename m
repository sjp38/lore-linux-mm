Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id C5C766B0033
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 01:11:17 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx1so2102763pab.27
        for <linux-mm@kvack.org>; Sat, 03 Aug 2013 22:11:17 -0700 (PDT)
From: Manjunath Goudar <manjunath.goudar@linaro.org>
Subject: [PATCH] MM: Make Contiguous Memory Allocator depends on MMU
Date: Sun,  4 Aug 2013 10:41:01 +0530
Message-Id: <1375593061-11350-1-git-send-email-manjunath.goudar@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: patches@linaro.org, arnd@linaro.org, dsaxena@linaro.org, manjunath.goudar@linaro.org, linaro-kernel@lists.linaro.org, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

s patch adds a Kconfig dependency on an MMU being available before
CMA can be enabled.  Without this patch, CMA can be enabled on an
MMU-less system which can lead to issues. This was discovered during
randconfig testing, in which CMA was enabled w/o MMU being enabled,
leading to the following error:

 CC      mm/migrate.o
mm/migrate.c: In function a??remove_migration_ptea??:
mm/migrate.c:134:3: error: implicit declaration of function a??pmd_trans_hugea??
[-Werror=implicit-function-declaration]
   if (pmd_trans_huge(*pmd))
   ^
mm/migrate.c:137:3: error: implicit declaration of function a??pte_offset_mapa??
[-Werror=implicit-function-declaration]
   ptep = pte_offset_map(pmd, addr);

Signed-off-by: Manjunath Goudar <manjunath.goudar@linaro.org>
Acked-by: Arnd Bergmann <arnd@linaro.org>
Cc: Deepak Saxena <dsaxena@linaro.org>
Cc: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 256bfd0..ad6b98e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -522,7 +522,7 @@ config MEM_SOFT_DIRTY
 
 config CMA
 	bool "Contiguous Memory Allocator"
-	depends on HAVE_MEMBLOCK
+	depends on MMU && HAVE_MEMBLOCK
 	select MIGRATION
 	select MEMORY_ISOLATION
 	help
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
