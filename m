Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 62E056B007E
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 11:29:37 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 2/2] staging: ramster: Dont build ramster when CONFIGFS_FS=m
Date: Mon, 20 Feb 2012 08:29:31 -0800
Message-Id: <1329755371-5444-2-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1329755371-5444-1-git-send-email-dan.magenheimer@oracle.com>
References: <1329755371-5444-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com

Ramster can't be a module (yet) and depends on CONFIGFS_FS=y, but
allmodconfig builds with CONFIGFS_FS=m, which breaks the build.
And forcing CONFIGFS_FS=y with select breaks the build in other ways.
So just don't build ramster unless CONFIGFS_FS=y.

Also, while we're here, add a comment as to why BROKEN is depended.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/ramster/Kconfig |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/ramster/Kconfig b/drivers/staging/ramster/Kconfig
index b045704..8b57b87 100644
--- a/drivers/staging/ramster/Kconfig
+++ b/drivers/staging/ramster/Kconfig
@@ -1,6 +1,10 @@
+# Dependency on CONFIG_BROKEN is because there is a commit dependency
+# on a cleancache naming change to be submitted by Konrad Wilk
+# a39c00ded70339603ffe1b0ffdf3ade85bcf009a "Merge branch 'stable/cleancache.v13'
+# into linux-next.  Once this commit is present, BROKEN can be removed
 config RAMSTER
 	bool "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
-	depends on (CLEANCACHE || FRONTSWAP) && CONFIGFS_FS && !ZCACHE && !XVMALLOC && !HIGHMEM && BROKEN
+	depends on (CLEANCACHE || FRONTSWAP) && CONFIGFS_FS=y && !ZCACHE && !XVMALLOC && !HIGHMEM && BROKEN
 	select LZO_COMPRESS
 	select LZO_DECOMPRESS
 	default n
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
