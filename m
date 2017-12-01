Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75E1F6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 09:56:45 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y15so5965607wrc.6
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 06:56:45 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a2si325056edi.359.2017.12.01.06.56.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Dec 2017 06:56:44 -0800 (PST)
Date: Fri, 1 Dec 2017 14:56:38 +0000
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] mm,oom: Move last second allocation to inside the
 OOM killer.
Message-ID: <20171201145638.GA10280@cmpxchg.org>
References: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171201143317.GC8097@cmpxchg.org>
 <20171201144634.sc4cn6hyyt6zawms@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201144634.sc4cn6hyyt6zawms@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Dec 01, 2017 at 03:46:34PM +0100, Michal Hocko wrote:
> On Fri 01-12-17 14:33:17, Johannes Weiner wrote:
> > On Sat, Nov 25, 2017 at 07:52:47PM +0900, Tetsuo Handa wrote:
> > > @@ -1068,6 +1071,17 @@ bool out_of_memory(struct oom_control *oc)
> > >  	}
> > >  
> > >  	select_bad_process(oc);
> > > +	/*
> > > +	 * Try really last second allocation attempt after we selected an OOM
> > > +	 * victim, for somebody might have managed to free memory while we were
> > > +	 * selecting an OOM victim which can take quite some time.
> > 
> > Somebody might free some memory right after this attempt fails. OOM
> > can always be a temporary state that resolves on its own.
> > 
> > What keeps us from declaring OOM prematurely is the fact that we
> > already scanned the entire LRU list without success, not last second
> > or last-last second, or REALLY last-last-last-second allocations.
> 
> You are right that this is inherently racy. The point here is, however,
> that the race window between the last check and the kill can be _huge_!

My point is that it's irrelevant. We already sampled the entire LRU
list; compared to that, the delay before the kill is immaterial.

> Another argument is that the allocator itself could have changed its
> allocation capabilities - e.g. become the OOM victim itself since the
> last time it the allocator could have reflected that fact.

Can you outline how this would happen exactly?

> > Nacked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
