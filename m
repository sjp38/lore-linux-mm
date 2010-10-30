Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AD0DF8D005B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 17:46:06 -0400 (EDT)
Date: Sat, 30 Oct 2010 23:35:46 +0200 (CEST)
From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] cgroup: Avoid a memset by using vzalloc
Message-ID: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi,

We can avoid doing a memset in swap_cgroup_swapon() by using vzalloc().


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
compile tested only.
 page_cgroup.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 5bffada..34970c7 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -450,11 +450,10 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 	length = ((max_pages/SC_PER_PAGE) + 1);
 	array_size = length * sizeof(void *);
 
-	array = vmalloc(array_size);
+	array = vzalloc(array_size);
 	if (!array)
 		goto nomem;
 
-	memset(array, 0, array_size);
 	ctrl = &swap_cgroup_ctrl[type];
 	mutex_lock(&swap_cgroup_mutex);
 	ctrl->length = length;

-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
