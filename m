Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE4CA6B054D
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:55:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p17so2345895wmd.5
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:55:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o80si1233985wme.162.2017.08.01.05.54.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 05:54:59 -0700 (PDT)
Date: Tue, 1 Aug 2017 14:54:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] mm, oom: do not grant oom victims full memory
 reserves access
Message-ID: <20170801125457.GM15774@dhcp22.suse.cz>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170801121643.GI15774@dhcp22.suse.cz>
 <20170801122344.GA8457@castle.DHCP.thefacebook.com>
 <20170801122905.GL15774@dhcp22.suse.cz>
 <20170801124238.GA9497@castle.dhcp.TheFacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801124238.GA9497@castle.dhcp.TheFacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 01-08-17 13:42:38, Roman Gushchin wrote:
> On Tue, Aug 01, 2017 at 02:29:05PM +0200, Michal Hocko wrote:
> > On Tue 01-08-17 13:23:44, Roman Gushchin wrote:
> > > On Tue, Aug 01, 2017 at 02:16:44PM +0200, Michal Hocko wrote:
> > > > On Thu 27-07-17 11:03:55, Michal Hocko wrote:
> > > > > Hi,
> > > > > this is a part of a larger series I posted back in Oct last year [1]. I
> > > > > have dropped patch 3 because it was incorrect and patch 4 is not
> > > > > applicable without it.
> > > > > 
> > > > > The primary reason to apply patch 1 is to remove a risk of the complete
> > > > > memory depletion by oom victims. While this is a theoretical risk right
> > > > > now there is a demand for memcg aware oom killer which might kill all
> > > > > processes inside a memcg which can be a lot of tasks. That would make
> > > > > the risk quite real.
> > > > > 
> > > > > This issue is addressed by limiting access to memory reserves. We no
> > > > > longer use TIF_MEMDIE to grant the access and use tsk_is_oom_victim
> > > > > instead. See Patch 1 for more details. Patch 2 is a trivial follow up
> > > > > cleanup.
> > > > 
> > > > Any comments, concerns? Can we merge it?
> > > 
> > > I've rebased the cgroup-aware OOM killer and ran some tests.
> > > Everything works well.
> > 
> > Thanks for your testing. Can I assume your Tested-by?
> 
> Sure.

Thanks!

> I wonder if we can get rid of TIF_MEMDIE completely,
> if we will count OOM victims on per-oom-victim-signal-struct rather than
> on per-thread basis? Say, assign oom_mm using cmpxchg, and call
> exit_oom_victim() from __exit_signal()? __thaw_task() can be called from
> mark_oom_victim() unconditionally.
> 
> Do you see any problems with this approach?

Ohh, I wish we could do that. All my previous attempts failed though. I
have always hit the problem to tell that the last thread of the process
is exiting to know when to call exit_oom_victim and release the oom
disable barrier. Maybe things have changed somehow since I've tried the
last time but this is a tricky code. I will certainly get back to it
some day but not likely anytime soon.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
