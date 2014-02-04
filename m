Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 249AE6B0036
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:29:49 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id r15so4560059ead.27
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:29:48 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id h44si27494382eew.164.2014.02.04.08.29.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:29:48 -0800 (PST)
Date: Tue, 4 Feb 2014 11:29:39 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -v2 4/6] memcg: make sure that memcg is not offline when
 charging
Message-ID: <20140204162939.GP6963@cmpxchg.org>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-5-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391520540-17436-5-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Feb 04, 2014 at 02:28:58PM +0100, Michal Hocko wrote:
> The current charge path might race with memcg offlining because holding
> css reference doesn't neither prevent from task move to a different
> group nor stop css offline. When a charging task is the last one in the
> group and it is moved to a different group in the middle of the charge
> the old memcg might get offlined. As a result res counter might be
> charged after mem_cgroup_reparent_charges (called from memcg css_offline
> callback) and so the charge would never be freed. This has been worked
> around by 96f1c58d8534 (mm: memcg: fix race condition between memcg
> teardown and swapin) which tries to catch such a leaked charges later
> during css_free. It is more optimal to heal this race in the long term
> though.
> 
> In order to make this raceless we have to check that the memcg is online
> and res_counter_charge in the same RCU read section. The online check can
> be done simply by calling css_tryget & css_put which are now wrapped
> into mem_cgroup_is_online helper.
> 
> Callers are then updated to retry with a new memcg which is associated
> with the current mm. There always has to be a valid memcg encountered
> sooner or later because task had to be moved to a valid and online
> cgroup.
> 
> The only exception is mem_cgroup_do_precharge which should never see
> this race because it is called from cgroup {can_}attach callbacks and so
> the whole cgroup cannot go away.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c | 70 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 66 insertions(+), 4 deletions(-)

Maybe we should remove the XXX if it makes you think we should change
the current situation by any means necessary.  This patch is not an
improvement.

I put the XXX there so that we one day maybe refactor the code in a
clean fashion where try_get_mem_cgroup_from_whatever() is in the same
rcu section as the first charge attempt.  On failure, reclaim, and do
the lookup again.

Also, this problem only exists on swapin, where the memcg is looked up
from an auxilliary data structure and not the current task, so maybe
that would be an angle to look for a clean solution.

Either way, the problem is currently fixed with a *oneliner*.  Unless
the alternative solution is inherent in a clean rework of the code to
match cgroup core lifetime management, I don't see any reason to move
away from the status quo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
