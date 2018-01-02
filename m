Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2226B029A
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 05:03:27 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id g33so30177479plb.13
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 02:03:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor4558200plb.107.2018.01.02.02.03.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jan 2018 02:03:26 -0800 (PST)
From: Joey Pabalinas <joeypabalinas@gmail.com>
Subject: [PATCH 2/2] mm/zswap: move `zswap_has_pool` to front of `if ()`
Date: Tue,  2 Jan 2018 00:03:20 -1000
Message-Id: <20180102100320.24801-3-joeypabalinas@gmail.com>
In-Reply-To: <20180102100320.24801-1-joeypabalinas@gmail.com>
References: <20180102100320.24801-1-joeypabalinas@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sjenning@redhat.com, ddstreet@ieee.org, linux-kernel@vger.kernel.org, Joey Pabalinas <joeypabalinas@gmail.com>

`zwap_has_pool` is a simple boolean, so it should be tested first
to avoid unnecessarily calling `strcmp()`. Test `zswap_has_pool`
first to take advantage of the short-circuiting behavior of && in
`__zswap_param_set()`.

Signed-off-by: Joey Pabalinas <joeypabalinas@gmail.com>

 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index a4f2dfaf9131694265..dbf35139471f692798 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -672,7 +672,7 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
 	}
 
 	/* no change required */
-	if (!strcmp(s, *(char **)kp->arg) && zswap_has_pool)
+	if (zswap_has_pool && !strcmp(s, *(char **)kp->arg))
 		return 0;
 
 	/* if this is load-time (pre-init) param setting,
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
