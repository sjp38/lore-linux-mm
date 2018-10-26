Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18DC26B0328
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 15:33:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id v7-v6so1222442plo.23
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 12:33:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v33-v6si11215019pga.450.2018.10.26.12.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 12:33:07 -0700 (PDT)
Date: Fri, 26 Oct 2018 21:33:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Message-ID: <20181026193304.GD18839@dhcp22.suse.cz>
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
 <20181026142531.GA27370@cmpxchg.org>
 <20181026192551.GC18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026192551.GC18839@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 26-10-18 21:25:51, Michal Hocko wrote:
> On Fri 26-10-18 10:25:31, Johannes Weiner wrote:
[...]
> > There is of course the scenario brought forward in this thread, where
> > multiple threads of a process race and the second one enters oom even
> > though it doesn't need to anymore. What the global case does to catch
> > this is to grab the oom lock and do one last alloc attempt. Should
> > memcg lock the oom_lock and try one more time to charge the memcg?
> 
> That would be another option. I agree that making it more towards the
> global case makes it more attractive. My tsk_is_oom_victim is more
> towards "plug this particular case".

Nevertheless let me emphasise that tsk_is_oom_victim will close the race
completely, while mem_cgroup_margin will always be racy. So the question
is whether we want to close the race because it is just too easy for
userspace to hit it or keep the global and memcg oom handling as close
as possible.
-- 
Michal Hocko
SUSE Labs
