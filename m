Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id B0BD96B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 04:27:25 -0500 (EST)
Received: by wevm14 with SMTP id m14so4463241wev.8
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 01:27:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gl9si45634173wjc.3.2015.02.20.01.27.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 01:27:23 -0800 (PST)
Date: Fri, 20 Feb 2015 10:27:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150220092721.GE21248@dhcp22.suse.cz>
References: <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150218082502.GA4478@dhcp22.suse.cz>
 <20150218104859.GM12722@dastard>
 <20150218121602.GC4478@dhcp22.suse.cz>
 <20150218213118.GN12722@dastard>
 <20150219094020.GE28427@dhcp22.suse.cz>
 <20150219220355.GX12722@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150219220355.GX12722@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Fri 20-02-15 09:03:55, Dave Chinner wrote:
[...]
> Converting the code to use GFP_NOFAIL takes us in exactly the
> opposite direction to our current line of development w.r.t. to
> filesystem error handling.

Fair enough. If there are plans to have a failure policy rather than
GFP_NOFAIL like behavior then I have, of course, no objections. Quite
opposite. This is exactly what I would like to see. GFP_NOFAIL should be
rarely used, really.

The whole point of this discussion, and I am sorry if I didn't make it
clear, is that _if_ there is really a GFP_NOFAIL requirement hidden
from the allocator then it should be changed to use GFP_NOFAIL so that
allocator knows about this requirement.

> > The reason I care about GFP_NOFAIL is that there are apparently code
> > paths which do not tell allocator they are basically GFP_NOFAIL without
> > any fallback. This leads to two main problems 1) we do not have a good
> > overview how many code paths have such a strong requirements and so
> > cannot estimate e.g. how big memory reserves should be and
> 
> Right, when GFP_NOFAIL got deprecated we lost the ability to document
> such behaviour and find it easily. People just put retry loops in
> instead of using GFP_NOFAIL. Good luck finding them all :/

That will be PITA, all right, but I guess the deprecation was a mistake
and we should stop this tendency.

> > 2) allocator
> > cannot help those paths (e.g. by giving them access to reserves to break
> > out of the livelock).
> 
> Allocator should not help. Global reserves are unreliable - make the
> allocation context reserve the amount it needs before it enters the
> context where it can't back out....

Sure pre-allocation is preferable. But once somebody asks for GFP_NOFAIL
then it is too late and the allocator only has memory reclaim and
potentially reserves.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
