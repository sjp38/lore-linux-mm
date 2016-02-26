Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id DFC496B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:27:50 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id hb3so31851503igb.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 02:27:50 -0800 (PST)
Received: from out21.biz.mail.alibaba.com (out114-136.biz.mail.alibaba.com. [205.204.114.136])
        by mx.google.com with ESMTP id m1si16047295iom.95.2016.02.26.02.27.49
        for <linux-mm@kvack.org>;
        Fri, 26 Feb 2016 02:27:50 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <20160203132718.GI6757@dhcp22.suse.cz> <alpine.LSU.2.11.1602241832160.15564@eggly.anvils> <20160225092315.GD17573@dhcp22.suse.cz> <alpine.LSU.2.11.1602252219020.9793@eggly.anvils> <009a01d1706a$e666dc00$b3349400$@alibaba-inc.com> <20160226092406.GB8940@dhcp22.suse.cz>
In-Reply-To: <20160226092406.GB8940@dhcp22.suse.cz>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Date: Fri, 26 Feb 2016 18:27:16 +0800
Message-ID: <00bd01d17080$445ceb00$cd16c100$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: 'Hugh Dickins' <hughd@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@i-love.sakura.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Sergey Senozhatsky' <sergey.senozhatsky.work@gmail.com>

>> 
> > --- a/mm/page_alloc.c	Thu Feb 25 15:43:18 2016
> > +++ b/mm/page_alloc.c	Fri Feb 26 15:18:55 2016
> > @@ -3113,6 +3113,8 @@ should_reclaim_retry(gfp_t gfp_mask, uns
> >  	struct zone *zone;
> >  	struct zoneref *z;
> >
> > +	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> > +		return true;
> 
> This is defeating the whole purpose of the rework - to behave
> deterministically. You have just disabled the oom killer completely.
> This is not the way to go
> 
Then in another direction, below is what I can do.

thanks
Hillf
--- a/mm/page_alloc.c	Thu Feb 25 15:43:18 2016
+++ b/mm/page_alloc.c	Fri Feb 26 18:14:59 2016
@@ -3366,8 +3366,11 @@ retry:
 		no_progress_loops++;
 
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
-				 did_some_progress > 0, no_progress_loops))
+				 did_some_progress > 0, no_progress_loops)) {
+		/* Burn more cycles if any zone seems to satisfy our request */
+		no_progress_loops /= 2;
 		goto retry;
+	}
 
 	/* Reclaim has failed us, start killing things */
 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
