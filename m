Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF437440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 06:31:58 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v8so3009328wrd.21
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 03:31:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m59si5561168ede.524.2017.11.09.03.31.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 03:31:57 -0800 (PST)
Date: Thu, 9 Nov 2017 12:31:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to
 loadbalance console writes
Message-ID: <20171109113156.i36uazn4esxm2vzw@dhcp22.suse.cz>
References: <20171108102723.602216b1@gandalf.local.home>
 <20171109101138.qmy3366myzjafexr@dhcp22.suse.cz>
 <201711091922.IHJ81787.OVQFFJOSOLtHMF@I-love.SAKURA.ne.jp>
 <20171109102613.hp6waybyxbkb3crz@dhcp22.suse.cz>
 <201711092003.ACJ86411.FOFtFMVOJOSLHQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711092003.ACJ86411.FOFtFMVOJOSLHQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz, peterz@infradead.org, torvalds@linux-foundation.org, jack@suse.cz, mathieu.desnoyers@efficios.com, rostedt@home.goodmis.org

On Thu 09-11-17 20:03:30, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 09-11-17 19:22:58, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > Hi,
> > > > assuming that this passes warn stall torturing by Tetsuo, do you think
> > > > we can drop http://lkml.kernel.org/r/1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> > > > from the mmotm tree?
> > > 
> > > I don't think so.
> > > 
> > > The rule that "do not try to printk() faster than the kernel can write to
> > > consoles" will remain no matter how printk() changes. Unless asynchronous
> > > approach like https://lwn.net/Articles/723447/ is used, I think we can't
> > > obtain useful information.
> > 
> > Does that mean that the patch doesn't pass your test?
> > 
> 
> Test is irrelevant. See the changelog.
> 
>   Synchronous approach is prone to unexpected results (e.g. too late [1], too
>   frequent [2], overlooked [3]). As far as I know, warn_alloc() never helped
>   with providing information other than "something is going wrong".
>   I want to consider asynchronous approach which can obtain information
>   during stalls with possibly relevant threads (e.g. the owner of oom_lock
>   and kswapd-like threads) and serve as a trigger for actions (e.g. turn
>   on/off tracepoints, ask libvirt daemon to take a memory dump of stalling
>   KVM guest for diagnostic purpose).
> 
>   [1] https://bugzilla.kernel.org/show_bug.cgi?id=192981
>   [2] http://lkml.kernel.org/r/CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMcBjBFyM_A@mail.gmail.com
>   [3] commit db73ee0d46379922 ("mm, vmscan: do not loop on too_many_isolated for ever")

So you want to keep the warning out of the kernel even though the
problems you are seeing are gone just to allow for an async approach
nobody is very fond of? That is a very dubious approach.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
