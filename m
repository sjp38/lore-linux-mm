Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id A6EAC6B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 23:04:28 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id va2so8787260obc.8
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 20:04:28 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id uk5si13164965oeb.0.2014.12.01.20.04.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Dec 2014 20:04:27 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: fadvise: avoid signed integer overflow calculating offset
Date: Mon,  1 Dec 2014 23:04:08 -0500
Message-Id: <1417493050-13594-4-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1417493050-13594-1-git-send-email-sasha.levin@oracle.com>
References: <1417493050-13594-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Sasha Levin <sasha.levin@oracle.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Both offset and len are signed integers who's overflow isn't defined. Use
unsigned addition to avoid the issue.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/fadvise.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index 3bcfd81d..762cb63 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -67,7 +67,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 	}
 
 	/* Careful about overflows. Len == 0 means "as much as possible" */
-	endbyte = offset + len;
+	endbyte = offset + (u64)len;
 	if (!len || endbyte < len)
 		endbyte = -1;
 	else
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
