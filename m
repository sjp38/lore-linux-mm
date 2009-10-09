Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C92B26B0062
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 21:09:22 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9919KKN013019
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Oct 2009 10:09:21 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A8312AEA81
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:09:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 558DF1EF083
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:09:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 116E3E1800C
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:09:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BA8E1DB8038
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:09:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/3] Fix memory leak of do_mbind()
In-Reply-To: <20091009100527.1284.A69D9226@jp.fujitsu.com>
References: <20091009100527.1284.A69D9226@jp.fujitsu.com>
Message-Id: <20091009100837.128A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  9 Oct 2009 10:09:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

If migrate_prep is failed, new variable is leaked.
This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mempolicy.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 824abf3..38ce2a7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1027,7 +1027,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 
 		err = migrate_prep();
 		if (err)
-			return err;
+			goto mpol_out;
 	}
 	{
 		NODEMASK_SCRATCH(scratch);
@@ -1042,10 +1042,9 @@ static long do_mbind(unsigned long start, unsigned long len,
 			err = -ENOMEM;
 		NODEMASK_SCRATCH_FREE(scratch);
 	}
-	if (err) {
-		mpol_put(new);
-		return err;
-	}
+	if (err)
+		goto mpol_out;
+
 	vma = check_range(mm, start, end, nmask,
 			  flags | MPOL_MF_INVERT, &pagelist);
 
@@ -1066,6 +1065,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	}
 
 	up_write(&mm->mmap_sem);
+ mpol_out:
 	mpol_put(new);
 	return err;
 }
-- 
1.6.0.GIT



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
