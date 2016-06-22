Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 911D56B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 08:08:46 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so1300714wme.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 05:08:46 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id t129si415518wmt.25.2016.06.22.05.08.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 05:08:45 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id r201so2974948wme.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 05:08:45 -0700 (PDT)
Date: Wed, 22 Jun 2016 14:08:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, oom_reaper: How to handle race with oom_killer_disable() ?
Message-ID: <20160622120843.GE9208@dhcp22.suse.cz>
References: <201606220032.EGD09344.VOSQOMFJOLHtFF@I-love.SAKURA.ne.jp>
 <20160621174617.GA27527@dhcp22.suse.cz>
 <201606220647.GGD48936.LMtJVOOOFFQFHS@I-love.SAKURA.ne.jp>
 <20160622064015.GB7520@dhcp22.suse.cz>
 <20160622065016.GD7520@dhcp22.suse.cz>
 <201606221957.DBC18723.LOFQSMHVJOFFOt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606221957.DBC18723.LOFQSMHVJOFFOt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 22-06-16 19:57:17, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > That being said I guess the patch to try_to_freeze_tasks after
> > oom_killer_disable should be simple enough to go for now and stable
> > trees and we can come up with something less hackish later. I do not
> > like the fact that oom_killer_disable doesn't act as a full "barrier"
> > anymore.
> > 
> > What do you think?
> 
> I'm OK with calling try_to_freeze_tasks(true) again for Linux 4.6 and 4.7 kernels.

OK, I will resend the patch CC Rafael and stable.
 
> But if free memory is little such that oom_killer_disable() can not expect TIF_MEMDIE
> threads to clear TIF_MEMDIE by themselves (and therefore has to depend on the OOM
> reaper to clear TIF_MEMDIE on behalf of them after the OOM reaper reaped some memory),
> subsequent operations would be as well blocked waiting for an operation which cannot
> make any forward progress because it cannot proceed with an allocation. Then,
> oom_killer_disable() returns false after some timeout (i.e. "do not try to suspend
> when the system is almost OOM") will be a safer reaction.

Yes that is exactly what I meant by "oom_killer_disable has to give up"
alternative. pm suspend already has a notion of timeout for back off
and oom_killer_disable can use wait_even_timeout. But let's do that
separately.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
