Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A209E6B00ED
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 18:08:51 -0400 (EDT)
Date: Fri, 29 Oct 2010 23:58:39 +0200 (CEST)
From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Zero memory more efficiently in
 mm/percpu.c::pcpu_mem_alloc()
Message-ID: <alpine.LNX.2.00.1010292354060.24561@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Don't do vmalloc() + memset() when vzalloc() will do.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 percpu.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index efe8168..8d75223 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -294,9 +294,7 @@ static void *pcpu_mem_alloc(size_t size)
 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_KERNEL);
 	else {
-		void *ptr = vmalloc(size);
-		if (ptr)
-			memset(ptr, 0, size);
+		void *ptr = vzalloc(size);
 		return ptr;
 	}
 }


-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
