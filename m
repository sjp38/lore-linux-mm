Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 009256B004A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 03:43:09 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o887h7Zw031875
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 8 Sep 2010 16:43:07 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 04E1D45DE79
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 16:43:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C94C045DE70
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 16:43:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E1741DB8040
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 16:43:06 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 77B461DB803B
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 16:43:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after direct reclaim allocation fails
In-Reply-To: <1283504926-2120-4-git-send-email-mel@csn.ul.ie>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <1283504926-2120-4-git-send-email-mel@csn.ul.ie>
Message-Id: <20100908163956.C930.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Wed,  8 Sep 2010 16:43:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> +	/*
> +	 * If an allocation failed after direct reclaim, it could be because
> +	 * pages are pinned on the per-cpu lists. Drain them and try again
> +	 */
> +	if (!page && !drained) {
> +		drain_all_pages();
> +		drained =3D true;
> +		goto retry;
> +	}

nit: when slub, get_page_from_freelist() failure is frequently happen
than slab because slub try to allocate high order page at first.
So, I guess we have to avoid drain_all_pages() if __GFP_NORETRY is passed.




=46rom 9209ceb1d48446b031576ba9360036ddabc1a0e5 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 10 Sep 2010 03:29:05 +0900
Subject: [PATCH] mm: don't call drain_all_pages() when __GFP_NORETRY

SLUB try to allocate high order pages at first. therefore page allocator
eventually call drain_all_pages() frequently. We don't hope IPI storm.
Thus, we don't call drain_all_pages() when caller passed __GFP_NORETRY.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8587c10..b9eafb1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1878,7 +1878,7 @@ retry:
 	 * If an allocation failed after direct reclaim, it could be because
 	 * pages are pinned on the per-cpu lists. Drain them and try again
 	 */
-	if (!page && !drained) {
+	if (!page && !drained && !(gfp_mask & __GFP_NORETRY)) {
 		drain_all_pages();
 		drained =3D true;
 		goto retry;
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
