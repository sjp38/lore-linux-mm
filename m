Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 585E56B03A1
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 00:58:05 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so6187152wmf.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 21:58:05 -0800 (PST)
Received: from vps202351.ovh.net (blatinox.fr. [51.254.120.209])
        by mx.google.com with ESMTP id x62si1164065wmb.132.2016.11.17.21.58.04
        for <linux-mm@kvack.org>;
        Thu, 17 Nov 2016 21:58:04 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Lefaure?= <jeremy.lefaure@lse.epita.fr>
Subject: [PATCH] shmem: fix compilation warnings on unused functions
Date: Fri, 18 Nov 2016 00:57:49 -0500
Message-Id: <20161118055749.11313-1-jeremy.lefaure@lse.epita.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, =?UTF-8?q?J=C3=A9r=C3=A9my=20Lefaure?= <jeremy.lefaure@lse.epita.fr>

Compiling shmem.c with CONFIG_SHMEM and
CONFIG_TRANSAPRENT_HUGE_PAGECACHE enabled raises warnings on two unused
functions when CONFIG_TMPFS and CONFIG_SYSFS are both disabled:

mm/shmem.c:390:20: warning: a??shmem_format_hugea?? defined but not used
[-Wunused-function]
 static const char *shmem_format_huge(int huge)
                    ^~~~~~~~~~~~~~~~~
mm/shmem.c:373:12: warning: a??shmem_parse_hugea?? defined but not used
[-Wunused-function]
 static int shmem_parse_huge(const char *str)
             ^~~~~~~~~~~~~~~~

A conditional compilation on tmpfs or sysfs removes the warnings.

Signed-off-by: JA(C)rA(C)my Lefaure <jeremy.lefaure@lse.epita.fr>
---
 mm/shmem.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 2c74186..99595d8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -370,6 +370,7 @@ static bool shmem_confirm_swap(struct address_space *mapping,
 
 int shmem_huge __read_mostly;
 
+#if defined(CONFIG_SYSFS) || defined(CONFIG_TMPFS)
 static int shmem_parse_huge(const char *str)
 {
 	if (!strcmp(str, "never"))
@@ -407,6 +408,7 @@ static const char *shmem_format_huge(int huge)
 		return "bad_val";
 	}
 }
+#endif
 
 static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
 		struct shrink_control *sc, unsigned long nr_to_split)
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
