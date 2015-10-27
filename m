Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDA16B0254
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 06:52:57 -0400 (EDT)
Received: by pasz6 with SMTP id z6so219351963pas.2
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 03:52:56 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id z10si60971304par.118.2015.10.27.03.52.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 03:52:56 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so229285231pac.3
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 03:52:56 -0700 (PDT)
Date: Tue, 27 Oct 2015 19:52:48 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151027105248.GA18741@mtj.duckdns.org>
References: <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
 <20151022153703.GA3899@mtj.duckdns.org>
 <20151022154922.GG26854@dhcp22.suse.cz>
 <20151022184226.GA19289@mtj.duckdns.org>
 <20151023083316.GB2410@dhcp22.suse.cz>
 <20151023103630.GA4170@mtj.duckdns.org>
 <20151023111145.GH2410@dhcp22.suse.cz>
 <20151023182109.GA14610@mtj.duckdns.org>
 <20151027091603.GB9891@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151027091603.GB9891@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Hello, Michal.

On Tue, Oct 27, 2015 at 10:16:03AM +0100, Michal Hocko wrote:
> > Seriously, nobody goes full-on RUNNING.
> 
> Looping with cond_resched seems like general pattern in the kernel when
> there is no clear source to wait for. We have io_schedule when we know
> we should wait for IO (in case of congestion) but this is not necessarily
> the case - as you can see here. What should we wait for? A short nap
> without actually waiting on anything sounds like a dirty workaround to
> me.

It's one thing to do cond_resched() in long loops to avoid long
priority inversions and another to indefinitely loop without making
any difference.

> > > guarantee that then I would argue that it should be implicit for
> > > WQ_MEM_RECLAIM otherwise we always risk a similar situation. What would
> > > be a counter argument for doing that?
> > 
> > Not serving any actual purpose and degrading execution behavior.
> 
> I dunno, I am not familiar with WQ internals to see the risks but to me
> it sounds like WQ_MEM_RECLAIM gives an incorrect impression of safety
> wrt. memory pressure and as demonstrated it doesn't do that. Even if you

It generally does.  This is an extremely rare corner case where
infinite loop w/o forward progress is introduce w/o the user being
outright buggy.

> consider cond_resched behavior of the page allocator as bug we should be
> able to handle this gracefully.

We can argue this back and forth forever but we'll either need to
special case it (be it short sleep or a special flag) or implement a
rather complex detection logic which will likely involve some level of
complexity and is dubious in its practical usefulness.  It's a
trade-off and given the circumstances adding short sleep looks like a
reasonable one to me.  If this is more common, we definitely wanna go
for automatic detection.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
