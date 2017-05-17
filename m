Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 137906B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 18:03:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p74so18710418pfd.11
        for <linux-mm@kvack.org>; Wed, 17 May 2017 15:03:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 203si3172203pfu.4.2017.05.17.15.03.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 15:03:54 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: fix oom invocation issues
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1495034780-9520-1-git-send-email-guro@fb.com>
	<20170517161446.GB20660@dhcp22.suse.cz>
	<20170517194316.GA30517@castle>
In-Reply-To: <20170517194316.GA30517@castle>
Message-Id: <201705180703.JGH95344.SOHJtFFMOQFLOV@I-love.SAKURA.ne.jp>
Date: Thu, 18 May 2017 07:03:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guro@fb.com, mhocko@kernel.org
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Roman Gushchin wrote:
> On Wed, May 17, 2017 at 06:14:46PM +0200, Michal Hocko wrote:
> > On Wed 17-05-17 16:26:20, Roman Gushchin wrote:
> > [...]
> > > [   25.781882] Out of memory: Kill process 492 (allocate) score 899 or sacrifice child
> > > [   25.783874] Killed process 492 (allocate) total-vm:2052368kB, anon-rss:1894576kB, file-rss:4kB, shmem-rss:0kB
> > 
> > Are there any oom_reaper messages? Could you provide the full kernel log
> > please?
> 
> Sure. Sorry, it was too bulky, so I've cut the line about oom_reaper by mistake.
> Here it is:
> --------------------------------------------------------------------------------
> [   25.721494] allocate invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
> [   25.725658] allocate cpuset=/ mems_allowed=0

> [   25.759892] Node 0 DMA32 free:44700kB min:44704kB low:55880kB high:67056kB active_anon:1944216kB inactive_anon:204kB active_file:592kB inactive_file:0kB unevictable:0kB writepending:304kB present:2080640kB managed:2031972kB mlocked:0kB slab_reclaimable:11336kB slab_unreclaimable:9784kB kernel_stack:1776kB pagetables:6932kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB

> [   25.781882] Out of memory: Kill process 492 (allocate) score 899 or sacrifice child
> [   25.783874] Killed process 492 (allocate) total-vm:2052368kB, anon-rss:1894576kB, file-rss:4kB, shmem-rss:0kB

> [   25.785680] allocate: page allocation failure: order:0, mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
> [   25.786797] allocate cpuset=/ mems_allowed=0

This is a side effect of commit 9a67f6488eca926f ("mm: consolidate GFP_NOFAIL
checks in the allocator slowpath") which I noticed at
http://lkml.kernel.org/r/e7f932bf-313a-917d-6304-81528aca5994@I-love.SAKURA.ne.jp .

> [   25.804499] Node 0 DMA32 free:251876kB min:44704kB low:55880kB high:67056kB active_anon:1737368kB inactive_anon:204kB active_file:592kB inactive_file:0kB unevictable:0kB writepending:304kB present:2080640kB managed:2031972kB mlocked:0kB slab_reclaimable:10312kB slab_unreclaimable:9784kB kernel_stack:1776kB pagetables:6932kB bounce:0kB free_pcp:700kB local_pcp:0kB free_cma:0kB

> [   25.817589] allocate invoked oom-killer: gfp_mask=0x0(), nodemask=(null),  order=0, oom_score_adj=0
> [   25.818821] allocate cpuset=/ mems_allowed=0

Since pagefault_out_of_memory() is unconditionally called if a normal allocation failed,
that commit made pagefault_out_of_memory() to be called if current thread was selected as
an OOM victim, despite the system is no longer under memory pressure because the OOM reaper
has reclaimed memory.

> [   25.835784] Node 0 DMA32 free:1934360kB min:44704kB low:55880kB high:67056kB active_anon:57104kB inactive_anon:204kB active_file:416kB inactive_file:2476kB unevictable:0kB writepending:424kB present:2080640kB managed:2031972kB mlocked:0kB slab_reclaimable:10236kB slab_unreclaimable:9584kB kernel_stack:1776kB pagetables:3604kB bounce:0kB free_pcp:144kB local_pcp:0kB free_cma:0kB

> [   25.863078] Out of memory: Kill process 233 (firewalld) score 10 or sacrifice child
> [   25.863634] Killed process 233 (firewalld) total-vm:246076kB, anon-rss:20956kB, file-rss:0kB, shmem-rss:0kB
> --------------------------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
