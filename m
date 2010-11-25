Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 29F556B004A
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 05:18:56 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAPAIrcj023464
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 25 Nov 2010 19:18:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EFDF45DE4F
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 19:18:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 433A745DE4C
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 19:18:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 288AB1DB8014
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 19:18:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DC2B21DB8013
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 19:18:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101125090328.GB14180@hostway.ca>
References: <1290647274.12777.3.camel@sli10-conroe> <20101125090328.GB14180@hostway.ca>
Message-Id: <20101125191759.F465.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Nov 2010 19:18:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

> There are actually a few problems here.  I think they are worth looking
> at them separately, unless "don't use order 3 allocations" is a valid
> statement, in which case we should fix slub.
> 
> The funny thing here is that slub.c's allocate_slab() calls alloc_pages()
> with flags | __GFP_NOWARN | __GFP_NORETRY, and intentionally tries a
> lower order allocation automatically if it fails.  This is why there is
> no allocation failure warning when this happens.  However, it is too late
> -- kswapd is woken and it ties to bring order 3 up to the watermark. 
> If we hacked __alloc_pages_slowpath() to not wake kswapd when
> __GFP_NOWARN is set, we would never see this problem and the slub
> optimization might still mostly work.  Either way, we should "fix" slub
> or "fix" order-3 allocations, so that other people who are using slub
> don't hit the same problem.

This?




Subject: [PATCH] slub: use no __GFP_WAIT instead __GFP_NORETRY

---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8c66aef..0c77399 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1134,7 +1134,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 * Let the initial higher-order allocation fail under memory pressure
 	 * so we fall-back to the minimum order allocation.
 	 */
-	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
+	alloc_gfp = (flags | __GFP_NOWARN) & ~(__GFP_NOFAIL | __GFP_WAIT);
 
 	page = alloc_slab_page(alloc_gfp, node, oo);
 	if (unlikely(!page)) {
-- 
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
