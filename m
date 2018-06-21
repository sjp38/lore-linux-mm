Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42CD16B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 08:05:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4-v6so1753791wmh.0
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 05:05:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m62-v6si2537858ede.199.2018.06.21.05.05.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 05:05:14 -0700 (PDT)
Date: Thu, 21 Jun 2018 14:05:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Message-ID: <20180621120511.GG10465@dhcp22.suse.cz>
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
 <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu 21-06-18 20:27:41, Tetsuo Handa wrote:
[....]
> On 2018/06/21 16:31, Michal Hocko wrote:
> > On Wed 20-06-18 15:36:45, David Rientjes wrote:
> > [...]
> >> That makes me think that "oom_notify_list" isn't very intuitive: it can 
> >> free memory as a last step prior to oom kill.  OOM notify, to me, sounds 
> >> like its only notifying some callbacks about the condition.  Maybe 
> >> oom_reclaim_list and then rename this to oom_reclaim_pages()?
> > 
> > Yes agreed and that is the reason I keep saying we want to get rid of
> > this yet-another-reclaim mechanism. We already have shrinkers which are
> > the main source of non-lru pages reclaim. Why do we even need
> > oom_reclaim_pages? What is fundamentally different here? Sure those
> > pages should be reclaimed as the last resort but we already do have
> > priority for slab shrinking so we know that the system is struggling
> > when reaching the lowest priority. Isn't that enough to express the need
> > for current oom notifier implementations?
> > 
> 
> Even if we update OOM notifier users to use shrinker hooks, they will need a
> subtle balance which is currently achieved by mutex_trylock(&oom_lock).

No they do not. They do not want to rely on an unrelated locks to work
properly. That is completely wrong design. We do want locks to protect
specific data rather than code.

> Removing OOM notifier is not doable right now.

I haven't heard any technical argument why.

> It is not suitable as a regression
> fix for commit 27ae357fa82be5ab ("mm, oom: fix concurrent munlock and oom reaper
> unmap, v3").

What is the regression?

> What we could afford for this regression is
> https://patchwork.kernel.org/patch/9842889/ which is exactly what you suggested
> in a thread at https://www.spinics.net/lists/linux-mm/msg117896.html .

-- 
Michal Hocko
SUSE Labs
