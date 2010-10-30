Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 88C308D005B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 09:58:31 -0400 (EDT)
Message-ID: <4CCC2480.70303@kernel.org>
Date: Sat, 30 Oct 2010 15:58:24 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: [PATCH] percpu: zero memory more efficiently in mm/percpu.c::pcpu_mem_alloc()
References: <alpine.LNX.2.00.1010292354060.24561@swampdragon.chaosbits.net>
In-Reply-To: <alpine.LNX.2.00.1010292354060.24561@swampdragon.chaosbits.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Don't do vmalloc() + memset() when vzalloc() will do.

tj: dropped unnecessary temp variable ptr.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Signed-off-by: Tejun Heo <tj@kernel.org>
---
Applied with slight modification.  Thank you.

 mm/percpu.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index efe8168..9e16d1c 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -293,12 +293,8 @@ static void *pcpu_mem_alloc(size_t size)

 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_KERNEL);
-	else {
-		void *ptr = vmalloc(size);
-		if (ptr)
-			memset(ptr, 0, size);
-		return ptr;
-	}
+	else
+		return vzalloc(size);
 }

 /**
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
