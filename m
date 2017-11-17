Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 212E36B025F
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 13:37:01 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v2so3020995pfa.10
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 10:37:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j18si3109724pgn.474.2017.11.17.10.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 10:36:58 -0800 (PST)
Date: Fri, 17 Nov 2017 10:36:49 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171117183649.GA14157@infradead.org>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171117173521.GA21692@infradead.org>
 <CALvZod7Mrs8=5A2j=x96vaUcjCMSxVYi6RVLaKF23UENcAPLvw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod7Mrs8=5A2j=x96vaUcjCMSxVYi6RVLaKF23UENcAPLvw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Nov 17, 2017 at 09:41:46AM -0800, Shakeel Butt wrote:
> On Fri, Nov 17, 2017 at 9:35 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > On Tue, Nov 14, 2017 at 06:37:42AM +0900, Tetsuo Handa wrote:
> >> Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
> >> using one RCU section. But using atomic_inc()/atomic_dec() for each
> >> do_shrink_slab() call will not impact so much.
> >
> > But you could use SRCU..
> 
> I looked into that but was advised to not go through that route due to
> SRCU behind the CONFIG_SRCU. However now I see the precedence of
> "#ifdef CONFIG_SRCU" in drivers/base/core.c and I think if we can take
> that route if even after Minchan's patch the issue persists.

To be honest, I'd rather always require RCU then have core kernel
code reinvent it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
