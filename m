Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 596636B0092
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 17:19:27 -0500 (EST)
Date: Sun, 19 Dec 2010 23:10:20 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Close mem leak in error path in
 mm/hugetlb.c::nr_hugepages_store_common()
Message-ID: <alpine.LNX.2.00.1012192305260.6486@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

The NODEMASK_ALLOC macro dynamically allocates memory for its second 
argument ('nodes_allowed' in this context).
In nr_hugepages_store_common() we may abort early if strict_strtoul() 
fails, but in that case we do not free the memory already allocated to 
'nodes_allowed', causing a memory leak.
This patch closes the leak by freeing the memory in the error path.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 hugetlb.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

  compile tested only

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8585524..9fdcc35 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1439,8 +1439,10 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
 
 	err = strict_strtoul(buf, 10, &count);
-	if (err)
+	if (err) {
+		kfree(nodes_allowed);
 		return 0;
+	}
 
 	h = kobj_to_hstate(kobj, &nid);
 	if (nid == NUMA_NO_NODE) {



-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
