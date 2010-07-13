Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 051636B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 00:48:31 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D4mSMD024571
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Jul 2010 13:48:28 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 598CD45DE4D
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:48:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A54845DE50
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:48:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CD2D1DB804F
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:48:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD9B91DB8053
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:48:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: stop meaningless loop iteration when no  reclaimable slab
In-Reply-To: <AANLkTilA2rzWVVLqDQjhivHmnt0ZfaQBGEDh2TU6OfcJ@mail.gmail.com>
References: <20100709195625.FA28.A69D9226@jp.fujitsu.com> <AANLkTilA2rzWVVLqDQjhivHmnt0ZfaQBGEDh2TU6OfcJ@mail.gmail.com>
Message-Id: <20100712101237.EA0E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Jul 2010 13:48:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Hi

> 
> old shrink_slab
> 
> shrinker->nr += delta; /* Add delta to previous shrinker's remained count */
> total_scan = shrinker->nr;
> 
> while(total_scan >= SHRINK_BATCH) {
> 	nr_before = shrink(xxx);
> 	total_scan =- this_scan;
> }
> 
> shrinker->nr += total_scan;
> 
> The total_scan can always be the number < SHRINK_BATCH.
> So, when next shrinker calcuates loop count, the number can affect.

Correct.


> 
> new shrink_slab
> 
> shrinker->nr += delta; /* nr is always zero by your patch */

no.
my patch don't change delta calculation at all.


> total_scan = shrinker->nr;
> 
> while(total_scan >= SHRINK_BATCH) {
> 	nr_before = shrink(xxx);
> 	if (nr_before == 0) {
> 		total_scan = 0;
> 		break;
> 	}
> }
> 
> shrinker->nr += 0;
> 
> But after your patch, total_scan is always zero. It never affect
> next shrinker's loop count.

No. after my patch this loop has two exiting way
 1) total_scan are less than SHRINK_BATCH.
      -> no behavior change.  we still pass shrinker->nr += total_scan code.
 2) (*shrinker->shrink)(0, gfp_mask) return 0
      don't increase shrinker->nr.  because two reason,
      a) if total_scan are 10000,  we shouldn't carry over such big number.
      b) now, we have zero slab objects, then we have been freed form the guilty of keeping
          balance page and slab reclaim. shrinker->nr += 0; have zero side effect.

Thanks.

> 
> Am I missing something?
> -- 
> Kind regards,
> Minchan Kim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
