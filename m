Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 40BD26B0031
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 08:38:37 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id cc10so573705wib.16
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 05:38:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si15096140wjf.5.2014.02.05.05.38.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 05:38:35 -0800 (PST)
Date: Wed, 5 Feb 2014 14:38:34 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 4/6] memcg: make sure that memcg is not offline when
 charging
Message-ID: <20140205133834.GB2425@dhcp22.suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-5-git-send-email-mhocko@suse.cz>
 <20140204162939.GP6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140204162939.GP6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 04-02-14 11:29:39, Johannes Weiner wrote:
[...]
> Maybe we should remove the XXX if it makes you think we should change
> the current situation by any means necessary.  This patch is not an
> improvement.
>
> I put the XXX there so that we one day maybe refactor the code in a
> clean fashion where try_get_mem_cgroup_from_whatever() is in the same
> rcu section as the first charge attempt.  On failure, reclaim, and do
> the lookup again.

I wouldn't be opposed to such a cleanup. It is not that simple, though.

> Also, this problem only exists on swapin, where the memcg is looked up
> from an auxilliary data structure and not the current task, so maybe
> that would be an angle to look for a clean solution.

I am not so sure about that. Task could have been moved to a different
group basically anytime it was outside of rcu_read_lock section (which
means most of the time). And so the group might get removed and we are
in the very same situation.

> Either way, the problem is currently fixed 

OK, my understanding (and my ack was based on that) was that we needed
a simple and safe fix for the stable trees and we would have something
more appropriate later on. Preventing from the race sounds like a more
appropriate and a better technical solution to me. So I would rather ask
why to keep a workaround in place. Does it add any risk?
Especially when we basically abuse the 2 stage cgroup removal. All the
charges should be cleared out after css_offline.

> with a *oneliner*.

That is really not importat becaust _that_ oneliner abuses the function
which should be in fact called from a different context.

> Unless the alternative solution is inherent in a clean rework of the
> code to match cgroup core lifetime management, I don't see any reason
> to move away from the status quo.

To be honest this sounds like a weak reasoning to refuse a real fix
which replaces a workaround.

This is a second attempt to fix the actual race that you are dismissing
which is really surprising to me. Especially when the workaround is an
ugly hack.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
