Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 24C9C6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 04:21:41 -0400 (EDT)
Received: by wigg3 with SMTP id g3so43264788wig.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 01:21:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p19si11772492wiw.26.2015.06.08.01.21.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 01:21:39 -0700 (PDT)
Date: Mon, 8 Jun 2015 10:21:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is configured
Message-ID: <20150608082137.GD1380@dhcp22.suse.cz>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com>
 <20150605111302.GB26113@dhcp22.suse.cz>
 <201506061551.BHH48489.QHFOMtFLSOFOJV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506061551.BHH48489.QHFOMtFLSOFOJV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 06-06-15 15:51:35, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > Let's move check_panic_on_oom up before the current task is
> > > > checked so that the knob value is . Do the same for the memcg in
> > > > mem_cgroup_out_of_memory.
> > > > 
> > > > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > 
> > > Nack, this is not the appropriate response to exit path livelocks.  By 
> > > doing this, you are going to start unnecessarily panicking machines that 
> > > have panic_on_oom set when it would not have triggered before.  If there 
> > > is no reclaimable memory and a process that has already been signaled to 
> > > die to is in the process of exiting has to allocate memory, it is 
> > > perfectly acceptable to give them access to memory reserves so they can 
> > > allocate and exit.  Under normal circumstances, that allows the process to 
> > > naturally exit.  With your patch, it will cause the machine to panic.
> > 
> > Isn't that what the administrator of the system wants? The system
> > is _clearly_ out of memory at this point. A coincidental exiting task
> > doesn't change a lot in that regard. Moreover it increases a risk of
> > unnecessarily unresponsive system which is what panic_on_oom tries to
> > prevent from. So from my POV this is a clear violation of the user
> > policy.
> 
> For me, !__GFP_FS allocations not calling out_of_memory() _forever_ is a
> violation of the user policy.

Yes, the current behavior of GFP_NOFS is highly suboptimal, but this has
_nothing_ what so ever to do with this patch and panic_on_oom handling.
The former one is the page allocator proper while we are in the OOM
killer layer here.

This is not the first time you have done that. Please stop it. It makes
a complete mess of the original discussions.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
