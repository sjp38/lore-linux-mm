Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2D76B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 09:58:11 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id r129so216584975wmr.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 06:58:11 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 134si4825785wmr.40.2016.01.22.06.58.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 06:58:09 -0800 (PST)
Date: Fri, 22 Jan 2016 09:57:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
Message-ID: <20160122145758.GB14432@cmpxchg.org>
References: <alpine.DEB.2.10.1601191502230.7346@chino.kir.corp.google.com>
 <201601202336.BJC04687.FOFVOQJOLSFtMH@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1601201538070.18155@chino.kir.corp.google.com>
 <201601212044.AFD30275.OSFFOFJHMVLOQt@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1601211513550.9813@chino.kir.corp.google.com>
 <201601222259.GJB90663.MLOJtFFOQFVHSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601222259.GJB90663.MLOJtFFOQFVHSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 22, 2016 at 10:59:10PM +0900, Tetsuo Handa wrote:
> David Rientjes wrote:
> > On Thu, 21 Jan 2016, Tetsuo Handa wrote:
> > 
> > > I consider phases for managing system-wide OOM events as follows.
> > > 
> > >   (1) Design and use a system with appropriate memory capacity in mind.
> > > 
> > >   (2) When (1) failed, the OOM killer is invoked. The OOM killer selects
> > >       an OOM victim and allow that victim access to memory reserves by
> > >       setting TIF_MEMDIE to it.
> > > 
> > >   (3) When (2) did not solve the OOM condition, start allowing all tasks
> > >       access to memory reserves by your approach.
> > > 
> > >   (4) When (3) did not solve the OOM condition, start selecting more OOM
> > >       victims by my approach.
> > > 
> > >   (5) When (4) did not solve the OOM condition, trigger the kernel panic.
> > > 
> > 
> > This was all mentioned previously, and I suggested that the panic only 
> > occur when memory reserves have been depleted, otherwise there is still 
> > the potential for the livelock to be solved.  That is a patch that would 
> > apply today, before any of this work, since we never want to loop 
> > endlessly in the page allocator when memory reserves are fully depleted.
> > 
> > This is all really quite simple.
> 
> So, David is OK with above approach, right?
> Then, Michal and Johannes, are you OK with above approach?

Yes, that order of events sounds reasonable to me. Personally, I'm not
entirely sure whether it's better to give out the last reserves to the
allocating task or subsequent OOM victims, but it's likely not even
that important. The most important part is to guarantee a predictable
and reasonable decision time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
