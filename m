Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30ED36B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 03:18:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i77so15266281wmh.10
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 00:18:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si21529137edd.254.2017.06.02.00.18.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 00:18:21 -0700 (PDT)
Date: Fri, 2 Jun 2017 09:18:18 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170602071818.GA29840@dhcp22.suse.cz>
References: <1496317427-5640-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170601115936.GA9091@dhcp22.suse.cz>
 <201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
 <20170601132808.GD9091@dhcp22.suse.cz>
 <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

On Thu 01-06-17 15:10:22, Andrew Morton wrote:
> On Thu, 1 Jun 2017 15:28:08 +0200 Michal Hocko <mhocko@suse.com> wrote:
> 
> > On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> > > > > Cong Wang has reported a lockup when running LTP memcg_stress test [1].
> > > >
> > > > This seems to be on an old and not pristine kernel. Does it happen also
> > > > on the vanilla up-to-date kernel?
> > > 
> > > 4.9 is not an old kernel! It might be close to the kernel version which
> > > enterprise distributions would choose for their next long term supported
> > > version.
> > > 
> > > And please stop saying "can you reproduce your problem with latest
> > > linux-next (or at least latest linux)?" Not everybody can use the vanilla
> > > up-to-date kernel!
> > 
> > The changelog mentioned that the source of stalls is not clear so this
> > might be out-of-tree patches doing something wrong and dump_stack
> > showing up just because it is called often. This wouldn't be the first
> > time I have seen something like that. I am not really keen on adding
> > heavy lifting for something that is not clearly debugged and based on
> > hand waving and speculations.
> 
> I'm thinking we should serialize warn_alloc anyway, to prevent the
> output from concurrent calls getting all jumbled together?

dump_stack already serializes concurrent calls.

> I'm not sure I buy the "this isn't a mainline kernel" thing. 

The changelog doesn't really explain what is going on and only
speculates that the excessive warn_alloc is the cause. The kernel is 
4.9.23.el7.twitter.x86_64 which I suspect contains a lot of stuff on top
of 4.9. So I would really _like_ to see whether this is reproducible
with the upstream kernel. Especially when this is a LTP test.

> warn_alloc() obviously isn't very robust, but we'd prefer that it be
> robust to peculiar situations, wild-n-wacky kernel patches, etc.  It's
> a low-level thing and it should Just Work.

Yes I would agree and if we have an evidence that warn_alloc is really
the problem then I am all for fixing it. There is no such evidence yet.
Note that dump_stack serialization might be unfair because there is no
queuing. Is it possible that this is the problem? If yes we should
rather fix that because that is arguably even more low-level routine than
warn_alloc.

That being said. I strongly believe that this patch is not properly
justified, issue fully understood and as such a disagree with adding a
new lock on those grounds.

Until the above is resolved
Nacked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
