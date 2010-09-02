Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EEF796B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 19:57:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o82Nv8ft018350
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 3 Sep 2010 08:57:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E406245DE53
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 08:57:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D76145DE50
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 08:57:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DEE91DB8038
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 08:57:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AB50A1DB803C
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 08:57:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3] vmscan: prevent background aging of anon page in no swap system
In-Reply-To: <1283441862-15855-1-git-send-email-minchan.kim@gmail.com>
References: <1283441862-15855-1-git-send-email-minchan.kim@gmail.com>
Message-Id: <20100903085612.B654.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  3 Sep 2010 08:57:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> Ying Han reported that backing aging of anon pages in no swap system
> causes unnecessary TLB flush.
> 
> When I sent a patch(69c8548175), I wanted this patch but Rik pointed out
> and allowed aging of anon pages to give a chance to promote from inactive
> to active LRU.
> 
> It has a two problem.
> 
> 1) non-swap system
> 
> Never make sense to age anon pages.
> 
> 2) swap configured but still doesn't swapon
> 
> It doesn't make sense to age anon pages until swap-on time.
> But it's arguable. If we have aged anon pages by swapon, VM have moved
> anon pages from active to inactive. And in the time swapon by admin,
> the VM can't reclaim hot pages so we can protect hot pages swapout.
> 
> But let's think about it. When does swap-on happen? It depends on admin.
> we can't expect it. Nonetheless, we have done aging of anon pages to
> protect hot pages swapout. It means we lost run time overhead when
> below high watermark but gain hot page swap-[in/out] overhead when VM
> decide swapout. Is it true? Let's think more detail.
> We don't promote anon pages in case of non-swap system. So even though
> VM does aging of anon pages, the pages would be in inactive LRU for a long
> time. It means many of pages in there would mark access bit again. So access
> bit hot/code separation would be pointless.
> 
> This patch prevents unnecessary anon pages demotion in not-yet-swapon and
> non-configured swap system. Even, in non-configuared swap system
> inactive_anon_is_low can be compiled out.
> 
> It could make side effect that hot anon pages could swap out
> when admin does swap on. But I think sooner or later it would be
> steady state. So it's not a big problem.
> 
> We could lose someting but gain more thing(TLB flush and unnecessary
> function call to demote anon pages).
> 
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
