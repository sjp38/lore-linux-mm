Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 6AAFB6B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 00:00:13 -0400 (EDT)
Message-ID: <5212E98E.9010902@asianux.com>
Date: Tue, 20 Aug 2013 11:59:10 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] mm/shmem.c: check the return value of mpol_to_str()
References: <5212E8DF.5020209@asianux.com> <5212E910.7030609@asianux.com> <5212E948.8000401@asianux.com>
In-Reply-To: <5212E948.8000401@asianux.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, Cyrill Gorcunov <gorcunov@openvz.org>, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>hughd@google.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

mpol_to_str() may fail, and not fill the buffer (e.g. -EINVAL), so need
check about it, or buffer may not be zero based, and next seq_printf()
will cause issue.

Also print related warning when the buffer space is not enough.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/shmem.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 75010ba..eb4eec8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -886,11 +886,24 @@ redirty:
 static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
 	char buffer[64];
+	int ret;
 
 	if (!mpol || mpol->mode == MPOL_DEFAULT)
 		return;		/* show nothing */
 
-	mpol_to_str(buffer, sizeof(buffer), mpol);
+	ret = mpol_to_str(buffer, sizeof(buffer), mpol);
+	if (ret < 0)
+		switch (ret) {
+		case -ENOSPC:
+			printk(KERN_WARNING
+				"in %s: string is truncated in mpol_to_str().\n",
+				__func__);
+		default:
+			printk(KERN_ERR
+				"in %s: call mpol_to_str() fail, errcode: %d. buffer: %p, size: %zu, pol: %p\n",
+				__func__, ret, buffer, sizeof(buffer), mpol);
+			return;
+		}
 
 	seq_printf(seq, ",mpol=%s", buffer);
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
