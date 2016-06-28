Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B34F8828E1
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 12:16:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so23435794wme.2
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 09:16:51 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0099.outbound.protection.outlook.com. [104.47.1.99])
        by mx.google.com with ESMTPS id ur10si1606191wjc.259.2016.06.28.09.16.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Jun 2016 09:16:50 -0700 (PDT)
Date: Tue, 28 Jun 2016 19:16:42 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160628161642.GA30658@esperanza>
References: <1467045594-20990-1-git-send-email-vdavydov@virtuozzo.com>
 <alpine.DEB.2.10.1606271713320.81440@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1606271713320.81440@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 27, 2016 at 05:14:31PM -0700, David Rientjes wrote:
> On Mon, 27 Jun 2016, Vladimir Davydov wrote:
> 
> > When selecting an oom victim, we use the same heuristic for both memory
> > cgroup and global oom. The only difference is the scope of tasks to
> > select the victim from. So we could just export an iterator over all
> > memcg tasks and keep all oom related logic in oom_kill.c, but instead we
> > duplicate pieces of it in memcontrol.c reusing some initially private
> > functions of oom_kill.c in order to not duplicate all of it. That looks
> > ugly and error prone, because any modification of select_bad_process
> > should also be propagated to mem_cgroup_out_of_memory.
> > 
> > Let's rework this as follows: keep all oom heuristic related code
> > private to oom_kill.c and make oom_kill.c use exported memcg functions
> > when it's really necessary (like in case of iterating over memcg tasks).
> > 
> 
> I don't know how others feel, but this actually turns out harder to read 
> for me with all the extra redirection with minimal savings (a few dozen 
> lines of code).

Well, if you guys find the code difficult to read after this patch,
let's leave it as is. Sorry for the noise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
