Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id C049F828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 17:59:33 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id f206so365618554wmf.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 14:59:33 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x5si12869071wja.161.2016.01.14.14.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 14:59:32 -0800 (PST)
Date: Thu, 14 Jan 2016 17:58:50 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
Message-ID: <20160114225850.GA23382@cmpxchg.org>
References: <alpine.DEB.2.10.1601121717220.17063@chino.kir.corp.google.com>
 <201601132111.GIG81705.LFOOHFOtQJSMVF@I-love.SAKURA.ne.jp>
 <20160113162610.GD17512@dhcp22.suse.cz>
 <20160113165609.GA21950@cmpxchg.org>
 <20160113180147.GL17512@dhcp22.suse.cz>
 <201601142026.BHI87005.FSOFJVFQMtHOOL@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1601141400170.16227@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601141400170.16227@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 14, 2016 at 02:01:45PM -0800, David Rientjes wrote:
> On Thu, 14 Jan 2016, Tetsuo Handa wrote:
> > I know. What I'm proposing is try to recover by killing more OOM-killable
> > tasks because I think impact of crashing the kernel is larger than impact
> > of killing all OOM-killable tasks. We should at least try OOM-kill all
> > OOM-killable processes before crashing the kernel. Some servers take many
> > minutes to reboot whereas restarting OOM-killed services takes only a few
> > seconds. Also, SysRq-i is inconvenient because it kills OOM-unkillable ssh
> > daemon process.
> 
> This is where me and you disagree; the goal should not be to continue to 
> oom kill more and more processes since there is no guarantee that further 
> kills will result in forward progress.  These additional kills can result 
> in the same livelock that is already problematic, and killing additional 
> processes has made the situation worse since memory reserves are more 
> depleted.
> 
> I believe what is better is to exhaust reclaim, check if the page 
> allocator is constantly looping due to waiting for the same victim to 
> exit, and then allowing that allocation with memory reserves, see the 
> attached patch which I have proposed before.

If giving the reserves to another OOM victim is bad, how is giving
them to the *allocating* task supposed to be better? Which path is
more likely to release memory? That doesn't seem to follow.

We need to make the OOM killer conclude in a fixed amount of time, no
matter what happens. If the system is irrecoverably deadlocked on
memory it needs to panic (and reboot) so we can get on with it. And
it's silly to panic while there are still killable tasks available.

Hence my proposal to wait a decaying amount of time after each OOM
victim before moving on, until we killed everything in the system and
panic (and reboot). What else is there we can do once out of memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
