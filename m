Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE6956B7864
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:35:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2-v6so5425694pgp.4
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:35:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5-v6si4592302plr.101.2018.09.06.04.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 04:35:56 -0700 (PDT)
Date: Thu, 6 Sep 2018 13:35:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180906113553.GR14951@dhcp22.suse.cz>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <0aeb76e1-558f-e38e-4c66-77be3ce56b34@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0aeb76e1-558f-e38e-4c66-77be3ce56b34@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Sat 01-09-18 20:48:57, Tetsuo Handa wrote:
> On 2018/08/07 5:51, Michal Hocko wrote:
> >> At the risk of continually repeating the same statement, the oom reaper 
> >> cannot provide the direct feedback for all possible memory freeing.  
> >> Waking up periodically and finding mm->mmap_sem contended is one problem, 
> >> but the other problem that I've already shown is the unnecessary oom 
> >> killing of additional processes while a thread has already reached 
> >> exit_mmap().  The oom reaper cannot free page tables which is problematic 
> >> for malloc implementations such as tcmalloc that do not release virtual 
> >> memory. 
> > 
> > But once we know that the exit path is past the point of blocking we can
> > have MMF_OOM_SKIP handover from the oom_reaper to the exit path. So the
> > oom_reaper doesn't hide the current victim too early and we can safely
> > wait for the exit path to reclaim the rest. So there is a feedback
> > channel. I would even do not mind to poll for that state few times -
> > similar to polling for the mmap_sem. But it would still be some feedback
> > rather than a certain amount of time has passed since the last check.
> 
> Michal, will you show us how we can handover as an actual patch? I'm not
> happy with postponing current situation with just your wish to handover.

I am sorry but I am bussy with other higher priority issues. I believe I
have outlined the scheme that might work (see above). All it takes is to
look into that closer a play with it.

I haven't seen bug reports except for David's very vaguely argued
report. I have asked about details several times but haven't received
any. So I didn't really give it a top priority and consider it as a
corner case which is nice to solve rather than absolutely have to do it
right away because many users would put spell on us because their
workloads are eaten by that evil OOM killer.

If I've misinterpreted the priority then I can certainly reconsider and
reprioritize or somebody else might have a look into it.
-- 
Michal Hocko
SUSE Labs
