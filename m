Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 97C8C6B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 04:03:34 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so16640441pab.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 01:03:34 -0700 (PDT)
Received: from out11.biz.mail.alibaba.com (out114-135.biz.mail.alibaba.com. [205.204.114.135])
        by mx.google.com with ESMTP id tl10si11303118pbc.253.2015.10.14.01.03.32
        for <linux-mm@kvack.org>;
        Wed, 14 Oct 2015 01:03:33 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: Silent hang up caused by pages being not scanned?
Date: Wed, 14 Oct 2015 16:03:15 +0800
Message-ID: <00bc01d10656$c7f19ef0$57d4dcd0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> > 
> > In particular, I think that you'll find that you will have to change
> > the heuristics in __alloc_pages_slowpath() where we currently do
> > 
> >         if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) || ..
> > 
> > when the "did_some_progress" logic changes that radically.
> > 
> 
> Yes. But we can't simply do
> 
>	if (order <= PAGE_ALLOC_COSTLY_ORDER || ..
> 
> because we won't be able to call out_of_memory(), can we?
>
Can you please try a simplified retry logic?

thanks
Hillf
--- a/mm/page_alloc.c	Wed Oct 14 14:45:28 2015
+++ b/mm/page_alloc.c	Wed Oct 14 15:43:31 2015
@@ -3154,8 +3154,7 @@ retry:
 
 	/* Keep reclaiming pages as long as there is reasonable progress */
 	pages_reclaimed += did_some_progress;
-	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
-	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
+	if (did_some_progress) {
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto retry;
--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
