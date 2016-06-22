Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C29786B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 06:57:59 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d132so18762658oig.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 03:57:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 194si1811022oie.137.2016.06.22.03.57.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 03:57:58 -0700 (PDT)
Subject: Re: mm, oom_reaper: How to handle race with oom_killer_disable() ?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201606220032.EGD09344.VOSQOMFJOLHtFF@I-love.SAKURA.ne.jp>
	<20160621174617.GA27527@dhcp22.suse.cz>
	<201606220647.GGD48936.LMtJVOOOFFQFHS@I-love.SAKURA.ne.jp>
	<20160622064015.GB7520@dhcp22.suse.cz>
	<20160622065016.GD7520@dhcp22.suse.cz>
In-Reply-To: <20160622065016.GD7520@dhcp22.suse.cz>
Message-Id: <201606221957.DBC18723.LOFQSMHVJOFFOt@I-love.SAKURA.ne.jp>
Date: Wed, 22 Jun 2016 19:57:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 22-06-16 08:40:15, Michal Hocko wrote:
> > On Wed 22-06-16 06:47:48, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Wed 22-06-16 00:32:29, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > [...]
> > > > > > Hmm, what about the following instead. It is rather a workaround than a
> > > > > > full flaged fix but it seems much more easier and shouldn't introduce
> > > > > > new issues.
> > > > > 
> > > > > Yes, I think that will work. But I think below patch (marking signal_struct
> > > > > to ignore TIF_MEMDIE instead of clearing TIF_MEMDIE from task_struct) on top of
> > > > > current linux.git will implement no-lockup requirement. No race is possible unlike
> > > > > "[PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init".
> > > > 
> > > > Not really. Because without the exit_oom_victim from oom_reaper you have
> > > > no guarantee that the oom_killer_disable will ever return. I have
> > > > mentioned that in the changelog. There is simply no guarantee the oom
> > > > victim will ever reach exit_mm->exit_oom_victim.
> > > 
> > > Why? Since any allocation after setting oom_killer_disabled = true will be
> > > forced to fail, nobody will be blocked on waiting for memory allocation. Thus,
> > > the TIF_MEMDIE tasks will eventually reach exit_mm->exit_oom_victim, won't it?
> > 
> > What if it gets blocked waiting for an operation which cannot make any
> > forward progress because it cannot proceed with an allocation (e.g.
> > an open coded allocation retry loop - not that uncommon when sending
> > a bio)? I mean if we want to guarantee a forward progress then there has
> > to be something to clear the flag no matter in what state the oom victim
> > is or give up on oom_killer_disable.

That sounds as if CONFIG_MMU=n kernels do OOM livelock at __mmput() regardless
of oom_killer_disabled.

> 
> That being said I guess the patch to try_to_freeze_tasks after
> oom_killer_disable should be simple enough to go for now and stable
> trees and we can come up with something less hackish later. I do not
> like the fact that oom_killer_disable doesn't act as a full "barrier"
> anymore.
> 
> What do you think?

I'm OK with calling try_to_freeze_tasks(true) again for Linux 4.6 and 4.7 kernels.

But if free memory is little such that oom_killer_disable() can not expect TIF_MEMDIE
threads to clear TIF_MEMDIE by themselves (and therefore has to depend on the OOM
reaper to clear TIF_MEMDIE on behalf of them after the OOM reaper reaped some memory),
subsequent operations would be as well blocked waiting for an operation which cannot
make any forward progress because it cannot proceed with an allocation. Then,
oom_killer_disable() returns false after some timeout (i.e. "do not try to suspend
when the system is almost OOM") will be a safer reaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
