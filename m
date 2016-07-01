Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D90A46B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 07:18:39 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g18so80465381lfg.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 04:18:39 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id ub2si3046247wjc.93.2016.07.01.04.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 04:18:38 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id f126so22336700wma.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 04:18:38 -0700 (PDT)
Date: Fri, 1 Jul 2016 13:18:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160701111836.GD10813@dhcp22.suse.cz>
References: <1467045594-20990-1-git-send-email-vdavydov@virtuozzo.com>
 <alpine.DEB.2.10.1606271713320.81440@chino.kir.corp.google.com>
 <20160628161642.GA30658@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160628161642.GA30658@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 28-06-16 19:16:42, Vladimir Davydov wrote:
> On Mon, Jun 27, 2016 at 05:14:31PM -0700, David Rientjes wrote:
> > On Mon, 27 Jun 2016, Vladimir Davydov wrote:
> > 
> > > When selecting an oom victim, we use the same heuristic for both memory
> > > cgroup and global oom. The only difference is the scope of tasks to
> > > select the victim from. So we could just export an iterator over all
> > > memcg tasks and keep all oom related logic in oom_kill.c, but instead we
> > > duplicate pieces of it in memcontrol.c reusing some initially private
> > > functions of oom_kill.c in order to not duplicate all of it. That looks
> > > ugly and error prone, because any modification of select_bad_process
> > > should also be propagated to mem_cgroup_out_of_memory.
> > > 
> > > Let's rework this as follows: keep all oom heuristic related code
> > > private to oom_kill.c and make oom_kill.c use exported memcg functions
> > > when it's really necessary (like in case of iterating over memcg tasks).
> > > 
> > 
> > I don't know how others feel, but this actually turns out harder to read 
> > for me with all the extra redirection with minimal savings (a few dozen 
> > lines of code).
> 
> Well, if you guys find the code difficult to read after this patch,
> let's leave it as is. Sorry for the noise.

I didn't get to read the patch yet and will be offline for next few
days. I will have a look later. I believe that this is an area which is
worth cleaning up and get rid of duplication. Whether your approach is
right one I cannot tell right now. I found the previous version harder
to read than a simpler approach I have posted. Anyway I will have a look
later. And this is definitelly not a noise...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
