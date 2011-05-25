Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 034866B0012
	for <linux-mm@kvack.org>; Tue, 24 May 2011 23:13:38 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4403E3EE0BD
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:13:36 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 28E3045DE5A
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:13:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FA0D45DE54
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:13:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0027BE08002
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:13:36 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C3159EF8004
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:13:35 +0900 (JST)
Message-ID: <4DDC73D8.5050900@jp.fujitsu.com>
Date: Wed, 25 May 2011 12:13:28 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] swap-token: add a comment for priority aging
References: <4DD480DD.2040307@jp.fujitsu.com>	<4DD481A7.3050108@jp.fujitsu.com> <20110520123004.e81c932e.akpm@linux-foundation.org> <4DDB1388.2080102@jp.fujitsu.com>
In-Reply-To: <4DDB1388.2080102@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com

Add to a few comment of design decision of swap token aging.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/thrash.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/thrash.c b/mm/thrash.c
index 0504e8a..8832edb 100644
--- a/mm/thrash.c
+++ b/mm/thrash.c
@@ -50,6 +50,17 @@ void grab_swap_token(struct mm_struct *mm)
 	if (!swap_token_mm)
 		goto replace_token;

+	/*
+	 * Usually, we don't need priority aging because long interval faults
+	 * makes priority decrease quickly. But there is one exception. If the
+	 * token owner task is sleeping, it never make long interval faults.
+	 * Thus, we need a priority aging mechanism instead. The requirements
+	 * of priority aging are
+	 *  1) An aging interval is reasonable enough long. Too short aging
+	 *     interval makes quick swap token lost and decrease performance.
+	 *  2) The swap token owner task have to get priority aging even if
+	 *     it's under sleep.
+	 */
 	if ((global_faults - last_aging) > TOKEN_AGING_INTERVAL) {
 		swap_token_mm->token_priority /= 2;
 		last_aging = global_faults;
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
