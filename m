Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE2F56B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 07:04:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y8-v6so5010328edr.12
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 04:04:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p4-v6si1039278eda.101.2018.08.07.04.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 04:04:07 -0700 (PDT)
Date: Tue, 7 Aug 2018 13:04:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, oom: be careful about races when warning about no
 reclaimable task
Message-ID: <20180807110405.GW10003@dhcp22.suse.cz>
References: <20180807072553.14941-1-mhocko@kernel.org>
 <863d73ce-fae9-c117-e361-12c415c787de@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <863d73ce-fae9-c117-e361-12c415c787de@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>

On Tue 07-08-18 19:15:11, Tetsuo Handa wrote:
[...]
> Of course, if the hard limit is 0, all processes will be killed after all. But
> Michal is ignoring the fact that if the hard limit were not 0, there is a chance
> of saving next process from needlessly killed if we waited until "mm of PID=23766
> completed __mmput()" or "mm of PID=23766 failed to complete __mmput() within
> reasonable period". 

This is a completely different issue IMHO. I haven't seen reports about
overly eager memcg oom killing so far.
 
> We can make efforts not to return false at
> 
> 	/*
> 	 * This task has already been drained by the oom reaper so there are
> 	 * only small chances it will free some more
> 	 */
> 	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> 		return false;
> 
> (I admit that ignoring MMF_OOM_SKIP for once might not be sufficient for memcg
> case), and we can use feedback based backoff like
> "[PATCH 4/4] mm, oom: Fix unnecessary killing of additional processes." *UNTIL*
> we come to the point where the OOM reaper can always reclaim all memory.

The code is quite tricky and I am really reluctant to make it even more
so without seeing this is really hurting real users with real workloads.
-- 
Michal Hocko
SUSE Labs
