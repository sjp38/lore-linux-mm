Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B591B6B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 08:17:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y44so6136269wry.3
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 05:17:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a6si1425395ede.278.2017.10.06.05.17.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Oct 2017 05:17:41 -0700 (PDT)
Date: Fri, 6 Oct 2017 14:17:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v11 4/6] mm, oom: introduce memory.oom_group
Message-ID: <20171006121739.2rsr6aiqeodcczoe@dhcp22.suse.cz>
References: <20171005130454.5590-1-guro@fb.com>
 <20171005130454.5590-5-guro@fb.com>
 <20171005143104.wo5xstpe7mhkdlbr@dhcp22.suse.cz>
 <20171006120435.GA22702@castle.dhcp.TheFacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171006120435.GA22702@castle.dhcp.TheFacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 06-10-17 13:04:35, Roman Gushchin wrote:
> On Thu, Oct 05, 2017 at 04:31:04PM +0200, Michal Hocko wrote:
> > Btw. here is how I would do the recursive oom badness. The diff is not
> > the nicest one because there is some code moving but the resulting code
> > is smaller and imho easier to grasp. Only compile tested though
> 
> Thanks!
> 
> I'm not against this approach, and maybe it can lead to a better code,
> but the version you sent is just not there yet.
> 
> There are some problems with it:
> 
> 1) If there are nested cgroups with oom_group set, you will calculate
> a badness multiple times, and rely on the fact, that top memcg will
> become the largest score. It can be optimized, of course, but it's
> additional code.

right. As I've said we can introduce iterator helper to skip the subtree
but I suspect it will not make much of a difference.

> 
> 2) cgroup_has_tasks() probably requires additional locking.
> Maybe it's ok to read nr_populated_csets without explicit locking,
> but it's not obvious for me.

I do not see why. Tasks are free to come and go and you only know at the
time you are killing.

> 3) Returning -1 from memcg_oom_badness() if eligible is equal to 0
> is suspicious.

I didn't spend too much time on it. I merely wanted to point out my
thinking more specifically than the pseudo code posted earlier. But this
should be ok, because that would mean that either all tasks are
OOM_SCORE_ADJ_MIN (eligible = 0) or there is a inflight victim (eligible
= -1). Anyway the initialization should go inside the tree walk

> Right now your version has exactly the same amount of code
> (skipping comments). I assume, this approach just requires some additional
> thinking/rework.

Well, this is not about the amount of code but more about the clear
logic implemented at the correct level. It is simply much easier when
you evaluate the killable entity at one place rather open code it.

But as I've said nothing I would want to enforce.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
