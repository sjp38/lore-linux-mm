Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id C49F36B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 11:17:54 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 27 Jun 2013 11:17:53 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id A48DD38C801A
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 11:17:50 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5RFHp1p302360
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 11:17:51 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5RFHo5s017265
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 11:17:51 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [RESEND][PATCH] zswap: fix Kconfig to depend on CRYPTO=y
Date: Thu, 27 Jun 2013 10:17:43 -0500
Message-Id: <1372346263-6005-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Fengguang Wu <fengguang.wu@intel.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The Kconfig entry for zswap currently allows CRYPTO=m to satisfy the
zswap dependency.  However zswap is boolean (i.e. built-in) and has
symbol dependencies on CRYPTO.  Additionally, because the CRYPTO dependency
is satisfied with =m, the additional selects zswap does can also
be satisfied with =m, which leads to additional linking errors.

>From the report:
=====
tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.9
head:   57cefddb141d6c9d0ab4f5a8589dd017f796a3f7
commit: 563f51c95b552e0d663df5bdf6cfc8e8a72d3ec6 [494/499] zswap: add to mm/
config: x86_64-randconfig-x004-0619 (attached as .config)

All error/warnings:

   mm/built-in.o: In function `zswap_frontswap_invalidate_area':
>> zswap.c:(.text+0x3a705): undefined reference to `zbud_free'
   mm/built-in.o: In function `zswap_free_entry':
>> zswap.c:(.text+0x3a76b): undefined reference to `zbud_free'
>> zswap.c:(.text+0x3a789): undefined reference to `zbud_get_pool_size'
on and on...
=====

This patch makes CRYPTO a built-in dependency of ZSWAP.  This has the
side effect of also making the selects built-in.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
---

Andrew, please merge this into your mmotm ASAP as it fixes a demonstrable
build break.

 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 949e8de..81763ae 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -490,7 +490,7 @@ config ZBUD
 
 config ZSWAP
 	bool "Compressed cache for swap pages (EXPERIMENTAL)"
-	depends on FRONTSWAP && CRYPTO
+	depends on FRONTSWAP && CRYPTO=y
 	select CRYPTO_LZO
 	select ZBUD
 	default n
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
