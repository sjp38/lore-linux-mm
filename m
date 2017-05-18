Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 915D8831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 05:00:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y43so7836173wrc.11
        for <linux-mm@kvack.org>; Thu, 18 May 2017 02:00:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u19si4966122edi.214.2017.05.18.02.00.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 02:00:43 -0700 (PDT)
Date: Thu, 18 May 2017 11:00:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: fix oom invocation issues
Message-ID: <20170518090039.GC25462@dhcp22.suse.cz>
References: <1495034780-9520-1-git-send-email-guro@fb.com>
 <20170517161446.GB20660@dhcp22.suse.cz>
 <20170517194316.GA30517@castle>
 <201705180703.JGH95344.SOHJtFFMOQFLOV@I-love.SAKURA.ne.jp>
 <20170518084729.GB25462@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518084729.GB25462@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 18-05-17 10:47:29, Michal Hocko wrote:
> On Thu 18-05-17 07:03:36, Tetsuo Handa wrote:
> > Roman Gushchin wrote:
> > > On Wed, May 17, 2017 at 06:14:46PM +0200, Michal Hocko wrote:
> > > > On Wed 17-05-17 16:26:20, Roman Gushchin wrote:
> > > > [...]
> > > > > [   25.781882] Out of memory: Kill process 492 (allocate) score 899 or sacrifice child
> > > > > [   25.783874] Killed process 492 (allocate) total-vm:2052368kB, anon-rss:1894576kB, file-rss:4kB, shmem-rss:0kB
> > > > 
> > > > Are there any oom_reaper messages? Could you provide the full kernel log
> > > > please?
> > > 
> > > Sure. Sorry, it was too bulky, so I've cut the line about oom_reaper by mistake.
> > > Here it is:
> > > --------------------------------------------------------------------------------
> > > [   25.721494] allocate invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
> > > [   25.725658] allocate cpuset=/ mems_allowed=0
> > 
> > > [   25.759892] Node 0 DMA32 free:44700kB min:44704kB low:55880kB high:67056kB active_anon:1944216kB inactive_anon:204kB active_file:592kB inactive_file:0kB unevictable:0kB writepending:304kB present:2080640kB managed:2031972kB mlocked:0kB slab_reclaimable:11336kB slab_unreclaimable:9784kB kernel_stack:1776kB pagetables:6932kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> > 
> > > [   25.781882] Out of memory: Kill process 492 (allocate) score 899 or sacrifice child
> > > [   25.783874] Killed process 492 (allocate) total-vm:2052368kB, anon-rss:1894576kB, file-rss:4kB, shmem-rss:0kB
> > 
> > > [   25.785680] allocate: page allocation failure: order:0, mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
> > > [   25.786797] allocate cpuset=/ mems_allowed=0
> > 
> > This is a side effect of commit 9a67f6488eca926f ("mm: consolidate GFP_NOFAIL
> > checks in the allocator slowpath") which I noticed at
> > http://lkml.kernel.org/r/e7f932bf-313a-917d-6304-81528aca5994@I-love.SAKURA.ne.jp .
> 
> Hmm, I guess you are right. I haven't realized that pagefault_out_of_memory
> can race and pick up another victim. For some reason I thought that the
> page fault would break out on fatal signal pending but we don't do that (we
> used to in the past). Now that I think about that more we should
> probably remove out_of_memory out of pagefault_out_of_memory completely.
> It is racy and it basically doesn't have any allocation context so we
> might kill a task from a different domain. So can we do this instead?
> There is a slight risk that somebody might have returned VM_FAULT_OOM
> without doing an allocation but from my quick look nobody does that
> currently.

If this is considered too risky then we can do what Roman was proposing
and check tsk_is_oom_victim in pagefault_out_of_memory and bail out.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
