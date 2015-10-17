Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8DD82F64
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 16:20:17 -0400 (EDT)
Received: by lbbpp2 with SMTP id pp2so91404730lbb.0
        for <linux-mm@kvack.org>; Sat, 17 Oct 2015 13:20:16 -0700 (PDT)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id t9si17185822lfd.41.2015.10.17.13.20.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Oct 2015 13:20:15 -0700 (PDT)
Received: by lffv3 with SMTP id v3so92644906lff.0
        for <linux-mm@kvack.org>; Sat, 17 Oct 2015 13:20:15 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] mm/maccess.c: actually return -EFAULT from strncpy_from_unsafe
Date: Sat, 17 Oct 2015 22:20:05 +0200
Message-Id: <1445113206-27980-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@plumgrid.com>, "David S. Miller" <davem@davemloft.net>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

As far as I can tell, strncpy_from_unsafe never returns -EFAULT. ret
is the result of a __copy_from_user_inatomic(), which is 0 for success
and positive (in this case necessarily 1) for access error - it is
never negative. So we were always returning the length of the,
possibly truncated, destination string.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
Probably not -stable-worthy. I can only find two callers, one of which
ignores the return value.

 mm/maccess.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/maccess.c b/mm/maccess.c
index 34fe24759ed1..d318db246826 100644
--- a/mm/maccess.c
+++ b/mm/maccess.c
@@ -99,5 +99,5 @@ long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count)
 	pagefault_enable();
 	set_fs(old_fs);
 
-	return ret < 0 ? ret : src - unsafe_addr;
+	return ret ? -EFAULT : src - unsafe_addr;
 }
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
