Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 96FE86B01B2
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 21:32:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5S1W1Au031006
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 28 Jun 2010 10:32:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B186F45DD77
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:32:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 921F145DE4D
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:32:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CEEC1DB8037
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:32:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EF721DB803B
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:32:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] vmscan: shrink_slab() require number of lru_pages, not page order
In-Reply-To: <alpine.DEB.2.00.1006250857040.18900@router.home>
References: <20100625201915.8067.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006250857040.18900@router.home>
Message-Id: <20100628102342.386D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 28 Jun 2010 10:32:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Fri, 25 Jun 2010, KOSAKI Motohiro wrote:
> 
> > Fix simple argument error. Usually 'order' is very small value than
> > lru_pages. then it can makes unnecessary icache dropping.
> 
> This is going to reduce the delta that is added to shrinker->nr
> significantly thereby increasing the number of times that shrink_slab() is
> called.

Yup. But,

Smaller shrink -> only makes retry
Bigger shrink  -> makes unnecessary icache/dcache drop. it can bring
                  mysterious low performance.


> What does the "lru_pages" parameter do in shrink_slab()? Looks
> like its only role is as a divison factor in a complex calculation of
> pages to be scanned.

Yes.
scanned/lru_pages ratio define basic shrink_slab puressure strength.

So, If you intentionally need bigger slab pressure, bigger scanned parameter
passing is better rather than mysterious 'order' parameter.

> 
> do_try_to_free_pages passes 0 as "lru_pages" to shrink_slab() when trying
> to do cgroup lru scans. Why is that?

?
When cgroup lru scans, do_try_to_free_pages() don't call shrink_slab().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
