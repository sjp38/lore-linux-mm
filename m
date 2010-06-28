Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8EDF96B01B2
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 21:39:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5S1dgJ8001897
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 28 Jun 2010 10:39:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EA82045DE6F
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:39:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C743545DE6E
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:39:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 97D591DB803F
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:39:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5717D1DB803B
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:39:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: recalculate lru_pages on each priority
In-Reply-To: <20100627113422.GA14504@cmpxchg.org>
References: <20100625181221.805A.A69D9226@jp.fujitsu.com> <20100627113422.GA14504@cmpxchg.org>
Message-Id: <20100628103828.3873.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 28 Jun 2010 10:39:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Fri, Jun 25, 2010 at 06:13:20PM +0900, KOSAKI Motohiro wrote:
> > shrink_zones() need relatively long time. and lru_pages can be
> > changed dramatically while shrink_zones().
> > then, lru_pages need recalculate on each priority.
> 
> In the direct reclaim path, we bail out of that loop after
> SWAP_CLUSTER_MAX reclaimed pages, so in this case, decreasing priority
> levels actually mean we do _not_ make any progress and the total
> number of lru pages should not change (much).  The possible distortion
> in shrink_slab() is small.

Oh, you seems forgot the case when much thread enter try_to_free_pages()
concurrently.

> 
> However, for the suspend-to-disk case the reclaim target can be a lot
> higher and we inevitably end up at higher priorities even though we
> make progress, but fail to increase pressure on the shrinkers as well
> without your patch.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
