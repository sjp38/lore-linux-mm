Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f70.google.com (mail-qg0-f70.google.com [209.85.192.70])
	by kanga.kvack.org (Postfix) with ESMTP id B0FBE6B0005
	for <linux-mm@kvack.org>; Sun, 22 May 2016 17:17:42 -0400 (EDT)
Received: by mail-qg0-f70.google.com with SMTP id e35so267192741qge.0
        for <linux-mm@kvack.org>; Sun, 22 May 2016 14:17:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n134si20622694qka.10.2016.05.22.14.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 May 2016 14:17:41 -0700 (PDT)
Date: Sun, 22 May 2016 23:17:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
Message-ID: <20160522211736.GA3161@redhat.com>
References: <20160520202817.GA22201@redhat.com>
 <237e1113-fca7-51c7-1271-fb48398fd599@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <237e1113-fca7-51c7-1271-fb48398fd599@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/21, Tetsuo Handa wrote:
>
> On 2016/05/21 5:28, Oleg Nesterov wrote:
> > It spins in __alloc_pages_slowpath() forever, __alloc_pages_may_oom() is never
> > called, it doesn't react to SIGKILL, etc.
> >
> > This is because zone_reclaimable() is always true in shrink_zones(), and the
> > problem goes away if I comment out this code
> >
> > 	if (global_reclaim(sc) &&
> > 	    !reclaimable && zone_reclaimable(zone))
> > 		reclaimable = true;
> >
> > in shrink_zones() which otherwise returns this "true" every time, and thus
> > __alloc_pages_slowpath() always sees did_some_progress != 0.
> >
>
> Michal Hocko's OOM detection rework patchset that removes that code was sent
> to Linus 4 hours ago. ( https://marc.info/?l=linux-mm-commits&m=146378862415399 )
> Please wait for a few days and try reproducing using linux.git .

I guess you mean
http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/mm/vmscan.c?id=fa8c5f033ebb43f925d68c29d297bafd36af7114
"mm, oom: rework oom detection"...

Yes thanks a lot Tetsuo, it should fix the problem.

Cough I can't resist I hate Michal^W the fact this was already fixed ;) Because
it took me some time to understand whats going on, initially it looked like some
subtle and hard-to-reproduce bug in userfaultfd.

Thanks!

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
