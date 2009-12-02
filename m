Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6535560021B
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 21:55:35 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB22tWqs005144
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 2 Dec 2009 11:55:32 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5020F45DE50
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:55:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CE7D45DE4F
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:55:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id ECF121DB803E
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:55:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E7271DB8038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:55:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] Clear reference bit although page isn't mapped.
In-Reply-To: <20091201102645.5C0A.A69D9226@jp.fujitsu.com>
References: <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com> <20091201102645.5C0A.A69D9226@jp.fujitsu.com>
Message-Id: <20091202115358.5C4F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed,  2 Dec 2009 11:55:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> btw, current shrink_active_list() have unnecessary page_mapping_inuse() call.
> it prevent to drop page reference bit from unmapped cache page. it mean
> we protect unmapped cache page than mapped page. it is strange.

How about this?

---------------------------------
SplitLRU VM replacement algorithm assume shrink_active_list() clear
the page's reference bit. but unnecessary page_mapping_inuse() test
prevent it.

This patch remove it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 00156f2..3e942b5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1347,8 +1347,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 		}
 
 		/* page_referenced clears PageReferenced */
-		if (page_mapping_inuse(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
+		if (page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
 			nr_rotated++;
 			/*
 			 * Identify referenced, file-backed active pages and
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
