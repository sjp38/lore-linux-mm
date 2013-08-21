Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 91B066B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 22:26:03 -0400 (EDT)
Message-ID: <521424FA.5000203@asianux.com>
Date: Wed, 21 Aug 2013 10:24:58 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] mm/shmem.c: check the return value of mpol_to_str()
References: <5212E8DF.5020209@asianux.com> <20130820053036.GB18673@moon> <52130194.4030903@asianux.com> <20130820064730.GD18673@moon> <52131F48.1030002@asianux.com> <52132011.60501@asianux.com> <52132432.3050308@asianux.com> <20130820082516.GE18673@moon> <52142422.9050209@asianux.com> <52142464.8060903@asianux.com> <521424BE.8020309@asianux.com>
In-Reply-To: <521424BE.8020309@asianux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

mpol_to_str() may fail, and not fill the buffer (e.g. -EINVAL), so need
check about it, or buffer may not be zero based, and next seq_printf()
will cause issue.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
---
 mm/shmem.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index e59d332..ae5112f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -886,11 +886,14 @@ redirty:
 static int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
 	char buffer[64];
+	int ret;
 
 	if (!mpol || mpol->mode == MPOL_DEFAULT)
 		return 0;		/* show nothing */
 
-	mpol_to_str(buffer, sizeof(buffer), mpol);
+	ret = mpol_to_str(buffer, sizeof(buffer), mpol);
+	if (ret < 0)
+		return ret;
 
 	seq_printf(seq, ",mpol=%s", buffer);
 	return 0;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
