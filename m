Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82A666B0264
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:56:16 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so7939641lfe.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:56:16 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id y14si2739485wmd.24.2016.07.07.02.56.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 02:56:15 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id A91F81C3019
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 10:56:14 +0100 (IST)
Date: Thu, 7 Jul 2016 10:56:13 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160707095613.GQ11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160705055931.GC28164@bbox>
 <20160705102639.GG11498@techsingularity.net>
 <20160706003054.GC12570@bbox>
 <20160706083121.GL11498@techsingularity.net>
 <20160707055121.GA18072@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707055121.GA18072@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 07, 2016 at 02:51:21PM +0900, Minchan Kim wrote:
> > It becomes difficult to tell the difference between "no wakeup and init to
> > zone 0" and "wakeup and reclaim for zone 0". At least that's the problem
> > I ran into when I tried before settling on -1.
> 
> Sorry for bothering you several times. I cannot parse what you mean.
> I didn't mean -1 is problem here but why do we need below two lines
> I removed?
> 

What you have should be fine. The hazard initially was that both
classzone_idx and kswapd_classzone_idx are enum and the signedness of
enum is implementation-dependent. Using max_t avoids that but it's a
subtle. I prefer the  obvious check of kswapd_classzone_idx == 1 because
it is clearer that we're checking for an initialised value instead of
depending on a side-effect of the casting in max_t to do the right thing.

I can apply it if you wish, I just don't think it helps.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
