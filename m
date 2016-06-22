Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7A36B025E
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 02:40:19 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id nq2so34061898lbc.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 23:40:19 -0700 (PDT)
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com. [209.85.215.46])
        by mx.google.com with ESMTPS id a2si19896050lbc.12.2016.06.21.23.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 23:40:17 -0700 (PDT)
Received: by mail-lf0-f46.google.com with SMTP id q132so61474282lfe.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 23:40:17 -0700 (PDT)
Date: Wed, 22 Jun 2016 08:40:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, oom_reaper: How to handle race with oom_killer_disable() ?
Message-ID: <20160622064015.GB7520@dhcp22.suse.cz>
References: <201606212003.FFB35429.QtMOJFFFOLSHVO@I-love.SAKURA.ne.jp>
 <20160621114643.GE30848@dhcp22.suse.cz>
 <20160621132736.GF30848@dhcp22.suse.cz>
 <201606220032.EGD09344.VOSQOMFJOLHtFF@I-love.SAKURA.ne.jp>
 <20160621174617.GA27527@dhcp22.suse.cz>
 <201606220647.GGD48936.LMtJVOOOFFQFHS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606220647.GGD48936.LMtJVOOOFFQFHS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 22-06-16 06:47:48, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 22-06-16 00:32:29, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > [...]
> > > > Hmm, what about the following instead. It is rather a workaround than a
> > > > full flaged fix but it seems much more easier and shouldn't introduce
> > > > new issues.
> > > 
> > > Yes, I think that will work. But I think below patch (marking signal_struct
> > > to ignore TIF_MEMDIE instead of clearing TIF_MEMDIE from task_struct) on top of
> > > current linux.git will implement no-lockup requirement. No race is possible unlike
> > > "[PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init".
> > 
> > Not really. Because without the exit_oom_victim from oom_reaper you have
> > no guarantee that the oom_killer_disable will ever return. I have
> > mentioned that in the changelog. There is simply no guarantee the oom
> > victim will ever reach exit_mm->exit_oom_victim.
> 
> Why? Since any allocation after setting oom_killer_disabled = true will be
> forced to fail, nobody will be blocked on waiting for memory allocation. Thus,
> the TIF_MEMDIE tasks will eventually reach exit_mm->exit_oom_victim, won't it?

What if it gets blocked waiting for an operation which cannot make any
forward progress because it cannot proceed with an allocation (e.g.
an open coded allocation retry loop - not that uncommon when sending
a bio)? I mean if we want to guarantee a forward progress then there has
to be something to clear the flag no matter in what state the oom victim
is or give up on oom_killer_disable.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
