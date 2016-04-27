Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB386B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 06:43:20 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id xm6so54443794pab.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 03:43:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o65si3571567pfi.251.2016.04.27.03.43.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 03:43:19 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201604212049.GFE34338.OQFOJSMOHFFLVt@I-love.SAKURA.ne.jp>
	<20160421130750.GA18427@dhcp22.suse.cz>
	<201604242319.GAF12996.tOJMOQFLFVOHSF@I-love.SAKURA.ne.jp>
	<20160425095508.GE23933@dhcp22.suse.cz>
	<20160426135402.GB20813@dhcp22.suse.cz>
In-Reply-To: <20160426135402.GB20813@dhcp22.suse.cz>
Message-Id: <201604271943.GAC60432.FFJHtFVSOQOOLM@I-love.SAKURA.ne.jp>
Date: Wed, 27 Apr 2016 19:43:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Michal Hocko wrote:
> On Mon 25-04-16 11:55:08, Michal Hocko wrote:
> > On Sun 24-04-16 23:19:03, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > I have seen that patch. I didn't get to review it properly yet as I am
> > > > still travelling. From a quick view I think it is conflating two things
> > > > together. I could see arguments for the panic part but I do not consider
> > > > the move-to-kill-another timeout as justified. I would have to see a
> > > > clear indication this is actually useful for real life usecases.
> > > 
> > > You admit that it is possible that the TIF_MEMDIE thread is blocked at
> > > unkillable wait (due to memory allocation requests by somebody else) but
> > > the OOM reaper cannot reap the victim's memory (due to holding the mmap_sem
> > > for write), don't you?
> > 
> > I have never said this to be impossible.
> 
> And just to clarify. I consider unkillable sleep while holding mmap_sem
> for write to be a _bug_ which should be fixed rather than worked around
> by some timeout based heuristics.

Excuse me, but I think that it is difficult to fix.
Since currently it is legal to block kswapd from memory reclaim paths
( http://lkml.kernel.org/r/20160211225929.GU14668@dastard ) and there
are allocation requests with mmap_sem held for write, you will need to
make memory reclaim paths killable. (I wish memory reclaim paths being
completely killable because fatal_signal_pending(current) check done in
throttle_direct_reclaim() is racy.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
