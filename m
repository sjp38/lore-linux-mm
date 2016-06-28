Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D91BD6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 20:14:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so2075009pfa.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 17:14:34 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id 87si2153510pfn.73.2016.06.27.17.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 17:14:34 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id hl6so351847pac.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 17:14:33 -0700 (PDT)
Date: Mon, 27 Jun 2016 17:14:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: oom: deduplicate victim selection code for memcg
 and global oom
In-Reply-To: <1467045594-20990-1-git-send-email-vdavydov@virtuozzo.com>
Message-ID: <alpine.DEB.2.10.1606271713320.81440@chino.kir.corp.google.com>
References: <1467045594-20990-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 27 Jun 2016, Vladimir Davydov wrote:

> When selecting an oom victim, we use the same heuristic for both memory
> cgroup and global oom. The only difference is the scope of tasks to
> select the victim from. So we could just export an iterator over all
> memcg tasks and keep all oom related logic in oom_kill.c, but instead we
> duplicate pieces of it in memcontrol.c reusing some initially private
> functions of oom_kill.c in order to not duplicate all of it. That looks
> ugly and error prone, because any modification of select_bad_process
> should also be propagated to mem_cgroup_out_of_memory.
> 
> Let's rework this as follows: keep all oom heuristic related code
> private to oom_kill.c and make oom_kill.c use exported memcg functions
> when it's really necessary (like in case of iterating over memcg tasks).
> 

I don't know how others feel, but this actually turns out harder to read 
for me with all the extra redirection with minimal savings (a few dozen 
lines of code).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
