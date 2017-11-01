Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F15916B027C
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 10:48:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b14so1408078wme.17
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 07:48:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j88si841970edd.495.2017.11.01.07.48.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 07:48:46 -0700 (PDT)
Date: Wed, 1 Nov 2017 15:48:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after
 selecting an OOM victim.
Message-ID: <20171101144845.tey4ozou44tfpp3g@dhcp22.suse.cz>
References: <20171031132259.irkladqbucz2qa3g@dhcp22.suse.cz>
 <201710312251.HBH43789.QVOFOtLFFSOHJM@I-love.SAKURA.ne.jp>
 <20171031141034.bg25xbo5cyfafnyp@dhcp22.suse.cz>
 <201711012058.CIF81791.OQOFHFLOFMSJtV@I-love.SAKURA.ne.jp>
 <20171101124601.aqk3ayjp643ifdw3@dhcp22.suse.cz>
 <201711012338.AGB30781.JHOMFQFVSFtOLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711012338.AGB30781.JHOMFQFVSFtOLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

On Wed 01-11-17 23:38:49, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 01-11-17 20:58:50, Tetsuo Handa wrote:
> > > > > But doing ALLOC_OOM for last second allocation attempt from out_of_memory() involve
> > > > > duplicating code (e.g. rebuilding zone list).
> > > > 
> > > > Why would you do it? Do not blindly copy and paste code without
> > > > a good reason. What kind of problem does this actually solve?
> > > 
> > > prepare_alloc_pages()/finalise_ac() initializes as
> > > 
> > > 	ac->high_zoneidx = gfp_zone(gfp_mask);
> > > 	ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
> > > 	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> > > 						     ac->high_zoneidx, ac->nodemask);
> > > 
> > > and selecting as an OOM victim reinitializes as
> > > 
> > > 	ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> > > 	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> > > 						     ac->high_zoneidx, ac->nodemask);
> > > 
> > > and I assume that this reinitialization might affect which memory reserve
> > > the OOM victim allocates from.
> > > 
> > > You mean such difference is too trivial to care about?
> > 
> > You keep repeating what the _current_ code does without explaining _why_
> > do we need the same thing in the oom path. Could you finaly answer my
> > question please?
> 
> Because I consider that following what the current code does is reasonable
> unless there are explicit reasons not to follow.

Following this pattern makes a code mess over time because nobody
remembers why something is done a specific way anymore. Everybody just
keeps the ball rolling because he is afraid to change the code he
doesn't understand. Don't do that!

[...]
> Does "that comment" refer to
> 
>   Elaborating the comment: the reason for the high wmark is to reduce
>   the likelihood of livelocks and be sure to invoke the OOM killer, if
>   we're still under pressure and reclaim just failed. The high wmark is
>   used to be sure the failure of reclaim isn't going to be ignored. If
>   using the min wmark like you propose there's risk of livelock or
>   anyway of delayed OOM killer invocation.
> 
> part? Then, I know it is not about gfp flags.
> 
> But how can OOM livelock happen when the last second allocation does not
> wait for memory reclaim (because __GFP_DIRECT_RECLAIM is masked) ?
> The last second allocation shall return immediately, and we will call
> out_of_memory() if the last second allocation failed.

I think Andrea just wanted to say that we do want to invoke OOM killer
and resolve the memory pressure rather than keep looping in the
reclaim/oom path just because there are few pages allocated and freed in
the meantime.

[...]
> > I am not sure such a scenario matters all that much because it assumes
> > that the oom victim doesn't really free much memory [1] (basically less than
> > HIGH-MIN). Most OOM situation simply have a memory hog consuming
> > significant amount of memory.
> 
> The OOM killer does not always kill a memory hog consuming significant amount
> of memory. The OOM killer kills a process with highest OOM score (and instead
> one of its children if any). I don't think that assuming an OOM victim will free
> memory enough to succeed ALLOC_WMARK_HIGH is appropriate.

OK, so let's agree to disagree. I claim that we shouldn't care all that
much. If any of the current heuristics turns out to lead to killing too
many tasks then we should simply remove it rather than keep bloating an
already complex code with more and more kluges.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
