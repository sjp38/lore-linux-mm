Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7AA8C6001DA
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 01:50:27 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2G5oNpR001567
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Mar 2010 14:50:23 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B39345DE51
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:50:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BDC945DE4F
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:50:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D2491DB803F
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:50:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F9191DB8040
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:50:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/5] tmpfs: mpol=bind:0 don't cause mount error.
In-Reply-To: <20100316143406.4C45.A69D9226@jp.fujitsu.com>
References: <201003122353.o2CNrC56015250@imap1.linux-foundation.org> <20100316143406.4C45.A69D9226@jp.fujitsu.com>
Message-Id: <20100316144929.4C4B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Mar 2010 14:50:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, kiran@scalex86.org, cl@linux-foundation.org, hugh.dickins@tiscali.co.uk, lee.schermerhorn@hp.com, mel@csn.ul.ie, stable@kernel.org, linux-mm <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Currently, following mount operation cause mount error.

% mount -t tmpfs -ompol=bind:0 none /tmp

Because commit 71fe804b6d5 (mempolicy: use struct mempolicy pointer in
shmem_sb_info) corrupted MPOL_BIND parse code.

This patch restore the needed one.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ravikiran Thirumalai <kiran@scalex86.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: <stable@kernel.org>
---
 mm/mempolicy.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 25a0c0f..3f77062 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2220,9 +2220,13 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 		if (!nodelist)
 			err = 0;
 		goto out;
-	/*
-	 * case MPOL_BIND:    mpol_new() enforces non-empty nodemask.
-	 */
+	case MPOL_BIND:
+		/* 
+		 * Insist on a nodelist
+		 */
+		if (!nodelist)
+			goto out;
+		err = 0;
 	}
 
 	mode_flags = 0;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
