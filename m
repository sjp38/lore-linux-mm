Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 504936B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:11:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j8so33465037lfd.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 04:11:50 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id hp7si3810917wjb.145.2016.04.27.04.11.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 04:11:48 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e201so11840064wme.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 04:11:48 -0700 (PDT)
Date: Wed, 27 Apr 2016 13:11:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
Message-ID: <20160427111147.GI2179@dhcp22.suse.cz>
References: <201604212049.GFE34338.OQFOJSMOHFFLVt@I-love.SAKURA.ne.jp>
 <20160421130750.GA18427@dhcp22.suse.cz>
 <201604242319.GAF12996.tOJMOQFLFVOHSF@I-love.SAKURA.ne.jp>
 <20160425095508.GE23933@dhcp22.suse.cz>
 <20160426135402.GB20813@dhcp22.suse.cz>
 <201604271943.GAC60432.FFJHtFVSOQOOLM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604271943.GAC60432.FFJHtFVSOQOOLM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Wed 27-04-16 19:43:08, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 25-04-16 11:55:08, Michal Hocko wrote:
> > > On Sun 24-04-16 23:19:03, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > I have seen that patch. I didn't get to review it properly yet as I am
> > > > > still travelling. From a quick view I think it is conflating two things
> > > > > together. I could see arguments for the panic part but I do not consider
> > > > > the move-to-kill-another timeout as justified. I would have to see a
> > > > > clear indication this is actually useful for real life usecases.
> > > > 
> > > > You admit that it is possible that the TIF_MEMDIE thread is blocked at
> > > > unkillable wait (due to memory allocation requests by somebody else) but
> > > > the OOM reaper cannot reap the victim's memory (due to holding the mmap_sem
> > > > for write), don't you?
> > > 
> > > I have never said this to be impossible.
> > 
> > And just to clarify. I consider unkillable sleep while holding mmap_sem
> > for write to be a _bug_ which should be fixed rather than worked around
> > by some timeout based heuristics.
> 
> Excuse me, but I think that it is difficult to fix.
> Since currently it is legal to block kswapd from memory reclaim paths
> ( http://lkml.kernel.org/r/20160211225929.GU14668@dastard ) and there
> are allocation requests with mmap_sem held for write, you will need to
> make memory reclaim paths killable. (I wish memory reclaim paths being
> completely killable because fatal_signal_pending(current) check done in
> throttle_direct_reclaim() is racy.)

Be it difficult or not it is something that should be fixed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
