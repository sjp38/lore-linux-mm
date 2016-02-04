Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id F080144044D
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 09:54:00 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id 128so30738742wmz.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:54:00 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id d84si38651643wmc.17.2016.02.04.06.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 06:53:59 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id r129so12553290wmr.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:53:59 -0800 (PST)
Date: Thu, 4 Feb 2016 15:53:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/5] mm, oom_reaper: implement OOM victims queuing
Message-ID: <20160204145357.GE14425@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-6-git-send-email-mhocko@kernel.org>
 <201602041949.BIG30715.QVFLFOOOHMtSFJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602041949.BIG30715.QVFLFOOOHMtSFJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 04-02-16 19:49:29, Tetsuo Handa wrote:
[...]
> I think we want to rewrite this patch's description from a different point
> of view.
> 
> As of "[PATCH 1/5] mm, oom: introduce oom reaper", we assumed that we try to
> manage OOM livelock caused by system-wide OOM events using the OOM reaper.
> Therefore, the OOM reaper had high scheduling priority and we considered side
> effect of the OOM reaper as a reasonable constraint.
> 
> But as the discussion went by, we started to try to manage OOM livelock
> caused by non system-wide OOM events (e.g. memcg OOM) using the OOM reaper.
> Therefore, the OOM reaper now has normal scheduling priority. For non
> system-wide OOM events, side effect of the OOM reaper might not be a
> reasonable constraint. Some administrator might expect that the OOM reaper
> does not break coredumping unless the system is under system-wide OOM events.

I am willing to discuss this as an option after we actually hear about a
_real_ usecase.

[...]

> But if we consider non system-wide OOM events, it is not very unlikely to hit
> this race. This queue is useful for situations where memcg1 and memcg2 hit
> memcg OOM at the same time and victim1 in memcg1 cannot terminate immediately.

This can happen of course but the likelihood is _much_ smaller without
the global OOM because the memcg OOM killer is invoked from a lockless
context so the oom context cannot block the victim to proceed.

> I expect parallel reaping (shown below) because there is no need to serialize
> victim tasks (e.g. wait for reaping victim1 in memcg1 which can take up to
> 1 second to complete before start reaping victim2 in memcg2) if we implement
> this queue.

I would really prefer to go a simpler way first and extend the code when
we see the current approach insufficient for real life loads. Please do
not get me wrong, of course the code can be enhanced in many different
ways and optimize for lots of pathological cases but I really believe
that we should start with correctness first and only later care about
optimizing corner cases. Realistically, who really cares about
oom_reaper acting on an Nth completely stuck tasks after N seconds?
For now, my target is to guarantee that oom_reaper will _eventually_
process a queued task and reap its memory if the target hasn't exited
yet. I do not think this is an unreasonable goal...

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
