Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C524828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 17:48:42 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ao6so54290442pac.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:48:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e72si10000475pfd.241.2016.06.21.14.48.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 14:48:41 -0700 (PDT)
Subject: Re: mm, oom_reaper: How to handle race with oom_killer_disable() ?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201606212003.FFB35429.QtMOJFFFOLSHVO@I-love.SAKURA.ne.jp>
	<20160621114643.GE30848@dhcp22.suse.cz>
	<20160621132736.GF30848@dhcp22.suse.cz>
	<201606220032.EGD09344.VOSQOMFJOLHtFF@I-love.SAKURA.ne.jp>
	<20160621174617.GA27527@dhcp22.suse.cz>
In-Reply-To: <20160621174617.GA27527@dhcp22.suse.cz>
Message-Id: <201606220647.GGD48936.LMtJVOOOFFQFHS@I-love.SAKURA.ne.jp>
Date: Wed, 22 Jun 2016 06:47:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 22-06-16 00:32:29, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > Hmm, what about the following instead. It is rather a workaround than a
> > > full flaged fix but it seems much more easier and shouldn't introduce
> > > new issues.
> > 
> > Yes, I think that will work. But I think below patch (marking signal_struct
> > to ignore TIF_MEMDIE instead of clearing TIF_MEMDIE from task_struct) on top of
> > current linux.git will implement no-lockup requirement. No race is possible unlike
> > "[PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init".
> 
> Not really. Because without the exit_oom_victim from oom_reaper you have
> no guarantee that the oom_killer_disable will ever return. I have
> mentioned that in the changelog. There is simply no guarantee the oom
> victim will ever reach exit_mm->exit_oom_victim.

Why? Since any allocation after setting oom_killer_disabled = true will be
forced to fail, nobody will be blocked on waiting for memory allocation. Thus,
the TIF_MEMDIE tasks will eventually reach exit_mm->exit_oom_victim, won't it?

The only possibility that the TIF_MEMDIE tasks won't reach exit_mm->exit_oom_victim
is __GFP_NOFAIL allocations failing to make forward progress even after
ALLOC_NO_WATERMARKS is used. But that is a different problem which I think
we can call panic() when __GFP_NOFAIL allocations failed after setting
oom_killer_disabled = true.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
